function surface_clear(_surface) {
	surface_set_target(_surface);
	draw_clear_alpha(c_black, 0);
	surface_reset_target();
}

#region jsDoc
/// @func    surface_rebuild
/// @desc    Ensures the given surface is valid and matches the desired size and format.
///          If it does not exist or is invalid, it optionally uses a cached surface instead.
///          If neither is valid or correctly sized/formatted, a new surface is created.
/// @param   {Id.Surface} surface - The primary surface to check and rebuild.
/// @param   {Real} width - The required width.
/// @param   {Real} height - The required height.
/// @param   {Constant.SurfaceFormatConstant} [format=surface_rgba8unorm] - The required format.
/// @param   {Id.Surface|Undefined} cached_surface - Optional fallback surface to use if primary is invalid.
/// @returns {Id.Surface} A valid surface with the correct dimensions and format.
#endregion
function surface_rebuild(_surface, _width, _height, _format = surface_rgba8unorm) {
	var _w = floor(_width);
	var _h = floor(_height);
	
	if (surface_exists(_surface)) {
		if (
			surface_get_width(_surface) == _w &&
			surface_get_height(_surface) == _h &&
			surface_get_format(_surface) == _format
		) {
			return _surface;
		}
		surface_free(_surface);
	}
	
	var _surf = surface_create(_w, _h, _format);
	surface_clear(_surf);
	return _surf;
}

function draw_surface_center(surface,_x,_y,xscale,yscale,rot,col,alpha) {
	var
	_x_offset = (-surface_get_width(surface) * 0.5) * xscale,
	_y_offset = (-surface_get_height(surface) * 0.5) * yscale;
 
	draw_surface_ext(
	    surface,
	    (_x - 1) + lengthdir_x(_x_offset,rot) + lengthdir_x(_y_offset,rot - 90),
	    (_y - 1) + lengthdir_y(_x_offset,rot) + lengthdir_y(_y_offset,rot - 90),
	    xscale,
	    yscale,
	    rot,
	    col,
	    alpha
	);
}

function draw_surface_origin(surface,_x,_y,xorigin,yorigin,xscale,yscale,rot,col,alpha) {
	draw_surface_ext(
	    surface,
	    (_x - 1) + lengthdir_x(xorigin,rot) + lengthdir_x(yorigin,rot - 90),
	    (_y - 1) + lengthdir_y(xorigin,rot) + lengthdir_y(yorigin,rot - 90),
	    xscale,
	    yscale,
	    rot,
	    col,
	    alpha
	);
}

#region jsDoc
/// @func    buffer_create_from_surface
/// @desc    Creates a fixed-size buffer containing the pixel data from the given surface. The buffer size is determined
///          by the surface's dimensions and format. The buffer is populated with the surface's pixel data starting at byte offset 0.
/// @param   {Id.Surface} _surf - The source surface from which to read pixel data.
/// @returns {Id.Buffer} A buffer containing the surface's pixel data.
#endregion
function buffer_create_from_surface(_surf) {
	// Get surface properties
	var _width = surface_get_width(_surf);
	var _height = surface_get_height(_surf);
	var _format = surface_get_format(_surf);
	
	// Determine bytes per pixel based on format
	var _bytes_per_pixel;
	switch (_format) {
		case surface_rgba4unorm:  _bytes_per_pixel = 2;  break;
		case surface_rgba8unorm:  _bytes_per_pixel = 4;  break;
		case surface_rgba16float: _bytes_per_pixel = 8;  break;
		case surface_rgba32float: _bytes_per_pixel = 16; break;
		case surface_r8unorm:     _bytes_per_pixel = 1;  break;
		case surface_r16float:    _bytes_per_pixel = 2;  break;
		case surface_r32float:    _bytes_per_pixel = 16; break;
		case surface_rg8unorm:    _bytes_per_pixel = 2;  break;
		default: throw "Unsupported format"
	}
	
	// Create a buffer large enough to store the surface data
	var _buff_size = _width * _height * _bytes_per_pixel;
	var _buff = buffer_create(_buff_size, buffer_fixed, 1);
	
	// Write surface data into buffer
	buffer_get_surface(_buff, _surf, 0);
	buffer_seek(_buff, buffer_seek_start, 0);
	
	return _buff;
}

#region jsDoc
/// @func    surface_create_from_buffer
/// @desc    Creates a new surface with the specified width, height, and format, and populates it with pixel data
///          read from the provided buffer. The buffer data is written to the surface starting at byte offset 0.
/// @param   {Id.Buffer} _buff - The buffer containing the pixel data to write to the surface.
/// @param   {Real} _width - The width of the new surface.
/// @param   {Real} _height - The height of the new surface.
/// @param   {Constant.SurfaceFormatConstant} _format - The format to use for the new surface.
/// @returns {Id.Surface} The newly created surface containing the pixel data from the buffer.
#endregion
function surface_create_from_buffer(_buff, _width, _height, _format=surface_rgba8unorm) {
    // Create a new surface with the specified width, height, and format.
    var _surf = surface_create(_width, _height, _format);
    
	// Determine bytes per pixel based on format
	var _bytes_per_pixel;
	switch (_format) {
		case surface_rgba4unorm:  _bytes_per_pixel = 2;  break;
		case surface_rgba8unorm:  _bytes_per_pixel = 4;  break;
		case surface_rgba16float: _bytes_per_pixel = 8;  break;
		case surface_rgba32float: _bytes_per_pixel = 16; break;
		case surface_r8unorm:     _bytes_per_pixel = 1;  break;
		case surface_r16float:    _bytes_per_pixel = 2;  break;
		case surface_r32float:    _bytes_per_pixel = 16; break;
		case surface_rg8unorm:    _bytes_per_pixel = 2;  break;
		default: throw "Unsupported format"
	}
	
	// Calculate the expected buffer size based on the surface dimensions and bytes per pixel.
	var _expected_size = _width * _height * _bytes_per_pixel;
	var _actual_size = buffer_get_size(_buff);
	
	// Safety check: Ensure the buffer size matches the expected size.
	if (_actual_size != _expected_size) {
		show_error("Buffer size mismatch: expected " + string(_expected_size) + " but got " + string(_actual_size), true);
	}
	
    // Write the pixel data from the buffer into the surface, starting at byte offset 0.
    buffer_set_surface(_buff, _surf, 0);
    
    // Return the newly created surface.
    return _surf;
}
/*
#region jsDoc
/// @func    surface_rebuild
/// @desc    Ensures the given surface is valid and matches the desired size and format.
///          If it does not exist or is invalid, it optionally uses a cached surface instead.
///          If neither is valid or correctly sized/formatted, a new surface is created.
/// @param   {Id.Surface} surface - The primary surface to check and rebuild.
/// @param   {Real} width - The required width.
/// @param   {Real} height - The required height.
/// @param   {Constant.SurfaceFormatConstant} [format=surface_rgba8unorm] - The required format.
/// @param   {Id.Surface|Undefined} cached_surface - Optional fallback surface to use if primary is invalid.
/// @returns {Id.Surface} A valid surface with the correct dimensions and format.
#endregion
function surface_rebuild(_surface, _width, _height, _format = surface_rgba8unorm, _cached_surface = undefined) {
	var _w = floor(_width);
	var _h = floor(_height);

	if (surface_exists(_surface)) {
		if (
			surface_get_width(_surface) == _w &&
			surface_get_height(_surface) == _h &&
			surface_get_format(_surface) == _format
		) {
			return _surface;
		}
		surface_free(_surface);
	}
	else {
		return surface_create_from_buffer(_cached_surface, _width, _height, _format);
	}

	return surface_create(_w, _h, _format);
}

function surface_cache(surface,width,height) {
	var _surface = surface;
	if ( surface_exists(_surface) ) {
		if (
			surface_get_width(_surface) != floor(width) ||
			surface_get_height(_surface) != floor(height)
		) {
			surface_free(_surface);
			
			_surface = surface_create(floor(width),floor(height));
		}
	} else {
		_surface = surface_create(floor(width),floor(height));
	}
	
	return _surface;
}


