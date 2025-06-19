function CanvasSand5() : SimulationCore() constructor {
	
	var _h = display_get_height()
	grid = array_create(_h);
	var _i=0; repeat (_h) {
		grid[_i] = array_create(display_get_width());
	_i++}
	
	// === Override STEP ===
	static step = function() {
		var _w = window_get_width();
		var _h = window_get_height();
		
		var _row = array_get(grid, _h-1);
		
		for (var _y = _h - 2; _y >= 0; _y--) {
			
			var _lower_row = _row;
			var _row = array_get(grid, _y);
			
			for (var _x = 0; _x < _w; _x++) {
				if (array_get(_row, _x) == 1) {
					//fall down
					if (array_get(_lower_row, _x) == 0) {
						array_set(_lower_row, _x, 1);
						array_set(_row, _x, 0);
						continue;
					}
					//fall left
					if (_x-1 >= 0)
					&& (array_get(_lower_row, _x-1) == 0) {
						array_set(_lower_row, _x-1, 1);
						array_set(_row, _x, 0);
						continue;
					}
					//fall right
					if (_x+1 < _w)
					&& (array_get(_lower_row, _x+1) == 0) {
						array_set(_lower_row, _x+1, 1);
						array_set(_row, _x, 0);
						continue;
					}
					
				}
			}
		}
	};

	// === Override DRAW ===
	static draw = function() {
		var _w = window_get_width();
		var _h = window_get_height();
		
		surface_id = surface_rebuild(surface_id, _w, _h)
		
		surface_set_target(surface_id);
		draw_clear_alpha(c_black, 0);
		draw_set_color(c_yellow);
		
		for (var _y = 0; _y < _h; _y++) {
			var _row = grid[@ _y];
			for (var _x = 0; _x < _w; _x++) {
				if (_row[@ _x] == 1) {
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