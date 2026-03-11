function CanvasSandShader() constructor {
	enum ElementId {
		EMPTY = 0,
		DEV = 1,
		SAND = 2,
		WATER = 3,
		STONE = 4,
		WALL = 5,
		WOOD = 6,
		FIRE = 7,
		SMOKE = 8,
		STEAM = 9,
		ICE = 10,
		SNOW = 11,
		MUD = 12,
		DIRT = 13,
		WET_SAND = 14,
		OIL = 15,
		LAVA = 16,
		ASH = 17,
		EMBER = 18,
		ACID = 19,
		METAL = 20,
		RUST = 21,
		GLASS = 22,
		SALT = 23,
		SALT_WATER = 24,
		PLANT = 25,
		SEED = 26,
		COAL = 27,
		GAS_FUEL = 28,
		SLIME = 29,
		OBSIDIAN = 30,
		GRAVEL = 31,
		CLAY = 32,
		__SIZE__ = 33
	}

	enum StateOfMatter {
		EMPTY = 0,
		GAS = 1,
		LIQUID = 2,
		SOLID = 3
	}

	enum MovementClass {
		NONE_STATIC = 0,
		POWDER = 1,
		LIQUID = 2,
		GAS = 3,
		VISCOUS_LIQUID = 4,
		DRIFTING_SOLID = 5,
		HEAVY_POWDER = 6,
		STICKY_POWDER = 7
	}

	enum DynamicMode {
		NONE = 0,
		LIFETIME = 1,
		TEMPERATURE = 2,
		MOISTURE = 3,
		CORROSION = 4,
		CHARGE_RESERVED = 5
	}

	enum ReplaceMode {
		EMPTY_ONLY = 0,
		LESS_DENSE = 1,
		LESS_DENSE_OR_EQUAL = 2,
		CLASS_MASK = 3,
		EXPLICIT_IDS_FALLBACK = 4
	}

	enum ReplaceMask {
		EMPTY = 1,
		GAS = 2,
		LIQUID = 4,
		SOLID = 8
	}

	enum InteractionGroup {
		INERT = 0,
		WATER_LIKE = 1,
		OIL_LIKE = 2,
		MOLTEN = 3,
		ACID_LIKE = 4,
		COMBUSTIBLE_GAS = 5,
		SMOKE_LIKE = 6,
		CRYOGENIC = 7,
		ORGANIC = 8,
		MINERAL = 9,
		METAL = 10
	}

	enum DisplayMode {
		RENDER = 0,
		ELEMENT = 1,
		INTENT = 2,
		ACCEPT = 3,
		CONFIRM = 4,
		RESOLVE = 5,
		VELOCITY = 6
	}

	surface_id = surface_create(1, 1);
	
	sim_width = window_get_width();
	sim_height = window_get_height();
	debug_view = false;
	display_mode = DisplayMode.RENDER;
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
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_movement_class"), dev_settings.movement_class);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_feature_flags"), dev_settings.feature_flags);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_dynamic_mode"), dev_settings.dynamic_mode);
	
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
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_density"), dev_settings.density);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_immovable"), dev_settings.immovable);
	
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_replace_mode"), dev_settings.replace_mode);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_replace_mask"), dev_settings.replace_mask);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_replace_count"), dev_settings.replace_count);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_replace_id_0"), dev_settings.replace_id_0);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_replace_id_1"), dev_settings.replace_id_1);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_replace_id_2"), dev_settings.replace_id_2);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_replace_id_3"), dev_settings.replace_id_3);
	
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_interaction_group"), dev_settings.interaction_group);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_interaction_mask"), dev_settings.interaction_mask);
	
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_lifetime_max"), dev_settings.lifetime_max);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_lifetime_decay_chance"), dev_settings.lifetime_decay_chance);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_transition_on_life_end"), dev_settings.transition_on_life_end);
	
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_temperature_decay"), dev_settings.temperature_decay);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_temperature_spread_chance"), dev_settings.temperature_spread_chance);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_temperature_min"), dev_settings.temperature_min);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_temperature_max"), dev_settings.temperature_max);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_transition_on_temp_low"), dev_settings.transition_on_temp_low);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_transition_on_temp_high"), dev_settings.transition_on_temp_high);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_ignition_threshold"), dev_settings.ignition_threshold);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_burn_product"), dev_settings.burn_product);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_cooling_product"), dev_settings.cooling_product);
	
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_corrosion_resistance"), dev_settings.corrosion_resistance);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_wetness_capacity"), dev_settings.wetness_capacity);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_quench_threshold"), dev_settings.quench_threshold);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_viscosity"), dev_settings.viscosity);
	
		var _color = dev_settings.color;
		var _blue = _color & 255;
		var _green = (_color >> 8) & 255;
		var _red = (_color >> 16) & 255;
		var _rgb = (_blue << 16) | (_green << 8) | _red;
		shader_set_uniform_f(shader_get_uniform(_shader, "u_dev_color"), _rgb);
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
			case DisplayMode.ELEMENT: return surf_element;
			case DisplayMode.INTENT: return surf_velocity;
			case DisplayMode.ACCEPT: return surf_valid_pre;
			case DisplayMode.CONFIRM: return surf_valid_post;
			case DisplayMode.RESOLVE: return surf_temp;
			case DisplayMode.VELOCITY: return surf_velocity;
			case DisplayMode.RENDER: return surf_render;
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
		
		if (display_mode == DisplayMode.VELOCITY || display_mode == DisplayMode.INTENT || display_mode == DisplayMode.ACCEPT || display_mode == DisplayMode.CONFIRM) {
			shader_set(shdSandSimVelocityDebug);
			draw_surface(_surface, 0, 0);
			shader_reset();
		} else {
			draw_surface(_surface, 0, 0);
		}
	};
	
	static spawn_element_circle = function(_element_id, _x, _y, _radius) {
		if (!surface_exists(surf_element)) {
			return;
		}
		
		surface_set_target(surf_element);
		draw_set_color(make_color_rgb(_element_id, 0, 0));
		draw_circle(_x, _y, _radius, false);
		surface_reset_target();
	};
}