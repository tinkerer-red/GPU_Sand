gmui_update();

var _mouse_gui_x = device_mouse_x_to_gui(0);
var _mouse_gui_y = device_mouse_y_to_gui(0);

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
	var _nub_top = nub_y;
	var _nub_right = panel_nub_width;
	var _nub_bottom = nub_y + nub_height;

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
	var _window_flags = gmui_window_flags.AUTO_VSCROLL | gmui_window_flags.SCROLL_WITH_MOUSE_WHEEL;

	if (gmui_begin(panel_title, panel_x, nub_y, panel_width, panel_height, _window_flags)) {
		if (gmui_button("<")) {
			panel_wants_open = false;
		}
		gmui_same_line();
		gmui_text("Elements");

		gmui_separator();

		var _element_count = array_length(elements);
		for (var i = 0; i < _element_count; i++) {
			var _element = elements[i];
			var _is_selected = (i == selected_element_index);

			if (gmui_selectable("   " + _element.name, _is_selected)) {
				selected_element_index = i;
				selected_element_id = _element.element_id;
				selected_element_name = _element.name;
			}
		}

		gmui_end();
	}
}

if (instance_exists(owner)) {
	if (variable_instance_exists(owner, "selected_element_index")) {
		owner.selected_element_index = selected_element_index;
	}
	if (variable_instance_exists(owner, "selected_element_id")) {
		owner.selected_element_id = selected_element_id;
	}
	if (variable_instance_exists(owner, "selected_element_name")) {
		owner.selected_element_name = selected_element_name;
	}
}