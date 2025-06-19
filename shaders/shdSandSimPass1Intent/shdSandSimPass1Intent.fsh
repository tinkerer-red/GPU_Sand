#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel_size;
uniform float u_frame;

void main() {
    vec4 self_pixel = texture2D(gm_BaseTexture, v_vTexcoord);
    int id = get_cell_index(self_pixel);

    ivec2 velocity = ivec2(0, 0);
	
	//if sand, set intended velocity
    if (id == 255) {
        // === 1. Try straight down ===
        vec2 dir = vec2(0.0, u_texel_size.y);
        vec2 dst_uv = v_vTexcoord + dir;
        int dst_id = get_cell_index(texture2D(gm_BaseTexture, dst_uv));

        if (dst_id == 0) {
            velocity.y = 1;
        } else {
            // === 2. Randomly choose left or right ===
            float bias = rand(v_vTexcoord, u_frame);
            int dx = (bias < 0.5) ? -1 : 1;

            // First attempt
            vec2 diag1_uv = v_vTexcoord + vec2(float(dx), 1.0) * u_texel_size;
            int diag1_id = get_cell_index(texture2D(gm_BaseTexture, diag1_uv));

            if (diag1_id == 0) {
                velocity = ivec2(dx, 1);
            } else {
                // Invert direction and try other side
                dx = -dx;
                vec2 diag2_uv = v_vTexcoord + vec2(float(dx), 1.0) * u_texel_size;
                int diag2_id = get_cell_index(texture2D(gm_BaseTexture, diag2_uv));

                if (diag2_id == 0) {
                    velocity = ivec2(dx, 1);
                }
            }
        }

        gl_FragColor = vec4(vel_to_rg(velocity), 0.0, 1.0);
    }
	//default to no velocity
	else {
        gl_FragColor = vec4(vel_to_rg(ivec2(0, 0)), 0.0, 1.0);
    }
}
