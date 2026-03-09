#pragma shady: import(shdSandSimCommon)
#pragma shady: inline(shdSandSimCommon.Uniforms)

#define OFFSET_RADIUS 3

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
		#pragma shady: inline(ElemDev.INTENT)
		
		break;
	}
	
	while (true) {
		bool intent_found = false;
		
		// === Cached Static Values ===
		float gravity_force = elem_static_data.gravity_force;
		float max_vel_x = elem_static_data.max_vel_x;
		float max_vel_y = elem_static_data.max_vel_y;
		
		bool can_slip = elem_static_data.can_slip;
		float x_slip_search_range = elem_static_data.x_slip_search_range;
		float y_slip_search_range = elem_static_data.y_slip_search_range;
		
		float stickiness_chance = elem_static_data.stickiness_chance;
		
		float bounce_chance = elem_static_data.bounce_chance;
		float bounce_dampening_multiplier = elem_static_data.bounce_dampening_multiplier;
		
		float airborne_vel_decay_chance = elem_static_data.airborne_vel_decay_chance;
		float friction_vel_decay_chance = elem_static_data.friction_vel_decay_chance;
		
		// === Step 1: Apply Gravity ===
		elem_dynamic_data.vel.y += gravity_force;
		
		// === Step 2: Clamp velocity ===
		elem_dynamic_data.vel.x = clamp(elem_dynamic_data.vel.x, -max_vel_x, max_vel_x);
		elem_dynamic_data.vel.y = clamp(elem_dynamic_data.vel.y, -max_vel_y, max_vel_y);
		
		if (elem_dynamic_data.vel != vec2(0.0)) {
			// Determine grounded state
			bool is_grounded = false;
			int sign_x = sign_int(int(sign(elem_dynamic_data.vel.x)));
			int sign_y = sign_int(int(sign(elem_dynamic_data.vel.y)));
			
			vec2 check_dir_0 = vec2(0.0, float(sign_y));
			vec2 check_dir_1 = vec2(float(sign_x), 0.0);
			vec2 check_dir_2 = vec2(float(sign_x), float(sign_y));
			
			vec2 test_uv_0 = v_vTexcoord + check_dir_0 * u_texel_size;
			vec2 test_uv_1 = v_vTexcoord + check_dir_1 * u_texel_size;
			vec2 test_uv_2 = v_vTexcoord + check_dir_2 * u_texel_size;
			
			vec4 test_px_0 = texture2D(gm_BaseTexture, test_uv_0);
			vec4 test_px_1 = texture2D(gm_BaseTexture, test_uv_1);
			vec4 test_px_2 = texture2D(gm_BaseTexture, test_uv_2);
			
			if (cell_is_solid(test_px_0)) {
				ElementDynamicData test_meta = ununpack_elem_dynamic_data(test_px_0);
				if (!elem_has_motion(test_meta)) {
					is_grounded = true;
				}
			}
			
			if (!is_grounded && cell_is_solid(test_px_1)) {
				ElementDynamicData test_meta = ununpack_elem_dynamic_data(test_px_1);
				if (!elem_has_motion(test_meta)) {
					is_grounded = true;
				}
			}
			
			if (!is_grounded && cell_is_solid(test_px_2)) {
				ElementDynamicData test_meta = ununpack_elem_dynamic_data(test_px_2);
				if (!elem_has_motion(test_meta)) {
					is_grounded = true;
				}
			}
			
			float decay_chance = is_grounded ? friction_vel_decay_chance : airborne_vel_decay_chance;
			
			// === Chance-based velocity decay ===
			if (abs(elem_dynamic_data.vel.x) >= 1.0) {
				if (chance(decay_chance, v_vTexcoord, u_frame + 17.0)) {
					elem_dynamic_data.vel.x -= sign(elem_dynamic_data.vel.x);
				}
			}
			
			if (abs(elem_dynamic_data.vel.y) >= 1.0) {
				if (chance(decay_chance, v_vTexcoord, u_frame + 18.0)) {
					elem_dynamic_data.vel.y -= sign(elem_dynamic_data.vel.y);
				}
			}
		}
		
		// === Step 3: Attempt to move via velocity ===
		if (elem_dynamic_data.vel != vec2(0.0)) {
			vec2 vel_uv = v_vTexcoord + vec2(elem_dynamic_data.vel) * u_texel_size;
			vec4 vel_px = texture2D(gm_BaseTexture, vel_uv);
			int vel_id = elem_get_index(vel_px);
			ElementStaticData vel_static_data = get_element_static_data(vel_id);
			
			if (vel_id == 0 || element_can_replace(elem_static_data, vel_static_data)) {
				intent_found = true;
				break;
			}
			
			// === Bounce Logic ===
			if (chance(bounce_chance, v_vTexcoord, u_frame + 1.0)) {
				vec2 slope = vec2(0.0);
				
				for (int ox = -OFFSET_RADIUS; ox <= OFFSET_RADIUS; ++ox) {
					for (int oy = -OFFSET_RADIUS; oy <= OFFSET_RADIUS; ++oy) {
						if (ox == 0 && oy == 0) continue;
						
						vec2 offset = vec2(float(ox), float(oy));
						vec2 sample_uv = v_vTexcoord + offset * u_texel_size;
						vec4 sample_px = texture2D(gm_BaseTexture, sample_uv);
						
						if (cell_is_solid(sample_px)) {
							slope -= offset;
						}
					}
				}
				
				if (length(slope) > 0.0) {
					vec2 reflected = elem_dynamic_data.vel - 2.0 * dot(elem_dynamic_data.vel, slope) * slope;
					
					// Preserve magnitude but apply dampening
					float orig_len = length(elem_dynamic_data.vel);
					reflected = normalize(reflected) * (orig_len * bounce_dampening_multiplier);
					
					vec2 bounce_uv = v_vTexcoord + reflected * u_texel_size;
					vec4 bounce_px = texture2D(gm_BaseTexture, bounce_uv);
					int bounce_id = elem_get_index(bounce_px);
					ElementStaticData bounce_static_data = get_element_static_data(bounce_id);
					
					if (bounce_id == 0 || element_can_replace(elem_static_data, bounce_static_data)) {
						elem_dynamic_data.vel = reflected;
						intent_found = true;
						break;
					}
				}
			}
		}
		
		// === Step 4: Fallback downward search (gravity direction only) ===
		int y_dir = gravity_force >= 0.0 ? 1 : -1;
		for (int dy = y_dir; abs_int(dy) <= int(y_slip_search_range); dy += y_dir) {
			vec2 test_uv = v_vTexcoord + vec2(0.0, float(dy)) * u_texel_size;
			vec4 test_px = texture2D(gm_BaseTexture, test_uv);
			int test_id = elem_get_index(test_px);
			ElementStaticData test_static = get_element_static_data(test_id);
			
			if (test_id == 0 || element_can_replace(elem_static_data, test_static)) {
				elem_dynamic_data.vel = vec2(0.0, float(dy));
				intent_found = true;
				break;
			}
		}
		
		if (intent_found) break;
		
		// === Step 5: Fallback diagonal slip ===
		if (can_slip) {
			int dx = (rand(v_vTexcoord, u_frame + 1.0) < 0.5) ? -1 : 1;
			int slip_y_dir = (gravity_force >= 0.0) ? 1 : -1;
			
			for (int sx = 1; sx <= int(x_slip_search_range); ++sx) {
				vec2 diag_offset = vec2(float(sx * dx), float(slip_y_dir));
				vec2 diag_uv = v_vTexcoord + diag_offset * u_texel_size;
				vec4 diag_px = texture2D(gm_BaseTexture, diag_uv);
				int diag_id = elem_get_index(diag_px);
				ElementStaticData diag_static = get_element_static_data(diag_id);
				
				if (diag_id == 0 || element_can_replace(elem_static_data, diag_static)) {
					elem_dynamic_data.vel = diag_offset;
					intent_found = true;
					break;
				}
			}
			
			if (intent_found) {
				break;
			}
		}
		
		if (!intent_found) {
			//cant move
			elem_dynamic_data.vel = vec2(0.0);
		}
		
		break;
	}
	
	gl_FragColor = vec4(vel_to_rg(elem_dynamic_data.vel), 0.0, 1.0);
}