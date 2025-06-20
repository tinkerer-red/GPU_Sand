#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;

void main() {
    vec4 input_pixel = vec4(v_vTexcoord.x, v_vTexcoord.y, 0.0, 1.0);
	
    ElemMeta meta;
    unpack_pixel(input_pixel, meta);
	
    vec4 roundtrip_pixel = pack_pixel(meta);
	
    // Absolute difference per channel (R = ID, G = velocity)
    float delta_r = abs(input_pixel.r - roundtrip_pixel.r);
    float delta_g = abs(input_pixel.g - roundtrip_pixel.g);
	
    gl_FragColor = vec4(delta_r, delta_g, 0.0, 1.0);
}
