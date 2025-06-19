
function GridSand() : SimulationCore() constructor {
	
	var _w = display_get_width()
	var _h = display_get_height()
	grid = ds_grid_create(_w, _h);
	
	// === Override STEP ===
	static step = function() {
		var _w = window_get_width();
		var _h = window_get_height();
		
		for (var _y = _h - 2; _y >= 0; _y--) {
			if (ds_grid_get_max(grid, 0, _y, _w-1, _y)) {
				for (var _x = 0; _x < _w; _x++) {
					if (grid[# _x, _y] == 1) {
						//fall down
						if (grid[# _x, _y+1] == 0) {
							grid[# _x, _y+1] = 1;
							grid[# _x, _y] = 0;
							continue;
						}
						//fall left
						if (_x-1 >= 0)
						&& (grid[# _x-1, _y+1] == 0) {
							grid[# _x-1, _y+1] = 1;
							grid[# _x, _y] = 0;
							continue;
						}
						//fall right
						if (_x+1 < _w)
						&& (grid[# _x+1, _y+1] == 0) {
							grid[# _x+1, _y+1] = 1;
							grid[# _x, _y] = 0;
							continue;
						}
					
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
			for (var _x = 0; _x < _w; _x++) {
				if (grid[# _x, _y] == 1) {
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
							grid[# _x, _y] = 0;
						}
						else if (grid[# _x, _y] == 0) {
							grid[# _x, _y] = 1;
						}
					}
				}
			}
		}
	};
	
}