#pragma shady: inline(shdSandSimCommon.Uniforms)
#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel_size;
uniform float u_frame;

// Returns true when the single target cell is enterable by source.
bool target_offset_is_open(ElementStaticData _source_static_data, vec2 _source_texcoord, vec2 _move_offset) {
	vec2 _target_texcoord = _source_texcoord + (_move_offset * u_texel_size);
	vec4 _target_pixel;
	ElementStaticData _target_static_data;

	if (!uv_in_bounds(_target_texcoord)) {
		return false;
	}

	_target_pixel = texture2D(gm_BaseTexture, _target_texcoord);
	_target_static_data = get_element_static_data(element_id_from_pixel(_target_pixel));

	return element_can_enter(_source_static_data, _target_static_data, element_id_from_pixel(_target_pixel));
}

float round_signed_float(float _value) {
	if (_value >= 0.0) {
		return floor(_value + 0.5);
	}
	return -floor(abs_float(_value) + 0.5);
}

// Returns true only when every intermediate cell along the path is open.
bool target_path_is_open(ElementStaticData _source_static_data, vec2 _source_texcoord, vec2 _move_offset) {
	float _step_count = max(abs_float(_move_offset.x), abs_float(_move_offset.y));
	vec2 _last_offset = vec2(0.0);

	if (_step_count <= 0.0) {
		return false;
	}

	for (int _sample_index = 1; _sample_index <= SIM_MAX_MOVE_RADIUS; ++_sample_index) {
		vec2 _sample_offset;
		float _sample_fraction;

		if (float(_sample_index) > _step_count) {
			continue;
		}

		_sample_fraction = float(_sample_index) / _step_count;
		_sample_offset = vec2(
			round_signed_float(_move_offset.x * _sample_fraction),
			round_signed_float(_move_offset.y * _sample_fraction)
		);

		if (_sample_offset.x == 0.0 && _sample_offset.y == 0.0) {
			continue;
		}

		if (_sample_offset.x == _last_offset.x && _sample_offset.y == _last_offset.y) {
			continue;
		}

		if (!target_offset_is_open(_source_static_data, _source_texcoord, _sample_offset)) {
			return false;
		}

		_last_offset = _sample_offset;
	}

	return true;
}

int vertical_step_from_drive(float _vertical_drive) {
	if (_vertical_drive > 0.0) {
		return 1;
	}
	if (_vertical_drive < 0.0) {
		return -1;
	}
	return 0;
}

// Deterministic rest validity for FLOW_MODE_POWDER.
//
// Returns true when the element is both:
//   - blocked directly below (cannot fall straight down), and
//   - has no open diagonal-below escape.
//
// When true, the powder should stay at rest until this check fails.
// When false, the powder must wake and search for a move.
//
// This replaces the old PRNG-based wake_chance approach.
// Design doc: "rest must depend on support quality" and "rest break conditions:
// the cell below changes, a supporting diagonal changes, a new diagonal spill
// path opens, or nearby motion invalidates support."
bool powder_rest_is_valid(ElementStaticData _elem_static_data, vec2 _center_texcoord) {
	int _vdir = vertical_step_from_drive(_elem_static_data.vertical_drive);

	// No vertical drive: element has no fall preference, always treat as supported.
	if (_vdir == 0) {
		return true;
	}

	// Check the cell directly in the drive direction.
	vec2 _direct_texcoord = _center_texcoord + vec2(0.0, float(_vdir)) * u_texel_size;
	if (!uv_in_bounds(_direct_texcoord)) {
		// At world boundary in the drive direction – treat as immovable wall, solid support.
		return true;
	}

	vec4 _direct_pixel = texture2D(gm_BaseTexture, _direct_texcoord);
	ElementStaticData _direct_static_data = get_element_static_data(element_id_from_pixel(_direct_pixel));

	// If the direct cell is enterable, we can fall – no rest.
	if (element_can_enter(_elem_static_data, _direct_static_data, _direct_static_data.id)) {
		return false;
	}

	// Direct cell is blocked. Now check diagonal-below cells for escape paths.
	// Diagonal escapes exist when either left-below or right-below is enterable.
	// If any diagonal is open, rest is invalid (powder should slough that way).
	for (int _di = 0; _di < 2; ++_di) {
		int _dx = (_di == 0) ? -1 : 1;
		vec2 _diag_texcoord = _center_texcoord + vec2(float(_dx), float(_vdir)) * u_texel_size;

		if (!uv_in_bounds(_diag_texcoord)) {
			continue; // World edge diagonal – no escape there.
		}

		vec4 _diag_pixel = texture2D(gm_BaseTexture, _diag_texcoord);
		ElementStaticData _diag_static_data = get_element_static_data(element_id_from_pixel(_diag_pixel));

		if (element_can_enter(_elem_static_data, _diag_static_data, _diag_static_data.id)) {
			return false; // Open diagonal – slough opportunity exists, wake up.
		}
	}

	// Direct is blocked and no diagonal escape exists: valid rest position.
	return true;
}

float flow_mode_vertical_weight(int _flow_mode) {
	if (_flow_mode == FLOW_MODE_POWDER) {
		return 3.5;
	}
	if (_flow_mode == FLOW_MODE_LIQUID) {
		return 2.9;
	}
	if (_flow_mode == FLOW_MODE_GAS) {
		return 2.6;
	}
	if (_flow_mode == FLOW_MODE_GOO) {
		return 2.3;
	}
	return 0.0;
}

float flow_mode_lateral_weight(int _flow_mode) {
	if (_flow_mode == FLOW_MODE_POWDER) {
		return 0.35;
	}
	if (_flow_mode == FLOW_MODE_LIQUID) {
		return 1.45;
	}
	if (_flow_mode == FLOW_MODE_GAS) {
		return 1.10;
	}
	if (_flow_mode == FLOW_MODE_GOO) {
		return 0.70;
	}
	return 0.0;
}

bool candidate_allowed_for_flow(ElementStaticData _elem_static_data, vec2 _candidate_offset, int _vertical_step) {
	if (_candidate_offset.x == 0.0 && _candidate_offset.y == 0.0) {
		return false;
	}

	if (_elem_static_data.flow_mode == FLOW_MODE_STATIC) {
		return false;
	}

	if (_elem_static_data.flow_mode == FLOW_MODE_POWDER) {
		if (_vertical_step == 0) {
			return false;
		}
		if ((_candidate_offset.y * float(_vertical_step)) < 0.0) {
			return false;
		}
		if (_candidate_offset.y == 0.0 && abs_float(_candidate_offset.x) > 1.0) {
			return false;
		}
		if (_candidate_offset.y != 0.0 && abs_float(_candidate_offset.x) > max(1.0, ceil(_elem_static_data.lateral_spread))) {
			return false;
		}
		return true;
	}

	if (_elem_static_data.flow_mode == FLOW_MODE_LIQUID) {
		if (_vertical_step != 0 && (_candidate_offset.y * float(_vertical_step)) < 0.0) {
			return false;
		}
		return true;
	}

	if (_elem_static_data.flow_mode == FLOW_MODE_GAS) {
		if (_vertical_step != 0 && (_candidate_offset.y * float(_vertical_step)) < 0.0) {
			return false;
		}
		return true;
	}

	if (_elem_static_data.flow_mode == FLOW_MODE_GOO) {
		if (_vertical_step != 0 && (_candidate_offset.y * float(_vertical_step)) < 0.0) {
			return false;
		}
		if (abs_float(_candidate_offset.x) > max(1.0, ceil(_elem_static_data.lateral_spread))) {
			return false;
		}
		return true;
	}

	return false;
}

float count_same_neighbors(ElementStaticData _elem_static_data, vec2 _center_texcoord) {
	float _neighbor_count = 0.0;

	for (int _offset_y = -1; _offset_y <= 1; ++_offset_y) {
		for (int _offset_x = -1; _offset_x <= 1; ++_offset_x) {
			vec2 _neighbor_texcoord;
			vec4 _neighbor_pixel;
			ElementStaticData _neighbor_static_data;

			if (_offset_x == 0 && _offset_y == 0) {
				continue;
			}

			_neighbor_texcoord = _center_texcoord + vec2(float(_offset_x) * u_texel_size.x, float(_offset_y) * u_texel_size.y);
			if (!uv_in_bounds(_neighbor_texcoord)) {
				continue;
			}

			_neighbor_pixel = texture2D(gm_BaseTexture, _neighbor_texcoord);
			_neighbor_static_data = get_element_static_data(element_id_from_pixel(_neighbor_pixel));
			if (_neighbor_static_data.id == _elem_static_data.id) {
				_neighbor_count += 1.0;
			}
		}
	}

	return _neighbor_count;
}

// Scores a candidate movement offset for the source element.
//
// Design doc changes implemented here:
//   GAS: lateral score is reduced proportionally to current vertical velocity
//        strength.  This implements "rise first, diffuse second" and prevents
//        gases from committing to horizontal rails while still having an open
//        upward path.  When the vertical path is blocked (vel.y near zero),
//        full lateral weight is restored, allowing natural diffusion.
float candidate_score(
	ElementStaticData _elem_static_data,
	vec2 _self_texcoord,
	vec2 _candidate_offset,
	vec2 _velocity,
	int _vertical_step,
	float _same_neighbor_count_here,
	float _side_bias
) {
	vec2 _candidate_direction = normalize(_candidate_offset);
	vec2 _preferred_velocity = _velocity;
	float _score = 0.0;
	float _distance = length(_candidate_offset);
	float _same_neighbor_count_there;
	float _neighbor_delta;

	if (_preferred_velocity.x == 0.0 && _preferred_velocity.y == 0.0) {
		_preferred_velocity.y = _elem_static_data.vertical_drive;
	}
	if (_preferred_velocity.x != 0.0 || _preferred_velocity.y != 0.0) {
		_score += dot(_candidate_direction, normalize(_preferred_velocity)) * (1.5 + (_elem_static_data.momentum_retention * 3.0));
	}

	if (_vertical_step != 0) {
		_score += ((_candidate_offset.y * float(_vertical_step)) / float(SIM_MAX_MOVE_RADIUS)) * flow_mode_vertical_weight(_elem_static_data.flow_mode);
	}

	_score += (abs_float(_candidate_offset.x) / float(SIM_MAX_MOVE_RADIUS)) * _elem_static_data.lateral_spread * flow_mode_lateral_weight(_elem_static_data.flow_mode);
	_score -= _distance * (0.22 + (_elem_static_data.support_resistance * 0.18));

	if (_candidate_offset.x != 0.0 && (_candidate_offset.x * _side_bias) > 0.0) {
		_score += 0.10;
	}

	_same_neighbor_count_there = count_same_neighbors(_elem_static_data, _self_texcoord + (_candidate_offset * u_texel_size));
	_neighbor_delta = _same_neighbor_count_there - _same_neighbor_count_here;
	_score += _neighbor_delta * _elem_static_data.clump_factor * 0.60;

	if (_elem_static_data.flow_mode == FLOW_MODE_POWDER) {
		if (_candidate_offset.y == 0.0) {
			_score -= 0.90;
		}
		if (abs_float(_candidate_offset.x) > 1.0) {
			_score -= 0.35 * abs_float(_candidate_offset.x);
		}
		_score -= _elem_static_data.support_resistance * 0.75;
	}

	if (_elem_static_data.flow_mode == FLOW_MODE_LIQUID) {
		if (_candidate_offset.y == 0.0) {
			_score += 0.25;
		}
	}

	// GAS: "rise first, diffuse second."
	// Reduce the lateral movement bonus proportionally to how strongly the gas
	// is currently moving in its drive direction.  A fast-rising gas (strong
	// vertical vel) gets almost no lateral bonus; a stalled/blocked gas gets
	// the full lateral bonus and diffuses normally.
	// This prevents committed sideways rails from forming when the upward path
	// is still available.
	if (_elem_static_data.flow_mode == FLOW_MODE_GAS) {
		if (_candidate_offset.y == 0.0) {
			float _vert_vel_ratio = 0.0;
			if (_elem_static_data.max_speed > 0.0) {
				_vert_vel_ratio = clamp(abs_float(_velocity.y) / _elem_static_data.max_speed, 0.0, 1.0);
			}
			_score += 0.20 * (1.0 - _vert_vel_ratio);
		}
		_score += _elem_static_data.surface_response * 0.20;
	}

	if (_elem_static_data.flow_mode == FLOW_MODE_GOO) {
		_score += _elem_static_data.surface_response * 0.35;
		_score += _elem_static_data.clump_factor * 0.55;
	}

	return _score;
}

// Chooses the highest-scoring open candidate movement offset.
//
// Design doc changes:
//   GAS side bias: when the gas has lateral velocity from previous movement,
//   that lateral direction is used as the side bias rather than the static
//   position-only hash.  This lets gas follow its own movement history and
//   breaks the locked-rail pattern that forms when every cell at a given
//   position always prefers the same fixed lateral side.
vec2 choose_profile_offset(ElementStaticData _elem_static_data, vec2 _self_texcoord, vec2 _velocity) {
	int _vertical_step = vertical_step_from_drive(_elem_static_data.vertical_drive);
	float _reach_x = clamp(ceil(max(abs_float(_velocity.x), _elem_static_data.lateral_spread)), 0.0, float(SIM_MAX_MOVE_RADIUS));
	float _reach_y = clamp(ceil(max(abs_float(_velocity.y), abs_float(_elem_static_data.vertical_drive))), 0.0, float(SIM_MAX_MOVE_RADIUS));
	float _best_score = -99999.0;
	float _same_neighbor_count_here = count_same_neighbors(_elem_static_data, _self_texcoord);
	float _side_bias;
	vec2 _best_offset = vec2(0.0);

	if (_elem_static_data.flow_mode == FLOW_MODE_STATIC) {
		return vec2(0.0);
	}

	// Side bias: for gas, use lateral velocity direction so flow follows history
	// and avoids fixed-position rails.  For all other modes, use the stable
	// position-based hash (deterministic, never PRNG-per-frame).
	if (_elem_static_data.flow_mode == FLOW_MODE_GAS && abs_float(_velocity.x) > 0.1) {
		_side_bias = sign_float(_velocity.x);
	} else {
		_side_bias = (rand(_self_texcoord, 91.0) < 0.5) ? -1.0 : 1.0;
	}

	if (_reach_x <= 0.0 && _reach_y <= 0.0) {
		if (_vertical_step != 0) {
			_reach_y = 1.0;
		}
		if (_elem_static_data.lateral_spread > 0.0) {
			_reach_x = 1.0;
		}
	}

	for (int _offset_y = -SIM_MAX_MOVE_RADIUS; _offset_y <= SIM_MAX_MOVE_RADIUS; ++_offset_y) {
		for (int _offset_x = -SIM_MAX_MOVE_RADIUS; _offset_x <= SIM_MAX_MOVE_RADIUS; ++_offset_x) {
			vec2 _candidate_offset = vec2(float(_offset_x), float(_offset_y));
			float _score;

			if (abs_float(_candidate_offset.x) > _reach_x || abs_float(_candidate_offset.y) > _reach_y) {
				continue;
			}

			if (!candidate_allowed_for_flow(_elem_static_data, _candidate_offset, _vertical_step)) {
				continue;
			}

			if (!target_path_is_open(_elem_static_data, _self_texcoord, _candidate_offset)) {
				continue;
			}

			_score = candidate_score(
				_elem_static_data,
				_self_texcoord,
				_candidate_offset,
				_velocity,
				_vertical_step,
				_same_neighbor_count_here,
				_side_bias
			);

			if (_score > _best_score) {
				_best_score = _score;
				_best_offset = _candidate_offset;
			}
		}
	}

	return _best_offset;
}

void main() {
	vec4 _self_pixel = texture2D(gm_BaseTexture, v_vTexcoord);
	ElementDynamicData _elem_dynamic_data = unpack_elem_dynamic_data(_self_pixel);
	ElementStaticData _elem_static_data = get_element_static_data(_elem_dynamic_data.id);
	vec2 _intent_offset = vec2(0.0);

	// B channel of the intent surface encodes a rest-state signal for Pass4:
	//   0.0 = normal intent (no rest action)
	//   1.0 = enter or maintain rest (Pass4 should write the rest bits)
	float _rest_signal = 0.0;

	if (_elem_dynamic_data.id == ELEM_ID_EMPTY) {
		gl_FragColor = vec4(vel_to_rg(vec2(0.0)), 0.0, 1.0);
		return;
	}

	if (_elem_static_data.immovable || _elem_static_data.flow_mode == FLOW_MODE_STATIC) {
		gl_FragColor = vec4(vel_to_rg(vec2(0.0)), 0.0, 1.0);
		return;
	}

	// -------------------------------------------------------------------------
	// Deterministic rest fast-path (FLOW_MODE_POWDER only).
	//
	// Design doc: "stable rest must be deterministic – powders must be able to
	// stay at rest until acted on; that state must not depend on per-frame PRNG
	// because that causes creeping and endless flattening."
	//
	// The rest state is encoded into the green byte of the pixel by Pass4 when
	// B=1.0 was signaled on a previous frame.  Specifically, when x_speed==0
	// and y_speed==0, the direction bits carry rest metadata:
	//   x_dir == 1  →  is_resting
	//   y_dir       →  rest_bias (preferred wake-side, 0=left, 1=right)
	//
	// If the element is resting and support is still valid, we skip the full
	// candidate search and emit (0,0) intent with B=1 to maintain rest.
	// If support has changed (a cell opened up below or diagonally), we clear
	// the rest state and fall through to normal movement evaluation.
	// -------------------------------------------------------------------------
	bool _is_resting = (
		_elem_dynamic_data.x_speed == 0 &&
		_elem_dynamic_data.y_speed == 0 &&
		_elem_dynamic_data.x_dir == 1
	);

	if (_is_resting && _elem_static_data.flow_mode == FLOW_MODE_POWDER) {
		if (powder_rest_is_valid(_elem_static_data, v_vTexcoord)) {
			// Support is still valid.  Stay resting, signal Pass4 to keep rest bits.
			gl_FragColor = vec4(vel_to_rg(vec2(0.0)), 1.0, 1.0);
			return;
		}
		// Support changed – fall through to candidate search with zero velocity.
		// _elem_dynamic_data.vel is already zero because rest was encoded as zero speed.
	}

	// -------------------------------------------------------------------------
	// Velocity integration.
	// Apply momentum retention and vertical drive each frame.
	// -------------------------------------------------------------------------
	_elem_dynamic_data.vel *= clamp(_elem_static_data.momentum_retention, 0.0, 1.0);
	_elem_dynamic_data.vel.y += _elem_static_data.vertical_drive;
	_elem_dynamic_data.vel = sanitize_velocity_to_static(_elem_dynamic_data.vel, _elem_static_data);

	// -------------------------------------------------------------------------
	// Candidate selection: find the best open move.
	// -------------------------------------------------------------------------
	_intent_offset = choose_profile_offset(_elem_static_data, v_vTexcoord, _elem_dynamic_data.vel);

	if (_intent_offset.x == 0.0 && _intent_offset.y == 0.0) {
		// No valid move found.
		_elem_dynamic_data.vel = vec2(0.0);

		// For powders: if support is also valid right now, signal Pass4 to enter
		// rest.  This prevents the element from reconsidering diagonal candidates
		// every frame when it is genuinely supported, which is what causes both
		// perfect-pyramid lock-in (too permissive scoring) and endless flat creep
		// (too generous lateral scoring).
		if (_elem_static_data.flow_mode == FLOW_MODE_POWDER &&
			powder_rest_is_valid(_elem_static_data, v_vTexcoord)) {
			_rest_signal = 1.0;
		}
	}

	gl_FragColor = vec4(vel_to_rg(_intent_offset), _rest_signal, 1.0);
}
