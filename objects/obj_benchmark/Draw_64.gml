// Time draw()
var _draw_start = current_time;
simulation.draw();
var _draw_end = current_time;

draw_times[frame_index mod fps_window] = (_draw_end - _draw_start);

// Optional display
var _avg_step = script_execute_ext(mean, step_times);
var _avg_draw = script_execute_ext(mean, draw_times);
var _avg_fps  = script_execute_ext(mean, fps_buffer);

draw_set_color(c_white);
draw_text(10, 10, $"FPS: {string_format(_avg_fps, 0, 2)} ({string_format(fps_buffer[frame_index mod fps_window], 0, 2)})");
draw_text(10, 30, $"Step Time: {string_format(_avg_step, 0, 2)}ms ({string_format(step_times[frame_index mod fps_window], 0, 2)})");
draw_text(10, 50, $"Draw Time: {string_format(_avg_draw, 0, 2)}ms ({string_format(draw_times[frame_index mod fps_window], 0, 2)})");
draw_text(10, 70, "Drop Timer: " + string(drop_timer));



// Bind and draw full-screen test shader
//shader_set(shdMetadatePackingRoundTripTest); // Replace with your shader name
//
//uniform_frame      = shader_get_uniform(shdMetadatePackingRoundTripTest, "u_frame");
//shader_set_uniform_f(uniform_frame, frame_count);
//frame_count++
//frame_count = (frame_count>= 60) ? -60 : frame_count;
//
//
//draw_sprite_stretched(sprPixel, 0, 0, 0, 900, 900)
//
//shader_reset();
