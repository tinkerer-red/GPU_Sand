#pragma shady: inline(shdSandSimCommon.Uniforms)
#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel_size;

void main() {
	vec4 _claim_pixel = texture2D(gm_BaseTexture, v_vTexcoord);
	vec2 _claim_offset = rg_to_vel(_claim_pixel.rg);
	vec2 _resolved_offset = _claim_offset;

	if (_claim_offset.x == 0.0 && _claim_offset.y == 0.0) {
		for (int _offset_y = -SIM_MAX_MOVE_RADIUS; _offset_y <= SIM_MAX_MOVE_RADIUS; ++_offset_y) {
			for (int _offset_x = -SIM_MAX_MOVE_RADIUS; _offset_x <= SIM_MAX_MOVE_RADIUS; ++_offset_x) {
				vec2 _neighbor_offset;
				vec2 _neighbor_texcoord;
				vec4 _neighbor_claim_pixel;
				vec2 _neighbor_claim_offset;

				if (_offset_x == 0 && _offset_y == 0) {
					continue;
				}

				_neighbor_offset = vec2(float(_offset_x), float(_offset_y));
				_neighbor_texcoord = v_vTexcoord + (_neighbor_offset * u_texel_size);

				if (!uv_in_bounds(_neighbor_texcoord)) {
					continue;
				}

				_neighbor_claim_pixel = texture2D(gm_BaseTexture, _neighbor_texcoord);
				_neighbor_claim_offset = rg_to_vel(_neighbor_claim_pixel.rg);

				if (_neighbor_claim_offset.x == -_neighbor_offset.x && _neighbor_claim_offset.y == -_neighbor_offset.y) {
					_resolved_offset = _neighbor_offset;
					break;
				}
			}

			if (_resolved_offset.x != 0.0 || _resolved_offset.y != 0.0) {
				break;
			}
		}
	}

	gl_FragColor = vec4(vel_to_rg(_resolved_offset), 0.0, 1.0);
}
