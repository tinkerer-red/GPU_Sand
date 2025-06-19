function number_eq(_num1, _num2, _eps = EPS) {
	/// @param {number} num1
	/// @param {number} num2
	/// @param {number} [epsilon=EPS]
	return (abs(_num1-_num2) <= _eps);
}

function modulo(_num1, _num2) {
	/// @param {number} num1
	/// @param {number} num2
	/// @desc Eucledian modulo

	var _mod = _num1 % _num2;
	if (_mod < 0) _mod += abs(_num2);
	return _mod;
}

function bitwise_ceil(v) {
	/// @param {number} num1
	/// @desc Rounds to the next highest bit value, 71>128; 14>16; 8>8
	v += (v==0);
	v--;
	v |= v >> 1;
	v |= v >> 2;
	v |= v >> 4;
	v |= v >> 8;
	v |= v >> 16;
	v++;
	return v;
}

function rectangle_in_rectangle_overlap(sx1, sy1, sx2, sy2, dx1, dy1, dx2, dy2){
	/// @desc How much of rectangle one is covered by rectangle two.
	/// @returns float 0-1;
	var _sa = (sx2-sx1)*(sy2-sy1);
	var _si = max(0, min(sx2, dx2) - max(sx1, dx1)) * max(0, min(sy2, dy2) - max(sy1, dy1));
	return _si/_sa;
}

function numeric_springing(_x, _v, _x_t, _damping, _freq, _speed) {
	/// @param {number} x Input value
	/// @param {number} v Input velocity
	/// @param {number} xt Target value
	/// @param {number} damping Damping of the oscillation (0 = no damping, 1 = critically damped)
	/// @param {number} freq Oscillations per second
	/// @param {number} speed How much of a second each step/use of the script takes (1 = normal time, 2 = twice as fast, 0.5 = half speed,...)
	/// @desc Numeric Springing
	var _v_new = _v + (-2.0 * _speed * _damping * _freq * _v + _speed * _freq * _freq * (_x_t - _x));
	var _x_new = _x + (_speed * _v);
	
	return [_x_new, _v_new];
};

function normalize(_input, min, max){
	return (_input-min)/(max-min);
}

function rect_to_rect_twiddle(sw, sh, dw, dh, twiddle_pref=0) {
	/// @param {number} src_width source rectangle width we wish to manipulate
	/// @param {number} src_height source rectangle height we wish to manipulate
	/// @param {number} dest_width the destination width to attempt to bound to
	/// @param {number} dest_height the destination height we wish to bound to
	/// @param {number} twiddle_pref What scale would we prefer. options: [-1, 0, 1] = [lowest, least diff, highest]
	/// @desc Rectangle to Rectangle Twiddle
	
	//find the lesser of two evils
		var _width_scaler  = dw/sw;
		var _height_scaler = dh/sh;
		
		var _width_floor_scaler  = floor(_width_scaler);
		var _width_ceil_scaler   = ceil(_width_scaler);
		var _height_floor_scaler = floor(_height_scaler);
		var _height_ceil_scaler  = ceil(_height_scaler);
		
		var _return = {
			width: dw,
			height: dh,
			scale: 1,
		};
		
		switch (twiddle_pref) {
			case -1: #region min
				_width_floor_scaler  = max(_width_floor_scaler , 1);
				_width_ceil_scaler   = max(_width_ceil_scaler  , 1);
				_height_floor_scaler = max(_height_floor_scaler, 1);
				_height_ceil_scaler  = max(_height_ceil_scaler , 1);
				var _scaler = min(_width_floor_scaler, _width_ceil_scaler, _height_floor_scaler, _height_ceil_scaler);
			break; #endregion
			case 0: #region least difference
				//the nearest rounding values to scale by
				var _width_floor_val  = dw/_width_floor_scaler
				var _width_ceil_val   = dw/_width_ceil_scaler;
				var _height_floor_val = dh/_height_floor_scaler;
				var _height_ceil_val  = dh/_height_ceil_scaler;
		
				//how much each one is off by
				var _width_floor_diff  = (_width_floor_val - sw   ) / _width_floor_scaler  ;
				var _width_ceil_diff   = (sw    - _width_ceil_val ) / _width_ceil_scaler   ;
				var _height_floor_diff = (_height_floor_val- sh  ) / _height_floor_scaler ;
				var _height_ceil_diff  = (sh   - _height_ceil_val) / _height_ceil_scaler  ;
		
				//addaption multiplier (to make sure you cant just stretch one _direction of the screen as far as you want)
				var _width_addaption  = dw/dh;
				var _height_addaption = dh/dw;
		
				var _diff = [_width_floor_diff, _width_ceil_diff, _height_floor_diff, _height_ceil_diff]
		
				//reject the other if one is much larger
				// we use 2.75 to support ultra wide screen devices, but not "super" ultra wide screen (32:9)
				if (_width_addaption > 2.75) { array_delete(_diff, 2, 2) };
				if (_height_addaption > 2.75) { array_delete(_diff, 0, 2) };
		
				//the 4 different scaling difference
				var _size = array_length(_diff);
				var _lowest_diff = infinity;
				var _i=0; repeat(_size) {
					if (_diff[_i] >= 0)
					&& (_diff[_i] < _lowest_diff){
						_lowest_diff = _diff[_i]
					}
				_i++;}//end repeat loop
				
				//this bit is gross looking because i couldnt think of a better way to do it other then a bunch of if statements -@Red
				switch(_lowest_diff){
					case _width_floor_diff: #region use width floor scaler
						var _scaler = floor(_width_scaler);
					break; #endregion
					
					case _width_ceil_diff: #region use width ceil scaler
						var _scaler = ceil(_width_scaler);
					break; #endregion
					
					case _height_floor_diff: #region use height floor scaler
						var _scaler = floor(_height_scaler);
					break; #endregion
					
					case _height_ceil_diff: #region use height ceil scaler
						var _scaler = ceil(_height_scaler);
					break; #endregion
					
					default: #region last resort
						var _scaler = 1;
					break; #endregion
				}
			break; #endregion
			case 1: #region max
				_width_floor_scaler  = max(_width_floor_scaler  , 1);
				_width_ceil_scaler   = max(_width_ceil_scaler   , 1);
				_height_floor_scaler = max(_height_floor_scaler , 1);
				_height_ceil_scaler  = max(_height_ceil_scaler  , 1);
				var _scaler = max(_width_floor_scaler, _width_ceil_scaler, _height_floor_scaler, _height_ceil_scaler);
			break; #endregion #endregion
		}
		
		_return.width  = dw/_scaler;
		_return.height = dh/_scaler;
		_return.scale = _scaler;
		
		return _return;
}

function math_point_distance_to_percentage(x1,y1,x2,y2,max_dist) {
	return 1 - (point_distance(x1,y1,x2,y2) / max_dist);
}

function math_direction_to_axis_x(_direction,__directional_padding) {
	/*
		Directional padding is used to prevent
		extreme precision of axis input.
		For exact input set _directional_padding to 0
	*/
	
	if ( _direction < 90 - _directional_padding || _direction > 270 + _directional_padding ) {
		return 1 - angle_difference(_direction,0) / 90;
	} else if ( _direction > 90 + _directional_padding || _direction < 270 - _directional_padding ) {
		return (angle_difference(_direction,180) / 90) - 1;
	}
	
	return 0;
}

function math_direction_to_axis_y(_direction,_directional_padding) {
	/*
		Directional padding is used to prevent
		extreme precision of axis input.
		For exact input set _directional_padding to 0
	*/
	
	if ( _direction < 180 + _directional_padding && _direction > 0 + _directional_padding ) {
		return (angle_difference(_direction,90) / 90) - 1;
	} else if ( _direction > 180 + _directional_padding && _direction < 360 - _directional_padding ) {
		return 1 - (angle_difference(_direction,270) / 90);
	}
	
	return 0;
}
	
function math_value_wrap(_value,_min,_max) {
/*
	Similar to clamp but will wrap the value
	instead of clamping it
*/
	
	if ( max == 0 ) { return 0; }
	
	var _mod = ( _value - _min ) mod ( _max - _min );
	if ( _mod < 0 ) return _mod + _max else return _mod + _min;
}

function math_chance(_chance) {
	// chance should be a value from 0 to 1
	return (random(1) < _chance);
}

function math_value_range(value,_min,_max) {
	return value >= _min && value <= _max;
}

function math_value_range_trimmed(value,_min,_max) {
	return value >= _min && value < _max;
}
	
function math_directional_rounding(_direction) {
	if ( _direction <= 45 ) {
		return 0;
	} else if ( _direction > 45 && _direction < 135 ) {
		return 90;
	} else if ( _direction >= 135 && _direction <= 225 ) {
		return 180;
	} else if ( _direction > 225 && _direction < 315 ) {
		return 270;
	} else if ( _direction >= 315 || _direction <= 45 ) {
		return 0;
	}
	
	return 0;
}
	
function math_ease_in_circ(value) {
	return 1 - sqrt(1 - sqr(value));
}

function math_ease_in_expo(value) {
	return value * value * value * value * value;
}

function math_snap(snap_value,real_value,round_func) {
	return round_func(real_value / snap_value) * snap_value;
}

function normalize_vector_to_analog(_x,_y) {
	#region jsDoc
	/*
	@func		normalize_vector_to_analog()
	@desc		normalizes a vector to always have a max length, useful for converting keyboard inputs into analog inputs
	@param {val}	x : the x of the vector
	@param {val}	y : the y of the vector
	@returns {struct}	Vector : A normalized version of the input vector
	
	add @ before if you want these flags to be true
	ignore
	deprecated
	*/#endregion
	
	var _dir = point_direction(0,0,_x,_y);
	var _dist = point_distance(0,0,_x,_y);
	if (_dist > 1) {_dist = 1};
	
	return {
		x: lengthdir_x(_dist, _dir),
		y: lengthdir_y(_dist, _dir),
	}
}

function approach(_source, _dest, _amount) {
	var _diff = _dest-_source;
	if (abs(_diff) <= _amount) return _dest;
	var _result = _source + (sign(_diff)*_amount);
	return _result;
}

function approach_angle(_source, _dest, turn_rate){
	var angle_result = _source;
	var angle_diff = angle_difference(_dest, angle_result);
	if (abs(angle_diff) <= turn_rate) return _dest;
	angle_result += sign(angle_diff) * turn_rate;
	return angle_result;
}

function smooth_approach(_source, _dest, _normalized_speed) {
	var _diff = _dest-_source;
	if (abs(_diff) <= 0.001) return _dest;
	var _result = _source + sign(_diff)*abs(_diff)*_normalized_speed;
	return _result;
}
