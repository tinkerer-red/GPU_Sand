#pragma shady: inline(shdSandSimCommon.Uniforms)
#pragma shady: import(shdSandSimCommon)

#define DEBUG_RESOLVE_VISUALIZE 0

#define RESOLVE_ENABLE_GENERIC_DYNAMIC_UPDATE 1
#define RESOLVE_ENABLE_LANE_TEMPERATURE 1
#define RESOLVE_ENABLE_LANE_MOISTURE 1
#define RESOLVE_ENABLE_LANE_CORROSION 1
#define RESOLVE_ENABLE_LANE_MAGIC 0


varying vec2 v_vTexcoord;

uniform vec2 u_texel_size;
uniform float u_frame;

uniform sampler2D gm_SecondaryTexture;
uniform sampler2D gm_TertiaryTexture;


float sample_temperature_ambient_average(ElementDynamicData _current_dynamic_data, ElementStaticData _current_static_data, vec2 _center_texcoord) {
	float _ambient_total = 0.0;
	float _ambient_count = 0.0;
	vec2 _neighbor_texcoord;
	vec4 _neighbor_pixel;
	ElementDynamicData _neighbor_dynamic_data;
	ElementStaticData _neighbor_static_data;

	if (static_lane_ignored(_current_static_data, LANE_TEMPERATURE)) {
		return 0.0;
	}

	for (int _offset_y = -1; _offset_y <= 1; ++_offset_y) {
		for (int _offset_x = -1; _offset_x <= 1; ++_offset_x) {
			if (_offset_x == 0 && _offset_y == 0) {
				continue;
			}

			_neighbor_texcoord = _center_texcoord + vec2(float(_offset_x) * u_texel_size.x, float(_offset_y) * u_texel_size.y);
			if (!uv_in_bounds(_neighbor_texcoord)) {
				continue;
			}

			_neighbor_pixel = texture2D(gm_BaseTexture, _neighbor_texcoord);
			_neighbor_dynamic_data = unpack_elem_dynamic_data(_neighbor_pixel);
			_neighbor_static_data = get_element_static_data(_neighbor_dynamic_data.id);

			if (static_lane_ignored(_neighbor_static_data, LANE_TEMPERATURE)) {
				continue;
			}

			if (_neighbor_dynamic_data.id != ELEM_ID_EMPTY && static_lane_contribute(_neighbor_static_data, LANE_TEMPERATURE)) {
				if (static_lane_locked(_neighbor_static_data, LANE_TEMPERATURE)) {
					_ambient_total += static_lane_idle_value(_neighbor_static_data, LANE_TEMPERATURE);
				} else {
					_ambient_total += lane_effective_value(_neighbor_static_data, LANE_TEMPERATURE, dynamic_temperature_get(_neighbor_dynamic_data));
				}
				_ambient_count += 1.0;
			}
		}
	}

	if (_ambient_count <= 0.0) {
		return 0.0;
	}

	return _ambient_total / _ambient_count;
}

float sample_moisture_ambient_average(ElementDynamicData _current_dynamic_data, ElementStaticData _current_static_data, vec2 _center_texcoord) {
	float _ambient_total = 0.0;
	float _ambient_count = 0.0;
	vec2 _neighbor_texcoord;
	vec4 _neighbor_pixel;
	ElementDynamicData _neighbor_dynamic_data;
	ElementStaticData _neighbor_static_data;

	if (static_lane_ignored(_current_static_data, LANE_MOISTURE)) {
		return 0.0;
	}

	for (int _offset_y = -1; _offset_y <= 1; ++_offset_y) {
		for (int _offset_x = -1; _offset_x <= 1; ++_offset_x) {
			if (_offset_x == 0 && _offset_y == 0) {
				continue;
			}

			_neighbor_texcoord = _center_texcoord + vec2(float(_offset_x) * u_texel_size.x, float(_offset_y) * u_texel_size.y);
			if (!uv_in_bounds(_neighbor_texcoord)) {
				continue;
			}

			_neighbor_pixel = texture2D(gm_BaseTexture, _neighbor_texcoord);
			_neighbor_dynamic_data = unpack_elem_dynamic_data(_neighbor_pixel);
			_neighbor_static_data = get_element_static_data(_neighbor_dynamic_data.id);

			if (static_lane_ignored(_neighbor_static_data, LANE_MOISTURE)) {
				continue;
			}

			if (_neighbor_dynamic_data.id != ELEM_ID_EMPTY && static_lane_contribute(_neighbor_static_data, LANE_MOISTURE)) {
				if (static_lane_locked(_neighbor_static_data, LANE_MOISTURE)) {
					_ambient_total += static_lane_idle_value(_neighbor_static_data, LANE_MOISTURE);
				} else {
					_ambient_total += lane_effective_value(_neighbor_static_data, LANE_MOISTURE, dynamic_moisture_get(_neighbor_dynamic_data));
				}
				_ambient_count += 1.0;
			}
		}
	}

	if (_ambient_count <= 0.0) {
		return 0.0;
	}

	return _ambient_total / _ambient_count;
}

float sample_corrosion_ambient_average(ElementDynamicData _current_dynamic_data, ElementStaticData _current_static_data, vec2 _center_texcoord) {
	float _ambient_total = 0.0;
	float _ambient_count = 0.0;
	vec2 _neighbor_texcoord;
	vec4 _neighbor_pixel;
	ElementDynamicData _neighbor_dynamic_data;
	ElementStaticData _neighbor_static_data;

	if (static_lane_ignored(_current_static_data, LANE_CORROSION)) {
		return 0.0;
	}

	for (int _offset_y = -1; _offset_y <= 1; ++_offset_y) {
		for (int _offset_x = -1; _offset_x <= 1; ++_offset_x) {
			if (_offset_x == 0 && _offset_y == 0) {
				continue;
			}

			_neighbor_texcoord = _center_texcoord + vec2(float(_offset_x) * u_texel_size.x, float(_offset_y) * u_texel_size.y);
			if (!uv_in_bounds(_neighbor_texcoord)) {
				continue;
			}

			_neighbor_pixel = texture2D(gm_BaseTexture, _neighbor_texcoord);
			_neighbor_dynamic_data = unpack_elem_dynamic_data(_neighbor_pixel);
			_neighbor_static_data = get_element_static_data(_neighbor_dynamic_data.id);

			if (static_lane_ignored(_neighbor_static_data, LANE_CORROSION)) {
				continue;
			}

			if (_neighbor_dynamic_data.id != ELEM_ID_EMPTY && static_lane_contribute(_neighbor_static_data, LANE_CORROSION)) {
				if (static_lane_locked(_neighbor_static_data, LANE_CORROSION)) {
					_ambient_total += static_lane_idle_value(_neighbor_static_data, LANE_CORROSION);
				} else {
					_ambient_total += lane_effective_value(_neighbor_static_data, LANE_CORROSION, dynamic_corrosion_get(_neighbor_dynamic_data));
				}
				_ambient_count += 1.0;
			}
		}
	}

	if (_ambient_count <= 0.0) {
		return 0.0;
	}

	return _ambient_total / _ambient_count;
}

float sample_magic_ambient_average(ElementDynamicData _current_dynamic_data, ElementStaticData _current_static_data, vec2 _center_texcoord) {
	float _ambient_total = 0.0;
	float _ambient_count = 0.0;
	vec2 _neighbor_texcoord;
	vec4 _neighbor_pixel;
	ElementDynamicData _neighbor_dynamic_data;
	ElementStaticData _neighbor_static_data;

	if (static_lane_ignored(_current_static_data, LANE_MAGIC)) {
		return 0.0;
	}

	for (int _offset_y = -1; _offset_y <= 1; ++_offset_y) {
		for (int _offset_x = -1; _offset_x <= 1; ++_offset_x) {
			if (_offset_x == 0 && _offset_y == 0) {
				continue;
			}

			_neighbor_texcoord = _center_texcoord + vec2(float(_offset_x) * u_texel_size.x, float(_offset_y) * u_texel_size.y);
			if (!uv_in_bounds(_neighbor_texcoord)) {
				continue;
			}

			_neighbor_pixel = texture2D(gm_BaseTexture, _neighbor_texcoord);
			_neighbor_dynamic_data = unpack_elem_dynamic_data(_neighbor_pixel);
			_neighbor_static_data = get_element_static_data(_neighbor_dynamic_data.id);

			if (static_lane_ignored(_neighbor_static_data, LANE_MAGIC)) {
				continue;
			}

			if (_neighbor_dynamic_data.id != ELEM_ID_EMPTY && static_lane_contribute(_neighbor_static_data, LANE_MAGIC)) {
				if (static_lane_locked(_neighbor_static_data, LANE_MAGIC)) {
					_ambient_total += static_lane_idle_value(_neighbor_static_data, LANE_MAGIC);
				} else {
					_ambient_total += lane_effective_value(_neighbor_static_data, LANE_MAGIC, dynamic_magic_get(_neighbor_dynamic_data));
				}
				_ambient_count += 1.0;
			}
		}
	}

	if (_ambient_count <= 0.0) {
		return 0.0;
	}

	return _ambient_total / _ambient_count;
}

ElementDynamicData apply_temperature_update(ElementDynamicData _elem_dynamic_data, ElementStaticData _elem_static_data, vec2 _seed_texcoord, float _seed_frame) {
	float _transfer_rate;
	int _lane_value;
	float _current_effective_value;
	float _ambient_value;
	int _target_high_id;
	int _target_low_id;
	ElementStaticData _target_high_static_data;
	ElementStaticData _target_low_static_data;
	float _target_high_idle_value;
	float _target_low_idle_value;
	float _step_ratio;
	float _saturated_effective_value;

	if (static_lane_ignored(_elem_static_data, LANE_TEMPERATURE)) {
		return _elem_dynamic_data; //dynamic_temperature_set(_elem_dynamic_data, 0);
	}

	_transfer_rate = static_lane_transfer_rate(_elem_static_data, LANE_TEMPERATURE);
	if (_transfer_rate <= 0.0 || !chance(_transfer_rate, _seed_texcoord, _seed_frame + float(LANE_TEMPERATURE * 37))) {
		return _elem_dynamic_data;
	}

	_lane_value = dynamic_temperature_get(_elem_dynamic_data);
	_current_effective_value = lane_effective_value(_elem_static_data, LANE_TEMPERATURE, _lane_value);
	_ambient_value = sample_temperature_ambient_average(_elem_dynamic_data, _elem_static_data, _seed_texcoord);
	_target_high_id = static_lane_on_high(_elem_static_data, LANE_TEMPERATURE);
	_target_low_id = static_lane_on_low(_elem_static_data, LANE_TEMPERATURE);
	_target_high_static_data = get_element_static_data(_target_high_id);
	_target_low_static_data = get_element_static_data(_target_low_id);
	_target_high_idle_value = static_lane_idle_value(_target_high_static_data, LANE_TEMPERATURE);
	_target_low_idle_value = static_lane_idle_value(_target_low_static_data, LANE_TEMPERATURE);

	if (_ambient_value > _current_effective_value && _target_high_idle_value > _current_effective_value) {
		_step_ratio = clamp((_ambient_value - _current_effective_value) / (_target_high_idle_value - _current_effective_value), 0.0, 1.0);
		if (chance(_step_ratio, _seed_texcoord, _seed_frame + float(101 + (LANE_TEMPERATURE * 41)))) {
			if (_lane_value < 7) {
				_elem_dynamic_data = dynamic_temperature_set(_elem_dynamic_data, _lane_value + 1);
				return _elem_dynamic_data;
			}

			_saturated_effective_value = lane_saturated_effective_value(_elem_static_data, LANE_TEMPERATURE, true);
			if (_ambient_value > _saturated_effective_value && _target_high_id != _elem_dynamic_data.id) {
				_elem_dynamic_data.id = _target_high_id;
				_elem_dynamic_data = dynamic_temperature_set(_elem_dynamic_data, -7);
				_elem_dynamic_data.vel = vec2(0.0);
				return _elem_dynamic_data;
			}
		}
	}

	if (_ambient_value < _current_effective_value && _target_low_idle_value < _current_effective_value) {
		_step_ratio = clamp((_current_effective_value - _ambient_value) / (_current_effective_value - _target_low_idle_value), 0.0, 1.0);
		if (chance(_step_ratio, _seed_texcoord, _seed_frame + float(173 + (LANE_TEMPERATURE * 43)))) {
			if (_lane_value > -7) {
				_elem_dynamic_data = dynamic_temperature_set(_elem_dynamic_data, _lane_value - 1);
				return _elem_dynamic_data;
			}

			_saturated_effective_value = lane_saturated_effective_value(_elem_static_data, LANE_TEMPERATURE, false);
			if (_ambient_value < _saturated_effective_value && _target_low_id != _elem_dynamic_data.id) {
				_elem_dynamic_data.id = _target_low_id;
				_elem_dynamic_data = dynamic_temperature_set(_elem_dynamic_data, 7);
				_elem_dynamic_data.vel = vec2(0.0);
				return _elem_dynamic_data;
			}
		}
	}

	return _elem_dynamic_data;
}

ElementDynamicData apply_moisture_update(ElementDynamicData _elem_dynamic_data, ElementStaticData _elem_static_data, vec2 _seed_texcoord, float _seed_frame) {
	float _transfer_rate;
	int _lane_value;
	float _current_effective_value;
	float _ambient_value;
	int _target_high_id;
	int _target_low_id;
	ElementStaticData _target_high_static_data;
	ElementStaticData _target_low_static_data;
	float _target_high_idle_value;
	float _target_low_idle_value;
	float _step_ratio;
	float _saturated_effective_value;

	if (static_lane_ignored(_elem_static_data, LANE_MOISTURE)) {
		return _elem_dynamic_data; //dynamic_moisture_set(_elem_dynamic_data, 0);
	}

	_transfer_rate = static_lane_transfer_rate(_elem_static_data, LANE_MOISTURE);
	if (_transfer_rate <= 0.0 || !chance(_transfer_rate, _seed_texcoord, _seed_frame + float(LANE_MOISTURE * 37))) {
		return _elem_dynamic_data;
	}

	_lane_value = dynamic_moisture_get(_elem_dynamic_data);
	_current_effective_value = lane_effective_value(_elem_static_data, LANE_MOISTURE, _lane_value);
	_ambient_value = sample_moisture_ambient_average(_elem_dynamic_data, _elem_static_data, _seed_texcoord);
	_target_high_id = static_lane_on_high(_elem_static_data, LANE_MOISTURE);
	_target_low_id = static_lane_on_low(_elem_static_data, LANE_MOISTURE);
	_target_high_static_data = get_element_static_data(_target_high_id);
	_target_low_static_data = get_element_static_data(_target_low_id);
	_target_high_idle_value = static_lane_idle_value(_target_high_static_data, LANE_MOISTURE);
	_target_low_idle_value = static_lane_idle_value(_target_low_static_data, LANE_MOISTURE);

	if (_ambient_value > _current_effective_value && _target_high_idle_value > _current_effective_value) {
		_step_ratio = clamp((_ambient_value - _current_effective_value) / (_target_high_idle_value - _current_effective_value), 0.0, 1.0);
		if (chance(_step_ratio, _seed_texcoord, _seed_frame + float(101 + (LANE_MOISTURE * 41)))) {
			if (_lane_value < 7) {
				_elem_dynamic_data = dynamic_moisture_set(_elem_dynamic_data, _lane_value + 1);
				return _elem_dynamic_data;
			}

			_saturated_effective_value = lane_saturated_effective_value(_elem_static_data, LANE_MOISTURE, true);
			if (_ambient_value > _saturated_effective_value && _target_high_id != _elem_dynamic_data.id) {
				_elem_dynamic_data.id = _target_high_id;
				_elem_dynamic_data = dynamic_moisture_set(_elem_dynamic_data, -7);
				_elem_dynamic_data.vel = vec2(0.0);
				return _elem_dynamic_data;
			}
		}
	}

	if (_ambient_value < _current_effective_value && _target_low_idle_value < _current_effective_value) {
		_step_ratio = clamp((_current_effective_value - _ambient_value) / (_current_effective_value - _target_low_idle_value), 0.0, 1.0);
		if (chance(_step_ratio, _seed_texcoord, _seed_frame + float(173 + (LANE_MOISTURE * 43)))) {
			if (_lane_value > -7) {
				_elem_dynamic_data = dynamic_moisture_set(_elem_dynamic_data, _lane_value - 1);
				return _elem_dynamic_data;
			}

			_saturated_effective_value = lane_saturated_effective_value(_elem_static_data, LANE_MOISTURE, false);
			if (_ambient_value < _saturated_effective_value && _target_low_id != _elem_dynamic_data.id) {
				_elem_dynamic_data.id = _target_low_id;
				_elem_dynamic_data = dynamic_moisture_set(_elem_dynamic_data, 7);
				_elem_dynamic_data.vel = vec2(0.0);
				return _elem_dynamic_data;
			}
		}
	}

	return _elem_dynamic_data;
}

ElementDynamicData apply_corrosion_update(ElementDynamicData _elem_dynamic_data, ElementStaticData _elem_static_data, vec2 _seed_texcoord, float _seed_frame) {
	float _transfer_rate;
	int _lane_value;
	float _current_effective_value;
	float _ambient_value;
	int _target_high_id;
	int _target_low_id;
	ElementStaticData _target_high_static_data;
	ElementStaticData _target_low_static_data;
	float _target_high_idle_value;
	float _target_low_idle_value;
	float _step_ratio;
	float _saturated_effective_value;

	if (static_lane_ignored(_elem_static_data, LANE_CORROSION)) {
		return _elem_dynamic_data; //dynamic_corrosion_set(_elem_dynamic_data, 0);
	}

	_transfer_rate = static_lane_transfer_rate(_elem_static_data, LANE_CORROSION);
	if (_transfer_rate <= 0.0 || !chance(_transfer_rate, _seed_texcoord, _seed_frame + float(LANE_CORROSION * 37))) {
		return _elem_dynamic_data;
	}

	_lane_value = dynamic_corrosion_get(_elem_dynamic_data);
	_current_effective_value = lane_effective_value(_elem_static_data, LANE_CORROSION, _lane_value);
	_ambient_value = sample_corrosion_ambient_average(_elem_dynamic_data, _elem_static_data, _seed_texcoord);
	_target_high_id = static_lane_on_high(_elem_static_data, LANE_CORROSION);
	_target_low_id = static_lane_on_low(_elem_static_data, LANE_CORROSION);
	_target_high_static_data = get_element_static_data(_target_high_id);
	_target_low_static_data = get_element_static_data(_target_low_id);
	_target_high_idle_value = static_lane_idle_value(_target_high_static_data, LANE_CORROSION);
	_target_low_idle_value = static_lane_idle_value(_target_low_static_data, LANE_CORROSION);

	if (_ambient_value > _current_effective_value && _target_high_idle_value > _current_effective_value) {
		_step_ratio = clamp((_ambient_value - _current_effective_value) / (_target_high_idle_value - _current_effective_value), 0.0, 1.0);
		if (chance(_step_ratio, _seed_texcoord, _seed_frame + float(101 + (LANE_CORROSION * 41)))) {
			if (_lane_value < 7) {
				_elem_dynamic_data = dynamic_corrosion_set(_elem_dynamic_data, _lane_value + 1);
				return _elem_dynamic_data;
			}

			_saturated_effective_value = lane_saturated_effective_value(_elem_static_data, LANE_CORROSION, true);
			if (_ambient_value > _saturated_effective_value && _target_high_id != _elem_dynamic_data.id) {
				_elem_dynamic_data.id = _target_high_id;
				_elem_dynamic_data = dynamic_corrosion_set(_elem_dynamic_data, -7);
				_elem_dynamic_data.vel = vec2(0.0);
				return _elem_dynamic_data;
			}
		}
	}

	if (_ambient_value < _current_effective_value && _target_low_idle_value < _current_effective_value) {
		_step_ratio = clamp((_current_effective_value - _ambient_value) / (_current_effective_value - _target_low_idle_value), 0.0, 1.0);
		if (chance(_step_ratio, _seed_texcoord, _seed_frame + float(173 + (LANE_CORROSION * 43)))) {
			if (_lane_value > -7) {
				_elem_dynamic_data = dynamic_corrosion_set(_elem_dynamic_data, _lane_value - 1);
				return _elem_dynamic_data;
			}

			_saturated_effective_value = lane_saturated_effective_value(_elem_static_data, LANE_CORROSION, false);
			if (_ambient_value < _saturated_effective_value && _target_low_id != _elem_dynamic_data.id) {
				_elem_dynamic_data.id = _target_low_id;
				_elem_dynamic_data = dynamic_corrosion_set(_elem_dynamic_data, 7);
				_elem_dynamic_data.vel = vec2(0.0);
				return _elem_dynamic_data;
			}
		}
	}

	return _elem_dynamic_data;
}

ElementDynamicData apply_magic_update(ElementDynamicData _elem_dynamic_data, ElementStaticData _elem_static_data, vec2 _seed_texcoord, float _seed_frame) {
	float _transfer_rate;
	int _lane_value;
	float _current_effective_value;
	float _ambient_value;
	int _target_high_id;
	int _target_low_id;
	ElementStaticData _target_high_static_data;
	ElementStaticData _target_low_static_data;
	float _target_high_idle_value;
	float _target_low_idle_value;
	float _step_ratio;
	float _saturated_effective_value;

	if (static_lane_ignored(_elem_static_data, LANE_MAGIC)) {
		return _elem_dynamic_data; //dynamic_magic_set(_elem_dynamic_data, 0);
	}

	_transfer_rate = static_lane_transfer_rate(_elem_static_data, LANE_MAGIC);
	if (_transfer_rate <= 0.0 || !chance(_transfer_rate, _seed_texcoord, _seed_frame + float(LANE_MAGIC * 37))) {
		return _elem_dynamic_data;
	}

	_lane_value = dynamic_magic_get(_elem_dynamic_data);
	_current_effective_value = lane_effective_value(_elem_static_data, LANE_MAGIC, _lane_value);
	_ambient_value = sample_magic_ambient_average(_elem_dynamic_data, _elem_static_data, _seed_texcoord);
	_target_high_id = static_lane_on_high(_elem_static_data, LANE_MAGIC);
	_target_low_id = static_lane_on_low(_elem_static_data, LANE_MAGIC);
	_target_high_static_data = get_element_static_data(_target_high_id);
	_target_low_static_data = get_element_static_data(_target_low_id);
	_target_high_idle_value = static_lane_idle_value(_target_high_static_data, LANE_MAGIC);
	_target_low_idle_value = static_lane_idle_value(_target_low_static_data, LANE_MAGIC);

	if (_ambient_value > _current_effective_value && _target_high_idle_value > _current_effective_value) {
		_step_ratio = clamp((_ambient_value - _current_effective_value) / (_target_high_idle_value - _current_effective_value), 0.0, 1.0);
		if (chance(_step_ratio, _seed_texcoord, _seed_frame + float(101 + (LANE_MAGIC * 41)))) {
			if (_lane_value < 7) {
				_elem_dynamic_data = dynamic_magic_set(_elem_dynamic_data, _lane_value + 1);
				return _elem_dynamic_data;
			}

			_saturated_effective_value = lane_saturated_effective_value(_elem_static_data, LANE_MAGIC, true);
			if (_ambient_value > _saturated_effective_value && _target_high_id != _elem_dynamic_data.id) {
				_elem_dynamic_data.id = _target_high_id;
				_elem_dynamic_data = dynamic_magic_set(_elem_dynamic_data, -7);
				_elem_dynamic_data.vel = vec2(0.0);
				return _elem_dynamic_data;
			}
		}
	}

	if (_ambient_value < _current_effective_value && _target_low_idle_value < _current_effective_value) {
		_step_ratio = clamp((_current_effective_value - _ambient_value) / (_current_effective_value - _target_low_idle_value), 0.0, 1.0);
		if (chance(_step_ratio, _seed_texcoord, _seed_frame + float(173 + (LANE_MAGIC * 43)))) {
			if (_lane_value > -7) {
				_elem_dynamic_data = dynamic_magic_set(_elem_dynamic_data, _lane_value - 1);
				return _elem_dynamic_data;
			}

			_saturated_effective_value = lane_saturated_effective_value(_elem_static_data, LANE_MAGIC, false);
			if (_ambient_value < _saturated_effective_value && _target_low_id != _elem_dynamic_data.id) {
				_elem_dynamic_data.id = _target_low_id;
				_elem_dynamic_data = dynamic_magic_set(_elem_dynamic_data, 7);
				_elem_dynamic_data.vel = vec2(0.0);
				return _elem_dynamic_data;
			}
		}
	}

	return _elem_dynamic_data;
}

ElementDynamicData apply_generic_dynamic_update(ElementDynamicData _elem_dynamic_data, ElementStaticData _elem_static_data, vec2 _seed_texcoord, float _seed_frame) {
	if (_elem_dynamic_data.id == ELEM_ID_EMPTY) {
		_elem_dynamic_data.vel = vec2(0.0);
		_elem_dynamic_data = dynamic_temperature_set(_elem_dynamic_data, 0);
		_elem_dynamic_data = dynamic_moisture_set(_elem_dynamic_data, 0);
		_elem_dynamic_data = dynamic_corrosion_set(_elem_dynamic_data, 0);
		_elem_dynamic_data = dynamic_magic_set(_elem_dynamic_data, 0);
		return _elem_dynamic_data;
	}

	#if RESOLVE_ENABLE_GENERIC_DYNAMIC_UPDATE

		#if RESOLVE_ENABLE_LANE_TEMPERATURE
		_elem_dynamic_data = apply_temperature_update(_elem_dynamic_data, _elem_static_data, _seed_texcoord, _seed_frame + 5.0);
		_elem_static_data = get_element_static_data(_elem_dynamic_data.id);
		#endif

		#if RESOLVE_ENABLE_LANE_MOISTURE
		_elem_dynamic_data = apply_moisture_update(_elem_dynamic_data, _elem_static_data, _seed_texcoord, _seed_frame + 11.0);
		_elem_static_data = get_element_static_data(_elem_dynamic_data.id);
		#endif

		#if RESOLVE_ENABLE_LANE_CORROSION
		_elem_dynamic_data = apply_corrosion_update(_elem_dynamic_data, _elem_static_data, _seed_texcoord, _seed_frame + 17.0);
		_elem_static_data = get_element_static_data(_elem_dynamic_data.id);
		#endif

		#if RESOLVE_ENABLE_LANE_MAGIC
		_elem_dynamic_data = apply_magic_update(_elem_dynamic_data, _elem_static_data, _seed_texcoord, _seed_frame + 23.0);
		_elem_static_data = get_element_static_data(_elem_dynamic_data.id);
		#endif

	#endif

	return _elem_dynamic_data;
}

void main() {
	vec2 _swap_offset = rg_to_vel(texture2D(gm_TertiaryTexture, v_vTexcoord).rg);
	vec4 _current_pixel = texture2D(gm_BaseTexture, v_vTexcoord);
	ElementDynamicData _current_dynamic_data = unpack_elem_dynamic_data(_current_pixel);
	ElementStaticData _current_static_data = get_element_static_data(_current_dynamic_data.id);
	ElementDynamicData _output_dynamic_data = _current_dynamic_data;
	ElementStaticData _output_static_data = _current_static_data;

	if (_swap_offset.x != 0.0 || _swap_offset.y != 0.0) {
		vec2 _other_texcoord = v_vTexcoord + (_swap_offset * u_texel_size);
		vec4 _other_pixel = texture2D(gm_BaseTexture, _other_texcoord);
		vec2 _other_intent = rg_to_vel(texture2D(gm_SecondaryTexture, _other_texcoord).rg);
		ElementDynamicData _other_dynamic_data = unpack_elem_dynamic_data(_other_pixel);
		ElementStaticData _other_static_data = get_element_static_data(_other_dynamic_data.id);
		vec2 _resolved_velocity;

		_output_dynamic_data = _other_dynamic_data;
		_output_static_data = _other_static_data;

		_resolved_velocity = sanitize_velocity_to_static(_other_intent, _output_static_data);
		_output_dynamic_data.vel = _resolved_velocity;
	} else {
		_output_dynamic_data.vel = vec2(0.0);
	}

	_output_dynamic_data = apply_generic_dynamic_update(_output_dynamic_data, _output_static_data, v_vTexcoord, u_frame);
	_output_static_data = get_element_static_data(_output_dynamic_data.id);
	_output_dynamic_data.vel = sanitize_velocity_to_static(_output_dynamic_data.vel, _output_static_data);

	#if DEBUG_RESOLVE_VISUALIZE
	if (_swap_offset.x != 0.0 || _swap_offset.y != 0.0) {
		gl_FragColor = vec4(1.0, 0.84, 0.0, 1.0);
		return;
	}
	#endif

	gl_FragColor = pack_elem_dynamic_data(_output_dynamic_data, _output_static_data);
}
