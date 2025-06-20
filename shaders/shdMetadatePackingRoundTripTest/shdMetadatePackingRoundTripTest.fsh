#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
uniform float u_frame; // Make sure you're passing this in!

void main() {
    float noise = rand(v_vTexcoord, u_frame);
    gl_FragColor = vec4(vec3(noise), 1.0);
}
