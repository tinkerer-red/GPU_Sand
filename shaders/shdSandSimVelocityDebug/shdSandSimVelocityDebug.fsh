#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 pixel = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if (pixel.a == 0.0) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
		return;
	}
	
    vec2 vel_rg = pixel.rg;
    vec2 vel = rg_to_vel(vel_rg);

    vec4 color = vec4(0.0, 0.0, 0.0, 1.0);

    if (vel.x < 0.0) color.r += 0.7; // left
    if (vel.x > 0.0) color.g += 0.7; // right
    if (vel.y > 0.0) color.b += 0.7; // down
    if (vel.y < 0.0) color.rgb += 0.25; // up

    // Optional: gray for (0,0)
    if (all(equal(vel, vec2(0.0)))) color = vec4(0.0);

    gl_FragColor = color;
}
