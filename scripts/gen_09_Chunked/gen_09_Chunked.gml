function CanvasSandChunked() : SimulationCore() constructor {

    var _w = window_get_width();
    var _h = window_get_height();
    sim_width = _w;
    sim_height = _h;

    // Create grid
    grid = array_create(_h);
    for (var _y = 0; _y < _h; _y++) {
        grid[@ _y] = array_create(_w, CELL_NONE);
    }

    // Create chunk list
    chunk_list = [];
    var _chunk_size = 64; // must be multiple of DITHER_STRIDE
    for (var _y = 0; _y < _h; _y += _chunk_size) {
        for (var _x = 0; _x < _w; _x += _chunk_size) {
            array_push(chunk_list, {
                x1: _x,
                y1: _y,
                x2: clamp(_x + _chunk_size, 0, _w - 1),
                y2: clamp(_y + _chunk_size, 0, _h - 1)
            });
        }
    }
	
    // === STEP ===
    static step = function() {
		var _grid = grid;
		var _w = sim_width;
	    var _h = sim_height;
		var _b4_cords = __dither3x3_coords;
		var _chunk_list = chunk_list;
        var _chunk_count = array_length(_chunk_list);

        for (var _ci = 0; _ci < _chunk_count; _ci++) {
            var _c = _chunk_list[@ _ci];
            var _x1 = _c.x1;
            var _y1 = _c.y1;
            var _x2 = _c.x2;
            var _y2 = _c.y2;
			
			for (var _y = _y1; _y < _y2; _y += 1) {
	            var _row = _grid[@ _y];
                var _row_below = _grid[@ (_y + 1)];
					
				for (var _x = _x1; _x < _x2; _x += 1) {
					    
                    if (_row[@ _x] & CELL_SAND) {
                        if (_row_below[@ _x] == CELL_NONE) {
                            _row[@ _x] = CELL_NONE;
                            _row_below[@ _x] = CELL_SAND;
                            continue;
                        }
						
						if (irandom(1)) {
	                        if (_x > 0 && _row_below[@ (_x - 1)] == CELL_NONE) {
	                            _row[@ _x] = CELL_NONE;
	                            _row_below[@ (_x - 1)] = CELL_SAND;
	                            continue;
	                        }
	                        if (_x + 1 < _w && _row_below[@ (_x + 1)] == CELL_NONE) {
	                            _row[@ _x] = CELL_NONE;
	                            _row_below[@ (_x + 1)] = CELL_SAND;
	                            continue;
	                        }
							continue;
						}
						else{
							if (_x + 1 < _w && _row_below[@ (_x + 1)] == CELL_NONE) {
	                            _row[@ _x] = CELL_NONE;
	                            _row_below[@ (_x + 1)] = CELL_SAND;
	                            continue;
	                        }
							if (_x > 0 && _row_below[@ (_x - 1)] == CELL_NONE) {
	                            _row[@ _x] = CELL_NONE;
	                            _row_below[@ (_x - 1)] = CELL_SAND;
	                            continue;
	                        }
							continue;
						}
                    }
                }
            }
        }
    };

    // === DRAW ===
    static draw = function() {
        surface_id = surface_rebuild(surface_id, sim_width, sim_height);
        surface_set_target(surface_id);
        draw_clear_alpha(c_black, 0);
        draw_set_color(c_yellow);

        for (var _y = 0; _y < sim_height; _y++) {
            var _row = grid[@ _y];
            for (var _x = 0; _x < sim_width; _x++) {
                if (_row[@ _x] & CELL_SAND) {
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
                    if (_x >= 0 && _x < sim_width && _y >= 0 && _y < sim_height) {
                        if (_erase) {
                            grid[@ _y][@ _x] = CELL_NONE;
                        } else {
                            if (grid[@ _y][@ _x] == CELL_NONE) {
                                grid[@ _y][@ _x] = CELL_SAND;
                            }
                        }
                    }
                }
            }
        }
    };
} 
