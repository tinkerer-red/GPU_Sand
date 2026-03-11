#pragma shady: inline(shdSandSimCommon.Uniforms)
#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 _pixel = texture2D(gm_BaseTexture, v_vTexcoord);
	ElementDynamicData _elem_dynamic_data;
	vec2 _velocity;
	vec4 _color;

	if (_pixel.a == 0.0) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
		return;
	}

	_elem_dynamic_data = unpack_elem_dynamic_data(_pixel);
	_velocity = _elem_dynamic_data.vel;
	_color = vec4(0.0, 0.0, 0.0, 1.0);

	if (_velocity.x < 0.0) {
		_color.r += 0.7;
	}
	if (_velocity.x > 0.0) {
		_color.g += 0.7;
	}
	if (_velocity.y > 0.0) {
		_color.b += 0.7;
	}
	if (_velocity.y < 0.0) {
		_color.rgb += 0.25;
	}

	if (_velocity.x == 0.0 && _velocity.y == 0.0) {
		_color = vec4(0.0, 0.0, 0.0, 0.0);
	}

	gl_FragColor = _color;
}
