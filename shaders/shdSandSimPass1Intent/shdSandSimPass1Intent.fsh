#pragma shady: import(shdSandSimCommon)

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
		
		break;
	}
	/*
	while (true) {
		bool intent_found = false;
		
	    // === Cache frequently used constants ===
	    float gravity_force                 = elem_static_data.gravity_force;
	    float max_vel_x                     = elem_static_data.max_vel_x;
	    float max_vel_y                     = elem_static_data.max_vel_y;
	
		bool can_slip                       = elem_static_data.can_slip;
		float x_slip_search_range           = elem_static_data.x_slip_search_range;
	    float y_slip_search_range           = elem_static_data.y_slip_search_range;
	
		float stickiness_chance             = elem_static_data.stickiness_chance;
		
		float bounce_chance                 = elem_static_data.bounce_chance;
		float bounce_dampening_multiplier   = elem_static_data.bounce_dampening_multiplier;
		
		float airborne_vel_decay_chance     = elem_static_data.airborne_vel_decay_chance;
		float friction_vel_decay_chance     = elem_static_data.friction_vel_decay_chance;
	
		// === Step 0: Sleep check & neighbor wake logic ===
		bool was_moving = elem_dynamic_data.is_moving;
		elem_dynamic_data.is_moving = false;

		if (!was_moving) {
			float wake_chance = elem_static_data.wake_chance;
			bool woke_up = false;

			for (int dx = -2; dx <= 2; ++dx) {
			    for (int dy = -2; dy <= 2; ++dy) {
			        if (dx == 0 && dy == 0) continue;

			        vec2 offset = vec2(float(dx), float(dy));
			        vec2 neighbor_uv = v_vTexcoord + offset * u_texel_size;
			        vec4 neighbor_px = texture2D(gm_BaseTexture, neighbor_uv);
			        int neighbor_id = elem_get_index(neighbor_px);

			        if (neighbor_id != 0) {
			            ElementDynamicData neighbor_meta = ununpack_elem_dynamic_data(neighbor_px);

			            if (neighbor_meta.is_moving) {
			                if (chance(wake_chance, v_vTexcoord + neighbor_uv, u_frame)) {
								woke_up = true;
			                    break;
			                }
			            }
			        }
			    }
			    if (woke_up) break;
			}

			if (!woke_up) {
			    break; // Stay asleep this frame
			}
		}

	    // === Step 1: Apply Gravity ===
	    elem_dynamic_data.vel.y += gravity_force;

	    // === Step 2: Clamp velocity ===
	    elem_dynamic_data.vel.x = clamp(elem_dynamic_data.vel.x, -max_vel_x, max_vel_x);
	    elem_dynamic_data.vel.y = clamp(elem_dynamic_data.vel.y, -max_vel_y, max_vel_y);
		
		if (elem_dynamic_data.vel != vec2(0.0)) {
			// Determine grounded state (same logic as before)
			bool is_grounded = false;
			ivec2 check_dirs[3];
			int sign_x = int(sign(elem_dynamic_data.vel.x));
			int sign_y = int(sign(elem_dynamic_data.vel.y));
    
			check_dirs[0] = ivec2(0, sign_y);              // Vertical
			check_dirs[1] = ivec2(sign_x, 0);              // Horizontal
			check_dirs[2] = ivec2(sign_x, sign_y);         // Diagonal
    
			for (int i = 0; i < 3; ++i) {
				vec2 dir = vec2(check_dirs[i]);
				vec2 test_uv = v_vTexcoord + dir * u_texel_size;
				vec4 test_px = texture2D(gm_BaseTexture, test_uv);
      
				if (cell_is_solid(test_px)) {
				    ElementDynamicData test_meta = ununpack_elem_dynamic_data(test_px);
				    if (!test_meta.is_moving) {
				        is_grounded = true;
				        break;
				    }
				}
			}

			// Pick appropriate decay chance
			float decay_chance = is_grounded
				? elem_static_data.friction_vel_decay_chance
				: elem_static_data.airborne_vel_decay_chance;

			// === Chance-based velocity decay ===
			if (abs(elem_dynamic_data.vel.x) >= 1.0) {
				if (chance(decay_chance, v_vTexcoord, u_frame + 17.0)) {
				    elem_dynamic_data.vel.x -= sign(elem_dynamic_data.vel.x); // Reduce by 1 px/frame
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
				break; // Success: move into intended velocity cell
			}
			
			// === Bounce Logic ===
			if (chance(bounce_chance, v_vTexcoord, u_frame + 1.0)) {
				vec2 slope = vec2(0.0);
				
				// Loop over 7×7 neighborhood centered on current texel
				for (int ox = -OFFSET_RADIUS; ox <= OFFSET_RADIUS; ++ox) {
				    for (int oy = -OFFSET_RADIUS; oy <= OFFSET_RADIUS; ++oy) {
				        if (ox == 0 && oy == 0) continue;
						
				        vec2 offset = vec2(float(ox), float(oy));
				        vec2 sample_uv = v_vTexcoord + offset * u_texel_size;
						
				        bool is_solid = cell_is_solid(texture2D(gm_BaseTexture, sample_uv));
						if (is_solid) {
				            slope -= offset;
				        }
				    }
				}
				
				if (length(slope) > 0.0) {
				    vec2 reflected = elem_dynamic_data.vel - 2.0 * dot(elem_dynamic_data.vel, slope) * slope;
					
				    // Preserve magnitude but apply dampening
				    float orig_len = length(elem_dynamic_data.vel);
				    reflected = normalize(reflected) * (orig_len * bounce_dampening_multiplier);
					
				    elem_dynamic_data.vel = reflected;
					
					intent_found = true;
				    break; // Bounce intent issued
				}

			}
		}

	    // === Step 4: Fallback downward search (gravity direction only) ===
	    int y_dir = int(sign(gravity_force));
	    for (int dy = y_dir; abs_int(dy) <= int(y_slip_search_range); dy += y_dir) {
	        vec2 test_uv = v_vTexcoord + vec2(0.0, float(dy)) * u_texel_size;
	        vec4 test_px = texture2D(gm_BaseTexture, test_uv);
	        int test_id = elem_get_index(test_px);
	        ElementStaticData test_static = get_element_static_data(test_id);

	        if (test_id == 0 || element_can_replace(elem_static_data, test_static)) {
	            elem_dynamic_data.vel = vec2(0.0, float(dy));
	            elem_dynamic_data.is_moving = true;
				intent_found = true;
	            break;
	        }
	    }

	    if (elem_dynamic_data.is_moving) break;

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
	                elem_dynamic_data.is_moving = true;
					intent_found = true;
	                break;
	            }
	        }
			
			if (elem_dynamic_data.is_moving) {
				break;
			}
	    }
		
		if (!intent_found) {
			//cant move
			elem_dynamic_data.vel = vec2(0.0);
		}
		//elem_dynamic_data.is_moving = false;
		
	    break;
	}

	//*/
	while (true) {
		bool intent_found = false;
		
		// === Cached Static Values ===
		float gravity_force                     = elem_static_data.gravity_force;
	    float max_vel_x                         = elem_static_data.max_vel_x;
	    float max_vel_y                         = elem_static_data.max_vel_y;
	  
		bool can_slip              = elem_static_data.can_slip;
		float x_slip_search_range               = elem_static_data.x_slip_search_range;
	    float y_slip_search_range               = elem_static_data.y_slip_search_range;
	  
		float stickiness_chance                 = elem_static_data.stickiness_chance;
		
		float bounce_chance                     = elem_static_data.bounce_chance;
		float bounce_dampening_multiplier       = elem_static_data.bounce_dampening_multiplier;
		
		float airborne_vel_decay_chance     = elem_static_data.airborne_vel_decay_chance;
		float friction_vel_decay_chance     = elem_static_data.friction_vel_decay_chance;
		
		
		// === Step 1: Sleep Detection ===
		//if (!elem_dynamic_data.is_moving) {
		//	float wake_chance = elem_static_data.wake_chance;
		//	bool attempt_wake = false;
		//	bool woke_up = false;
			
		//	if (elem_dynamic_data.vel != vec2(0.0)) {
		//		woke_up = true;
		//	}
		//	else {
				
		//		for (int dx = -3; dx <= 3; ++dx) {
		//		    for (int dy = -3; dy <= 3; ++dy) {
		//		        if (dx == 0 && dy == 0) continue;

		//		        vec2 offset = vec2(float(dx), float(dy));
		//		        vec2 neighbor_uv = v_vTexcoord + offset * u_texel_size;
		//		        vec4 neighbor_px = texture2D(gm_BaseTexture, neighbor_uv);
		//		        int neighbor_id = elem_get_index(neighbor_px);

		//		        if (neighbor_id != 0) {
		//		            ElementDynamicData neighbor_meta = ununpack_elem_dynamic_data(neighbor_px);

		//		            if (neighbor_meta.is_moving) {
		//						attempt_wake = true;
		//		            }
		//		        }
		//		    }
		//		    if (attempt_wake) break;
		//		}
		//	}
			
		//	if (attempt_wake && chance(wake_chance, v_vTexcoord, u_frame)) {
		//		woke_up = true;
		//	}
			
		//	if (!woke_up) {
		//	    break; // Stay asleep this frame
		//	}
		//}
		
		// === Step 2: Apply Gravity Force ===
	    elem_dynamic_data.vel.y = clamp(
	        elem_dynamic_data.vel.y + gravity_force,
	        -max_vel_y,
	        max_vel_y
	    );
		
		// === Step 3: Apply Velocity Decay (Grounded vs Airborne) ===
		if (elem_dynamic_data.vel != vec2(0.0)) {
			// Determine grounded state (same logic as before)
			bool is_grounded = false;
			ivec2 check_dirs[3];
			int sign_x = int(sign(elem_dynamic_data.vel.x));
			int sign_y = int(sign(elem_dynamic_data.vel.y));
    
			check_dirs[0] = ivec2(0, sign_y);              // Vertical
			check_dirs[1] = ivec2(sign_x, 0);              // Horizontal
			check_dirs[2] = ivec2(sign_x, sign_y);         // Diagonal
    
			for (int i = 0; i < 3; ++i) {
				vec2 dir = vec2(check_dirs[i]);
				vec2 test_uv = v_vTexcoord + dir * u_texel_size;
				vec4 test_px = texture2D(gm_BaseTexture, test_uv);
      
				if (cell_is_solid(test_px)) {
				    ElementDynamicData test_meta = ununpack_elem_dynamic_data(test_px);
				    if (!test_meta.is_moving) {
				        is_grounded = true;
				        break;
				    }
				}
			}

			// Pick appropriate decay chance
			float decay_chance = is_grounded
				? elem_static_data.friction_vel_decay_chance
				: elem_static_data.airborne_vel_decay_chance;

			// === Chance-based velocity decay ===
			if (abs(elem_dynamic_data.vel.x) >= 1.0) {
				if (chance(decay_chance, v_vTexcoord, u_frame + 17.0)) {
				    elem_dynamic_data.vel.x -= sign(elem_dynamic_data.vel.x); // Reduce by 1 px/frame
				}
			}

			if (abs(elem_dynamic_data.vel.y) >= 1.0) {
				if (chance(decay_chance, v_vTexcoord, u_frame + 18.0)) {
				    elem_dynamic_data.vel.y -= sign(elem_dynamic_data.vel.y);
				}
			}
		}
		
		
		// === Step 4: Attempt to Move via Velocity ===
		if (elem_dynamic_data.vel != vec2(0.0)) {
			vec2 vel_uv = v_vTexcoord + vec2(elem_dynamic_data.vel) * u_texel_size;
			vec4 vel_px = texture2D(gm_BaseTexture, vel_uv);
			int vel_id = elem_get_index(vel_px);
			ElementStaticData vel_static_data = get_element_static_data(vel_id);
		
			if (vel_id == 0 || element_can_replace(elem_static_data, vel_static_data)) {
				intent_found = true;
				break; // Success: move into intended velocity cell
			}
			
			// === Bounce Logic ===
			if (chance(bounce_chance, v_vTexcoord, u_frame + 1.0)) {
				vec2 slope = vec2(0.0);
				
				// Loop over 7×7 neighborhood centered on current texel
				for (int ox = -OFFSET_RADIUS; ox <= OFFSET_RADIUS; ++ox) {
				    for (int oy = -OFFSET_RADIUS; oy <= OFFSET_RADIUS; ++oy) {
				        if (ox == 0 && oy == 0) continue;
						
				        vec2 offset = vec2(float(ox), float(oy));
				        vec2 sample_uv = v_vTexcoord + offset * u_texel_size;
						
				        bool is_solid = cell_is_solid(texture2D(gm_BaseTexture, sample_uv));
						if (is_solid) {
				            slope -= offset;
				        }
				    }
				}
				
				if (length(slope) > 0.0) {
				    vec2 reflected = elem_dynamic_data.vel - 2.0 * dot(elem_dynamic_data.vel, slope) * slope;
					
				    // Preserve magnitude but apply dampening
				    float orig_len = length(elem_dynamic_data.vel);
				    reflected = normalize(reflected) * (orig_len * bounce_dampening_multiplier);

				    // Test if bounce destination is valid
				    vec2 bounce_uv = v_vTexcoord + reflected * u_texel_size;
				    vec4 bounce_px = texture2D(gm_BaseTexture, bounce_uv);
				    int bounce_id = elem_get_index(bounce_px);
				    ElementStaticData bounce_static = get_element_static_data(bounce_id);

				    if (bounce_id == 0 || element_can_replace(elem_static_data, bounce_static)) {
				        elem_dynamic_data.vel = reflected;
				        intent_found = true;
				        break; // Bounce intent issued
				    }
				    // Else: fall through to fallback logic instead of breaking
				}


			}
		}
		
		//// === Step 5: Fallback Downward ===
	    int y_dir = (gravity_force >= 0.0) ? 1 : -1;
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
		
		// === Step 6: Fallback Diagonal Slip ===
	    if (can_slip) {
	        int dx = (rand(v_vTexcoord, u_frame + 2.0) < 0.5) ? -1 : 1;
			
	        for (int i = 1; i <= int(x_slip_search_range); ++i) {
	            vec2 diag_uv = v_vTexcoord + vec2(float(i * dx), gravity_force > 0.0 ? 1.0 : -1.0) * u_texel_size;
	            vec4 diag_px = texture2D(gm_BaseTexture, diag_uv);
	            int diag_id = elem_get_index(diag_px);
	            ElementStaticData diag_static = get_element_static_data(diag_id);
				
	            if (diag_id == 0 || element_can_replace(elem_static_data, diag_static)) {
	                elem_dynamic_data.vel = vec2(float(i * dx), gravity_force > 0.0 ? 1.0 : -1.0);
					intent_found = true;
	                break;
	            }
	        }
	    }
		
		if (!intent_found) {
			elem_dynamic_data.vel = vec2(0.0);
		}
		
		break;
	}
    //*/
	
	// Default to no movement
	//elem_dynamic_data.is_moving = bool(elem_dynamic_data.vel != vec2(0.0));
	
	// === Step 2: Clamp velocity ===
	elem_dynamic_data.vel.x = clamp(elem_dynamic_data.vel.x, -elem_static_data.max_vel_x, elem_static_data.max_vel_x);
	elem_dynamic_data.vel.y = clamp(elem_dynamic_data.vel.y, -elem_static_data.max_vel_y, elem_static_data.max_vel_y);
	
	gl_FragColor = vec4(vel_to_rg(elem_dynamic_data.vel), 0.0, 1.0);
}
