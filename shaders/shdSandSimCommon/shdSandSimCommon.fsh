//
// Simple passthrough fragment shader
//

#pragma shady: import(shdMaths)

//delete me
int get_cell_index(vec4 px) {
    return int(floor(px.r * 255.0 + 0.5));
}
//


struct ElemMeta {
    int id;
	ivec2 vel;
    int x_dir;
    int y_dir;
    int x_speed;
    int y_speed;
};


#region Elem getter functions
int elem_get_index(vec4 px) {
    return int(floor(px.r * 255.0 + 0.5));
}

ivec2 elem_get_velocity(vec4 pixel) {
    int g = float_to_byte(pixel.g);

    int y_speed = bitwise_and(bit_shift_right(g, 6), 0x03);
    int y_dir   = bitwise_and(bit_shift_right(g, 5), 0x01);
    int x_speed = bitwise_and(bit_shift_right(g, 2), 0x03);
    int x_dir   = bitwise_and(bit_shift_right(g, 1), 0x01);

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

void unpack_pixel(vec4 pixel, inout ElemMeta meta) {
    
	//red
	meta.id = elem_get_index(pixel);
	
	//green
    int g = float_to_byte(pixel.g);

    meta.y_speed = elem_get_yspeed(pixel);
    meta.y_dir   = elem_get_ydir(pixel);
    meta.x_speed = elem_get_xspeed(pixel);
    meta.x_dir   = elem_get_xdir(pixel);

    meta.vel = ivec2(
        (meta.x_dir == 1) ? meta.x_speed : -meta.x_speed,
        (meta.y_dir == 1) ? meta.y_speed : -meta.y_speed
    );
	
	//blue
	
	//alpha
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
