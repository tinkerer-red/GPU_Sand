#pragma shady: inline(shdSandSimCommon.Uniforms)
#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 _pixel = texture2D(gm_BaseTexture, v_vTexcoord);
	ElementDynamicData _elem_dynamic_data = unpack_elem_dynamic_data(_pixel);
	int _lane_value = dynamic_corrosion_get(_elem_dynamic_data);
	float _strength = float(abs_int(_lane_value)) / 7.0;
	vec3 _lane_color = vec3(0.0);

	if (_lane_value == 0) {
		gl_FragColor = vec4(0.0);
		return;
	}

	if (_lane_value > 0) {
		_lane_color = vec3(0.70, 1.0, 0.15);
	} else {
		_lane_color = vec3(0.00, 0.55, 0.45);
	}

	gl_FragColor = vec4(_lane_color * _strength, _strength);
}