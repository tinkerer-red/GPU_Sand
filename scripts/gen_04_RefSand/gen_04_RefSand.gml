function RefSand() : SimulationCore() constructor {
	var _w = display_get_height();
	var _h = display_get_width();

	// Store all cells in a 2D grid
	grid = array_create(_h);
	for (var _y = 0; _y < _h; _y++) {
		grid[@ _y] = array_create(_w);
		for (var _x = 0; _x < _w; _x++) {
			grid[@ _y][@ _x] = {
				is_sand: false,
				down: undefined,
				down_left: undefined,
				down_right: undefined
			};
		}
	}

	// === Hook up neighbors ===
	for (var _y = 0; _y < _h; _y++) {
		for (var _x = 0; _x < _w; _x++) {
			var _cell = grid[@ _y][@ _x];
			if (_y + 1 < _h) {
				_cell.down       = grid[@ (_y + 1)][@ _x];
				if (_x > 0)        _cell.down_left  = grid[@ (_y + 1)][@ (_x - 1)];
				if (_x + 1 < _w)   _cell.down_right = grid[@ (_y + 1)][@ (_x + 1)];
			}
		}
	}

	// === STEP ===
	static step = function() {
		var _w = window_get_width();
		var _h = window_get_height();

		for (var _y = _h - 2; _y >= 0; _y--) {
			for (var _x = 0; _x < _w; _x++) {
				var _cell = grid[@ _y][@ _x];

				if (_cell.is_sand) {
					if (_cell.down && !_cell.down.is_sand) {
						_cell.down.is_sand = true;
						_cell.is_sand = false;
						continue;
					}
					if (_cell.down_left && !_cell.down_left.is_sand) {
						_cell.down_left.is_sand = true;
						_cell.is_sand = false;
						continue;
					}
					if (_cell.down_right && !_cell.down_right.is_sand) {
						_cell.down_right.is_sand = true;
						_cell.is_sand = false;
						continue;
					}
				}
			}
		}
	};

	// === DRAW ===
	static draw = function() {
		surface_id = surface_rebuild(surface_id, window_get_width(), window_get_height());

		surface_set_target(surface_id);
		draw_clear_alpha(c_black, 0);

		for (var _y = 0; _y < window_get_height(); _y++) {
			for (var _x = 0; _x < window_get_width(); _x++) {
				if (grid[@ _y][@ _x].is_sand) {
					draw_set_color(c_yellow);
					draw_point(_x, _y);
				}
			}
		}

		surface_reset_target();
		draw_surface(surface_id, 0, 0);
	};

	// === SPAWN ===
	static spawn_element_circle = function(_element, _cx, _cy, _radius) {
		var _erase = (_element != "sand");
		var _r2 = _radius * _radius;

		for (var _dx = -_radius; _dx <= _radius; _dx++) {
			for (var _dy = -_radius; _dy <= _radius; _dy++) {
				if (_dx * _dx + _dy * _dy <= _r2) {
					var _x = floor(_cx + _dx);
					var _y = floor(_cy + _dy);
					if (_x >= 0 && _x < window_get_width() && _y >= 0 && _y < window_get_height()) {
						grid[@ _y][@ _x].is_sand = !_erase;
					}
				}
			}
		}
	};
}
