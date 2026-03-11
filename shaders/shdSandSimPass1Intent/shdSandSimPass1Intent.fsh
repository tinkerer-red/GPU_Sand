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

bool pixel_is_grounded(ElementStaticData _elem_static_data, vec2 _self_texcoord, ElementDynamicData _elem_dynamic_data) {
	int _step_x = sign_int(int(sign(_elem_dynamic_data.vel.x)));
	int _step_y = sign_int(int(sign(_elem_dynamic_data.vel.y)));
	vec2 _check_offset_0 = vec2(0.0, float(_step_y));
	vec2 _check_offset_1 = vec2(float(_step_x), 0.0);
	vec2 _check_offset_2 = vec2(float(_step_x), float(_step_y));
	vec2 _check_texcoord_0 = _self_texcoord + (_check_offset_0 * u_texel_size);
	vec2 _check_texcoord_1 = _self_texcoord + (_check_offset_1 * u_texel_size);
	vec2 _check_texcoord_2 = _self_texcoord + (_check_offset_2 * u_texel_size);
	vec4 _check_pixel;
	ElementDynamicData _check_dynamic_data;

	if (_step_y == 0 && _elem_static_data.gravity_force != 0.0) {
		_step_y = sign_int(int(sign(_elem_static_data.gravity_force)));
		_check_offset_0 = vec2(0.0, float(_step_y));
		_check_texcoord_0 = _self_texcoord + (_check_offset_0 * u_texel_size);
	}

	if (uv_in_bounds(_check_texcoord_0)) {
		_check_pixel = texture2D(gm_BaseTexture, _check_texcoord_0);
		if (cell_is_solid(_check_pixel)) {
			_check_dynamic_data = unpack_elem_dynamic_data(_check_pixel);
			if (!dynamic_has_motion(_check_dynamic_data)) {
				return true;
			}
		}
	}

	if (uv_in_bounds(_check_texcoord_1)) {
		_check_pixel = texture2D(gm_BaseTexture, _check_texcoord_1);
		if (cell_is_solid(_check_pixel)) {
			_check_dynamic_data = unpack_elem_dynamic_data(_check_pixel);
			if (!dynamic_has_motion(_check_dynamic_data)) {
				return true;
			}
		}
	}

	if (uv_in_bounds(_check_texcoord_2)) {
		_check_pixel = texture2D(gm_BaseTexture, _check_texcoord_2);
		if (cell_is_solid(_check_pixel)) {
			_check_dynamic_data = unpack_elem_dynamic_data(_check_pixel);
			if (!dynamic_has_motion(_check_dynamic_data)) {
				return true;
			}
		}
	}

	return false;
}

vec2 compute_bounce_velocity(ElementStaticData _elem_static_data, vec2 _self_texcoord, vec2 _current_velocity) {
	vec2 _impact_offset = rand_round_vel(_current_velocity, _self_texcoord, u_frame + 30.0);
	vec2 _impact_texcoord;
	vec2 _normal_sum = vec2(0.0, 0.0);
	float _normal_length;
	vec2 _surface_normal;
	vec2 _incoming_direction;
	vec2 _reflected_direction;
	float _reflected_speed;
	vec2 _reflected_velocity;

	_impact_offset.x = clamp(_impact_offset.x, -float(SIM_MAX_MOVE_RADIUS), float(SIM_MAX_MOVE_RADIUS));
	_impact_offset.y = clamp(_impact_offset.y, -float(SIM_MAX_MOVE_RADIUS), float(SIM_MAX_MOVE_RADIUS));

	if (_impact_offset.x == 0.0 && _impact_offset.y == 0.0) {
		return vec2(0.0);
	}

	if (target_offset_is_open(_elem_static_data, _self_texcoord, _impact_offset)) {
		return vec2(0.0);
	}

	_impact_texcoord = _self_texcoord + (_impact_offset * u_texel_size);

	for (int _sample_y = -1; _sample_y <= 1; ++_sample_y) {
		for (int _sample_x = -1; _sample_x <= 1; ++_sample_x) {
			vec2 _sample_offset;
			vec2 _sample_texcoord;
			vec4 _sample_pixel;

			if (_sample_x == 0 && _sample_y == 0) {
				continue;
			}

			_sample_offset = vec2(float(_sample_x), float(_sample_y));
			_sample_texcoord = _impact_texcoord + (_sample_offset * u_texel_size);

			if (!uv_in_bounds(_sample_texcoord)) {
				continue;
			}

			_sample_pixel = texture2D(gm_BaseTexture, _sample_texcoord);
			if (cell_is_solid(_sample_pixel)) {
				_normal_sum -= _sample_offset;
			}
		}
	}

	_normal_length = length(_normal_sum);
	if (_normal_length <= 0.0) {
		return vec2(0.0);
	}

	_surface_normal = _normal_sum / _normal_length;
	_incoming_direction = normalize(_current_velocity);
	_reflected_direction = reflect(_incoming_direction, _surface_normal);

	if (_reflected_direction.y * sign(_elem_static_data.gravity_force) < 0.0) {
		_reflected_direction.y = 0.0;
	}

	if (_reflected_direction.x == 0.0 && _reflected_direction.y == 0.0) {
		return vec2(0.0);
	}

	_reflected_direction = normalize(_reflected_direction);
	_reflected_speed = length(_current_velocity) * _elem_static_data.bounce_dampening_multiplier;
	_reflected_velocity = _reflected_direction * _reflected_speed;

	_reflected_velocity.x = clamp(_reflected_velocity.x, -_elem_static_data.max_vel_x, _elem_static_data.max_vel_x);
	_reflected_velocity.y = clamp(_reflected_velocity.y, -_elem_static_data.max_vel_y, _elem_static_data.max_vel_y);

	return _reflected_velocity;
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

bool movement_class_uses_velocity_box(ElementStaticData _elem_static_data) {
	return (
		_elem_static_data.movement_class == MOVE_CLASS_LIQUID ||
		_elem_static_data.movement_class == MOVE_CLASS_VISCOUS_LIQUID ||
		_elem_static_data.movement_class == MOVE_CLASS_GAS ||
		_elem_static_data.movement_class == MOVE_CLASS_DRIFTING_SOLID
	);
}

vec2 choose_velocity_box_offset(ElementStaticData _elem_static_data, vec2 _self_texcoord, vec2 _velocity, int _gravity_step, float _seed) {
	float _reach_x = clamp(ceil(abs_float(_velocity.x)), 0.0, float(SIM_MAX_MOVE_RADIUS));
	float _reach_y = clamp(ceil(abs_float(_velocity.y)), 0.0, float(SIM_MAX_MOVE_RADIUS));
	float _side_bias = (rand(_self_texcoord, _seed) < 0.5) ? -1.0 : 1.0;
	float _best_score = -100000.0;
	float _horizontal_bonus = 0.0;
	float _vertical_bonus = 0.0;
	vec2 _best_offset = vec2(0.0);
	vec2 _preferred_velocity = _velocity;
	vec2 _preferred_direction;

	if (_reach_x <= 0.0 && _reach_y <= 0.0) {
		return vec2(0.0);
	}

	if (_elem_static_data.movement_class == MOVE_CLASS_LIQUID) {
		_horizontal_bonus = 0.40;
		_vertical_bonus = 0.15;
	} else if (_elem_static_data.movement_class == MOVE_CLASS_VISCOUS_LIQUID) {
		_horizontal_bonus = 0.20;
		_vertical_bonus = 0.15;
	} else if (_elem_static_data.movement_class == MOVE_CLASS_GAS) {
		_horizontal_bonus = 0.55;
		_vertical_bonus = 0.25;
	} else if (_elem_static_data.movement_class == MOVE_CLASS_DRIFTING_SOLID) {
		_horizontal_bonus = 0.45;
		_vertical_bonus = 0.20;
	}

	if (_preferred_velocity.y == 0.0 && _gravity_step != 0) {
		_preferred_velocity.y = float(_gravity_step);
	}

	if (_preferred_velocity.x == 0.0 && _preferred_velocity.y == 0.0) {
		return vec2(0.0);
	}

	_preferred_direction = normalize(_preferred_velocity);

	for (int _search_y = -SIM_MAX_MOVE_RADIUS; _search_y <= SIM_MAX_MOVE_RADIUS; ++_search_y) {
		for (int _search_x = -SIM_MAX_MOVE_RADIUS; _search_x <= SIM_MAX_MOVE_RADIUS; ++_search_x) {
			vec2 _candidate_offset;
			vec2 _candidate_direction;
			float _alignment_score;
			float _distance_score;
			float _horizontal_score = 0.0;
			float _vertical_score = 0.0;
			float _tie_break_score = 0.0;
			float _score;

			if (_search_x == 0 && _search_y == 0) {
				continue;
			}

			if (float(abs_int(_search_x)) > _reach_x || float(abs_int(_search_y)) > _reach_y) {
				continue;
			}

			if (_gravity_step != 0 && _search_y != 0 && sign_int(_search_y) != _gravity_step) {
				continue;
			}

			_candidate_offset = vec2(float(_search_x), float(_search_y));
			if (!target_path_is_open(_elem_static_data, _self_texcoord, _candidate_offset)) {
				continue;
			}

			_candidate_direction = normalize(_candidate_offset);
			_alignment_score = dot(_candidate_direction, _preferred_direction) * 8.0;
			_distance_score = (length(_candidate_offset) / float(SIM_MAX_MOVE_RADIUS)) * 1.5;

			if (_reach_x > 0.0) {
				_horizontal_score = (abs_float(_candidate_offset.x) / _reach_x) * _horizontal_bonus;
			}
			if (_reach_y > 0.0) {
				_vertical_score = (abs_float(_candidate_offset.y) / _reach_y) * _vertical_bonus;
			}
			if (_candidate_offset.x != 0.0 && (_candidate_offset.x * _side_bias) > 0.0) {
				_tie_break_score = 0.02;
			}

			_score = _alignment_score + _distance_score + _horizontal_score + _vertical_score + _tie_break_score;

			if (_gravity_step != 0 && _candidate_offset.y == 0.0 && abs_float(_velocity.y) >= 1.0) {
				_score -= 0.75;
			}

			if (abs_float(_velocity.x) < 0.5 && _candidate_offset.x != 0.0) {
				_score -= 1.25 * (abs_float(_candidate_offset.x) / max(_reach_x, 1.0));
			}

			if (abs_float(_velocity.y) < 0.5 && _candidate_offset.y != 0.0 && _gravity_step != 0) {
				_score -= 0.35 * (abs_float(_candidate_offset.y) / max(_reach_y, 1.0));
			}

			if (_score > _best_score) {
				_best_score = _score;
				_best_offset = _candidate_offset;
			}
		}
	}

	return _best_offset;
}

vec2 choose_direct_velocity_offset(ElementStaticData _elem_static_data, vec2 _self_texcoord, vec2 _velocity) {
	vec2 _direct_offset = vec2(
		round_signed_float(_velocity.x),
		round_signed_float(_velocity.y)
	);

	_direct_offset.x = clamp(_direct_offset.x, -float(SIM_MAX_MOVE_RADIUS), float(SIM_MAX_MOVE_RADIUS));
	_direct_offset.y = clamp(_direct_offset.y, -float(SIM_MAX_MOVE_RADIUS), float(SIM_MAX_MOVE_RADIUS));

	if (_direct_offset.x == 0.0 && _direct_offset.y == 0.0) {
		return vec2(0.0);
	}

	if (target_path_is_open(_elem_static_data, _self_texcoord, _direct_offset)) {
		return _direct_offset;
	}

	return vec2(0.0);
}

vec2 choose_diagonal_offset(ElementStaticData _elem_static_data, vec2 _self_texcoord, int _gravity_step, float _seed) {
	int _first_direction = (rand(_self_texcoord, _seed) < 0.5) ? -1 : 1;
	int _second_direction = -_first_direction;
	float _sticky_roll = rand(_self_texcoord, _seed + 11.0);

	if (_sticky_roll < _elem_static_data.stickiness_chance) {
		return vec2(0.0);
	}

	for (int _search_step = 1; _search_step <= SIM_MAX_MOVE_RADIUS; ++_search_step) {
		vec2 _first_offset;
		vec2 _second_offset;

		if (float(_search_step) > _elem_static_data.x_slip_search_range) {
			continue;
		}

		_first_offset = vec2(float(_search_step * _first_direction), float(_gravity_step));
		if (target_path_is_open(_elem_static_data, _self_texcoord, _first_offset)) {
			return _first_offset;
		}

		_second_offset = vec2(float(_search_step * _second_direction), float(_gravity_step));
		if (target_path_is_open(_elem_static_data, _self_texcoord, _second_offset)) {
			return _second_offset;
		}
	}

	return vec2(0.0);
}

vec2 choose_immediate_diagonal_offset(ElementStaticData _elem_static_data, vec2 _self_texcoord, int _gravity_step, float _seed) {
	int _first_direction = (rand(_self_texcoord, _seed) < 0.5) ? -1 : 1;
	int _second_direction = -_first_direction;
	vec2 _first_offset = vec2(float(_first_direction), float(_gravity_step));
	vec2 _second_offset = vec2(float(_second_direction), float(_gravity_step));

	if (_elem_static_data.x_slip_search_range < 1.0) {
		return vec2(0.0);
	}

	if (target_path_is_open(_elem_static_data, _self_texcoord, _first_offset)) {
		return _first_offset;
	}

	if (target_path_is_open(_elem_static_data, _self_texcoord, _second_offset)) {
		return _second_offset;
	}

	return vec2(0.0);
}

vec2 choose_lateral_offset(ElementStaticData _elem_static_data, vec2 _self_texcoord, float _seed) {
	int _first_direction = (rand(_self_texcoord, _seed) < 0.5) ? -1 : 1;
	int _second_direction = -_first_direction;
	float _viscosity_roll = rand(_self_texcoord, _seed + 21.0);

	if (_viscosity_roll < _elem_static_data.viscosity) {
		return vec2(0.0);
	}

	for (int _search_step = 1; _search_step <= SIM_MAX_MOVE_RADIUS; ++_search_step) {
		vec2 _first_offset;
		vec2 _second_offset;

		if (float(_search_step) > _elem_static_data.x_slip_search_range) {
			continue;
		}

		_first_offset = vec2(float(_search_step * _first_direction), 0.0);
		if (target_path_is_open(_elem_static_data, _self_texcoord, _first_offset)) {
			return _first_offset;
		}

		_second_offset = vec2(float(_search_step * _second_direction), 0.0);
		if (target_path_is_open(_elem_static_data, _self_texcoord, _second_offset)) {
			return _second_offset;
		}
	}

	return vec2(0.0);
}

void main() {
	vec4 _self_pixel = texture2D(gm_BaseTexture, v_vTexcoord);
	ElementDynamicData _elem_dynamic_data = unpack_elem_dynamic_data(_self_pixel);
	ElementStaticData _elem_static_data = get_element_static_data(_elem_dynamic_data.id);
	vec2 _intent_offset = vec2(0.0);
	bool _is_grounded = false;
	float _decay_chance = 0.0;
	int _gravity_step = sign_int(int(sign(_elem_static_data.gravity_force)));

	if (_elem_dynamic_data.id == ELEM_ID_EMPTY) {
		gl_FragColor = vec4(vel_to_rg(vec2(0.0)), 0.0, 1.0);
		return;
	}

	if (_elem_static_data.immovable || _elem_static_data.movement_class == MOVE_CLASS_NONE_STATIC) {
		gl_FragColor = vec4(vel_to_rg(vec2(0.0)), 0.0, 1.0);
		return;
	}

	_elem_dynamic_data.vel.y += _elem_static_data.gravity_force;
	_elem_dynamic_data.vel.x = clamp(_elem_dynamic_data.vel.x, -_elem_static_data.max_vel_x, _elem_static_data.max_vel_x);
	_elem_dynamic_data.vel.y = clamp(_elem_dynamic_data.vel.y, -_elem_static_data.max_vel_y, _elem_static_data.max_vel_y);

	if (_elem_dynamic_data.vel.x != 0.0 || _elem_dynamic_data.vel.y != 0.0) {
		_is_grounded = pixel_is_grounded(_elem_static_data, v_vTexcoord, _elem_dynamic_data);
		_decay_chance = _is_grounded ? _elem_static_data.friction_vel_decay_chance : _elem_static_data.airborne_vel_decay_chance;

		if (abs_float(_elem_dynamic_data.vel.x) >= 1.0 && chance(_decay_chance, v_vTexcoord, u_frame + 17.0)) {
			_elem_dynamic_data.vel.x -= sign(_elem_dynamic_data.vel.x);
		}
		if (abs_float(_elem_dynamic_data.vel.y) >= 1.0 && chance(_decay_chance, v_vTexcoord, u_frame + 18.0)) {
			_elem_dynamic_data.vel.y -= sign(_elem_dynamic_data.vel.y);
		}
	}

	_intent_offset = choose_direct_velocity_offset(_elem_static_data, v_vTexcoord, _elem_dynamic_data.vel);

	if ((_intent_offset.x == 0.0 && _intent_offset.y == 0.0) && movement_class_uses_velocity_box(_elem_static_data)) {
		if (abs_float(_elem_dynamic_data.vel.x) >= 0.5 || abs_float(_elem_dynamic_data.vel.y) >= 0.5) {
			_intent_offset = choose_velocity_box_offset(_elem_static_data, v_vTexcoord, _elem_dynamic_data.vel, _gravity_step, u_frame + 7.0);
		}
	}

	if (_intent_offset.x == 0.0 && _intent_offset.y == 0.0 && _elem_static_data.bounce_chance > 0.0 && chance(_elem_static_data.bounce_chance, v_vTexcoord, u_frame + 31.0)) {
		vec2 _bounce_velocity = compute_bounce_velocity(_elem_static_data, v_vTexcoord, _elem_dynamic_data.vel);
		vec2 _bounce_offset = choose_direct_velocity_offset(_elem_static_data, v_vTexcoord, _bounce_velocity);
		if (_bounce_offset.x == 0.0 && _bounce_offset.y == 0.0 && movement_class_uses_velocity_box(_elem_static_data)) {
			_bounce_offset = choose_velocity_box_offset(_elem_static_data, v_vTexcoord, _bounce_velocity, _gravity_step, u_frame + 32.0);
		}

		if (_bounce_offset.x != 0.0 || _bounce_offset.y != 0.0) {
			_elem_dynamic_data.vel = _bounce_velocity;
			_intent_offset = _bounce_offset;
		}
	}

	if (_intent_offset.x == 0.0 && _intent_offset.y == 0.0 && _gravity_step != 0) {
		for (int _search_step = 1; _search_step <= SIM_MAX_MOVE_RADIUS; ++_search_step) {
			vec2 _vertical_offset;

			if (float(_search_step) > _elem_static_data.y_slip_search_range) {
				continue;
			}

			_vertical_offset = vec2(0.0, float(_search_step * _gravity_step));
			if (target_path_is_open(_elem_static_data, v_vTexcoord, _vertical_offset)) {
				_intent_offset = _vertical_offset;
				break;
			}
		}
	}

	if (_intent_offset.x == 0.0 && _intent_offset.y != 0.0 && _elem_static_data.can_slip) {
		if (
			_elem_static_data.movement_class == MOVE_CLASS_LIQUID ||
			_elem_static_data.movement_class == MOVE_CLASS_VISCOUS_LIQUID ||
			_elem_static_data.movement_class == MOVE_CLASS_GAS ||
			_elem_static_data.movement_class == MOVE_CLASS_DRIFTING_SOLID
		) {
			vec2 _diagonal_offset = choose_immediate_diagonal_offset(_elem_static_data, v_vTexcoord, sign_int(int(sign(_intent_offset.y))), u_frame + 45.0);
			if (_diagonal_offset.x != 0.0 || _diagonal_offset.y != 0.0) {
				_intent_offset = _diagonal_offset;
			}
		}
	}

	if (_intent_offset.x == 0.0 && _intent_offset.y == 0.0 && _elem_static_data.can_slip) {
		if (
			_elem_static_data.movement_class == MOVE_CLASS_POWDER ||
			_elem_static_data.movement_class == MOVE_CLASS_HEAVY_POWDER ||
			_elem_static_data.movement_class == MOVE_CLASS_STICKY_POWDER
		) {
			_intent_offset = choose_diagonal_offset(_elem_static_data, v_vTexcoord, _gravity_step, u_frame + 40.0);
		}
	}

	if (_intent_offset.x == 0.0 && _intent_offset.y == 0.0) {
		if (
			_elem_static_data.movement_class == MOVE_CLASS_LIQUID ||
			_elem_static_data.movement_class == MOVE_CLASS_VISCOUS_LIQUID
		) {
			if (_gravity_step != 0) {
				_intent_offset = choose_diagonal_offset(_elem_static_data, v_vTexcoord, _gravity_step, u_frame + 50.0);
			}
			if (_intent_offset.x == 0.0 && _intent_offset.y == 0.0) {
				_intent_offset = choose_lateral_offset(_elem_static_data, v_vTexcoord, u_frame + 60.0);
			}
		} else if (
			_elem_static_data.movement_class == MOVE_CLASS_GAS ||
			_elem_static_data.movement_class == MOVE_CLASS_DRIFTING_SOLID
		) {
			if (_gravity_step != 0) {
				_intent_offset = choose_diagonal_offset(_elem_static_data, v_vTexcoord, _gravity_step, u_frame + 70.0);
			}
			if (_intent_offset.x == 0.0 && _intent_offset.y == 0.0) {
				_intent_offset = choose_lateral_offset(_elem_static_data, v_vTexcoord, u_frame + 80.0);
			}
		}
	}

	if (_intent_offset.x == 0.0 && _intent_offset.y == 0.0) {
		_elem_dynamic_data.vel = vec2(0.0);
	}

	gl_FragColor = vec4(vel_to_rg(_intent_offset), 0.0, 1.0);
}
