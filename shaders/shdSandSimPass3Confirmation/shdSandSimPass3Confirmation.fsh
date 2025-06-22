#pragma shady: import(shdSandSimCommon)

#define OFFSET_RADIUS 3.0

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel_size;
// gm_BaseTexture // pre-passed validity (RG)

void main() {
    vec2 my_rg = texture2D(gm_BaseTexture, v_vTexcoord).rg;
    vec2 my_vel = rg_to_vel(my_rg);

    // === Case 1: I'm already validated (no need to participate in confirmation)
    if (my_vel.x != 0.0 || my_vel.y != 0.0) {
        gl_FragColor = vec4(my_rg, 0.0, 1.0);
        return;
    }

    // === Case 2: See if anyone wants to move into my cell
    vec2 reply_offset = vec2(0.0);

    for (float oy = -OFFSET_RADIUS; oy <= OFFSET_RADIUS; ++oy) {
        for (float ox = -OFFSET_RADIUS; ox <= OFFSET_RADIUS; ++ox) {
            
			//skip self
			if (ox == 0.0 && oy == 0.0) continue;

            vec2 offset = vec2(float(ox), float(oy));
            vec2 neighbor_uv = v_vTexcoord + offset * u_texel_size;
			
            if (neighbor_uv.x < 0.0 || neighbor_uv.y < 0.0 ||
                neighbor_uv.x > 1.0 || neighbor_uv.y > 1.0)
                continue;
			
            vec2 n_rg = texture2D(gm_BaseTexture, neighbor_uv).rg;
            vec2 vel = rg_to_vel(n_rg);

            // Skip neighbors that aren't trying to move into this cell
            if (vel.x == 0.0 && vel.y == 0.0) continue;
			
            if (vel.x == -ox && vel.y == -oy) {
                reply_offset = vec2(ox, oy);
                break; // first match wins
            }
        }
        if (reply_offset.x != 0.0 && reply_offset.y != 0.0) break;
    }

    gl_FragColor = vec4(vel_to_rg(reply_offset), 0.0, 1.0);
}
