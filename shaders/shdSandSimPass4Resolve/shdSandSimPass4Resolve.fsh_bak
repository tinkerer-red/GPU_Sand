#pragma shady: inline(shdSandSimCommon.Uniforms)
#pragma shady: import(shdSandSimCommon)

#define DEBUG_RESOLVE_VISUALIZE 0

varying vec2 v_vTexcoord;

uniform vec2 u_texel_size;
uniform float u_frame;

uniform sampler2D gm_SecondaryTexture;
uniform sampler2D gm_TertiaryTexture;

ElementDynamicData apply_generic_dynamic_update(ElementDynamicData _elem_dynamic_data, ElementStaticData _elem_static_data, vec2 _seed_texcoord, float _seed_frame) {
	if (_elem_dynamic_data.id == ELEM_ID_EMPTY) {
		_elem_dynamic_data.dynamic_byte = 0;
		_elem_dynamic_data.vel = vec2(0.0);
		return _elem_dynamic_data;
	}

	if (_elem_static_data.dynamic_mode == DYNAMIC_MODE_LIFETIME && feature_enabled(_elem_static_data.feature_flags, FEATURE_USES_LIFETIME)) {
		if (_elem_static_data.lifetime_max > 0.0 && chance(_elem_static_data.lifetime_decay_chance, _seed_texcoord, _seed_frame + 5.0)) {
			_elem_dynamic_data.dynamic_byte = clamp(_elem_dynamic_data.dynamic_byte + 1, 0, 255);

			if (float(_elem_dynamic_data.dynamic_byte) >= _elem_static_data.lifetime_max) {
				_elem_dynamic_data.id = _elem_static_data.transition_on_life_end;
				_elem_dynamic_data.dynamic_byte = 0;
				_elem_dynamic_data.vel = vec2(0.0);
			}
		}
	}

	if (_elem_dynamic_data.id != ELEM_ID_EMPTY) {
		_elem_static_data = get_element_static_data(_elem_dynamic_data.id);
	}

	if (_elem_static_data.dynamic_mode == DYNAMIC_MODE_TEMPERATURE && feature_enabled(_elem_static_data.feature_flags, FEATURE_USES_TEMPERATURE)) {
		int _signed_temperature = signed_byte_to_int(_elem_dynamic_data.dynamic_byte);

		if (_signed_temperature > 0 && chance(_elem_static_data.temperature_decay, _seed_texcoord, _seed_frame + 9.0)) {
			_signed_temperature -= 1;
		} else if (_signed_temperature < 0 && chance(_elem_static_data.temperature_decay, _seed_texcoord, _seed_frame + 9.0)) {
			_signed_temperature += 1;
		}

		if (feature_enabled(_elem_static_data.feature_flags, FEATURE_PHASE_CHANGES)) {
			if (float(_signed_temperature) <= _elem_static_data.temperature_min) {
				_elem_dynamic_data.id = _elem_static_data.transition_on_temp_low;
				_elem_dynamic_data.dynamic_byte = 0;
				_elem_dynamic_data.vel = vec2(0.0);
				return _elem_dynamic_data;
			}

			if (float(_signed_temperature) >= _elem_static_data.temperature_max) {
				_elem_dynamic_data.id = _elem_static_data.transition_on_temp_high;
				_elem_dynamic_data.dynamic_byte = 0;
				_elem_dynamic_data.vel = vec2(0.0);
				return _elem_dynamic_data;
			}
		}

		_elem_dynamic_data.dynamic_byte = int_to_signed_byte(float(_signed_temperature));
	}

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
