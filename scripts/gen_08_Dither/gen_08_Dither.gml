function CanvasSandDithered() : SimulationCore() constructor {

    #macro DITHER_STRIDE 3
    #macro CELL_NONE 0
    #macro CELL_SAND 1

    var _w = floor(window_get_width() / DITHER_STRIDE) * DITHER_STRIDE;
    var _h = floor(window_get_height() / DITHER_STRIDE) * DITHER_STRIDE;
    sim_width = _w;
    sim_height = _h;

    // Create grid
    grid = array_create(_h);
    for (var _y = 0; _y < _h; _y++) {
        grid[@ _y] = array_create(_w, CELL_NONE);
    }

    // Create chunk list
    chunk_list = [];
    var _chunk_size = DITHER_STRIDE*16; // must be multiple of DITHER_STRIDE
    for (var _y = 0; _y < _h-_chunk_size; _y += _chunk_size) {
        for (var _x = 0; _x < _w-_chunk_size; _x += _chunk_size) {
            array_push(chunk_list, {
                x1: _x,
                y1: _y,
                x2: _x + _chunk_size,
                y2: _y + _chunk_size
            });
        }
    }
	
	static __dither3x3_coords = [
    1,0, // 0
    0,1, // 1
    2,1, // 2
    1,2, // 3
    0,0, // 4
    2,2, // 5
    2,0, // 6
    0,2, // 7
    1,1  // 8
];

    static __bayer4_coords = [
	     0,0,  2,2,	 2,0,  0,2,
	     1,1,  3,3,	 3,1,  1,3,
	     1,0,  3,2,	 3,0,  1,2,
	     0,1,  2,3,	 2,1,  0,3,
	];
	static __bayer8_coords = [
	    0,0, 4,0, 0,2, 4,2, 1,4, 5,4, 1,6, 5,6,
	    2,1, 6,1, 2,3, 6,3, 3,5, 7,5, 3,7, 7,7,
	    1,0, 5,0, 1,2, 5,2, 0,4, 4,4, 0,6, 4,6,
	    3,1, 7,1, 3,3, 7,3, 2,5, 6,5, 2,7, 6,7,
	    2,0, 6,0, 2,2, 6,2, 3,4, 7,4, 3,6, 7,6,
	    1,1, 5,1, 1,3, 5,3, 0,5, 4,5, 0,7, 4,7,
	    3,0, 7,0, 3,2, 7,2, 2,4, 6,4, 2,6, 6,6,
	    0,1, 4,1, 0,3, 4,3, 1,5, 5,5, 1,7, 5,7
	];


    // === STEP ===
    static step = function() {
		var _grid = grid;
		var _w = sim_width;
	    var _h = sim_height;
		var _b4_cords = __dither3x3_coords;
		var _chunk_list = chunk_list;
        var _chunk_count = array_length(chunk_list);

        for (var _ci = 0; _ci < _chunk_count; _ci++) {
            var _c = _chunk_list[@ _ci];
            var _x1 = _c.x1;
            var _y1 = _c.y1;
            var _x2 = _c.x2;
            var _y2 = _c.y2;
			
			for (var _b = 0; _b < 18; _b += 2) {
	            var _lx = _b4_cords[@ _b];
                var _ly = _b4_cords[@ _b + 1];
				
				for (var _dy = _y1; _dy < _y2; _dy += DITHER_STRIDE) {
	                var _y = _dy + _ly;
					var _row = _grid[@ _y];
                    var _row_below = _grid[@ (_y + 1)];
					
					for (var _dx = _x1; _dx < _x2; _dx += DITHER_STRIDE) {
						var _x = _dx + _lx;
                        
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
							}else{
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
							}
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
