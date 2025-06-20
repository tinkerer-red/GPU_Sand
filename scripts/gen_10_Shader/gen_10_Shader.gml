function CanvasSandShader() : SimulationCore() constructor {
	// === Configuration ===
	sim_width  = window_get_width();
	sim_height = window_get_height();
	debug_view = true;
	
	// === Simulation Textures ===
	surf_element    = -1; // Red: Element ID
	surf_velocity   = -1; // (RG) x,y desired velocity
	surf_valid_pre  = -1; // (RG) x,y approved swaps
	surf_valid_post = -1; // (RG) x,y approved swaps
	surf_render     = -1; // (RG) 
	surf_temp       = -1; // double buffer
	
	// === Shader Uniform Handles ===
	uniform_texel_size = -1;
	uniform_pass_id    = -1;
	uniform_frame      = -1;
	
	// === Sampler Index Handles ===
	texture_stage_1 = -1;
	texture_stage_2 = -1;
	
	// === Internal Step Counter ===
	frame_count = 0;

	// === Uniform Setup Helper ===
	static set_common_uniforms = function(_shader) {
		uniform_texel_size = shader_get_uniform(_shader, "u_texel_size");
		uniform_frame      = shader_get_uniform(_shader, "u_frame");
		
		shader_set_uniform_f(uniform_texel_size, 1 / sim_width, 1 / sim_height);
		shader_set_uniform_f(uniform_frame, frame_count);
		
		frame_count++
	};
	
	static set_sampler_indices = function(_shader) {
		texture_stage_1 = shader_get_sampler_index(_shader, "gm_SecondaryTexture");
		texture_stage_2 = shader_get_sampler_index(_shader, "gm_TertiaryTexture");
	};

	// === Step Function ===
	static step = function() {
		if (!surface_exists(surf_element) || !surface_exists(surf_velocity)) return;
		
		//spawn_element_circle("sand", sim_width/2, sim_height/2, 32)
		
		surface_clear(surf_velocity);
		surface_clear(surf_valid_pre);
		surface_clear(surf_valid_post);
		surface_clear(surf_temp);
		surface_clear(surf_render);
		
		// === PASS 1: Logic Generation (intent) ===
		shader_set(shdSandSimPass1Intent);
		{
			set_common_uniforms(shdSandSimPass1Intent);
			surface_set_target(surf_velocity);
			draw_surface(surf_element, 0, 0);
			surface_reset_target();
		}
		shader_reset();
		
		// === PASS 2: Validation (intent approval) ===
		shader_set(shdSandSimPass2Acceptance);
		{
			set_common_uniforms(shdSandSimPass2Acceptance);
			set_sampler_indices(shdSandSimPass2Acceptance);
			texture_set_stage(texture_stage_1, surface_get_texture(surf_velocity));
			surface_set_target(surf_valid_pre);
			draw_surface(surf_element, 0, 0);
			//draw_rectangle(0, 0, sim_width, sim_height, false);
			surface_reset_target();
		}
		shader_reset();

		//// === PASS 3: Invalidate Old Positions ===
		shader_set(shdSandSimPass3Confirmation);
		{
			set_common_uniforms(shdSandSimPass3Confirmation);
			///// UNUSED ////////////////////////////////////////////////////////////
			//  set_sampler_indices(undefined);
			//  texture_set_stage(texture_stage_1, surface_get_texture(surf_velocity));
			/////////////////////////////////////////////////////////////////////////
			surface_set_target(surf_valid_post);
			draw_surface(surf_valid_pre, 0, 0);
			surface_reset_target();
		}
		shader_reset();
		

		////// === PASS 4: Resolve Movement ===
		shader_set(shdSandSimPass4Resolve);
		{
			set_common_uniforms(shdSandSimPass4Resolve);
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
	

	// === Draw Final Image ===
	static draw = function() {
		// Surface rebuilding must occur in draw event to avoid referencing application surface
		surf_element    = surface_rebuild(surf_element,    sim_width, sim_height, surface_rgba8unorm);
		surf_velocity   = surface_rebuild(surf_velocity,   sim_width, sim_height, surface_rgba8unorm);
		surf_valid_pre  = surface_rebuild(surf_valid_pre,  sim_width, sim_height, surface_rgba8unorm);
		surf_valid_post = surface_rebuild(surf_valid_post, sim_width, sim_height, surface_rgba8unorm);
		surf_temp       = surface_rebuild(surf_temp,       sim_width, sim_height, surface_rgba8unorm);
		
		surf_render     = surface_rebuild(surf_render,     sim_width, sim_height, surface_rgba8unorm);
		
		if (!surface_exists(surf_render)) return;
		
		// === PASS 4: Render Output ===
		shader_set(shdSandSimPass5Render);
		{
			texture_set_stage(0, surface_get_texture(surf_element));

			surface_set_target(surf_render);
			draw_surface(surf_element, 0, 0);
			surface_reset_target();
		}
		shader_reset();
		
		draw_surface(surf_element, 0, 0);
		
		// === Debug View: Display Simulation Buffers ===
		if (debug_view) {
			draw_set_color(c_white);
			
			var _scale = 0.15
			var _text_height = string_height("_")
			var _surf_height = sim_height*_scale
			
			var y_off = 100;
			
			draw_surface_ext(surf_element, 0, y_off, _scale, _scale, 0, c_white, 1);
			draw_text(0, y_off, "surf_element");
			y_off += _surf_height
			
			
			shader_set(shdSandSimVelocityDebug)
			draw_surface_ext(surf_velocity, 0, y_off, _scale, _scale, 0, c_white, 1);
			shader_reset()
			draw_text(0, y_off, "surf_velocity");
			y_off += _surf_height
			
			shader_set(shdSandSimVelocityDebug)
			draw_surface_ext(surf_valid_pre, 0, y_off, _scale, _scale, 0, c_white, 1);
			shader_reset()
			draw_text(0, y_off, "surf_valid_pre");
			y_off += _surf_height
			
			shader_set(shdSandSimVelocityDebug)
			draw_surface_ext(surf_valid_post, 0, y_off, _scale, _scale, 0, c_white, 1);
			shader_reset()
			draw_text(0, y_off, "surf_valid_post");
			y_off += _surf_height
			
			//shader_set(shdSandSimVelocityDebug)
			draw_surface_ext(surf_temp, 0, y_off, _scale, _scale, 0, c_white, 1);
			//shader_reset()
			draw_text(0, y_off, "surf_temp");
			y_off += _surf_height
			
			
			
			
			//shader_set(shdSandSimVelocityDebug)
			//draw_surface(surf_velocity, 0, 0);
			//draw_surface(surf_valid_pre, 0, 0);
			//draw_surface(surf_valid_post, 0, 0);
			//shader_reset()
			
			
		}
		
		//draw_set_alpha(0.25)
		//draw_surface(surf_element, 0, 0);
		//draw_surface(surf_velocity, 0, 0);
		//draw_surface(surf_valid_pre, 0, 0);
		//draw_surface(surf_valid_post, 0, 0);
		//draw_surface(surf_temp, 0, 0);
		//draw_set_alpha(1.0)
		
	};

	// === Spawn Elements ===
	static spawn_element_circle = function(_element, _x, _y, _radius) {
		if (!surface_exists(surf_element)) return;
		var _col = (_element == "sand") ? c_red : c_black;

		surface_set_target(surf_element);
		draw_set_color(_col);
		draw_circle(_x, _y, _radius, false);
		surface_reset_target();
	};
}


