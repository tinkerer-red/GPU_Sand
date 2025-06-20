void main()
{
    
	//this is only here to prevent errors
	#ifdef EXCLUDE
	
	#region INTENT
	#pragma shady: macro_begin INTENT
    // Only continue if we're sand
    if (metadata.id == Elem_Sand) {
        // === 1. Check straight down
        vec2 down_uv = v_vTexcoord + vec2(0.0, u_texel_size.y);
        vec4 down_px = texture2D(gm_BaseTexture, down_uv);
        int down_id = elem_get_index(down_px);
		
        if (down_id == 0) {
            metadata.vel = ivec2(0, 1);
        } else {
            // === 2. Choose diagonal fallback
            float bias = rand(v_vTexcoord, u_frame);
            int dx = (bias < 0.5) ? -1 : 1;
			
            vec2 diag1_uv = v_vTexcoord + vec2(float(dx), 1.0) * u_texel_size;
            vec4 diag1_px = texture2D(gm_BaseTexture, diag1_uv);
            int diag1_id = elem_get_index(diag1_px);
			
            if (diag1_id == 0) {
                metadata.vel = ivec2(dx, 1);
            } else {
                dx = -dx;
                vec2 diag2_uv = v_vTexcoord + vec2(float(dx), 1.0) * u_texel_size;
                vec4 diag2_px = texture2D(gm_BaseTexture, diag2_uv);
                int diag2_id = elem_get_index(diag2_px);

                if (diag2_id == 0) {
                    metadata.vel = ivec2(dx, 1);
                }
            }
        }
		break;
    }
	#pragma shady: macro_end
	#endregion
	
	#region ACCEPT
	#pragma shady: macro_begin ACCEPT
	if (metadata.id == Elem_Sand) {
		
		//currently sand doesnt accept anything else
		accepted = false;
		
		break;
	}
	#pragma shady: macro_end
	#endregion
	
	#endif
}
