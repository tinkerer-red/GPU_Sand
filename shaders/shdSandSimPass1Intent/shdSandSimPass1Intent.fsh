#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel_size;
uniform float u_frame;


void main() {
    vec4 self_pixel = texture2D(gm_BaseTexture, v_vTexcoord);
    ElementDynamicData elem_dynamic_data = ununpack_elem_dynamic_data(self_pixel);
	ElementStaticData elem_static_data = get_element_static_data(elem_dynamic_data.id);
	
    //Use a while loop just so we can break out when we find a match and skip everything else
	while(true){
		#pragma shady: inline(ElemSand.INTENT)
		
		break;
	}
	
	
    
	// Default to no movement
	gl_FragColor = vec4(vel_to_rg(elem_dynamic_data.vel), 0.0, 1.0);
}
