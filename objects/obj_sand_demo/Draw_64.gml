var _draw_start = current_time;

ui_draw_pass_surface(selected_pass_index, 0, 0, 1, 1);

var _draw_end = current_time;

draw_times[frame_index mod fps_window] = (_draw_end - _draw_start);

var _buffer_index = (frame_index - 1 + fps_window) mod fps_window;
var _avg_step = script_execute_ext(mean, step_times);
var _avg_draw = script_execute_ext(mean, draw_times);
var _avg_fps = script_execute_ext(mean, fps_buffer);

draw_set_color(c_white);
draw_text(ui_elem_open_x, 34, "FPS: " + string_format(_avg_fps, 0, 2) + " (" + string_format(fps_buffer[_buffer_index], 0, 2) + ")");
draw_text(ui_elem_open_x, 54, "Step Time: " + string_format(_avg_step, 0, 2) + "ms (" + string_format(step_times[_buffer_index], 0, 2) + ")");
draw_text(ui_elem_open_x, 74, "Draw Time: " + string_format(_avg_draw, 0, 2) + "ms (" + string_format(draw_times[_buffer_index], 0, 2) + ")");
draw_text(ui_elem_open_x, 94, "Drop Timer: " + string(drop_timer));

//var _mouse_gui_x = device_mouse_x_to_gui(0);
//var _mouse_gui_y = device_mouse_y_to_gui(0);
//var _viewport_left = ui_get_viewport_left();
//var _viewport_right = ui_get_viewport_right();
//var _mouse_in_viewport = (_mouse_gui_x >= _viewport_left && _mouse_gui_x <= _viewport_right);
//
//if (_mouse_in_viewport) {
//	var _inspect = debug_inspect_element(_mouse_gui_x, _mouse_gui_y);
//	draw_text(_mouse_gui_x + 12, _mouse_gui_y + 12, json_stringify(_inspect));
//}

ui_draw_elem_nub();
ui_draw_dev_nub();
ui_draw_pass_nub();

gmui_render();