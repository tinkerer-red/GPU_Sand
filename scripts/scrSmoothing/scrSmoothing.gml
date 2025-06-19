function lerp_smooth(current,target,_speed) {
	if ( abs(target - current) < 0.0005 ) {
	   return target;
	} else {
	   return current + (sign(target - current) * abs(target - current) * _speed);
	}
}

function angle_lerp_smooth(_current,_target,_rate,_speed) {
	/*
		Rotates the calling instance towards the target _direction,
		at a given rate and easing. The larger the easing factor,
		the more gradually the turn completes.
	*/
	
	return math_value_wrap(_current + median(-_rate,_rate,(1 - _speed) * angle_difference(_target,_current)),0,360);
}
