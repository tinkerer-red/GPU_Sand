// shdSandSimPass4Render
#pragma shady: import(shdSandSimCommon)
#pragma shady: inline(shdSandSimCommon.Uniforms)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 element_px = texture2D(gm_BaseTexture, v_vTexcoord);
	int id = elem_get_index(element_px);
	
	vec3 color = vec3(0.0);
	
	if (id == ELEM_ID_SAND) { // Sand
		color = vec3(0.95, 0.85, 0.2); // yellowish sand
	}
	
	if (id == ELEM_ID_DEV) {
		color = vec3(
			mod(floor(u_dev_color / 65536.0), 256.0) / 255.0,
			mod(floor(u_dev_color / 256.0), 256.0) / 255.0,
			mod(u_dev_color, 256.0) / 255.0
		);
	}
	
	gl_FragColor = vec4(color, 1.0);
}