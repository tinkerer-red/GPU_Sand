#pragma shady: inline(shdSandSimCommon.Uniforms)
#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 _element_pixel = texture2D(gm_BaseTexture, v_vTexcoord);
	ElementStaticData _elem_static_data = get_element_static_data(element_id_from_pixel(_element_pixel));

	if (_elem_static_data.id == ELEM_ID_EMPTY) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
		return;
	}

	gl_FragColor = vec4(color_to_vec3(_elem_static_data.base_color), 1.0);
}
