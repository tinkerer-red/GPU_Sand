//
// Simple passthrough fragment shader
//

#pragma shady: import(shdMaths)

#region Data Structures
struct ElementStaticData {
	int id;						// The ID of the element
	
    // Gravity and movement behavior
    int gravity_dir;            // 1 = down, -1 = up (for things like steam)
    int x_search;               // Horizontal movement range
    int y_search;               // Vertical movement range (in gravity direction)
    int stickiness;             // Preference to clump (higher = more sticky)
    int can_slip;               // 1 = can attempt diagonal fallback
    int inertial_resistance;    // Resistance to velocity decay

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
	ivec2 vel;
    int x_dir;
    int y_dir;
    int x_speed;
    int y_speed;
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
	
	// Red
    elem_dynamic_data.id = elem_get_index(pixel);
    
    // Green
    int g = float_to_byte(pixel.g);

    // Layout: [y_dir (1)][y_speed (2)][x_dir (1)][x_speed (2)][? (2)]
    // Binary:  0_00_0_00_00

    elem_dynamic_data.y_dir   = bitwise_and(bit_shift_right(g, 7), 1);
    elem_dynamic_data.y_speed = bitwise_and(bit_shift_right(g, 5), 3);
    elem_dynamic_data.x_dir   = bitwise_and(bit_shift_right(g, 4), 1);
    elem_dynamic_data.x_speed = bitwise_and(bit_shift_right(g, 2), 3);

    elem_dynamic_data.vel = ivec2(
        (elem_dynamic_data.x_dir == 1) ? elem_dynamic_data.x_speed : -elem_dynamic_data.x_speed,
        (elem_dynamic_data.y_dir == 1) ? elem_dynamic_data.y_speed : -elem_dynamic_data.y_speed
    );

    // Reserved bits (placeholder examples):
    // int extra_2bit  = bitwise_and(g, 0x03);         // Last 2 bits as one field
    // int extra_bit0  = bitwise_and(bit_shift_right(g, 1), 1); // Bit 1
    // int extra_bit1  = bitwise_and(g, 1);            // Bit 0

    // Blue and Alpha unused for now
	
	return elem_dynamic_data;
}

vec4 pack_elem_dynamic_data(in ElementDynamicData elem_dynamic_data) {
    int g = 0;

    // Layout: [y_dir (1)][y_speed (2)][x_dir (1)][x_speed (2)][? (2)]
    // Binary:  0_00_0_00_00

    g = bitwise_or(g, bit_shift_left(clamp(elem_dynamic_data.y_dir  , 0, 1), 7));
    g = bitwise_or(g, bit_shift_left(clamp(elem_dynamic_data.y_speed, 0, 3), 5));
    g = bitwise_or(g, bit_shift_left(clamp(elem_dynamic_data.x_dir  , 0, 1), 4));
    g = bitwise_or(g, bit_shift_left(clamp(elem_dynamic_data.x_speed, 0, 3), 2));

    // Reserved bits (leave for future use):
    // g = bitwise_or(g, bit_shift_left(clamp(elem_dynamic_data.extra_2bit, 0, 3), 0)); // One 2-bit field
    // g = bitwise_or(g, bit_shift_left(clamp(elem_dynamic_data.extra_bit0, 0, 1), 1)); // Bit 1
    // g = bitwise_or(g, bit_shift_left(clamp(elem_dynamic_data.extra_bit1, 0, 1), 0)); // Bit 0

    float g_float = byte_to_float(g);
    float r_float = byte_to_float(elem_dynamic_data.id); // assuming ID lives in red
	
    return vec4(r_float, g_float, 0.0, 1.0);
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


// === Encode velocity (ivec2) into RG float pair (vec2)
// Maps signed int [-128,127] to float [0.0,1.0]
vec2 vel_to_rg(ivec2 vel) {
    return (vec2(vel) + 128.0) / 255.0;
}

// === Decode RG float pair (vec2) back into velocity (ivec2)
// Maps float [0.0,1.0] to signed int [-128,127]
ivec2 rg_to_vel(vec2 rg) {
    return ivec2(floor(rg * 255.0 + 0.5)) - 128;
}


































void main()
{
    //this is only here to prevent errors
	#ifdef EXCLUDE
	
	#region GENERIC_INTENT
	#pragma shady: macro_begin GENERIC_INTENT
	
	// Read once for clarity
	int grav_dir         = elem_static_data.gravity_dir;
	int x_search         = elem_static_data.x_search;
	int y_search         = elem_static_data.y_search;
	int can_slip         = elem_static_data.can_slip;
	int stickiness       = elem_static_data.stickiness;
	int inertial_resist  = elem_static_data.inertial_resistance;
	
	if (elem_dynamic_data.vel.x != 0 || elem_dynamic_data.vel.y != 0) {
	    // === AIR RESISTANCE ===
	    if (abs_int(elem_dynamic_data.vel.x) == 3 && inertial_resist > 0) {
	        if (chance(0.2, v_vTexcoord + vec2(1.234, 4.567), u_frame)) {
	            int dir = sign_int(elem_dynamic_data.vel.x);
	            elem_dynamic_data.vel.x = 2 * dir;
	            elem_dynamic_data.x_speed = 2;
	            elem_dynamic_data.x_dir = (dir > 0) ? 1 : 0;
	        }
	    }
		
	    // === ATTEMPT VELOCITY MOVE ===
	    vec2 fall_uv = v_vTexcoord + vec2(elem_dynamic_data.vel) * u_texel_size;
	    vec4 fall_px = texture2D(gm_BaseTexture, fall_uv);
	    int fall_id = elem_get_index(fall_px);
		
	    ElementStaticData dst_static_data = get_element_static_data(fall_id);
		
	    if (fall_id == 0 || element_can_replace(elem_static_data, dst_static_data)) {
	        if (chance(0.1, v_vTexcoord + vec2(0.456, 0.789), u_frame)) {
	            elem_dynamic_data.vel.y = clamp(elem_dynamic_data.vel.y + grav_dir, -3, 3);
	        }
	        break;
	    }
	}
	
	// === FALLBACK SEARCH ===
	bool moved = false;
	
	for (int dy = grav_dir; abs_int(dy) <= y_search; dy += grav_dir) {
	    vec2 down_uv = v_vTexcoord + vec2(0.0, float(dy)) * u_texel_size;
	    vec4 down_px = texture2D(gm_BaseTexture, down_uv);
	    int down_id = elem_get_index(down_px);
	    ElementStaticData down_static = get_element_static_data(down_id);
		
	    if (down_id == 0 || element_can_replace(elem_static_data, down_static)) {
	        elem_dynamic_data.vel = ivec2(0, dy);
	        moved = true;
	        break;
	    }
	}
	
	if (!moved && can_slip == 1) {
	    int dx = (rand(v_vTexcoord, u_frame) < 0.5) ? -1 : 1;
		
	    for (int i = 1; i <= x_search; ++i) {
	        vec2 diag_uv = v_vTexcoord + vec2(float(i * dx), grav_dir) * u_texel_size;
	        vec4 diag_px = texture2D(gm_BaseTexture, diag_uv);
	        int diag_id = elem_get_index(diag_px);
	        ElementStaticData diag_static = get_element_static_data(diag_id);
			
	        if (diag_id == 0 || element_can_replace(elem_static_data, diag_static)) {
	            elem_dynamic_data.vel = ivec2(i * dx, grav_dir);
	            break;
	        }
	    }
	}
	
	#pragma shady: macro_end
	#endregion
	
	#endif
}
