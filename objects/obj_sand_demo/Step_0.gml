gmui_update();

ui_elem();
ui_dev();
ui_pass();

simulation.dev_settings = dev_settings;
simulation.display_mode = ui_passes[selected_pass_index].mode;

var _mouse_gui_x = device_mouse_x_to_gui(0);
var _mouse_gui_y = device_mouse_y_to_gui(0);
var _viewport_left = ui_get_viewport_left();
var _viewport_right = ui_get_viewport_right();
var _mouse_in_viewport = (_mouse_gui_x >= _viewport_left && _mouse_gui_x <= _viewport_right);

if (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right)) {
	viewport_focused = _mouse_in_viewport;
}
if (mouse_check_button_released(mb_left) || mouse_check_button_released(mb_right)) {
	viewport_focused = _mouse_in_viewport;
}

if (viewport_focused) {
	if (mouse_wheel_up()) { paint_radius += 4; }
	if (mouse_wheel_down()) { paint_radius -= 4; }
	paint_radius = clamp(paint_radius, 1, 1000);

	if (mouse_check_button(mb_left)) {
		simulation.spawn_element_circle(selected_element_id, _mouse_gui_x, _mouse_gui_y, paint_radius);
	}

	if (mouse_check_button(mb_right)) {
		simulation.spawn_element_circle(ElementId.EMPTY, _mouse_gui_x, _mouse_gui_y, paint_radius);
	}
}

var _step_start = current_time;
repeat (10) {
	simulation.step();
}
var _step_end = current_time;

step_times[frame_index mod fps_window] = (_step_end - _step_start);
fps_buffer[frame_index mod fps_window] = fps_real;

frame_index += 1;

var _avg_fps = script_execute_ext(mean, fps_buffer);
below_60 = (_avg_fps < 60);
drop_timer = below_60 ? (drop_timer + 1) : 0;

if (drop_timer >= 300) {
	show_debug_message("Simulation dropped below 60 FPS for 5 seconds.");
}
