#region Debug Helpers
debug_inspect_element = function(_x, _y) {
	var _pixel = surface_getpixel_ext(simulation.surf_element, _x, _y);
	var _chan_a = (_pixel >> 24) & 255;
	var _chan_b = (_pixel >> 16) & 255;
	var _chan_g = (_pixel >> 8) & 255;
	var _chan_r = _pixel & 255;

	var _elem_id = _chan_r;
	var _custom_data = _chan_b;

	var _y_dir = (_chan_g >> 7) & 1;
	var _y_speed = (_chan_g >> 4) & 7;
	var _x_dir = (_chan_g >> 3) & 1;
	var _x_speed = (_chan_g >> 0) & 7;

	var _vel_x = (_x_speed / 7.0) * ((_x_dir == 1) ? -1.0 : 1.0);
	var _vel_y = (_y_speed / 7.0) * ((_y_dir == 1) ? -1.0 : 1.0);

	return {
		element_id: _elem_id,
		custom_data: _custom_data,
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

	var _panel_should_draw_window = ui_elem_wants_open || (ui_elem_x != ui_elem_closed_x);

	if (_panel_should_draw_window) {
		var _window_flags = gmui_window_flags.AUTO_VSCROLL | gmui_window_flags.SCROLL_WITH_MOUSE_WHEEL;

		if (gmui_begin(ui_elem_title, ui_elem_x, ui_elem_nub_y, ui_elem_expanded_width, ui_elem_height, _window_flags)) {
			gmui_text("Elements");

			gmui_separator();

			var _elem_count = array_length(ui_elements);

			for (var i = 0; i < _elem_count; i++) {
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
		draw_set_color(_elem_data.color);
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

	var _panel_should_draw_window = ui_dev_wants_open || (ui_dev_x != ui_dev_closed_x);

	if (_panel_should_draw_window) {
		var _window_flags = gmui_window_flags.AUTO_VSCROLL | gmui_window_flags.SCROLL_WITH_MOUSE_WHEEL;

		if (gmui_begin(ui_dev_title, ui_dev_x, ui_dev_margin, ui_dev_expanded_width, ui_dev_height, _window_flags)) {
			gmui_text("Dev Uniforms");

			gmui_separator();

			gmui_text("State Of Matter");
			if (gmui_selectable("Solid", dev_settings.state_of_matter == 1)) {
				dev_settings.state_of_matter = 1;
			}
			if (gmui_selectable("Liquid", dev_settings.state_of_matter == 2)) {
				dev_settings.state_of_matter = 2;
			}
			if (gmui_selectable("Gas", dev_settings.state_of_matter == 3)) {
				dev_settings.state_of_matter = 3;
			}

			gmui_separator();

			gmui_text("Movement");
			dev_settings.gravity_force = gmui_slider("Gravity Force", dev_settings.gravity_force, 0.0, 2.0);
			dev_settings.max_vel_x = gmui_slider("Max Vel X", dev_settings.max_vel_x, 0.0, 8.0);
			dev_settings.max_vel_y = gmui_slider("Max Vel Y", dev_settings.max_vel_y, 0.0, 8.0);
			dev_settings.x_slip_search_range = gmui_slider("X Slip Range", dev_settings.x_slip_search_range, 0.0, 8.0);
			dev_settings.y_slip_search_range = gmui_slider("Y Slip Range", dev_settings.y_slip_search_range, 0.0, 8.0);

			gmui_separator();

			gmui_text("Flags");
			if (gmui_button("Can Slip: " + ((dev_settings.can_slip > 0.5) ? "On" : "Off"))) {
				dev_settings.can_slip = 1.0 - dev_settings.can_slip;
			}
			if (gmui_button("Can Ignite: " + ((dev_settings.can_ignite > 0.5) ? "On" : "Off"))) {
				dev_settings.can_ignite = 1.0 - dev_settings.can_ignite;
			}

			gmui_separator();

			gmui_text("Motion Shaping");
			dev_settings.wake_chance = gmui_slider("Wake Chance", dev_settings.wake_chance, 0.0, 1.0);
			dev_settings.stickiness_chance = gmui_slider("Stickiness Chance", dev_settings.stickiness_chance, 0.0, 1.0);
			dev_settings.bounce_chance = gmui_slider("Bounce Chance", dev_settings.bounce_chance, 0.0, 1.0);
			dev_settings.bounce_dampening_multiplier = gmui_slider("Bounce Dampening", dev_settings.bounce_dampening_multiplier, 0.0, 1.0);
			dev_settings.airborne_vel_decay_chance = gmui_slider("Airborne Decay", dev_settings.airborne_vel_decay_chance, 0.0, 1.0);
			dev_settings.friction_vel_decay_chance = gmui_slider("Friction Decay", dev_settings.friction_vel_decay_chance, 0.0, 1.0);

			gmui_separator();

			gmui_text("Physical");
			dev_settings.mass = gmui_slider("Mass", dev_settings.mass, 0.0, 10.0);

			gmui_separator();

			gmui_text("Heat / Special");
			dev_settings.temperature_decay = gmui_slider("Temperature Decay", dev_settings.temperature_decay, 0.0, 10.0);
			dev_settings.temperature_spread_chance = gmui_slider("Temp Spread Chance", dev_settings.temperature_spread_chance, 0.0, 1.0);
			dev_settings.explosion_resistance = gmui_slider("Explosion Resistance", dev_settings.explosion_resistance, 0.0, 10.0);
			dev_settings.explosion_radius = gmui_slider("Explosion Radius", dev_settings.explosion_radius, 0.0, 10.0);
			dev_settings.custom_event_chance = gmui_slider("Custom Event Chance", dev_settings.custom_event_chance, 0.0, 1.0);

			gmui_separator();

			gmui_text("Replacement Rules");
			dev_settings.replace_count = round(gmui_slider("Replace Count", dev_settings.replace_count, 0.0, 4.0));
			dev_settings.replace_id_0 = round(gmui_slider("Replace ID 0", dev_settings.replace_id_0, 0.0, 255.0));
			dev_settings.replace_id_1 = round(gmui_slider("Replace ID 1", dev_settings.replace_id_1, 0.0, 255.0));
			dev_settings.replace_id_2 = round(gmui_slider("Replace ID 2", dev_settings.replace_id_2, 0.0, 255.0));
			dev_settings.replace_id_3 = round(gmui_slider("Replace ID 3", dev_settings.replace_id_3, 0.0, 255.0));

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