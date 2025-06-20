void main()
{
    
	//this is only here to prevent errors
	#ifdef EXCLUDE
	
#region INTENT
#pragma shady: macro_begin INTENT
if (metadata.id == Elem_Sand) {
    // 1. Try to reuse falling motion
    if (metadata.vel.x > 0 || metadata.vel.y > 0) {
		// Air resistance for horz velocity
		if (abs_int(metadata.vel.x) == 3) {
		    if (rand(v_vTexcoord + vec2(1.234, 4.567), u_frame) < 0.2) {
		        int x_dir = (metadata.vel.x >= 0) ? 1 : -1;
		        metadata.vel.x = 2 * x_dir;
		        metadata.x_speed = 2;
		        metadata.x_dir = (x_dir > 0) ? 1 : 0;
		    }
		}

		
        vec2 fall_uv = v_vTexcoord + vec2(metadata.vel) * u_texel_size;
        vec4 fall_px = texture2D(gm_BaseTexture, fall_uv);
        int fall_id = elem_get_index(fall_px);

        if (fall_id == 0) {
            // Random chance to increase speed (simulate gravity)
            if (chance(0.1, v_vTexcoord, u_frame)) {
                metadata.vel.y = clamp(metadata.vel.y + 1, 0, 3);
            }
            break;
        }
    }
	
    // 2. Fallback classic sand behavior
    vec2 down_uv = v_vTexcoord + vec2(0.0, u_texel_size.y);
    vec4 down_px = texture2D(gm_BaseTexture, down_uv);
    int down_id = elem_get_index(down_px);

    if (down_id == 0) {
        metadata.vel = ivec2(0, 1);
    } else {
        // Diagonal fallback
        int dx = (rand(v_vTexcoord, u_frame) < 0.5) ? -1 : 1;

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
