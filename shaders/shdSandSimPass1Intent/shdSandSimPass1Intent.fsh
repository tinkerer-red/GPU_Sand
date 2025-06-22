#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel_size;
uniform float u_frame;


void main() {
    vec4 self_pixel = texture2D(gm_BaseTexture, v_vTexcoord);
    ElementDynamicData elem_dynamic_data = ununpack_elem_dynamic_data(self_pixel);
	ElementStaticData elem_static_data = get_element_static_data(elem_dynamic_data.id);
	
    //Use a while loop just so we can break out when we find a match and skip everything else
	while(true){
		#pragma shady: inline(ElemSand.INTENT)
		
		break;
	}
	
	#region Movement / Physics
    while (true) {
		// === Cache static fields for clarity ===
		float gravity_force       = elem_static_data.gravity_force;
		float x_search              = elem_static_data.x_search;
		float y_search              = elem_static_data.y_search;
		float max_vel_x             = elem_static_data.max_vel_x;
		float max_vel_y             = elem_static_data.max_vel_y;
		float stickiness            = elem_static_data.stickiness;
		float inertial_resist       = elem_static_data.inertial_resistance;
		float bounce_chance       = elem_static_data.bounce_chance;
		bool can_slip              = elem_static_data.can_slip;
		
		// === Apply Gravity Accumulator ===
		// (Assumes a float gravity accumulator system)
		elem_dynamic_data.vel.y = clamp(elem_dynamic_data.vel.y + gravity_force, -max_vel_y, max_vel_y);

		// === Air Resistance on X ===
		if (abs_float(elem_dynamic_data.vel.x) >= max_vel_x && inertial_resist > 0.0) {
			if (chance(0.2, v_vTexcoord + vec2(1.234, 4.567), u_frame)) {
				float dir = sign_float(elem_dynamic_data.vel.x);
				elem_dynamic_data.vel.x = clamp(elem_dynamic_data.vel.x - dir, -max_vel_x, max_vel_x);
				elem_dynamic_data.x_speed = int(abs_float(elem_dynamic_data.vel.x));
				elem_dynamic_data.x_dir = (dir > 0.0) ? 1 : 0;
			}
		}

		// === Attempt velocity-based movement ===
		if (abs_float(elem_dynamic_data.vel.x) > 1.0 || abs_float(elem_dynamic_data.vel.y) > 1.0) {
			vec2 vel_uv = v_vTexcoord + vec2(elem_dynamic_data.vel) * u_texel_size;
			vec4 vel_px = texture2D(gm_BaseTexture, vel_uv);
			int vel_id = elem_get_index(vel_px);
			ElementStaticData vel_static_data = get_element_static_data(vel_id);
			
			if (vel_id == 0 || element_can_replace(elem_static_data, vel_static_data)) {
				break; // Success: move into intended velocity cell
			}
			
			// === Bounce Logic ===
			if (chance(bounce_chance, v_vTexcoord + vec2(0.987, 0.321), u_frame)) {
				// === Sample 4-neighbor cells to estimate slope ===
				bool s_l = cell_is_solid(texture2D(gm_BaseTexture, v_vTexcoord + vec2(-1,  0) * u_texel_size));
				bool s_r = cell_is_solid(texture2D(gm_BaseTexture, v_vTexcoord + vec2( 1,  0) * u_texel_size));
				bool s_u = cell_is_solid(texture2D(gm_BaseTexture, v_vTexcoord + vec2( 0, -1) * u_texel_size));
				bool s_d = cell_is_solid(texture2D(gm_BaseTexture, v_vTexcoord + vec2( 0,  1) * u_texel_size));

				float g_x = float(s_r) - float(s_l);
				float g_y = float(s_d) - float(s_u);
				vec2 slope = vec2(g_x, g_y);

				if (length(slope) > 0.0) {
					vec2 v = vec2(elem_dynamic_data.vel);
					vec2 n = normalize(slope);
					vec2 bounce = v - 2.0 * dot(v, n) * n;

					// Dampen and add slight randomness
					float jitter = 0.9 + rand(v_vTexcoord, u_frame) * 0.15;
					bounce *= jitter;

					// Clamp and assign back to dynamic data
					bounce.x = clamp(bounce.x, -max_vel_x, max_vel_x);
					bounce.y = clamp(bounce.y, -max_vel_y, max_vel_y);

					elem_dynamic_data.vel = bounce;
					elem_dynamic_data.x_speed = int(abs_float(elem_dynamic_data.vel.x));
					elem_dynamic_data.x_dir   = (elem_dynamic_data.vel.x > 0.0) ? 1 : 0;
					elem_dynamic_data.y_speed = int(abs_float(elem_dynamic_data.vel.y));
					elem_dynamic_data.y_dir   = (elem_dynamic_data.vel.y > 0.0) ? 1 : 0;

					break; // Bounce intent issued
				}
			}
		}

		// === Fallback vertical search ===
		bool moved = false;
		float g_dir = sign_float(gravity_force);
		for (float dy = g_dir; abs_float(dy) <= y_search; dy += g_dir) {
			vec2 down_uv = v_vTexcoord + vec2(0.0, float(dy)) * u_texel_size;
			vec4 down_px = texture2D(gm_BaseTexture, down_uv);
			int down_id = elem_get_index(down_px);
			ElementStaticData down_static = get_element_static_data(down_id);

			if (down_id == 0 || element_can_replace(elem_static_data, down_static)) {
				elem_dynamic_data.vel = vec2(0.0, dy);
				moved = true;
				break;
			}
		}

		// === Fallback slip diagonally ===
		if (!moved && can_slip) {
			float dx = (rand(v_vTexcoord, u_frame) < 0.5) ? -1.0 : 1.0;
			for (float i = 1.0; i <= x_search; ++i) {
				vec2 diag_uv = v_vTexcoord + vec2(float(i * dx), g_dir) * u_texel_size;
				vec4 diag_px = texture2D(gm_BaseTexture, diag_uv);
				int diag_id = elem_get_index(diag_px);
				ElementStaticData diag_static = get_element_static_data(diag_id);

				if (diag_id == 0 || element_can_replace(elem_static_data, diag_static)) {
					elem_dynamic_data.vel = vec2(i * dx, g_dir);
					break;
				}
			}
		}
		
		break;
	}
	#endregion
	
	// Default to no movement
	gl_FragColor = vec4(vel_to_rg(elem_dynamic_data.vel), 0.0, 1.0);
}
