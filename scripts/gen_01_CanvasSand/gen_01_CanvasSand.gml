function CanvasSand() : SimulationCore() constructor {
	
	var _h = display_get_height()
	grid = array_create(_h);
	var _i=0; repeat (_h) {
		grid[_i] = array_create(display_get_width());
	_i++}
	
	// === Override STEP ===
	static step = function() {
		for (var _x = 0; _x < window_get_width(); _x++) {
			for (var _y = window_get_height() - 2; _y >= 0; _y--) {
				if (grid[@ _y][@ _x] == 1) {
					//fall down
					if (grid[@ _y+1][@ _x] == 0) {
						grid[@ _y+1][@ _x] = 1;
						grid[@ _y][@ _x] = 0;
						continue;
					}
					//fall left
					if (_x-1 >= 0)
					&& (grid[@ _y+1][@ _x-1] == 0) {
						grid[@ _y+1][@ _x-1] = 1;
						grid[@ _y][@ _x] = 0;
						continue;
					}
					//fall right
					if (_x+1 < window_get_width())
					&& (grid[@ _y+1][@ _x+1] == 0) {
						grid[@ _y+1][@ _x+1] = 1;
						grid[@ _y][@ _x] = 0;
						continue;
					}
					
				}
			}
		}
	};

	// === Override DRAW ===
	static draw = function() {
		surface_id = surface_rebuild(surface_id, window_get_width(), window_get_height())

		surface_set_target(surface_id);
		draw_clear_alpha(c_black, 0);

		for (var _x = 0; _x < window_get_width(); _x++) {
			for (var _y = 0; _y < window_get_height(); _y++) {
				if (grid[@ _y][@ _x] == 1) {
					draw_set_color(c_yellow);
					draw_point(_x, _y)
				}
			}
		}

		surface_reset_target();
		draw_surface(surface_id, 0, 0);
	};
	
	static spawn_element_circle = function(_element, _cx, _cy, _radius) {
		var _erase = (_element != "sand")
		
		var _r2 = _radius * _radius;
		for (var _dx = -_radius; _dx <= _radius; _dx++) {
			for (var _dy = -_radius; _dy <= _radius; _dy++) {
				if (_dx * _dx + _dy * _dy <= _r2) {
					var _x = floor(_cx + _dx);
					var _y = floor(_cy + _dy);
				
					if (_x >= 0 && _x < window_get_width() && _y >= 0 && _y < window_get_height()) {
						if (_erase) {
							grid[@ _y][@ _x] = 0;
						}
						else if (grid[@ _y][@ _x] == 0) {
							grid[@ _y][@ _x] = 1;
						}
					}
				}
			}
		}
	};
	
}