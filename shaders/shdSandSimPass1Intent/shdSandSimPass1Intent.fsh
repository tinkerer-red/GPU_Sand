#pragma shady: inline(shdSandSimCommon.Uniforms)
#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel_size;
uniform float u_frame;

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

	if (_elem_static_data.flow_mode == FLOW_MODE_GAS) {
		if (_candidate_offset.y == 0.0) {
			_score += 0.20;
		}
		_score += _elem_static_data.surface_response * 0.20;
	}

	if (_elem_static_data.flow_mode == FLOW_MODE_GOO) {
		_score += _elem_static_data.surface_response * 0.35;
		_score += _elem_static_data.clump_factor * 0.55;
	}

	return _score;
}

vec2 choose_profile_offset(ElementStaticData _elem_static_data, vec2 _self_texcoord, vec2 _velocity) {
	int _vertical_step = vertical_step_from_drive(_elem_static_data.vertical_drive);
	float _reach_x = clamp(ceil(max(abs_float(_velocity.x), _elem_static_data.lateral_spread)), 0.0, float(SIM_MAX_MOVE_RADIUS));
	float _reach_y = clamp(ceil(max(abs_float(_velocity.y), abs_float(_elem_static_data.vertical_drive))), 0.0, float(SIM_MAX_MOVE_RADIUS));
	float _best_score = -99999.0;
	float _same_neighbor_count_here = count_same_neighbors(_elem_static_data, _self_texcoord);
	float _side_bias = (rand(_self_texcoord, 91.0) < 0.5) ? -1.0 : 1.0;
	vec2 _best_offset = vec2(0.0);

	if (_elem_static_data.flow_mode == FLOW_MODE_STATIC) {
		return vec2(0.0);
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

	if (_elem_dynamic_data.id == ELEM_ID_EMPTY) {
		gl_FragColor = vec4(vel_to_rg(vec2(0.0)), 0.0, 1.0);
		return;
	}

	if (_elem_static_data.immovable || _elem_static_data.flow_mode == FLOW_MODE_STATIC) {
		gl_FragColor = vec4(vel_to_rg(vec2(0.0)), 0.0, 1.0);
		return;
	}

	_elem_dynamic_data.vel *= clamp(_elem_static_data.momentum_retention, 0.0, 1.0);
	_elem_dynamic_data.vel.y += _elem_static_data.vertical_drive;
	_elem_dynamic_data.vel = sanitize_velocity_to_static(_elem_dynamic_data.vel, _elem_static_data);

	_intent_offset = choose_profile_offset(_elem_static_data, v_vTexcoord, _elem_dynamic_data.vel);
	if (_intent_offset.x == 0.0 && _intent_offset.y == 0.0) {
		_elem_dynamic_data.vel = vec2(0.0);
	}

	gl_FragColor = vec4(vel_to_rg(_intent_offset), 0.0, 1.0);
}
