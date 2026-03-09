function CanvasSandShader() constructor {
	surface_id = surface_create(1, 1);
	
	sim_width = window_get_width();
	sim_height = window_get_height();
	debug_view = false;
	display_mode = "render";
	dev_settings = undefined;
	
	surf_element = -1;
	surf_velocity = -1;
	surf_valid_pre = -1;
	surf_valid_post = -1;
	surf_render = -1;
	surf_temp = -1;
	
	uniform_texel_size = -1;
	uniform_frame = -1;
	
	texture_stage_1 = -1;
	texture_stage_2 = -1;
	
	frame_count = 0;
	
	static set_common_uniforms = function(_shader) {
		uniform_texel_size = shader_get_uniform(_shader, "u_texel_size");
		uniform_frame = shader_get_uniform(_shader, "u_frame");
		
		shader_set_uniform_f(uniform_texel_size, 1 / sim_width, 1 / sim_height);
		shader_set_uniform_f(uniform_frame, frame_count);
		
		frame_count += 1;
		frame_count = (frame_count >= 60) ? -60 : frame_count;
	};
	
	static set_sampler_indices = function(_shader) {
		texture_stage_1 = shader_get_sampler_index(_shader, "gm_SecondaryTexture");
		texture_stage_2 = shader_get_sampler_index(_shader, "gm_TertiaryTexture");
	};
	
	static set_dev_uniforms = function(_shader) {
		if (is_undefined(dev_settings)) {
			return;
		}
		
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_state_of_matter"), dev_settings.state_of_matter);
		
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_gravity_force"), dev_settings.gravity_force);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_max_vel_x"), dev_settings.max_vel_x);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_max_vel_y"), dev_settings.max_vel_y);
		
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_can_slip"), dev_settings.can_slip);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_x_slip_search_range"), dev_settings.x_slip_search_range);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_y_slip_search_range"), dev_settings.y_slip_search_range);
		
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_wake_chance"), dev_settings.wake_chance);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_stickiness_chance"), dev_settings.stickiness_chance);
		
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_bounce_chance"), dev_settings.bounce_chance);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_bounce_dampening_multiplier"), dev_settings.bounce_dampening_multiplier);
		
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_airborne_vel_decay_chance"), dev_settings.airborne_vel_decay_chance);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_friction_vel_decay_chance"), dev_settings.friction_vel_decay_chance);
		
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_mass"), dev_settings.mass);
		
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_can_ignite"), dev_settings.can_ignite);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_temperature_decay"), dev_settings.temperature_decay);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_temperature_spread_chance"), dev_settings.temperature_spread_chance);
		
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_explosion_resistance"), dev_settings.explosion_resistance);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_explosion_radius"), dev_settings.explosion_radius);
		
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_custom_event_chance"), dev_settings.custom_event_chance);
		
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_replace_count"), dev_settings.replace_count);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_replace_id_0"), dev_settings.replace_id_0);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_replace_id_1"), dev_settings.replace_id_1);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_replace_id_2"), dev_settings.replace_id_2);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_replace_id_3"), dev_settings.replace_id_3);
		
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_color"), dev_settings.color);
	};
	
	static rebuild_surfaces = function() {
		surf_element = surface_rebuild(surf_element, sim_width, sim_height, surface_rgba8unorm);
		surf_velocity = surface_rebuild(surf_velocity, sim_width, sim_height, surface_rgba8unorm);
		surf_valid_pre = surface_rebuild(surf_valid_pre, sim_width, sim_height, surface_rgba8unorm);
		surf_valid_post = surface_rebuild(surf_valid_post, sim_width, sim_height, surface_rgba8unorm);
		surf_temp = surface_rebuild(surf_temp, sim_width, sim_height, surface_rgba8unorm);
		surf_render = surface_rebuild(surf_render, sim_width, sim_height, surface_rgba8unorm);
	};
	
	static step = function() {
		if (!surface_exists(surf_element) || !surface_exists(surf_velocity)) {
			return;
		}
		
		surface_clear(surf_velocity);
		surface_clear(surf_valid_pre);
		surface_clear(surf_valid_post);
		surface_clear(surf_temp);
		surface_clear(surf_render);
		
		shader_set(shdSandSimPass1Intent);
		{
			set_common_uniforms(shdSandSimPass1Intent);
			set_dev_uniforms(shdSandSimPass1Intent);
			surface_set_target(surf_velocity);
			draw_surface(surf_element, 0, 0);
			surface_reset_target();
		}
		shader_reset();
		
		shader_set(shdSandSimPass2Acceptance);
		{
			set_common_uniforms(shdSandSimPass2Acceptance);
			set_dev_uniforms(shdSandSimPass2Acceptance);
			set_sampler_indices(shdSandSimPass2Acceptance);
			texture_set_stage(texture_stage_1, surface_get_texture(surf_velocity));
			surface_set_target(surf_valid_pre);
			draw_surface(surf_element, 0, 0);
			surface_reset_target();
		}
		shader_reset();
		
		shader_set(shdSandSimPass3Confirmation);
		{
			set_common_uniforms(shdSandSimPass3Confirmation);
			surface_set_target(surf_valid_post);
			draw_surface(surf_valid_pre, 0, 0);
			surface_reset_target();
		}
		shader_reset();
		
		shader_set(shdSandSimPass4Resolve);
		{
			set_common_uniforms(shdSandSimPass4Resolve);
			set_dev_uniforms(shdSandSimPass4Resolve);
			set_sampler_indices(shdSandSimPass4Resolve);
			texture_set_stage(texture_stage_1, surface_get_texture(surf_velocity));
			texture_set_stage(texture_stage_2, surface_get_texture(surf_valid_post));
			surface_set_target(surf_temp);
			draw_surface(surf_element, 0, 0);
			surface_reset_target();
			
			var _swap = surf_element;
			surf_element = surf_temp;
			surf_temp = _swap;
		}
		shader_reset();
	};
	
	static get_display_surface = function() {
		switch (display_mode) {
			case "element": return surf_element;
			case "intent": return surf_velocity;
			case "accept": return surf_valid_pre;
			case "confirm": return surf_valid_post;
			case "resolve": return surf_temp;
			case "velocity": return surf_velocity;
			case "render": return surf_render;
		}
		
		return surf_render;
	};
	
	static draw = function() {
		rebuild_surfaces();
		
		if (!surface_exists(surf_render)) {
			return;
		}
		
		shader_set(shdSandSimPass5Render);
		{
			set_dev_uniforms(shdSandSimPass5Render);
			surface_set_target(surf_render);
			draw_surface(surf_element, 0, 0);
			surface_reset_target();
		}
		shader_reset();
		
		var _surface = get_display_surface();
		
		if (display_mode == "velocity" || display_mode == "intent" || display_mode == "accept" || display_mode == "confirm") {
			shader_set(shdSandSimVelocityDebug);
			draw_surface(_surface, 0, 0);
			shader_reset();
		} else {
			draw_surface(_surface, 0, 0);
		}
	};
	
	static spawn_element_circle = function(_element, _x, _y, _radius) {
		if (!surface_exists(surf_element)) {
			return;
		}
		
		var _col;
		
		switch (string_lower(_element)) {
			case "sand":
				_col = make_color_rgb(255, 0, 0);
			break;
			
			case "dev":
				_col = make_color_rgb(200, 0, 0);
			break;
			
			default:
				_col = make_color_rgb(0, 0, 0);
			break;
		}
		
		surface_set_target(surf_element);
		draw_set_color(_col);
		draw_circle(_x, _y, _radius, false);
		surface_reset_target();
	};
}