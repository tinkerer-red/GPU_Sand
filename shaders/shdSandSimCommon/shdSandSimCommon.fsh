//
// Simple passthrough fragment shader
//

#pragma shady: import(shdMaths)

struct ElemMeta {
    int id;
	ivec2 vel;
    int x_dir;
    int y_dir;
    int x_speed;
    int y_speed;
};

#region Element IDs Enum

#define Elem_Empty 0
#define Elem_Water 100
#define Elem_Sand 255

#endregion

#region Elem getter functions
int elem_get_index(vec4 px) {
    return int(floor(px.r * 255.0 + 0.5));
}

ivec2 elem_get_velocity(vec4 pixel) {
    int g = float_to_byte(pixel.g);
	
	
	// 0_00_0_00_00
    int y_dir   = bitwise_and(bit_shift_right(g, 7), 1);
    int y_speed = bitwise_and(bit_shift_right(g, 6), 3);
    int x_dir   = bitwise_and(bit_shift_right(g, 4), 1);
	int x_speed = bitwise_and(bit_shift_right(g, 2), 3);
    
    int vx = (x_dir == 1) ? x_speed : -x_speed;
    int vy = (y_dir == 1) ? y_speed : -y_speed;

    return ivec2(vx, vy);
}

int elem_get_xdir(vec4 pixel) {
    return bitwise_and(bit_shift_right(float_to_byte(pixel.g), 1), 1);
}

int elem_get_ydir(vec4 pixel) {
    return bitwise_and(bit_shift_right(float_to_byte(pixel.g), 5), 1);
}

int elem_get_xspeed(vec4 pixel) {
    return bitwise_and(bit_shift_right(float_to_byte(pixel.g), 2), 3);
}

int elem_get_yspeed(vec4 pixel) {
    return bitwise_and(bit_shift_right(float_to_byte(pixel.g), 6), 3);
}
#endregion

void unpack_pixel(vec4 pixel, inout ElemMeta metadata) {
    // Red
    metadata.id = elem_get_index(pixel);
    
    // Green
    int g = float_to_byte(pixel.g);

    // Layout: [y_dir (1)][y_speed (2)][x_dir (1)][x_speed (2)][? (2)]
    // Binary:  0_00_0_00_00

    metadata.y_dir   = bitwise_and(bit_shift_right(g, 7), 1);
    metadata.y_speed = bitwise_and(bit_shift_right(g, 5), 3);
    metadata.x_dir   = bitwise_and(bit_shift_right(g, 4), 1);
    metadata.x_speed = bitwise_and(bit_shift_right(g, 2), 3);

    metadata.vel = ivec2(
        (metadata.x_dir == 1) ? metadata.x_speed : -metadata.x_speed,
        (metadata.y_dir == 1) ? metadata.y_speed : -metadata.y_speed
    );

    // Reserved bits (placeholder examples):
    // int extra_2bit  = bitwise_and(g, 0x03);         // Last 2 bits as one field
    // int extra_bit0  = bitwise_and(bit_shift_right(g, 1), 1); // Bit 1
    // int extra_bit1  = bitwise_and(g, 1);            // Bit 0

    // Blue and Alpha unused for now
}

vec4 pack_pixel(in ElemMeta meta) {
    int g = 0;

    // Layout: [y_dir (1)][y_speed (2)][x_dir (1)][x_speed (2)][? (2)]
    // Binary:  0_00_0_00_00

    g = bitwise_or(g, bit_shift_left(clamp(meta.y_dir  , 0, 1), 7));
    g = bitwise_or(g, bit_shift_left(clamp(meta.y_speed, 0, 3), 5));
    g = bitwise_or(g, bit_shift_left(clamp(meta.x_dir  , 0, 1), 4));
    g = bitwise_or(g, bit_shift_left(clamp(meta.x_speed, 0, 3), 2));

    // Reserved bits (leave for future use):
    // g = bitwise_or(g, bit_shift_left(clamp(meta.extra_2bit, 0, 3), 0)); // One 2-bit field
    // g = bitwise_or(g, bit_shift_left(clamp(meta.extra_bit0, 0, 1), 1)); // Bit 1
    // g = bitwise_or(g, bit_shift_left(clamp(meta.extra_bit1, 0, 1), 0)); // Bit 0

    float g_float = byte_to_float(g);
    float r_float = byte_to_float(meta.id); // assuming ID lives in red
	
    return vec4(r_float, g_float, 0.0, 1.0);
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
    //gl_FragColor = vec4(0.0);
}
