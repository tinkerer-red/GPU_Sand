#pragma shady: import(shdSandSimCommon)
#pragma shady: inline(shdSandSimCommon.Uniforms)

varying vec2 v_vTexcoord;

void main() {
	vec2 original_vel = vec2(-1.0, 1.0); // test vector
	vec2 encoded = vel_to_rg(original_vel);
	vec2 decoded = rg_to_vel(encoded);
	
	// Compare result - if match, green; else, red
	if (all(equal(original_vel, decoded))) {
		gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0); // match
	} else {
		gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0); // mismatch
	}
}