#pragma shady: import(shdSandSimCommon)
#pragma shady: inline(shdSandSimCommon.Uniforms)

#define OFFSET_RADIUS 3

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel_size;
uniform sampler2D gm_SecondaryTexture; // surf_velocity (desired velocity of a cell)

float compute_claim_score(vec2 offset) {
	// Prefer shorter moves, optionally bias straight-down later
	return dot(offset, offset);
}

void main() {
	vec4 self_px = texture2D(gm_BaseTexture, v_vTexcoord);
	ElementDynamicData elem_dynamic_data = ununpack_elem_dynamic_data(self_px);
	
	float best_score = 99999.0;
	vec2 best_offset = vec2(0.0);
	
	// Search 7x7 around this target cell for neighbors pointing at us
	for (int oy = -OFFSET_RADIUS; oy <= OFFSET_RADIUS; ++oy) {
		for (int ox = -OFFSET_RADIUS; ox <= OFFSET_RADIUS; ++ox) {
			if (ox == 0 && oy == 0) continue;
			
			vec2 offset = vec2(float(ox), float(oy));
			vec2 neighbor_uv = v_vTexcoord + offset * u_texel_size;
			
			//skip out of bounds
			if (neighbor_uv.x < 0.0 || neighbor_uv.y < 0.0 ||
				neighbor_uv.x > 1.0 || neighbor_uv.y > 1.0) continue;
			
			vec4 vel_px = texture2D(gm_SecondaryTexture, neighbor_uv);
			vec4 elem_px = texture2D(gm_BaseTexture, neighbor_uv);
			
			vec2 vel = rg_to_vel(vel_px.rg);
			
			//skip pixels which arent moving this frame
			if (vel.x == 0.0 && vel.y == 0.0) continue;
			
			// Is the neighbor trying to move into us?
			vec2 offset_dir = vec2(float(ox), float(oy));
			
			if (all(equal(-vel, offset_dir))) {
				// === Permission check (custom element logic goes here)
				bool accepted = false;
				
				//Use a while loop just so we can break out when we find a match and skip everything else
				while(true){
					#pragma shady: inline(ElemSand.ACCEPT)
					#pragma shady: inline(ElemDev.ACCEPT)
					
					accepted = true;
					break;
				}
				
				if (accepted) {
					float score = compute_claim_score(offset);
					if (score < best_score) {
						best_score = score;
						best_offset = offset_dir;
					}
				}
			}
		}
	}
	
	gl_FragColor = vec4(vel_to_rg(best_offset), 0.0, 1.0);
}