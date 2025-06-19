#pragma shady: import(shdSandSimCommon)

#define OFFSET_RADIUS 3

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel_size;
uniform sampler2D gm_SecondaryTexture; // velocity surface (RG)

// Score movement priority by proximity
float compute_claim_score(vec2 offset) {
    return dot(offset, offset);
}

void main() {
    float best_score = 99999.0;
    ivec2 best_offset = ivec2(0);
	
    for (int oy = -OFFSET_RADIUS; oy <= OFFSET_RADIUS; ++oy) {
        for (int ox = -OFFSET_RADIUS; ox <= OFFSET_RADIUS; ++ox) {
            
			//skip self
			if (ox == 0 && oy == 0) continue;
			
            vec2 offset = vec2(float(ox), float(oy));
            vec2 neighbor_uv = v_vTexcoord + offset * u_texel_size;
			
			//skip out of bounds
            if (neighbor_uv.x < 0.0 || neighbor_uv.y < 0.0 ||
                neighbor_uv.x > 1.0 || neighbor_uv.y > 1.0) continue;
			
			
            vec4 neighbor_px = texture2D(gm_SecondaryTexture, neighbor_uv);
            ivec2 vel = rg_to_vel(neighbor_px.rg);
			
            // Is the neighbor trying to move into us?
            ivec2 incoming_dir = ivec2(-ox, -oy);
			if (vel.x == incoming_dir.x && vel.y == incoming_dir.y) {
			    float score = compute_claim_score(vec2(ox, oy));
			    if (score < best_score) {
			        best_score = score;
			        best_offset = -incoming_dir;
			    }
			}

        }
    }

    gl_FragColor = vec4(vel_to_rg(best_offset), 0.0, 1.0);
}
