var _draw_start = current_time;
simulation.draw();
var _draw_end = current_time;

draw_times[frame_index mod fps_window] = (_draw_end - _draw_start);

var _avg_step = script_execute_ext(mean, step_times);
var _avg_draw = script_execute_ext(mean, draw_times);
var _avg_fps = script_execute_ext(mean, fps_buffer);

draw_set_color(c_white);
draw_text(10, 34, "FPS: " + string_format(_avg_fps, 0, 2) + " (" + string_format(fps_buffer[frame_index mod fps_window], 0, 2) + ")");
draw_text(10, 54, "Step Time: " + string_format(_avg_step, 0, 2) + "ms (" + string_format(step_times[frame_index mod fps_window], 0, 2) + ")");
draw_text(10, 74, "Draw Time: " + string_format(_avg_draw, 0, 2) + "ms (" + string_format(draw_times[frame_index mod fps_window], 0, 2) + ")");
draw_text(10, 94, "Drop Timer: " + string(drop_timer));

if (ui_viewport_has_mouse()) {
	var _inspect = debug_inspect_element(mouse_gui_x, mouse_gui_y);
	draw_text(mouse_gui_x + 12, mouse_gui_y + 12, json_stringify(_inspect));
}

ui_draw_top_bar();
ui_draw_left_bar();
ui_draw_right_bar();