//
// Simple passthrough fragment shader
//

#pragma shady: import(shdMaths)

#region Data Structures
struct ElementStaticData {
	int id;						// The ID of the element
	
    // Gravity and movement behavior
    float gravity_force;        // Gravity strength per frame (e.g., 0.25 = slow fall)
    int x_search;               // Horizontal movement range
    int y_search;               // Vertical movement range (in gravity direction)
	int max_vel_x;              // Maximum horizontal velocity
    int max_vel_y;              // Maximum vertical velocity
    int stickiness;             // Preference to clump (higher = more sticky)
    int can_slip;               // 1 = can attempt diagonal fallback
    int inertial_resistance;    // Resistance to velocity decay
	float bounce_chance;        // Chance to bounce on hard landing (0.0 - 1.0)

    // Physical characteristics
    int mass;                   // Affects momentum transfer
    int friction_factor;        // How much friction affects motion
    int stopped_moving_threshold; // Frames before considered "stopped"
    int state_of_matter;        // 0 = empty, 1 = gas, 2 = liquid, 3 = solid

    // Heat and flammability
    int flammable;              // 1 = can ignite
    int heat_factor;            // Heat applied to neighbors
    int fire_damage;            // Damage per frame when ignited

    // Explosive properties
    int explosion_resist;       // Resistance to explosion
    int explosion_radius;       // Radius if it explodes

    // Lifecycle
    int lifespan;               // Frames before death (-1 = infinite)

    // Interaction rules
    int replace_count;          // Number of element types this can move into
    int replace_ids[4];         // Element IDs it can replace
};

struct ElementDynamicData {
    int id;
	
	ElementStaticData static_data;
	
	//Green Channel
    vec2 vel;
    int x_dir;
    int y_dir;
    int x_speed;
    int y_speed;
    bool is_moving;
	bool unused_movement_bool;
	
};
#endregion

#region Element IDs Enum

#define ELEM_ID_EMPTY 0
#define ELEM_ID_WATER 100
#define ELEM_ID_SAND 255

#endregion

#region Getter Functions
int elem_get_index(vec4 px) {
    return int(floor(px.r * 255.0 + 0.5));
}
#endregion

#region Element Static Data
ElementStaticData get_element_static_data(int id) {
    ElementStaticData elem_static_data;
	
	if (id == ELEM_ID_SAND) {
        #pragma shady: inline(ElemSand.DefineElementStaticData)
		return elem_static_data;
    }
    // Add others here...
	
	return elem_static_data;
}
#endregion

#region Dynamic Data
ElementDynamicData ununpack_elem_dynamic_data(vec4 pixel) {
    ElementDynamicData elem_dynamic_data;
	
    // Red (element ID)
    elem_dynamic_data.id = elem_get_index(pixel);
	
	elem_dynamic_data.static_data = get_element_static_data(elem_dynamic_data.id);
	
    // Green (packed dynamic motion flags)
    int g = float_to_byte(pixel.g);
	
    // Layout: [y_dir (1)][y_speed (2)][x_dir (1)][x_speed (2)][is_moving (1)][unused (1)]
    // Binary:  ydddxdu?
    // Bit:     7   65  4   32  1       0
	
    elem_dynamic_data.y_dir               = bitwise_and(bit_shift_right(g, 7), 1);
    elem_dynamic_data.y_speed             = bitwise_and(bit_shift_right(g, 5), 3);
    elem_dynamic_data.x_dir               = bitwise_and(bit_shift_right(g, 4), 1);
    elem_dynamic_data.x_speed             = bitwise_and(bit_shift_right(g, 2), 3);
    
	// extract flags as ints then convert
    elem_dynamic_data.is_moving            = bool(bitwise_and(bit_shift_right(g, 1), 1));
    elem_dynamic_data.unused_movement_bool = bool(bitwise_and(bit_shift_right(g, 0), 1));
	
    float x_norm = float(elem_dynamic_data.x_speed) / 3.0;
    float y_norm = float(elem_dynamic_data.y_speed) / 3.0;
	
    float x_signed = x_norm * (elem_dynamic_data.x_dir == 0 ? 1.0 : -1.0);
    float y_signed = y_norm * (elem_dynamic_data.y_dir == 0 ? 1.0 : -1.0);
	
	
	
	
	
    elem_dynamic_data.vel = vec2(
        x_signed * float(elem_dynamic_data.static_data.max_vel_x),
        y_signed * float(elem_dynamic_data.static_data.max_vel_y)
    );
	
	
    return elem_dynamic_data;
}

vec4 pack_elem_dynamic_data(in ElementDynamicData elem_dynamic_data) {
    int g = 0;
	
	int x_speed = int(round(clamp(abs(elem_dynamic_data.vel.x) / float(elem_dynamic_data.static_data.max_vel_x), 0.0, 1.0) * 3.0));
	int y_speed = int(round(clamp(abs(elem_dynamic_data.vel.y) / float(elem_dynamic_data.static_data.max_vel_y), 0.0, 1.0) * 3.0));
    int x_dir = elem_dynamic_data.vel.x >= 0.0 ? 0 : 1;
    int y_dir = elem_dynamic_data.vel.y >= 0.0 ? 0 : 1;
	
    // Layout: [y_dir (1)][y_speed (2)][x_dir (1)][x_speed (2)][is_moving (1)][unused (1)]
    
    g = bitwise_or(g, bit_shift_left(clamp(y_dir   , 0, 1), 7));
    g = bitwise_or(g, bit_shift_left(clamp(y_speed , 0, 3), 5));
    g = bitwise_or(g, bit_shift_left(clamp(x_dir   , 0, 1), 4));
    g = bitwise_or(g, bit_shift_left(clamp(x_speed , 0, 3), 2));
    g = (elem_dynamic_data.is_moving)            ? bitwise_or(g, bit_shift_left(1, 1)) : g;
	g = (elem_dynamic_data.unused_movement_bool) ? bitwise_or(g, bit_shift_left(1, 0)) : g;
    
    float g_float = byte_to_float(g);
    float r_float = byte_to_float(elem_dynamic_data.id);
	
    return vec4(r_float, g_float, 0.0, 1.0);
}
#endregion

#region is_* functions
//used when passing in the element's data
bool elem_is_solid(ElementStaticData elem) {
    return elem.state_of_matter == 3;
}

bool elem_is_liquid(ElementStaticData elem) {
    return elem.state_of_matter == 2;
}

bool elem_is_gas(ElementStaticData elem) {
    return elem.state_of_matter == 1;
}

bool elem_is_empty(ElementStaticData elem) {
    return elem.state_of_matter == 0 || elem.id == ELEM_ID_EMPTY;
}


//used when passing in the matrix
bool cell_is_solid(vec4 pixel) {
	return get_element_static_data(elem_get_index(pixel)).state_of_matter == 3;
}

bool cell_is_liquid(vec4 pixel) {
    return get_element_static_data(elem_get_index(pixel)).state_of_matter == 2;
}

bool cell_is_gas(vec4 pixel) {
    return get_element_static_data(elem_get_index(pixel)).state_of_matter == 1;
}

bool cell_is_empty(vec4 pixel) {
    return elem_get_index(pixel) == ELEM_ID_EMPTY || get_element_static_data(elem_get_index(pixel)).state_of_matter == 0;
}



#endregion

bool element_can_replace(ElementStaticData src, ElementStaticData dst) {
    // Solids can never be replaced by anything
    if (dst.state_of_matter == 3) {
        return false;
    }

    // Fast check for identical types or empty
    if (dst.state_of_matter <= src.state_of_matter) {
        return true;
    }

    // Lookup table test
    for (int i = 0; i < src.replace_count; ++i) {
        if (src.replace_ids[i] == dst.id) {
            return true;
        }
    }

    return false;
}


// === Encode velocity (vec2) into RG float pair (vec2)
// Maps signed int [-128,127] to float [0.0,1.0]
vec2 vel_to_rg(vec2 vel) {
    return (vel + 128.0) / 255.0;
}

// === Decode RG float pair (vec2) back into velocity (vec2)
// Maps float [0.0,1.0] to signed int [-128,127]
vec2 rg_to_vel(vec2 rg) {
    return vec2(floor(rg * 255.0 + 0.5)) - vec2(128.0);
}


































void main()
{
    //this is only here to prevent errors
	#ifdef EXCLUDE
	
	#region GENERIC_INTENT
	#pragma shady: macro_begin GENERIC_INTENT

	// === Cached Static Values ===
	float gravity_force       = elem_static_data.gravity_force;
	int x_search              = elem_static_data.x_search;
	int y_search              = elem_static_data.y_search;
	int max_vel_x             = elem_static_data.max_vel_x;
	int max_vel_y             = elem_static_data.max_vel_y;
	int stickiness            = elem_static_data.stickiness;
	int can_slip              = elem_static_data.can_slip;
	int inertial_resist       = elem_static_data.inertial_resistance;
	float bounce_chance       = elem_static_data.bounce_chance;
	
	
	if (!elem_dynamic_data.is_moving && elem_dynamic_data.vel == vec2(0.0)) {
	    bool woke_up = false;
	    float resist_chance = 1.0 - (float(inertial_resist) / 10.0);

	    for (int dx = -3; dx <= 3; ++dx) {
	        for (int dy = -3; dy <= 3; ++dy) {
	            if (dx == 0 && dy == 0) continue;

	            vec2 offset = vec2(float(dx), float(dy));
	            vec2 neighbor_uv = v_vTexcoord + offset * u_texel_size;
	            vec4 neighbor_px = texture2D(gm_BaseTexture, neighbor_uv);
	            int neighbor_id = elem_get_index(neighbor_px);

	            if (neighbor_id != 0) {
	                ElementDynamicData neighbor_meta = ununpack_elem_dynamic_data(neighbor_px);

	                if (neighbor_meta.is_moving) {
	                    if (chance(resist_chance, v_vTexcoord + neighbor_uv, u_frame)) {
	                        elem_dynamic_data.is_moving = true;
	                        woke_up = true;
	                        break;
	                    }
	                }
	            }
	        }
	        if (woke_up) break;
	    }

	    if (!woke_up) {
	        elem_dynamic_data.vel = vec2(0.0, 0.0);
	        break; // Stay asleep this frame
	    }
	}


	// === Step 2: Apply Gravity Force ===
	elem_dynamic_data.vel.y += gravity_force;
	elem_dynamic_data.vel.y = clamp(elem_dynamic_data.vel.y + gravity_force, -float(max_vel_y), float(max_vel_y));
	
	// === Step 3: Bounce Check ===
	if (abs(elem_dynamic_data.vel.y) >= float(max_vel_y)) {
	    if (chance(bounce_chance, v_vTexcoord + vec2(0.789, 0.123), u_frame)) {
	        elem_dynamic_data.vel.y = -elem_dynamic_data.vel.y;
	        elem_dynamic_data.is_moving = true;
	    }
	}
	
	// === Step 4: Air Resistance (X Axis) ===
	if (abs_float(elem_dynamic_data.vel.x) >= float(max_vel_x)) {
		if (chance(0.2, v_vTexcoord + vec2(1.234, 4.567), u_frame)) {
			float dir = sign_float(elem_dynamic_data.vel.x);
			elem_dynamic_data.vel.x -= dir * 0.1; // Gradual decay
		}
	}

	// === Step 5: Attempt to Move via Velocity ===
	if (length(elem_dynamic_data.vel) > 2.0) {
		vec2 vel_uv = v_vTexcoord + vec2(elem_dynamic_data.vel) * u_texel_size;
		vec4 vel_px = texture2D(gm_BaseTexture, vel_uv);
		int vel_id = elem_get_index(vel_px);
		ElementStaticData vel_static_data = get_element_static_data(vel_id);
		
		if (vel_id == 0 || element_can_replace(elem_static_data, vel_static_data)) {
			elem_dynamic_data.is_moving = true;
			break; // Success: move into intended velocity cell
		}
		
		// === Bounce Logic ===
		if (chance(bounce_chance, v_vTexcoord + vec2(0.987, 0.321), u_frame)) {
			// === Sample 4-neighbor cells to estimate slope ===
			bool s_l = cell_is_solid(texture2D(gm_BaseTexture, v_vTexcoord + vec2(-1,  0) * u_texel_size));
			bool s_r = cell_is_solid(texture2D(gm_BaseTexture, v_vTexcoord + vec2( 1,  0) * u_texel_size));
			bool s_u = cell_is_solid(texture2D(gm_BaseTexture, v_vTexcoord + vec2( 0, -1) * u_texel_size));
			bool s_d = cell_is_solid(texture2D(gm_BaseTexture, v_vTexcoord + vec2( 0,  1) * u_texel_size));
		
			float g_x = float(s_r) - float(s_l);
			float g_y = float(s_d) - float(s_u);
			vec2 slope = vec2(g_x, g_y);
		
			if (length(slope) > 0.0) {
				vec2 n = normalize(slope);
				vec2 bounce = elem_dynamic_data.vel - 2.0 * dot(elem_dynamic_data.vel, n) * n;
				
				// Dampen and add slight randomness
				float jitter = 0.9 + rand(v_vTexcoord, u_frame) * 0.15;
				bounce *= jitter;
				
				// Clamp and assign back to dynamic data
				bounce.x = clamp(bounce.x, -float(max_vel_x), float(max_vel_x));
				bounce.y = clamp(bounce.y, -float(max_vel_y), float(max_vel_y));
				
				elem_dynamic_data.vel = bounce;
				
				break; // Bounce intent issued
			}
		}
	}

	//// === Step 6: Fallback Downward ===
	bool moved = false;
	int y_dir = (gravity_force >= 0.0) ? 1 : -1;
	for (int dy = y_dir; abs_int(dy) <= y_search; dy += y_dir) {
		
	    if (dy == 0) continue;
	    vec2 test_uv = v_vTexcoord + vec2(0.0, float(dy)) * u_texel_size;
	    vec4 test_px = texture2D(gm_BaseTexture, test_uv);
	    int test_id = elem_get_index(test_px);
	    ElementStaticData test_static = get_element_static_data(test_id);

	    if (test_id == 0 || element_can_replace(elem_static_data, test_static)) {
	        elem_dynamic_data.vel = vec2(0.0, float(dy));
	        elem_dynamic_data.is_moving = true;
	        moved = true;
	        break;
	    }
	}

	// === Step 7: Fallback Diagonal Slip ===
	if (!moved && can_slip == 1) {
	    int dx = (rand(v_vTexcoord, u_frame) < 0.5) ? -1 : 1;

	    for (int i = 1; i <= x_search; ++i) {
	        vec2 diag_uv = v_vTexcoord + vec2(float(i * dx), gravity_force > 0.0 ? 1.0 : -1.0) * u_texel_size;
	        vec4 diag_px = texture2D(gm_BaseTexture, diag_uv);
	        int diag_id = elem_get_index(diag_px);
	        ElementStaticData diag_static = get_element_static_data(diag_id);

	        if (diag_id == 0 || element_can_replace(elem_static_data, diag_static)) {
	            elem_dynamic_data.vel = vec2(float(i * dx), gravity_force > 0.0 ? 1.0 : -1.0);
	            elem_dynamic_data.is_moving = true;
	            break;
	        }
	    }
	}

	#pragma shady: macro_end
	#endregion

	
	#endif
}
