ui_update_input();
ui_rebuild_layout();

ui_step_top_bar();
ui_step_left_bar();
ui_step_right_bar();

simulation.display_mode = ui_pass_modes[ui_selected_pass_index];
simulation.dev_settings = dev_settings;

if (ui_export_timer > 0) {
	ui_export_timer -= 1;
}

if (ui_viewport_has_mouse()) {
	if (mouse_check_button(mb_left)) {
		var _spawn_x = mouse_gui_x;
		var _spawn_y = mouse_gui_y;
		var _spawn_name = ui_get_selected_spawn_name();
		
		if (ui_elements[ui_selected_element_index].implemented) {
			simulation.spawn_element_circle(_spawn_name, _spawn_x, _spawn_y, paint_radius);
		}
	}
	
	if (mouse_check_button(mb_right)) {
		simulation.spawn_element_circle(undefined, mouse_gui_x, mouse_gui_y, paint_radius);
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
drop_timer = below_60 ? drop_timer + 1 : 0;

if (drop_timer >= 300) {
	show_debug_message("Simulation dropped below 60 FPS for 5 seconds.");
}