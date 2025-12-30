//show_debug_overlay(true)

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
frame_count = 0;

// Perf timing buffers (in microseconds)
step_times = array_create(fps_window, 0);
draw_times = array_create(fps_window, 0);


/// @function debug_inspect_element(x, y)
/// @desc Inspect and decode the element at a given pixel on surf_element
/// @param x
/// @param y
/// @returns { struct } Decoded debug info
debug_inspect_element = function(_x, _y) {
	//if (!surface_exists(simulation.surf_element)) return undefined;
	
	var _px = surface_getpixel_ext(simulation.surf_element, _x, _y);
	var _a = (_px >> 24) & 255;
	var _b = (_px >> 16) & 255;
	var _g = (_px >> 8) & 255;
	var _r = _px & 255;

	var _id = _r;
	var _dyn = _g;
	var _flags = _b;

	// Unpack dynamic data (example based on previous conventions)
	var _y_dir = (_dyn >> 7) & 1;
	var _y_speed = (_dyn >> 5) & 0b11;
	var _x_dir = (_dyn >> 4) & 1;
	var _x_speed = (_dyn >> 2) & 0b11;
	var _is_moving = (_dyn >> 1) & 1;
	var _unused_flag = (_dyn >> 0) & 1;

	var _vx = (1.0 * _x_speed / 3.0) * (_x_dir == 1 ? -1.0 : 1.0);
	var _vy = (1.0 * _y_speed / 3.0) * (_y_dir == 1 ? -1.0 : 1.0);

	return {
		element_id: _id,
		is_moving: (_is_moving == 1),
		vel: [ _vx, _vy ],
		flags: _flags,
		raw: [ _r, _g, _b, _a ]
	};
}