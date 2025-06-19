#pragma shady: import(shdSandSimCommon)

#define DEBUG_RESOLVE_VISUALIZE 0

varying vec2 v_vTexcoord;
uniform vec2 u_texel_size;

//uniform sampler2D gm_BaseTexture;       // Element ID/color surface
uniform sampler2D gm_SecondaryTexture;  // surf_valid_pre (offsets)

void main() {
    // Decode incoming offset vector
    vec2 offset_rg = texture2D(gm_SecondaryTexture, v_vTexcoord).rg;
    ivec2 offset = rg_to_vel(offset_rg);

    // Default: use our own element color
    vec4 out_elem = texture2D(gm_BaseTexture, v_vTexcoord);

    if (offset.x != 0 || offset.y != 0) {
        // Movement accepted → fetch from source cell
        vec2 source_uv = v_vTexcoord + vec2(offset) * u_texel_size;
        out_elem = texture2D(gm_BaseTexture, source_uv);

        #if DEBUG_RESOLVE_VISUALIZE
            // Highlight swapped elements
            out_elem.rgb = vec3(1.0, 0.84, 0.0); // golden for moving pixels
        #endif
    }
	
    gl_FragColor = out_elem;
}
