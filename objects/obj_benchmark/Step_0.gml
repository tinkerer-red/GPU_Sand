// Time step()
var _step_start = current_time;
repeat (4) simulation.step();
var _step_end = current_time;

// Store microseconds (or ms, depending on your preference)
step_times[frame_index mod fps_window] = (_step_end - _step_start);

// Track FPS
fps_buffer[frame_index mod fps_window] = fps_real;
frame_index += 1;

// Evaluate average FPS and performance drop
var _avg_fps = script_execute_ext(mean, fps_buffer);
below_60 = (_avg_fps < 60);
drop_timer = (below_60) ? drop_timer + 1 : 0;

if (drop_timer >= 300) {
	show_debug_message("Simulation dropped below 60 FPS for 5 seconds.");
}
