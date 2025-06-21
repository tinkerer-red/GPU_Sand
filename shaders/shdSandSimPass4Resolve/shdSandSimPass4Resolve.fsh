#pragma shady: import(shdSandSimCommon)

#define DEBUG_RESOLVE_VISUALIZE 0

varying vec2 v_vTexcoord;
uniform vec2 u_texel_size;
uniform float u_frame;

uniform sampler2D gm_SecondaryTexture;  // surf_velocity (desired velocity of a cell)
uniform sampler2D gm_TertiaryTexture;  // surf_valid_pre (offsets)

void main() {
    vec2 offset_rg = texture2D(gm_TertiaryTexture, v_vTexcoord).rg;
    ivec2 offset = rg_to_vel(offset_rg);

    vec4 pixel = texture2D(gm_BaseTexture, v_vTexcoord);

    ElementDynamicData elem_dynamic_data = ununpack_elem_dynamic_data(pixel);

    if (offset.x != 0 || offset.y != 0) {
        // swap pixel: where we moved *from*
        vec2 swap_uv = v_vTexcoord + vec2(offset) * u_texel_size;
        vec4 swap_pixel = texture2D(gm_BaseTexture, swap_uv);

        ElementDynamicData swap_elem_dynamic_data = ununpack_elem_dynamic_data(swap_pixel);

        ivec2 old_vel = swap_elem_dynamic_data.vel;
        
		vec2 vel_rg = texture2D(gm_SecondaryTexture, swap_uv).rg;
		ivec2 new_vel = rg_to_vel(vel_rg);
		

        // Case 1: stationary → adopt move vector
        if (old_vel == ivec2(0)) {
            //new_vel = offset;
        } else {
            // Case 2: average motion (clean rounding for now)
            vec2 average = (vec2(old_vel) + vec2(new_vel)) * 0.5;
            new_vel = ivec2(round(average.x), round(average.y));
		
            // === RANDOMIZED ROUNDING DISABLED ===
             float rand_seed = rand(v_vTexcoord, u_frame);
             float ax = abs_float(fract(average.x));
             float ay = abs_float(fract(average.y));
             new_vel.x = int(floor(average.x + ((rand_seed < ax) ? 1.0 : 0.0)));
             rand_seed = rand(v_vTexcoord + 0.123, u_frame);
             new_vel.y = int(floor(average.y + ((rand_seed < ay) ? 1.0 : 0.0)));
        }

        // Clamp to allowed max
        new_vel.x = clamp(new_vel.x, -3, 3);
        new_vel.y = clamp(new_vel.y, -3, 3);

        // Update velocity bits in elem_dynamic_data
        swap_elem_dynamic_data.vel     = new_vel;
        swap_elem_dynamic_data.y_dir   = (new_vel.y > 0) ? 1 : 0;
        swap_elem_dynamic_data.y_speed = clamp(abs_int(new_vel.y), 0, 3);
		swap_elem_dynamic_data.x_dir   = (new_vel.x > 0) ? 1 : 0;
        swap_elem_dynamic_data.x_speed = clamp(abs_int(new_vel.x), 0, 3);
        
        
        gl_FragColor = pack_elem_dynamic_data(swap_elem_dynamic_data);
		
		#if DEBUG_RESOLVE_VISUALIZE
            // Optional visual debug color
            gl_FragColor = vec4(1.0, 0.84, 0.0, 1.0);
        #endif
		
    } else {
        // No motion — just return ourself
        gl_FragColor = pack_elem_dynamic_data(elem_dynamic_data);
    }
}
