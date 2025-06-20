//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// Converts [0.0, 1.0] float to [0, 255] int
int float_to_byte(float x) {
    return int(floor(clamp(x, 0.0, 1.0) * 255.0 + 0.5));
}

// Converts [0, 255] int to [0.0, 1.0] float
float byte_to_float(int x) {
    return clamp(float(x), 0.0, 255.0) / 255.0;
}



int imod(int x, int y) {
    return x - y * int(floor(float(x) / float(y)));
}

int bit_shift_left(int x, int n) {
    return int(float(x) * pow(2.0, float(n)));
}

int bit_shift_right(int x, int n) {
    return int(floor(float(x) / pow(2.0, float(n))));
}

int bitwise_and(int x, int mask) {
    return x - (x / (mask + 1)) * (mask + 1); // equivalent to x % (mask + 1) if mask is a power-of-two minus 1
}

// Or if mask is a power-of-two (e.g., 2^n), just do:
int bitwise_and_of_pow2(int x, int pow2) {
    return imod(x, pow2);
}

// Emulate `x | y` using base-2 binary math
int bitwise_or(int x, int y) {
    int result = 0;
    for (int i = 0; i < 8; ++i) {
        int bit = int(pow(2.0, float(i)));
        if (mod(float(x), float(2 * bit)) >= float(bit) ||
            mod(float(y), float(2 * bit)) >= float(bit)) {
            result += bit;
        }
    }
    return result;
}

int bitwise_xor(int x, int y) {
    int result = 0;
    for (int i = 0; i < 8; ++i) {
        int bit = int(pow(2.0, float(i)));
        bool a = mod(float(x), float(2 * bit)) >= float(bit);
        bool b = mod(float(y), float(2 * bit)) >= float(bit);
        if (a != b) {
            result += bit;
        }
    }
    return result;
}

int bitwise_not(int x, int bit_count) {
    return int(pow(2.0, float(bit_count)) - 1.0) - x;
}

int clamp(int v, int lower, int upper) {
	return (v < lower) ? lower : ((v > upper) ? upper : v);
}

float abs_float(float x) {
    return x < 0.0 ? -x : x;
}

int abs_int(int x) {
    return x < 0 ? -x : x;
}

float rand(vec2 coord, float seed) {
    return fract(sin(dot(coord + seed, vec2(12.9898, 78.233))) * 43758.5453);
}

int round(float x) {
    return int(floor(x + 0.5));
}






























void main()
{
    //gl_FragColor = vec4(0.0);
}
