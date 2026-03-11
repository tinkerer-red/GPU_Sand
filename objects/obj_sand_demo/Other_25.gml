#region Debug Helpers
debug_inspect_element = function(_x, _y) {
	var _pixel = surface_getpixel_ext(simulation.surf_element, _x, _y);
	var _chan_a = (_pixel >> 24) & 255;
	var _chan_b = (_pixel >> 16) & 255;
	var _chan_g = (_pixel >> 8) & 255;
	var _chan_r = _pixel & 255;

	var _elem_id = _chan_r;
	var _dynamic_byte = _chan_b;

	var _y_dir = (_chan_g >> 7) & 1;
	var _y_speed = (_chan_g >> 4) & 7;
	var _x_dir = (_chan_g >> 3) & 1;
	var _x_speed = (_chan_g >> 0) & 7;

	var _vel_x = (_x_speed / 7.0) * ((_x_dir == 1) ? -1.0 : 1.0);
	var _vel_y = (_y_speed / 7.0) * ((_y_dir == 1) ? -1.0 : 1.0);

	return {
		element_id: _elem_id,
		dynamic_byte: _dynamic_byte,
		vel: [_vel_x, _vel_y],
		x_dir: _x_dir,
		y_dir: _y_dir,
		x_speed: _x_speed,
		y_speed: _y_speed,
		raw: [_chan_r, _chan_g, _chan_b, _chan_a]
	};
};
#endregion

#region UI Helpers
ui_get_viewport_left = function() {
	var _viewport_left = 0;

	if (ui_elem_wants_open || (ui_elem_x != ui_elem_closed_x)) {
		_viewport_left = max(_viewport_left, ui_elem_x + ui_elem_expanded_width);
	}

	if (ui_dev_wants_open || (ui_dev_x != ui_dev_closed_x)) {
		_viewport_left = max(_viewport_left, ui_dev_x + ui_dev_expanded_width);
	}

	return max(0, _viewport_left);
};

ui_get_viewport_right = function() {
	var _viewport_right = display_get_gui_width();

	if (ui_pass_wants_open || (ui_pass_x != ui_pass_closed_x)) {
		_viewport_right = min(_viewport_right, ui_pass_x);
	}

	return _viewport_right;
};

ui_get_pass_surface = function(_pass_index) {
	switch (_pass_index) {
		case 1: return simulation.surf_element;
		case 2: return simulation.surf_velocity;
		case 3: return simulation.surf_valid_pre;
		case 4: return simulation.surf_valid_post;
		case 5: return simulation.surf_temp;
	}

	return -1;
};

ui_bitmask_has_flag = function(_mask, _flag) {
	return (_mask & _flag) != 0;
};

ui_bitmask_set_flag = function(_mask, _flag, _enabled) {
	if (_enabled) {
		return _mask | _flag;
	}

	return _mask & (~_flag);
};
#endregion

#region UI Element Panel
ui_elem = function() {
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _nub_left = 0;
	var _nub_top = ui_elem_nub_y;
	var _nub_right = ui_elem_nub_width;
	var _nub_bottom = ui_elem_nub_y + ui_elem_nub_height;
	var _mouse_over_nub = (
		_mouse_gui_x >= _nub_left &&
		_mouse_gui_x <= _nub_right &&
		_mouse_gui_y >= _nub_top &&
		_mouse_gui_y <= _nub_bottom
	);

	if (_mouse_over_nub && mouse_check_button_pressed(mb_left)) {
		if (ui_elem_wants_open || (ui_elem_x != ui_elem_closed_x)) {
			ui_elem_wants_open = false;
		}
		else {
			ui_dev_wants_open = false;
			ui_elem_wants_open = true;
		}
	}

	ui_elem_target_x = ui_elem_wants_open ? ui_elem_open_x : ui_elem_closed_x;
	ui_elem_x = lerp(ui_elem_x, ui_elem_target_x, ui_panel_anim_lerp);

	if (abs(ui_elem_x - ui_elem_target_x) < ui_panel_anim_epsilon) {
		ui_elem_x = ui_elem_target_x;
	}

	if (ui_elem_wants_open || (ui_elem_x != ui_elem_closed_x)) {
		var _window_flags = gmui_window_flags.AUTO_VSCROLL | gmui_window_flags.SCROLL_WITH_MOUSE_WHEEL | gmui_window_flags.NO_BORDER | gmui_window_flags.NO_TITLE_BAR;

		if (gmui_begin(ui_elem_title, ui_elem_x, ui_elem_nub_y, ui_elem_expanded_width, ui_elem_height, _window_flags)) {
			gmui_text("Elements");
			gmui_separator();

			for (var i = 0; i < array_length(ui_elements); i++) {
				var _elem_data = ui_elements[i];
				var _is_selected = (i == selected_element_index);

				if (gmui_selectable(_elem_data.name, _is_selected)) {
					selected_element_index = i;
					selected_element_id = _elem_data.element_id;
					selected_element_name = _elem_data.name;
				}
			}

			gmui_end();
		}
	}
};

ui_draw_elem_nub = function() {
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _nub_left = 0;
	var _nub_top = ui_elem_nub_y;
	var _nub_width = ui_elem_nub_width;
	var _nub_height = ui_elem_nub_height;
	var _mouse_over_nub = (
		_mouse_gui_x >= _nub_left &&
		_mouse_gui_x <= (_nub_left + _nub_width) &&
		_mouse_gui_y >= _nub_top &&
		_mouse_gui_y <= (_nub_top + _nub_height)
	);

	draw_set_alpha(0.9);
	draw_set_color(_mouse_over_nub ? make_color_rgb(70, 70, 78) : make_color_rgb(48, 48, 54));
	draw_roundrect(_nub_left, _nub_top, _nub_left + _nub_width, _nub_top + _nub_height, false);
	draw_set_alpha(1);

	if (selected_element_index >= 0 && selected_element_index < array_length(ui_elements)) {
		var _elem_data = ui_elements[selected_element_index];

		if (string_lower(_elem_data.name) == "dev") {
			draw_set_color(dev_settings.color);
		}
		else {
			draw_set_color(_elem_data.color);
		}

		draw_rectangle(_nub_left + 7, _nub_top + 8, _nub_left + 20, _nub_top + 21, false);
	}

	draw_set_color(c_white);
	draw_text_transformed(_nub_left + 7, _nub_top + 82, "ELEM", 1, 1, 90);
};
#endregion

#region UI Dev Panel
ui_dev = function() {
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _max_element_id = ElementId.__SIZE__ - 1;
	
	var _state_labels = [
		"Empty",
		"Gas",
		"Liquid",
		"Solid"
	];
	
	var _movement_labels = [
		"Static",
		"Powder",
		"Liquid",
		"Gas",
		"Viscous Liquid",
		"Drifting Solid",
		"Heavy Powder",
		"Sticky Powder"
	];
	
	var _dynamic_mode_labels = [
		"None",
		"Lifetime",
		"Temperature",
		"Moisture",
		"Corrosion",
		"Charge Reserved"
	];
	
	var _replace_mode_labels = [
		"Empty Only",
		"Less Dense",
		"Less Dense Or Equal",
		"Class Mask",
		"Explicit IDs Fallback"
	];
	
	var _interaction_labels = [
		"Inert",
		"Water",
		"Oil",
		"Molten",
		"Acid",
		"Combustible Gas",
		"Smoke",
		"Cryogenic",
		"Organic",
		"Mineral",
		"Metal"
	];

	var _feature_flag_labels = [
		{ name: "Uses Lifetime", value: 1 },
		{ name: "Uses Temperature", value: 2 },
		{ name: "Can Ignite", value: 4 },
		{ name: "Phase Changes", value: 8 },
		{ name: "Can Wet", value: 16 },
		{ name: "Can Corrode", value: 32 },
		{ name: "Emits Heat", value: 64 },
		{ name: "Reacts As Coolant", value: 128 }
	];

	var _replace_mask_labels = [
		{ name: "Empty", value: 1 },
		{ name: "Gas", value: 2 },
		{ name: "Liquid", value: 4 },
		{ name: "Solid Movable", value: 8 },
		{ name: "Same Element", value: 16 },
		{ name: "Same Group", value: 32 }
	];

	var _interaction_mask_labels = [
		{ name: "Water", value: 1 },
		{ name: "Oil", value: 2 },
		{ name: "Molten", value: 4 },
		{ name: "Acid", value: 8 },
		{ name: "Combustible Gas", value: 16 },
		{ name: "Smoke", value: 32 },
		{ name: "Cryogenic", value: 64 },
		{ name: "Organic", value: 128 },
		{ name: "Mineral", value: 256 },
		{ name: "Metal", value: 512 }
	];
	
	ui_dev_height = display_get_gui_height() - (ui_dev_margin * 2);

	var _nub_left = 0;
	var _nub_top = ui_dev_nub_y;
	var _nub_right = ui_dev_nub_width;
	var _nub_bottom = ui_dev_nub_y + ui_dev_nub_height;
	var _mouse_over_nub = (
		_mouse_gui_x >= _nub_left &&
		_mouse_gui_x <= _nub_right &&
		_mouse_gui_y >= _nub_top &&
		_mouse_gui_y <= _nub_bottom
	);

	if (_mouse_over_nub && mouse_check_button_pressed(mb_left)) {
		if (ui_dev_wants_open || (ui_dev_x != ui_dev_closed_x)) {
			ui_dev_wants_open = false;
		}
		else {
			ui_elem_wants_open = false;
			ui_dev_wants_open = true;
		}
	}

	ui_dev_target_x = ui_dev_wants_open ? ui_dev_open_x : ui_dev_closed_x;
	ui_dev_x = lerp(ui_dev_x, ui_dev_target_x, ui_panel_anim_lerp);

	if (abs(ui_dev_x - ui_dev_target_x) < ui_panel_anim_epsilon) {
		ui_dev_x = ui_dev_target_x;
	}

	if (ui_dev_wants_open || (ui_dev_x != ui_dev_closed_x)) {
		var _window_flags = gmui_window_flags.AUTO_VSCROLL | gmui_window_flags.SCROLL_WITH_MOUSE_WHEEL | gmui_window_flags.NO_BORDER | gmui_window_flags.NO_TITLE_BAR;

		if (gmui_begin(ui_dev_title, ui_dev_x, ui_dev_margin, ui_dev_expanded_width, ui_dev_height, _window_flags)) {
			gmui_text("Dev Uniforms");
			gmui_separator();

			ui_dev_section_identity_open = gmui_collapsing_header("Identity / Class", ui_dev_section_identity_open)[0];
			if (ui_dev_section_identity_open) {
				gmui_text("State of  Matter"); gmui_separator();
				dev_settings.state_of_matter = gmui_selectable_radio_group_vertical(
					_state_labels,
					dev_settings.state_of_matter
				);
				
				gmui_text("Dynamic Mode"); gmui_separator();
				dev_settings.dynamic_mode = gmui_selectable_radio_group_vertical(
					_dynamic_mode_labels,
					dev_settings.dynamic_mode
				);
				
				gmui_text("Movement Class"); gmui_separator();
				dev_settings.movement_class = gmui_selectable_radio_group_vertical(
					_movement_labels,
					dev_settings.movement_class
				);
				
				gmui_text("Feature Flags"); gmui_separator();
				for (var i = 0; i < array_length(_feature_flag_labels); i++) {
					var _feature_flag_data = _feature_flag_labels[i];
					var _feature_flag_enabled = ui_bitmask_has_flag(dev_settings.feature_flags, _feature_flag_data.value);
					var _feature_flag_next = gmui_checkbox(_feature_flag_data.name, _feature_flag_enabled);
					dev_settings.feature_flags = ui_bitmask_set_flag(dev_settings.feature_flags, _feature_flag_data.value, _feature_flag_next);
				}

				gmui_text("Feature Value"); gmui_same_line(); gmui_tab(6);
				gmui_text(string(dev_settings.feature_flags));
				
				var _col = gmui_color_button_4("Color", dev_settings.color)
				
				var _dev_rgba = gmui_color_rgb_to_color_rgba(dev_settings.color, 255);
				var _color_array = gmui_color_rgba_to_array(_dev_rgba);
				gmui_text("Color"); gmui_same_line(); gmui_color_button(_dev_rgba);
				
				gmui_text("R:"); gmui_same_line();
				_color_array[0] = clamp(gmui_input_int(_color_array[0], 1, 0, 255, 60), 0, 255);
				
				gmui_same_line(); gmui_text("G:"); gmui_same_line();
				_color_array[1] = clamp(gmui_input_int(_color_array[1], 1, 0, 255, 60), 0, 255);
				
				gmui_same_line(); gmui_text("B:"); gmui_same_line();
				_color_array[2] = clamp(gmui_input_int(_color_array[2], 1, 0, 255, 60), 0, 255);
				
				dev_settings.color = gmui_color_rgba_to_color_rgb(gmui_array_to_color_rgba(_color_array));
				gmui_collapsing_header_end();
			}

			ui_dev_section_movement_open = gmui_collapsing_header("Gravity / Movement", ui_dev_section_movement_open)[0];
			if (ui_dev_section_movement_open) {
				gmui_text("Gravity Force"); gmui_same_line(); gmui_tab(6);
				dev_settings.gravity_force = gmui_input_float(dev_settings.gravity_force, 0.05, -8.0, 8.0, 96, "");
				
				gmui_text("Max Vel X"); gmui_same_line(); gmui_tab(6);
				dev_settings.max_vel_x = gmui_input_float(dev_settings.max_vel_x, 0.1, 0.0, 16.0, 96, "");
				
				gmui_text("Max Vel Y"); gmui_same_line(); gmui_tab(6);
				dev_settings.max_vel_y = gmui_input_float(dev_settings.max_vel_y, 0.1, 0.0, 16.0, 96, "");
				
				dev_settings.can_slip = gmui_checkbox("Can Slip", dev_settings.can_slip);
				
				gmui_text("X Slip Search"); gmui_same_line(); gmui_tab(6);
				dev_settings.x_slip_search_range = gmui_input_float(dev_settings.x_slip_search_range, 1.0, 0.0, 8.0, 96, "");
				
				gmui_text("Y Slip Search"); gmui_same_line(); gmui_tab(6);
				dev_settings.y_slip_search_range = gmui_input_float(dev_settings.y_slip_search_range, 1.0, 0.0, 8.0, 96, "");
				
				gmui_text("Wake Chance"); gmui_same_line(); gmui_tab(6);
				dev_settings.wake_chance = gmui_input_float(dev_settings.wake_chance, 0.01, 0.0, 1.0, 96, "");
				gmui_collapsing_header_end();
			}

			ui_dev_section_motion_open = gmui_collapsing_header("Motion Shaping", ui_dev_section_motion_open)[0];
			if (ui_dev_section_motion_open) {
				gmui_text("Stickiness"); gmui_same_line(); gmui_tab(6);
				dev_settings.stickiness_chance = gmui_input_float(dev_settings.stickiness_chance, 0.01, 0.0, 1.0, 96, "");
				
				gmui_text("Bounce Chance"); gmui_same_line(); gmui_tab(6);
				dev_settings.bounce_chance = gmui_input_float(dev_settings.bounce_chance, 0.01, 0.0, 1.0, 96, "");
				
				gmui_text("Bounce Dampening"); gmui_same_line(); gmui_tab(6);
				dev_settings.bounce_dampening_multiplier = gmui_input_float(dev_settings.bounce_dampening_multiplier, 0.01, 0.0, 1.0, 96, "");
				
				gmui_text("Viscosity"); gmui_same_line(); gmui_tab(6);
				dev_settings.viscosity = gmui_input_float(dev_settings.viscosity, 0.01, 0.0, 1.0, 96, "");
				gmui_collapsing_header_end();
			}

			ui_dev_section_decay_open = gmui_collapsing_header("Velocity Decay", ui_dev_section_decay_open)[0];
			if (ui_dev_section_decay_open) {
				gmui_text("Airborne Decay"); gmui_same_line(); gmui_tab(6);
				dev_settings.airborne_vel_decay_chance = gmui_input_float(dev_settings.airborne_vel_decay_chance, 0.01, 0.0, 1.0, 96, "");
				
				gmui_text("Ground Decay"); gmui_same_line(); gmui_tab(6);
				dev_settings.friction_vel_decay_chance = gmui_input_float(dev_settings.friction_vel_decay_chance, 0.01, 0.0, 1.0, 96, "");
				gmui_collapsing_header_end();
			}

			ui_dev_section_physical_open = gmui_collapsing_header("Physical / Replacement", ui_dev_section_physical_open)[0];
			if (ui_dev_section_physical_open) {
				gmui_text("Mass"); gmui_same_line(); gmui_tab(6);
				dev_settings.mass = gmui_input_float(dev_settings.mass, 1.0, 0.0, 5000.0, 96, "");
				
				gmui_text("Density"); gmui_same_line(); gmui_tab(6);
				dev_settings.density = gmui_input_float(dev_settings.density, 1.0, 0.0, 5000.0, 96, "");
				
				dev_settings.immovable = gmui_checkbox("Immovable", dev_settings.immovable);
				gmui_text("Replace Mode"); gmui_separator();
				dev_settings.replace_mode = gmui_selectable_radio_group_vertical(
					_replace_mode_labels,
					dev_settings.replace_mode
				);
				
				gmui_text("Replace Mask"); gmui_separator();
				for (var i = 0; i < array_length(_replace_mask_labels); i++) {
					var _replace_mask_data = _replace_mask_labels[i];
					var _replace_mask_enabled = ui_bitmask_has_flag(dev_settings.replace_mask, _replace_mask_data.value);
					var _replace_mask_next = gmui_checkbox(_replace_mask_data.name, _replace_mask_enabled);
					dev_settings.replace_mask = ui_bitmask_set_flag(dev_settings.replace_mask, _replace_mask_data.value, _replace_mask_next);
				}

				gmui_text("Replace Mask Value"); gmui_same_line(); gmui_tab(6);
				gmui_text(string(dev_settings.replace_mask));
				
				gmui_text("Replace Count"); gmui_same_line(); gmui_tab(6);
				dev_settings.replace_count = gmui_input_int(round(dev_settings.replace_count), 1, 0, 4, 96, "");
				
				gmui_text("Replace Id 0"); gmui_same_line(); gmui_tab(6);
				dev_settings.replace_id_0 = gmui_input_int(round(dev_settings.replace_id_0), 1, 0, _max_element_id, 96, "");
				
				gmui_text("Replace Id 1"); gmui_same_line(); gmui_tab(6);
				dev_settings.replace_id_1 = gmui_input_int(round(dev_settings.replace_id_1), 1, 0, _max_element_id, 96, "");
				
				gmui_text("Replace Id 2"); gmui_same_line(); gmui_tab(6);
				dev_settings.replace_id_2 = gmui_input_int(round(dev_settings.replace_id_2), 1, 0, _max_element_id, 96, "");
				
				gmui_text("Replace Id 3"); gmui_same_line(); gmui_tab(6);
				dev_settings.replace_id_3 = gmui_input_int(round(dev_settings.replace_id_3), 1, 0, _max_element_id, 96, "");
				gmui_collapsing_header_end();
			}

			ui_dev_section_interaction_open = gmui_collapsing_header("Interaction", ui_dev_section_interaction_open)[0];
			if (ui_dev_section_interaction_open) {
				gmui_text("Interaction Group"); gmui_separator();
				dev_settings.interaction_group = gmui_selectable_radio_group_vertical(
					_interaction_labels,
					dev_settings.interaction_group
				);
				
				gmui_text("Interaction Mask"); gmui_separator();
				for (var i = 0; i < array_length(_interaction_mask_labels); i++) {
					var _interaction_mask_data = _interaction_mask_labels[i];
					var _interaction_mask_enabled = ui_bitmask_has_flag(dev_settings.interaction_mask, _interaction_mask_data.value);
					var _interaction_mask_next = gmui_checkbox(_interaction_mask_data.name, _interaction_mask_enabled);
					dev_settings.interaction_mask = ui_bitmask_set_flag(dev_settings.interaction_mask, _interaction_mask_data.value, _interaction_mask_next);
				}

				gmui_text("Interaction Mask Value"); gmui_same_line(); gmui_tab(6);
				gmui_text(string(dev_settings.interaction_mask));
				
				gmui_text("Corrosion Resist"); gmui_same_line(); gmui_tab(6);
				dev_settings.corrosion_resistance = gmui_input_float(dev_settings.corrosion_resistance, 0.05, 0.0, 4.0, 96, "");
				
				gmui_text("Wetness Capacity"); gmui_same_line(); gmui_tab(6);
				dev_settings.wetness_capacity = gmui_input_float(dev_settings.wetness_capacity, 0.05, 0.0, 4.0, 96, "");
				
				gmui_text("Quench Threshold"); gmui_same_line(); gmui_tab(6);
				dev_settings.quench_threshold = gmui_input_float(dev_settings.quench_threshold, 1.0, 0.0, 255.0, 96, "");
				gmui_collapsing_header_end();
			}

			ui_dev_section_lifecycle_open = gmui_collapsing_header("Lifecycle", ui_dev_section_lifecycle_open)[0];
			if (ui_dev_section_lifecycle_open) {
				gmui_text("Lifetime Max"); gmui_same_line(); gmui_tab(6);
				dev_settings.lifetime_max = gmui_input_float(dev_settings.lifetime_max, 1.0, 0.0, 255.0, 96, "");
				
				gmui_text("Lifetime Decay"); gmui_same_line(); gmui_tab(6);
				dev_settings.lifetime_decay_chance = gmui_input_float(dev_settings.lifetime_decay_chance, 0.01, 0.0, 1.0, 96, "");
				
				gmui_text("Life End Id"); gmui_same_line(); gmui_tab(6);
				dev_settings.transition_on_life_end = gmui_input_int(round(dev_settings.transition_on_life_end), 1, 0, _max_element_id, 96, "");
				gmui_collapsing_header_end();
			}

			ui_dev_section_temperature_open = gmui_collapsing_header("Temperature", ui_dev_section_temperature_open)[0];
			if (ui_dev_section_temperature_open) {
				gmui_text("Temp Decay"); gmui_same_line(); gmui_tab(6);
				dev_settings.temperature_decay = gmui_input_float(dev_settings.temperature_decay, 0.01, 0.0, 1.0, 96, "");
				
				gmui_text("Temp Spread"); gmui_same_line(); gmui_tab(6);
				dev_settings.temperature_spread_chance = gmui_input_float(dev_settings.temperature_spread_chance, 0.01, 0.0, 1.0, 96, "");
				
				gmui_text("Temp Min"); gmui_same_line(); gmui_tab(6);
				dev_settings.temperature_min = gmui_input_float(dev_settings.temperature_min, 1.0, -128.0, 127.0, 96, "");
				
				gmui_text("Temp Max"); gmui_same_line(); gmui_tab(6);
				dev_settings.temperature_max = gmui_input_float(dev_settings.temperature_max, 1.0, -128.0, 127.0, 96, "");
				
				gmui_text("Temp Low Id"); gmui_same_line(); gmui_tab(6);
				dev_settings.transition_on_temp_low = gmui_input_int(round(dev_settings.transition_on_temp_low), 1, 0, _max_element_id, 96, "");
				
				gmui_text("Temp High Id"); gmui_same_line(); gmui_tab(6);
				dev_settings.transition_on_temp_high = gmui_input_int(round(dev_settings.transition_on_temp_high), 1, 0, _max_element_id, 96, "");
				
				gmui_text("Ignition Thresh"); gmui_same_line(); gmui_tab(6);
				dev_settings.ignition_threshold = gmui_input_float(dev_settings.ignition_threshold, 1.0, 0.0, 255.0, 96, "");
				
				gmui_text("Burn Product"); gmui_same_line(); gmui_tab(6);
				dev_settings.burn_product = gmui_input_int(round(dev_settings.burn_product), 1, 0, _max_element_id, 96, "");
				
				gmui_text("Cooling Product"); gmui_same_line(); gmui_tab(6);
				dev_settings.cooling_product = gmui_input_int(round(dev_settings.cooling_product), 1, 0, _max_element_id, 96, "");
				gmui_collapsing_header_end();
			}

			gmui_end();
		}
	}
};
ui_draw_dev_nub = function() {
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _nub_left = 0;
	var _nub_top = ui_dev_nub_y;
	var _nub_width = ui_dev_nub_width;
	var _nub_height = ui_dev_nub_height;
	var _mouse_over_nub = (
		_mouse_gui_x >= _nub_left &&
		_mouse_gui_x <= (_nub_left + _nub_width) &&
		_mouse_gui_y >= _nub_top &&
		_mouse_gui_y <= (_nub_top + _nub_height)
	);

	draw_set_alpha(0.9);
	draw_set_color(_mouse_over_nub ? make_color_rgb(70, 70, 78) : make_color_rgb(48, 48, 54));
	draw_roundrect(_nub_left, _nub_top, _nub_left + _nub_width, _nub_top + _nub_height, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_text(_nub_left + 8, _nub_top + 8, ">");
	draw_text_transformed(_nub_left + 7, _nub_top + 72, "DEV", 1, 1, 90);
};
#endregion

#region UI Pass Panel
ui_pass = function() {
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _gui_width = display_get_gui_width();
	var _gui_width_changed = (_gui_width != ui_pass_last_gui_width);

	ui_pass_open_x = display_get_gui_width() - ui_pass_expanded_width - ui_pass_nub_width - ui_pass_margin;
	ui_pass_closed_x = _gui_width + ui_pass_margin;

	if (_gui_width_changed) {
		ui_pass_last_gui_width = _gui_width;

		if (ui_pass_wants_open) {
			ui_pass_x = ui_pass_open_x;
			ui_pass_target_x = ui_pass_open_x;
		}
		else {
			ui_pass_x = ui_pass_closed_x;
			ui_pass_target_x = ui_pass_closed_x;
		}
	}

	var _nub_left = _gui_width - ui_pass_nub_width;
	var _nub_top = ui_pass_nub_y;
	var _nub_right = _gui_width;
	var _nub_bottom = ui_pass_nub_y + ui_pass_nub_height;
	var _mouse_over_nub = (
		_mouse_gui_x >= _nub_left &&
		_mouse_gui_x <= _nub_right &&
		_mouse_gui_y >= _nub_top &&
		_mouse_gui_y <= _nub_bottom
	);

	if (_mouse_over_nub && mouse_check_button_pressed(mb_left)) {
		ui_pass_wants_open = !ui_pass_wants_open;
	}

	ui_pass_target_x = ui_pass_wants_open ? ui_pass_open_x : ui_pass_closed_x;
	ui_pass_x = lerp(ui_pass_x, ui_pass_target_x, ui_panel_anim_lerp);

	if (abs(ui_pass_x - ui_pass_target_x) < ui_panel_anim_epsilon) {
		ui_pass_x = ui_pass_target_x;
	}

	if (ui_pass_wants_open || (ui_pass_x != ui_pass_closed_x)) {
		var _window_flags = gmui_window_flags.AUTO_VSCROLL | gmui_window_flags.SCROLL_WITH_MOUSE_WHEEL | gmui_window_flags.NO_BORDER | gmui_window_flags.NO_TITLE_BAR;

		if (gmui_begin(ui_pass_title, ui_pass_x, ui_pass_margin, ui_pass_expanded_width, ui_pass_height, _window_flags)) {
			gmui_text("Pass Views");
			gmui_separator();

			for (var i = 0; i < array_length(ui_passes); i++) {
				var _pass_data = ui_passes[i];
				var _preview_surface = ui_get_pass_preview_surface(i);
				var _is_selected = (i == selected_pass_index);

				if (_preview_surface != -1) {
					gmui_surface(_preview_surface);
				}

				if (gmui_selectable(_pass_data.name, _is_selected)) {
					selected_pass_index = i;
				}

				gmui_separator();
			}

			gmui_end();
		}
	}
};

ui_draw_pass_nub = function() {
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _gui_width = display_get_gui_width();
	var _nub_left = _gui_width - ui_pass_nub_width;
	var _nub_top = ui_pass_nub_y;
	var _nub_width = ui_pass_nub_width;
	var _nub_height = ui_pass_nub_height;
	var _mouse_over_nub = (
		_mouse_gui_x >= _nub_left &&
		_mouse_gui_x <= (_nub_left + _nub_width) &&
		_mouse_gui_y >= _nub_top &&
		_mouse_gui_y <= (_nub_top + _nub_height)
	);

	draw_set_alpha(0.9);
	draw_set_color(_mouse_over_nub ? make_color_rgb(70, 70, 78) : make_color_rgb(48, 48, 54));
	draw_roundrect(_nub_left, _nub_top, _nub_left + _nub_width, _nub_top + _nub_height, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_text(_nub_left + 8, _nub_top + 8, "<");
	draw_set_align(1);
	draw_text_transformed(_nub_left + 6, _nub_top + 38, "PASS", 1, 1, 270);
	draw_set_align(7);
};

ui_draw_pass_surface = function(_pass_index, _draw_x, _draw_y, _scale_x, _scale_y) {
	var _surface_id = ui_get_pass_surface(_pass_index);
	var _pass_data = ui_passes[_pass_index];

	if (_surface_id == -1) {
		if (_scale_x == 1 && _scale_y == 1 && _draw_x == 0 && _draw_y == 0) {
			simulation.draw();
		}
		else {
			var _cache_width = max(1, round(simulation.sim_width * _scale_x));
			var _cache_height = max(1, round(simulation.sim_height * _scale_y));
			var _cache_name = "pass_render_preview_" + string(_cache_width) + "_" + string(_cache_height);
			var _cache_surface = gmui_cache_surface_get(_cache_name, _cache_width, _cache_height);

			if (surface_exists(_cache_surface)) {
				surface_set_target(_cache_surface);
				draw_clear_alpha(c_black, 0);
				matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, _scale_x, _scale_y, 1));
				simulation.draw();
				matrix_set(matrix_world, matrix_build_identity());
				surface_reset_target();

				if (_pass_data.shader_id != -1) {
					shader_set(_pass_data.shader_id);
					draw_surface(_cache_surface, _draw_x, _draw_y);
					shader_reset();
				}
				else {
					draw_surface(_cache_surface, _draw_x, _draw_y);
				}
			}
		}

		exit;
	}

	if (!surface_exists(_surface_id)) {
		exit;
	}

	if (_pass_data.shader_id != -1) {
		shader_set(_pass_data.shader_id);
		draw_surface_ext(_surface_id, _draw_x, _draw_y, _scale_x, _scale_y, 0, c_white, 1);
		shader_reset();
	}
	else {
		draw_surface_ext(_surface_id, _draw_x, _draw_y, _scale_x, _scale_y, 0, c_white, 1);
	}
};

ui_get_pass_preview_surface = function(_pass_index) {
	var _pass_data = ui_passes[_pass_index];
	var _surface_id = ui_get_pass_surface(_pass_index);
	var _preview_width = ui_pass_preview_width;
	var _preview_height = max(1, round(simulation.sim_height * ui_pass_preview_scale));
	var _cache_name = "pass_preview_" + string(_pass_index);
	var _preview_surface = gmui_cache_surface_get(_cache_name, _preview_width, _preview_height);

	if (!surface_exists(_preview_surface)) {
		return -1;
	}

	surface_set_target(_preview_surface);
	draw_clear_alpha(c_black, 0);

	if (_surface_id == -1) {
		var _render_scale_x = _preview_width / simulation.sim_width;
		var _render_scale_y = _preview_height / simulation.sim_height;
		matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, _render_scale_x, _render_scale_y, 1));
		simulation.draw();
		matrix_set(matrix_world, matrix_build_identity());
	}
	else if (surface_exists(_surface_id)) {
		var _surface_scale_x = _preview_width / surface_get_width(_surface_id);
		var _surface_scale_y = _preview_height / surface_get_height(_surface_id);

		if (_pass_data.shader_id != -1) {
			shader_set(_pass_data.shader_id);
			draw_surface_ext(_surface_id, 0, 0, _surface_scale_x, _surface_scale_y, 0, c_white, 1);
			shader_reset();
		}
		else {
			draw_surface_ext(_surface_id, 0, 0, _surface_scale_x, _surface_scale_y, 0, c_white, 1);
		}
	}

	surface_reset_target();

	return _preview_surface;
};
#endregion
