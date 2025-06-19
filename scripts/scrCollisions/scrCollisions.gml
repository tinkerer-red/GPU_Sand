function circle_in_circle(x1, y1, x2, y2, r1, r2) {
	var d = sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
	
	if (d <= r1 - r2) {
		return 2; //overlap
		//console.log("Circle B is inside A");
	} else if (d <= r2 - r1) {
		return true; //encompassed
		//console.log("Circle A is inside B");
	} else if (d < r1 + r2) {
		return 2; //overlap
		//console.log("Circle intersect to each other");
	} else if (d == r1 + r2) {
		return 2; //overlap
		//console.log("Circle touch to each other");
	} else {
		return false
		//console.log("Circle not touch to each other");
	}
}

function raycast(_x, _y, _dir, _range, _obj, _precise=true, _notme=true) {
	//check if we collided with the first half of the line
	_range *= 0.5;
	
	if (_range <= math_get_epsilon()) {
		return _range;
	}
	
	// check first half of range
	var _col = collision_line(_x, _y, _x + lengthdir_x(_range, _dir), _y + lengthdir_y(_range, _dir), _obj, _precise, _notme);
	
	//recusively check deeper in the first half
	if (_col) {
		return raycast(_x, _y, _dir, _range, _obj, _precise, _notme);
	}
	
	// check second half of range
	_x += lengthdir_x(_range, _dir);
	_y += lengthdir_y(_range, _dir);
	
	_col = collision_line(_x, _y, _x + lengthdir_x(_range, _dir), _y + lengthdir_y(_range, _dir), _obj, _precise, _notme);
	
	//recusively check deeper in the second half
	if (_col) {
		return _range + raycast(_x, _y, _dir, _range, _obj, _precise, _notme);
	}
	
	//if no collision was found
	return false;
}

function raycast_adv(_x, _y, _dir, _range, _precession=0.1, _func) {
	//use this if you need to itterate through an array or something else for your ray cast
	//function's inputs are (_x,_y,) and should return true if it has met the collide conditions and false otherwise
	//when the first instance to meet the conditions returns true; the distance traveled will be returned
	
	var _col;
	var _dist = 0
	while (_dist < _range) {
		_x += lengthdir_x(_range, _dir);
		_y += lengthdir_y(_range, _dir);
		
		_col = _func(_x, _y, _x + lengthdir_x(_range, _dir), _y + lengthdir_y(_range, _dir));
		if (_col) return _dist;
		
		_dist += _precession;
	}
	
	//if nothing was found
	return false;
}