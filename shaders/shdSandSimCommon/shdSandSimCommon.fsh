//
// Simple passthrough fragment shader
//

#pragma shady: import(shdMaths)

#region Data Structures
struct ElementStaticData {
	int id;						// The ID of the element
	int state_of_matter;        // 0 = empty, 1 = gas, 2 = liquid, 3 = solid
	
    // === Gravity & Movement ===
    float gravity_force;        // Gravity strength per frame (e.g., 0.25 = slow fall)
    float max_vel_x;            // Maximum horizontal velocity
    float max_vel_y;            // Maximum vertical velocity
    
	bool can_slip;               // 1 = can attempt diagonal fallback
    float x_slip_search_range;   // Horizontal movement range
    float y_slip_search_range;   // Vertical movement range (in gravity direction)
	
	float wake_chance; // Chance to wake up from nearby movement (0.0 = inert, 1.0 = always wake)
	
	float stickiness_chance;    // Preference to clump (higher = more sticky)
    
	float bounce_chance;        // Chance to bounce on hard landing (0.0 - 1.0)
	float bounce_dampening_multiplier;     // Fraction of velocity retained after a bounce (0.0 = no bounce, 1.0 = perfect)
	
	// === Velocity Decay ===
	float airborne_vel_decay_chance;    // Chance for Velocity decay while airborn (adds better random movements)
	float friction_vel_decay_chance;    // Chance for Velocity decay while grounded (adds better random movements)
	
	
    // === Physical ===
    float mass;                   // Affects momentum transfer
    
    // === Heat and Flammability ==
    bool can_ignite;                 // True if it can catch fire
    float temperature_decay;           //chance to disperse heat or cold
	float temperature_spread_chance;   //chance of adopting temperature from neighbor
	
    // === Explosive properties ===
    float explosion_resistance;       // Resistance to explosion
    float explosion_radius;       // Radius if it explodes

    // === Lifecycle Control ===
    float custom_event_chance; // Optional: triggers a special effect, defined in the element macro

    // === Replacement Rules ===
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

vec2 rand_round_vel(vec2 velocity, vec2 texcoord, float seed) {
    vec2 rounded;
	
    float ax = abs(fract(velocity.x));
    float ay = abs(fract(velocity.y));
	
    float rand_x = rand(texcoord, seed);
    float rand_y = rand(texcoord, seed + 1.0);
	
    rounded.x = floor(velocity.x + (rand_x < ax ? 1.0 : 0.0));
    rounded.y = floor(velocity.y + (rand_y < ay ? 1.0 : 0.0));
	
    return rounded;
}


































void main()
{
    //this is only here to prevent errors
	#ifdef EXCLUDE
	
	//#region GENERIC_INTENT
	#pragma shady: macro_begin GENERIC_INTENT
	
	
	
	#pragma shady: macro_end
	//#endregion

	
	#endif
}
