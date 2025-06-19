// shdSandSimPass4Render
#pragma shady: import(shdSandSimCommon)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    vec4 element_px = texture2D(gm_BaseTexture, v_vTexcoord);
    int id = elem_get_index(element_px);

    vec3 color = vec3(0.0);

    if (id == 1) { // Sand
        color = vec3(0.95, 0.85, 0.2); // yellowish sand
    }

    gl_FragColor = vec4(color, 1.0);
}
