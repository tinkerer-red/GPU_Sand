#pragma shady: import(shdSandSimCommon)
#pragma shady: inline(shdSandSimCommon.Uniforms)

varying vec2 v_vTexcoord;
uniform float u_frame;

void main() {
	ElementDynamicData elem_dynamic_data;
	
	elem_dynamic_data.id = ELEM_ID_SAND;
	elem_dynamic_data.static_data = get_element_static_data(elem_dynamic_data.id);
	elem_dynamic_data.vel = vec2(-1.0, 2.0);
	elem_dynamic_data.x_dir = 0;
	elem_dynamic_data.y_dir = 0;
	elem_dynamic_data.x_speed = 0;
	elem_dynamic_data.y_speed = 0;
	elem_dynamic_data.custom_data = 173;
	
	vec4 pixel = pack_elem_dynamic_data(elem_dynamic_data);
	ElementDynamicData unpacked = ununpack_elem_dynamic_data(pixel);
	
	bool matches_id = unpacked.id == elem_dynamic_data.id;
	bool matches_custom_data = unpacked.custom_data == elem_dynamic_data.custom_data;
	bool matches_x_dir = unpacked.x_dir == 1;
	bool matches_y_dir = unpacked.y_dir == 0;
	bool matches_x_speed = unpacked.x_speed == 4;
	bool matches_y_speed = unpacked.y_speed == 7;
	
	if (matches_id && matches_custom_data && matches_x_dir && matches_y_dir && matches_x_speed && matches_y_speed) {
		gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
	} else {
		gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
	}
}