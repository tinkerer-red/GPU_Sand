show_debug_overlay(true)

var _w = floor(800 / DITHER_STRIDE) * DITHER_STRIDE;
var _h = floor(800 / DITHER_STRIDE) * DITHER_STRIDE;


window_set_size(
	900,
	900
);
window_center();

simulation = new CanvasSandShader();

// FPS tracking
fps_window = 60;
fps_buffer = array_create(fps_window, 60);
frame_index = 0;
below_60 = false;
drop_timer = 0;

// Perf timing buffers (in microseconds)
step_times = array_create(fps_window, 0);
draw_times = array_create(fps_window, 0);
