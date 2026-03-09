var _mouse_gui_x = device_mouse_x_to_gui(0);
var _mouse_gui_y = device_mouse_y_to_gui(0);

var _panel_is_fully_closed = (panel_x == panel_closed_x);

if (_panel_is_fully_closed) {
	var _nub_left = 0;
	var _nub_top = nub_y;
	var _nub_width = panel_nub_width;
	var _nub_height = nub_height;

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
	draw_text_transformed(_nub_left + 7, _nub_top + 76, "ELEM", 1, 1, 90);

	if (selected_element_index >= 0 && selected_element_index < array_length(elements)) {
		var _element = elements[selected_element_index];
		draw_set_color(_element.color);
		draw_rectangle(_nub_left + 7, _nub_top + 8, _nub_left + 20, _nub_top + 21, false);
	}

	draw_set_color(c_white);
}
else {
	var _base_x = panel_x + 14;
	var _base_y = nub_y + 40;
	var _row_height = 22;
	var _swatch_size = element_swatch_size;
	var _element_count = array_length(elements);

	for (var i = 0; i < _element_count; i++) {
		var _element = elements[i];
		var _swatch_x = _base_x + 4;
		var _swatch_y = _base_y + (i * _row_height) + 4;

		draw_set_color(_element.color);
		draw_rectangle(_swatch_x, _swatch_y, _swatch_x + _swatch_size, _swatch_y + _swatch_size, false);
	}

	draw_set_color(c_white);
}

gmui_render();