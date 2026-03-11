#pragma shady: inline(shdSandSimCommon.Uniforms)
#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel_size;
uniform sampler2D gm_SecondaryTexture;

float compute_claim_score(ElementStaticData _source_static_data, vec2 _offset) {
	float _score = dot(_offset, _offset);

	if (_source_static_data.gravity_force > 0.0 && _offset.y > 0.0) {
		_score -= 0.25;
	}
	if (_source_static_data.gravity_force < 0.0 && _offset.y < 0.0) {
		_score -= 0.25;
	}
	if (_offset.x == 0.0) {
		_score -= 0.05;
	}

	return _score;
}

void main() {
	vec4 _self_pixel = texture2D(gm_BaseTexture, v_vTexcoord);
	ElementStaticData _target_static_data = get_element_static_data(element_id_from_pixel(_self_pixel));
	float _best_score = 99999.0;
	vec2 _best_offset = vec2(0.0);

	for (int _offset_y = -SIM_MAX_MOVE_RADIUS; _offset_y <= SIM_MAX_MOVE_RADIUS; ++_offset_y) {
		for (int _offset_x = -SIM_MAX_MOVE_RADIUS; _offset_x <= SIM_MAX_MOVE_RADIUS; ++_offset_x) {
			vec2 _source_offset;
			vec2 _source_texcoord;
			vec4 _intent_pixel;
			vec2 _intent_offset;
			vec4 _source_pixel;
			ElementStaticData _source_static_data;
			float _claim_score;

			if (_offset_x == 0 && _offset_y == 0) {
				continue;
			}

			_source_offset = vec2(float(_offset_x), float(_offset_y));
			_source_texcoord = v_vTexcoord + (_source_offset * u_texel_size);

			if (!uv_in_bounds(_source_texcoord)) {
				continue;
			}

			_intent_pixel = texture2D(gm_SecondaryTexture, _source_texcoord);
			_intent_offset = rg_to_vel(_intent_pixel.rg);

			if (_intent_offset.x == 0.0 && _intent_offset.y == 0.0) {
				continue;
			}

			if (_intent_offset.x != -_source_offset.x || _intent_offset.y != -_source_offset.y) {
				continue;
			}

			_source_pixel = texture2D(gm_BaseTexture, _source_texcoord);
			_source_static_data = get_element_static_data(element_id_from_pixel(_source_pixel));

			if (!element_can_enter(_source_static_data, _target_static_data, element_id_from_pixel(_self_pixel))) {
				continue;
			}

			_claim_score = compute_claim_score(_source_static_data, _source_offset);
			if (_claim_score < _best_score) {
				_best_score = _claim_score;
				_best_offset = _source_offset;
			}
		}
	}

	gl_FragColor = vec4(vel_to_rg(_best_offset), 0.0, 1.0);
}
