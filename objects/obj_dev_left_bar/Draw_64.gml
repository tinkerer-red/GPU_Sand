var _mouse_gui_x = device_mouse_x_to_gui(0);
var _mouse_gui_y = device_mouse_y_to_gui(0);

var _panel_is_fully_closed = (panel_x == panel_closed_x);

if (_panel_is_fully_closed) {
	var _nub_left = 0;
	var _nub_top = panel_margin;
	var _nub_width = panel_nub_width;
	var _nub_height = 96;

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
	draw_text_transformed(_nub_left + 7, _nub_top + 72, "DEV", 1, 1, 90);
	draw_text(_nub_left + 8, _nub_top + 8, ">");
}

gmui_render();