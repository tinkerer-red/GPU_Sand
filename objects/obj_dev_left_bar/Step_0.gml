gmui_update();

var _mouse_gui_x = device_mouse_x_to_gui(0);
var _mouse_gui_y = device_mouse_y_to_gui(0);

if (instance_exists(owner)) {
	if (variable_instance_exists(owner, "dev_settings")) {
		dev_settings = owner.dev_settings;
	}
}

panel_height = display_get_gui_height() - (panel_margin * 2);

panel_target_x = panel_wants_open ? panel_open_x : panel_closed_x;
panel_x = lerp(panel_x, panel_target_x, panel_anim_lerp);

if (abs(panel_x - panel_target_x) < panel_anim_epsilon) {
	panel_x = panel_target_x;
}

panel_width = panel_expanded_width;
panel_target_width = panel_expanded_width;

var _panel_is_fully_closed = (panel_x == panel_closed_x);
var _panel_should_draw_window = panel_wants_open || !_panel_is_fully_closed;

if (_panel_is_fully_closed) {
	var _nub_left = 0;
	var _nub_top = panel_margin;
	var _nub_right = panel_nub_width;
	var _nub_bottom = panel_margin + 96;

	var _mouse_over_nub = (
		_mouse_gui_x >= _nub_left &&
		_mouse_gui_x <= _nub_right &&
		_mouse_gui_y >= _nub_top &&
		_mouse_gui_y <= _nub_bottom
	);

	if (_mouse_over_nub && mouse_check_button_pressed(mb_left)) {
		panel_wants_open = true;
	}
}

if (_panel_should_draw_window) {
	var _window_flags = gmui_window_flags.AUTO_VSCROLL | gmui_window_flags.SCROLL_WITH_MOUSE_WHEEL | gmui_window_flags.NO_CLOSE | gmui_window_flags.NO_TITLE_BAR;

	if (gmui_begin(panel_title, panel_x, panel_margin, panel_width, panel_height, _window_flags)) {
		if (gmui_button("<")) {
			panel_wants_open = false;
		}
		gmui_same_line();
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

if (instance_exists(owner)) {
	if (variable_instance_exists(owner, "dev_settings")) {
		owner.dev_settings = dev_settings;
	}
}