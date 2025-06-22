//
// Simple passthrough fragment shader
//

#pragma shady: import(shdMaths)

#region Data Structures
struct ElementStaticData {
	int id;						// The ID of the element
	
    // Gravity and movement behavior
    float gravity_force;          // Gravity strength per frame (e.g., 0.25 = slow fall)
    float x_search;               // Horizontal movement range
    float y_search;               // Vertical movement range (in gravity direction)
	float max_vel_x;              // Maximum horizontal velocity
    float max_vel_y;              // Maximum vertical velocity
    float stickiness;             // Preference to clump (higher = more sticky)
    float inertial_resistance;    // Resistance to velocity decay
	float bounce_chance;          // Chance to bounce on hard landing (0.0 - 1.0)
	bool can_slip;               // 1 = can attempt diagonal fallback
    
    // Physical characteristics
    int mass;                     // Affects momentum transfer
    int friction_factor;          // How much friction affects motion
    int state_of_matter;            // 0 = empty, 1 = gas, 2 = liquid, 3 = solid
	
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
	vec2 vel;
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

    elem_dynamic_data.vel = vec2(
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
// Maps signed float [-128.0,127.0] to float [0.0,1.0]
vec2 vel_to_rg(vec2 vel) {
    return (vec2(vel) + 128.0) / 255.0;
}

// === Decode RG float pair (vec2) back into velocity (vec2)
// Maps float [0.0,1.0] to signed float [-128.0,127.0]
vec2 rg_to_vel(vec2 rg) {
    return vec2(floor(rg * 255.0 + 0.5)) - 128.0;
}


































void main()
{
    //this is only here to prevent errors
	#ifdef EXCLUDE
	
	#endif
}
