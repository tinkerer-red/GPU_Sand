#pragma shady: import(shdSandSimCommon)

#define DEBUG_RESOLVE_VISUALIZE 0
#define OFFSET_RADIUS 3

varying vec2 v_vTexcoord;
uniform vec2 u_texel_size;
uniform float u_frame;

uniform sampler2D gm_SecondaryTexture;  // surf_velocity (desired velocity of a cell)
uniform sampler2D gm_TertiaryTexture;   // surf_valid_pre (offsets)

void main() {
	vec2 offset_rg = texture2D(gm_TertiaryTexture, v_vTexcoord).rg;
	vec2 offset = rg_to_vel(offset_rg);
	
	vec4 pixel = texture2D(gm_BaseTexture, v_vTexcoord);
	
	ElementDynamicData elem_dynamic_data = ununpack_elem_dynamic_data(pixel);
	
	if (offset.x != 0.0 || offset.y != 0.0) {
		// swap pixel: where we moved *from*
		vec2 swap_uv = v_vTexcoord + vec2(offset) * u_texel_size;
		vec4 swap_pixel = texture2D(gm_BaseTexture, swap_uv);
		
		ElementDynamicData swap_elem_dynamic_data = ununpack_elem_dynamic_data(swap_pixel);
		
		vec2 old_vel = swap_elem_dynamic_data.vel;
		
		vec2 vel_rg = texture2D(gm_SecondaryTexture, swap_uv).rg;
		vec2 new_vel = rg_to_vel(vel_rg);
		
		// === RANDOMIZED ROUNDING ===
		vec2 average = (vec2(old_vel) + vec2(new_vel)) * 0.5;
		new_vel = rand_round_vel(average, v_vTexcoord, u_frame + 1.0);
		
		// Clamp to allowed max
		new_vel.x = clamp(new_vel.x, -swap_elem_dynamic_data.static_data.max_vel_x, swap_elem_dynamic_data.static_data.max_vel_x);
		new_vel.y = clamp(new_vel.y, -swap_elem_dynamic_data.static_data.max_vel_y, swap_elem_dynamic_data.static_data.max_vel_y);
		
		// Update velocity state
		swap_elem_dynamic_data.vel = new_vel;
		
		gl_FragColor = pack_elem_dynamic_data(swap_elem_dynamic_data);
		
		#if DEBUG_RESOLVE_VISUALIZE
			// Optional visual debug color
			gl_FragColor = vec4(1.0, 0.84, 0.0, 1.0);
		#endif
		
	} else {
		elem_dynamic_data.vel = vec2(0.0);
		
		if (elem_dynamic_data.id == ELEM_ID_EMPTY) {
			elem_dynamic_data.custom_data = 0;
		}
		
		gl_FragColor = pack_elem_dynamic_data(elem_dynamic_data);
	}
}