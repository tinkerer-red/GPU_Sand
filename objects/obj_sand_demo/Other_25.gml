#region UI Init
ui_init = function() {
	gui_width = display_get_gui_width();
	gui_height = display_get_gui_height();
	
	mouse_gui_x = 0;
	mouse_gui_y = 0;
	mouse_left_pressed = false;
	mouse_left_down = false;
	mouse_left_released = false;
	mouse_left_previous = false;
	
	ui_font_height = string_height("A");
	ui_padding = 8;
	ui_line_height = 20;
	ui_section_gap = 6;
	ui_button_height = 22;
	ui_header_height = 26;
	ui_top_bar_height = 30;
	ui_nub_size = 22;
	ui_left_bar_width = 280;
	ui_right_bar_width = 180;
	ui_scroll_speed = 16;
	ui_slider_height = 16;
	ui_checkbox_size = 12;
	
	ui_left_bar_open = false;
	ui_right_bar_open = false;
	ui_left_bar_scroll = 0;
	ui_right_bar_scroll = 0;
	
	ui_left_bar_rect = { x1: 0, y1: 0, x2: 0, y2: 0 };
	ui_right_bar_rect = { x1: 0, y1: 0, x2: 0, y2: 0 };
	ui_top_bar_rect = { x1: 0, y1: 0, x2: 0, y2: 0 };
	ui_viewport_rect = { x1: 0, y1: 0, x2: 0, y2: 0 };
	ui_left_nub_rect = { x1: 0, y1: 0, x2: 0, y2: 0 };
	ui_right_nub_rect = { x1: 0, y1: 0, x2: 0, y2: 0 };
	
	ui_pass_names = [
		"Render",
		"Element",
		"Intent",
		"Accept",
		"Confirm",
		"Resolve",
		"Velocity"
	];
	ui_pass_modes = [
		"render",
		"element",
		"intent",
		"accept",
		"confirm",
		"resolve",
		"velocity"
	];
	ui_selected_pass_index = 0;
	
	ui_selected_element_index = 0;
	ui_elements = [
		{ name: "Sand", implemented: true, spawn_name: "sand" },
		{ name: "Dev", implemented: true, spawn_name: "dev" },
		{ name: "Water", implemented: false, spawn_name: "water" },
		{ name: "Coal", implemented: false, spawn_name: "coal" },
		{ name: "Fire", implemented: false, spawn_name: "fire" },
		{ name: "Smoke", implemented: false, spawn_name: "smoke" },
		{ name: "Steam", implemented: false, spawn_name: "steam" },
		{ name: "Oil", implemented: false, spawn_name: "oil" },
		{ name: "Acid", implemented: false, spawn_name: "acid" },
		{ name: "Stone", implemented: false, spawn_name: "stone" },
		{ name: "Lava", implemented: false, spawn_name: "lava" },
		{ name: "Ice", implemented: false, spawn_name: "ice" },
		{ name: "Snow", implemented: false, spawn_name: "snow" },
		{ name: "Mud", implemented: false, spawn_name: "mud" },
		{ name: "Ash", implemented: false, spawn_name: "ash" },
		{ name: "Metal", implemented: false, spawn_name: "metal" },
		{ name: "Gas", implemented: false, spawn_name: "gas" },
		{ name: "Plant", implemented: false, spawn_name: "plant" },
		{ name: "Wood", implemented: false, spawn_name: "wood" },
		{ name: "Ember", implemented: false, spawn_name: "ember" },
		{ name: "Salt", implemented: false, spawn_name: "salt" },
		{ name: "Glass", implemented: false, spawn_name: "glass" },
		{ name: "Spark", implemented: false, spawn_name: "spark" },
		{ name: "Slime", implemented: false, spawn_name: "slime" }
	];
	
	dev_settings = {
		state_of_matter: 3,
		gravity_force: 0.35,
		max_vel_x: 1.0,
		max_vel_y: 3.0,
		can_slip: 1.0,
		x_slip_search_range: 1.0,
		y_slip_search_range: 3.0,
		wake_chance: 0.0,
		stickiness_chance: 0.0,
		bounce_chance: 0.0,
		bounce_dampening_multiplier: 0.5,
		airborne_vel_decay_chance: 0.02,
		friction_vel_decay_chance: 0.05,
		mass: 1.0,
		can_ignite: 0.0,
		temperature_decay: 0.0,
		temperature_spread_chance: 0.0,
		explosion_resistance: 0.0,
		explosion_radius: 0.0,
		custom_event_chance: 0.0,
		replace_count: 0.0,
		replace_id_0: 0.0,
		replace_id_1: 0.0,
		replace_id_2: 0.0,
		replace_id_3: 0.0
	};
	
	ui_export_message = "";
	ui_export_timer = 0;
	
	paint_radius = 24;
};
#endregion

#region Input Helpers
ui_update_input = function() {
	gui_width = display_get_gui_width();
	gui_height = display_get_gui_height();
	
	mouse_gui_x = device_mouse_x_to_gui(0);
	mouse_gui_y = device_mouse_y_to_gui(0);
	
	mouse_left_down = mouse_check_button(mb_left);
	mouse_left_pressed = mouse_left_down && !mouse_left_previous;
	mouse_left_released = !mouse_left_down && mouse_left_previous;
	mouse_left_previous = mouse_left_down;
};

ui_point_in_rect = function(_x, _y, _rect) {
	return _x >= _rect.x1 && _x <= _rect.x2 && _y >= _rect.y1 && _y <= _rect.y2;
};

ui_make_rect = function(_x1, _y1, _x2, _y2) {
	return {
		x1: _x1,
		y1: _y1,
		x2: _x2,
		y2: _y2
	};
};
#endregion

#region Layout
ui_rebuild_layout = function() {
	var _left_width = ui_left_bar_open ? ui_left_bar_width : ui_nub_size;
	var _right_width = ui_right_bar_open ? ui_right_bar_width : ui_nub_size;
	
	ui_top_bar_rect = ui_make_rect(0, 0, gui_width, ui_top_bar_height);
	ui_left_bar_rect = ui_make_rect(0, ui_top_bar_height, _left_width, gui_height);
	ui_right_bar_rect = ui_make_rect(gui_width - _right_width, ui_top_bar_height, gui_width, gui_height);
	ui_viewport_rect = ui_make_rect(_left_width, ui_top_bar_height, gui_width - _right_width, gui_height);
	
	ui_left_nub_rect = ui_make_rect(0, ui_top_bar_height + 40, ui_nub_size, ui_top_bar_height + 40 + 80);
	ui_right_nub_rect = ui_make_rect(gui_width - ui_nub_size, ui_top_bar_height + 40, gui_width, ui_top_bar_height + 40 + 80);
};
#endregion

#region Draw Helpers
ui_draw_panel_background = function(_rect, _alpha) {
	draw_set_alpha(_alpha);
	draw_set_color(make_color_rgb(24, 24, 24));
	draw_rectangle(_rect.x1, _rect.y1, _rect.x2, _rect.y2, false);
	draw_set_alpha(1);
	draw_set_color(make_color_rgb(70, 70, 70));
	draw_rectangle(_rect.x1, _rect.y1, _rect.x2, _rect.y2, true);
};

ui_draw_button = function(_rect, _text, _selected, _enabled) {
	var _back_color = _selected ? make_color_rgb(70, 110, 160) : make_color_rgb(45, 45, 45);
	var _text_color = _enabled ? c_white : make_color_rgb(140, 140, 140);
	
	draw_set_color(_back_color);
	draw_rectangle(_rect.x1, _rect.y1, _rect.x2, _rect.y2, false);
	draw_set_color(make_color_rgb(90, 90, 90));
	draw_rectangle(_rect.x1, _rect.y1, _rect.x2, _rect.y2, true);
	draw_set_color(_text_color);
	draw_text(_rect.x1 + 6, _rect.y1 + 3, _text);
};

ui_draw_label = function(_x, _y, _text, _color) {
	draw_set_color(_color);
	draw_text(_x, _y, _text);
};

ui_draw_slider = function(_x, _y, _width, _label, _value, _min, _max) {
	var _track_y = _y + 14;
	var _track_rect = ui_make_rect(_x, _track_y, _x + _width, _track_y + 4);
	var _t = (_max == _min) ? 0 : clamp((_value - _min) / (_max - _min), 0, 1);
	var _handle_x = _x + floor(_t * _width);
	
	ui_draw_label(_x, _y, _label + ": " + string_format(_value, 0, 3), c_white);
	
	draw_set_color(make_color_rgb(70, 70, 70));
	draw_rectangle(_track_rect.x1, _track_rect.y1, _track_rect.x2, _track_rect.y2, false);
	draw_set_color(make_color_rgb(150, 150, 150));
	draw_rectangle(_handle_x - 3, _track_y - 4, _handle_x + 3, _track_y + 8, false);
	
	if (mouse_left_down) {
		var _hit_rect = ui_make_rect(_x, _y, _x + _width, _y + 24);
		if (ui_point_in_rect(mouse_gui_x, mouse_gui_y, _hit_rect)) {
			_t = clamp((mouse_gui_x - _x) / _width, 0, 1);
			return _min + ((_max - _min) * _t);
		}
	}
	
	return _value;
};

ui_draw_checkbox = function(_x, _y, _label, _value) {
	var _box_rect = ui_make_rect(_x, _y, _x + ui_checkbox_size, _y + ui_checkbox_size);
	
	draw_set_color(make_color_rgb(50, 50, 50));
	draw_rectangle(_box_rect.x1, _box_rect.y1, _box_rect.x2, _box_rect.y2, false);
	draw_set_color(make_color_rgb(90, 90, 90));
	draw_rectangle(_box_rect.x1, _box_rect.y1, _box_rect.x2, _box_rect.y2, true);
	
	if (_value > 0.5) {
		draw_set_color(c_white);
		draw_rectangle(_box_rect.x1 + 3, _box_rect.y1 + 3, _box_rect.x2 - 3, _box_rect.y2 - 3, false);
	}
	
	ui_draw_label(_x + ui_checkbox_size + 6, _y - 2, _label, c_white);
	
	if (mouse_left_pressed && ui_point_in_rect(mouse_gui_x, mouse_gui_y, ui_make_rect(_x, _y, _x + 160, _y + 18))) {
		return (_value > 0.5) ? 0.0 : 1.0;
	}
	
	return _value;
};
#endregion

#region Top Bar
ui_step_top_bar = function() {
	if (!mouse_left_pressed) {
		return;
	}
	
	var _pass_count = array_length(ui_pass_names);
	var _button_width = max(72, floor(gui_width / _pass_count));
	var _x = 0;
	var _index = 0;
	
	repeat (_pass_count) {
		var _button_rect = ui_make_rect(_x, 0, _x + _button_width, ui_top_bar_height);
		if (ui_point_in_rect(mouse_gui_x, mouse_gui_y, _button_rect)) {
			ui_selected_pass_index = _index;
			simulation.display_mode = ui_pass_modes[_index];
			break;
		}
		
		_x += _button_width;
		_index += 1;
	}
};

ui_draw_top_bar = function() {
	ui_draw_panel_background(ui_top_bar_rect, 0.9);
	
	var _pass_count = array_length(ui_pass_names);
	var _button_width = max(72, floor(gui_width / _pass_count));
	var _x = 0;
	var _index = 0;
	
	repeat (_pass_count) {
		var _button_rect = ui_make_rect(_x, 0, _x + _button_width, ui_top_bar_height);
		ui_draw_button(_button_rect, ui_pass_names[_index], _index == ui_selected_pass_index, true);
		_x += _button_width;
		_index += 1;
	}
};
#endregion

#region Left Bar
ui_build_export_text = function() {
	var _text = "";
	
	_text += "int dev_replace_ids[4];" + "\n";
	_text += "dev_replace_ids[0] = " + string(floor(dev_settings.replace_id_0)) + ";" + "\n";
	_text += "dev_replace_ids[1] = " + string(floor(dev_settings.replace_id_1)) + ";" + "\n";
	_text += "dev_replace_ids[2] = " + string(floor(dev_settings.replace_id_2)) + ";" + "\n";
	_text += "dev_replace_ids[3] = " + string(floor(dev_settings.replace_id_3)) + ";" + "\n";
	_text += "\n";
	_text += "ElementStaticData elem_static_data = ElementStaticData(" + "\n";
	_text += "\tELEM_ID_DEV," + "\n";
	_text += "\t" + string(floor(dev_settings.state_of_matter)) + "," + "\n";
	_text += "\t" + string(dev_settings.gravity_force) + "," + "\n";
	_text += "\t" + string(dev_settings.max_vel_x) + "," + "\n";
	_text += "\t" + string(dev_settings.max_vel_y) + "," + "\n";
	_text += "\t" + ((dev_settings.can_slip > 0.5) ? "true" : "false") + "," + "\n";
	_text += "\t" + string(dev_settings.x_slip_search_range) + "," + "\n";
	_text += "\t" + string(dev_settings.y_slip_search_range) + "," + "\n";
	_text += "\t" + string(dev_settings.wake_chance) + "," + "\n";
	_text += "\t" + string(dev_settings.stickiness_chance) + "," + "\n";
	_text += "\t" + string(dev_settings.bounce_chance) + "," + "\n";
	_text += "\t" + string(dev_settings.bounce_dampening_multiplier) + "," + "\n";
	_text += "\t" + string(dev_settings.airborne_vel_decay_chance) + "," + "\n";
	_text += "\t" + string(dev_settings.friction_vel_decay_chance) + "," + "\n";
	_text += "\t" + string(dev_settings.mass) + "," + "\n";
	_text += "\t" + ((dev_settings.can_ignite > 0.5) ? "true" : "false") + "," + "\n";
	_text += "\t" + string(dev_settings.temperature_decay) + "," + "\n";
	_text += "\t" + string(dev_settings.temperature_spread_chance) + "," + "\n";
	_text += "\t" + string(dev_settings.explosion_resistance) + "," + "\n";
	_text += "\t" + string(dev_settings.explosion_radius) + "," + "\n";
	_text += "\t" + string(dev_settings.custom_event_chance) + "," + "\n";
	_text += "\t" + string(floor(dev_settings.replace_count)) + "," + "\n";
	_text += "\tdev_replace_ids" + "\n";
	_text += ");";
	
	return _text;
};

ui_export_dev_element = function() {
	var _text = ui_build_export_text();
	clipboard_set_text(_text);
	ui_export_message = "Copied GLSL snippet to clipboard";
	ui_export_timer = room_speed * 2;
};

ui_step_left_bar = function() {
	if (mouse_left_pressed && ui_point_in_rect(mouse_gui_x, mouse_gui_y, ui_left_nub_rect)) {
		ui_left_bar_open = !ui_left_bar_open;
	}
	
	if (!ui_left_bar_open) {
		return;
	}
	
	var _panel_x = ui_left_bar_rect.x1 + ui_padding;
	var _panel_y = ui_left_bar_rect.y1 + ui_padding - ui_left_bar_scroll;
	var _panel_width = ui_left_bar_width - ui_padding * 2;
	var _slider_width = _panel_width - 12;
	
	var _button_rect;
	
	_panel_y += ui_header_height;
	
	dev_settings.state_of_matter = round(ui_draw_slider(_panel_x, _panel_y, _slider_width, "State Of Matter", dev_settings.state_of_matter, 0, 3));
	_panel_y += 28;
	
	dev_settings.gravity_force = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Gravity", dev_settings.gravity_force, -3, 3);
	_panel_y += 28;
	dev_settings.max_vel_x = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Max Vel X", dev_settings.max_vel_x, 0, 8);
	_panel_y += 28;
	dev_settings.max_vel_y = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Max Vel Y", dev_settings.max_vel_y, 0, 8);
	_panel_y += 28;
	
	dev_settings.can_slip = ui_draw_checkbox(_panel_x, _panel_y, "Can Slip", dev_settings.can_slip);
	_panel_y += 22;
	dev_settings.x_slip_search_range = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Slip Range X", dev_settings.x_slip_search_range, 0, 8);
	_panel_y += 28;
	dev_settings.y_slip_search_range = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Slip Range Y", dev_settings.y_slip_search_range, 0, 8);
	_panel_y += 28;
	
	dev_settings.wake_chance = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Wake Chance", dev_settings.wake_chance, 0, 1);
	_panel_y += 28;
	dev_settings.stickiness_chance = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Stickiness", dev_settings.stickiness_chance, 0, 1);
	_panel_y += 28;
	dev_settings.bounce_chance = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Bounce Chance", dev_settings.bounce_chance, 0, 1);
	_panel_y += 28;
	dev_settings.bounce_dampening_multiplier = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Bounce Dampening", dev_settings.bounce_dampening_multiplier, 0, 1);
	_panel_y += 28;
	dev_settings.airborne_vel_decay_chance = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Air Decay", dev_settings.airborne_vel_decay_chance, 0, 1);
	_panel_y += 28;
	dev_settings.friction_vel_decay_chance = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Ground Decay", dev_settings.friction_vel_decay_chance, 0, 1);
	_panel_y += 28;
	dev_settings.mass = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Mass", dev_settings.mass, 0, 8);
	_panel_y += 28;
	
	dev_settings.can_ignite = ui_draw_checkbox(_panel_x, _panel_y, "Can Ignite", dev_settings.can_ignite);
	_panel_y += 22;
	dev_settings.temperature_decay = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Temp Decay", dev_settings.temperature_decay, 0, 1);
	_panel_y += 28;
	dev_settings.temperature_spread_chance = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Temp Spread", dev_settings.temperature_spread_chance, 0, 1);
	_panel_y += 28;
	dev_settings.explosion_resistance = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Explosion Resist", dev_settings.explosion_resistance, 0, 8);
	_panel_y += 28;
	dev_settings.explosion_radius = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Explosion Radius", dev_settings.explosion_radius, 0, 8);
	_panel_y += 28;
	dev_settings.custom_event_chance = ui_draw_slider(_panel_x, _panel_y, _slider_width, "Custom Event", dev_settings.custom_event_chance, 0, 1);
	_panel_y += 28;
	
	dev_settings.replace_count = round(ui_draw_slider(_panel_x, _panel_y, _slider_width, "Replace Count", dev_settings.replace_count, 0, 4));
	_panel_y += 28;
	dev_settings.replace_id_0 = round(ui_draw_slider(_panel_x, _panel_y, _slider_width, "Replace Id 0", dev_settings.replace_id_0, 0, 255));
	_panel_y += 28;
	dev_settings.replace_id_1 = round(ui_draw_slider(_panel_x, _panel_y, _slider_width, "Replace Id 1", dev_settings.replace_id_1, 0, 255));
	_panel_y += 28;
	dev_settings.replace_id_2 = round(ui_draw_slider(_panel_x, _panel_y, _slider_width, "Replace Id 2", dev_settings.replace_id_2, 0, 255));
	_panel_y += 28;
	dev_settings.replace_id_3 = round(ui_draw_slider(_panel_x, _panel_y, _slider_width, "Replace Id 3", dev_settings.replace_id_3, 0, 255));
	_panel_y += 34;
	
	_button_rect = ui_make_rect(_panel_x, _panel_y, _panel_x + _panel_width, _panel_y + ui_button_height);
	if (mouse_left_pressed && ui_point_in_rect(mouse_gui_x, mouse_gui_y, _button_rect)) {
		ui_export_dev_element();
	}
};

ui_draw_left_bar = function() {
	if (!ui_left_bar_open) {
		ui_draw_panel_background(ui_left_nub_rect, 0.9);
		ui_draw_label(ui_left_nub_rect.x1 + 4, ui_left_nub_rect.y1 + 28, "DEV", c_white);
		return;
	}
	
	ui_draw_panel_background(ui_left_bar_rect, 0.95);
	ui_draw_label(ui_left_bar_rect.x1 + ui_padding, ui_left_bar_rect.y1 + ui_padding, "Dev Element", c_white);
	
	var _panel_x = ui_left_bar_rect.x1 + ui_padding;
	var _panel_y = ui_left_bar_rect.y1 + ui_padding + ui_header_height - ui_left_bar_scroll;
	var _panel_width = ui_left_bar_width - ui_padding * 2;
	
	ui_draw_label(_panel_x, _panel_y, "Settings", make_color_rgb(220, 220, 220));
	_panel_y += 28 * 22 + 40;
	
	var _button_rect = ui_make_rect(_panel_x, _panel_y, _panel_x + _panel_width, _panel_y + ui_button_height);
	ui_draw_button(_button_rect, "Export GLSL", false, true);
	
	if (ui_export_timer > 0) {
		ui_draw_label(_panel_x, _button_rect.y2 + 6, ui_export_message, make_color_rgb(120, 220, 120));
	}
};
#endregion

#region Right Bar
ui_step_right_bar = function() {
	if (mouse_left_pressed && ui_point_in_rect(mouse_gui_x, mouse_gui_y, ui_right_nub_rect)) {
		ui_right_bar_open = !ui_right_bar_open;
	}
	
	if (!ui_right_bar_open) {
		return;
	}
	
	var _entry_height = 22;
	var _draw_y = ui_right_bar_rect.y1 + ui_padding + ui_header_height - ui_right_bar_scroll;
	var _index = 0;
	var _count = array_length(ui_elements);
	
	repeat (_count) {
		var _entry_rect = ui_make_rect(
			ui_right_bar_rect.x1 + ui_padding,
			_draw_y,
			ui_right_bar_rect.x2 - ui_padding,
			_draw_y + _entry_height
		);
		
		if (mouse_left_pressed && ui_point_in_rect(mouse_gui_x, mouse_gui_y, _entry_rect)) {
			ui_selected_element_index = _index;
		}
		
		_draw_y += _entry_height + 4;
		_index += 1;
	}
};

ui_draw_right_bar = function() {
	if (!ui_right_bar_open) {
		ui_draw_panel_background(ui_right_nub_rect, 0.9);
		ui_draw_label(ui_right_nub_rect.x1 + 3, ui_right_nub_rect.y1 + 20, "E", c_white);
		ui_draw_label(ui_right_nub_rect.x1 + 3, ui_right_nub_rect.y1 + 38, "L", c_white);
		ui_draw_label(ui_right_nub_rect.x1 + 3, ui_right_nub_rect.y1 + 56, "M", c_white);
		return;
	}
	
	ui_draw_panel_background(ui_right_bar_rect, 0.95);
	ui_draw_label(ui_right_bar_rect.x1 + ui_padding, ui_right_bar_rect.y1 + ui_padding, "Elements", c_white);
	
	var _entry_height = 22;
	var _draw_y = ui_right_bar_rect.y1 + ui_padding + ui_header_height - ui_right_bar_scroll;
	var _index = 0;
	var _count = array_length(ui_elements);
	
	repeat (_count) {
		var _entry = ui_elements[_index];
		var _entry_rect = ui_make_rect(
			ui_right_bar_rect.x1 + ui_padding,
			_draw_y,
			ui_right_bar_rect.x2 - ui_padding,
			_draw_y + _entry_height
		);
		
		ui_draw_button(_entry_rect, _entry.name, _index == ui_selected_element_index, _entry.implemented);
		
		_draw_y += _entry_height + 4;
		_index += 1;
	}
};
#endregion

#region Viewport Helpers
ui_viewport_has_mouse = function() {
	return ui_point_in_rect(mouse_gui_x, mouse_gui_y, ui_viewport_rect);
};

ui_get_selected_spawn_name = function() {
	return ui_elements[ui_selected_element_index].spawn_name;
};
#endregion

#region Debug Helpers
debug_inspect_element = function(_x, _y) {
	var _px = surface_getpixel_ext(simulation.surf_element, _x, _y);
	var _a = (_px >> 24) & 255;
	var _b = (_px >> 16) & 255;
	var _g = (_px >> 8) & 255;
	var _r = _px & 255;
	
	var _id = _r;
	var _custom_data = _b;
	
	var _y_dir = (_g >> 7) & 1;
	var _y_speed = (_g >> 4) & 7;
	var _x_dir = (_g >> 3) & 1;
	var _x_speed = (_g >> 0) & 7;
	
	var _vx = (_x_speed / 7.0) * ((_x_dir == 1) ? -1.0 : 1.0);
	var _vy = (_y_speed / 7.0) * ((_y_dir == 1) ? -1.0 : 1.0);
	
	return {
		element_id: _id,
		custom_data: _custom_data,
		vel: [_vx, _vy],
		x_dir: _x_dir,
		y_dir: _y_dir,
		x_speed: _x_speed,
		y_speed: _y_speed,
		raw: [_r, _g, _b, _a]
	};
};
#endregion