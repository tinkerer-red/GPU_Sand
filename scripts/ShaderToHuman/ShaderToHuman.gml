#macro _S2H_ERROR "[ShaderToHuman] Error ::"

show_debug_message($"ShaderToHuman.gml by Nikita Musatov | https://github.com/KeeVeeGames | https://musnik.itch.io");

function __surface_validate(id/*:surface*/, width/*:int*/, height/*:int*/, format/*:surface_format*/ = surface_rgba8unorm)/*->surface*/ {
    gml_pragma("forceinline");
    
    if (!surface_exists(id)) {
        return surface_create(width, height, format);
    }
    
    if (surface_get_width(id) != width || surface_get_height(id) != height) {
        surface_resize(id, width, height);
    }
    
    return id;
}

function s2h_UiHandle() constructor {
    surfaces = [-1, -1];        /// @is {tuple<surface, surface>}
    readIndex = 0;              /// @is {int}
    
    static __handleCurrent = undefined;
    static __drawFunc = undefined;
    static __uiStateSampler = undefined;
    static __resolutionUniform = undefined;
    
    /// @param ...
    static __draw = function()/*->void*/ {
        var handle/*:s2h_UiHandle*/ = __handleCurrent;
        var drawFunc/*:function*/ = __drawFunc;
        var uiStateSampler/*:shader_sampler*/ = __uiStateSampler;
        var resolutionUniform/*:shader_uniform*/ = __resolutionUniform;
        
        var surface/*:surface*/ = argument[0];
        var width = surface_get_width(surface);
        var height = surface_get_height(surface);
        
        handle.surfaces[handle.readIndex] = __surface_validate(handle.surfaces[handle.readIndex], width, height);
        handle.surfaces[!handle.readIndex] = __surface_validate(handle.surfaces[!handle.readIndex], width, height);
        
        texture_set_stage(uiStateSampler, surface_get_texture(handle.surfaces[handle.readIndex]));
        shader_set_uniform_f(resolutionUniform, width, height);
        surface_set_target(handle.surfaces[!handle.readIndex]);
        draw_surface(surface, 0, 0);
        surface_reset_target();
        
        shader_reset();
        
        var drawParams = [handle.surfaces[!handle.readIndex]];
        for (var i = 1; i < argument_count; i++) drawParams[i] = argument[i];
        script_execute_ext(drawFunc, drawParams);
        
        handle.readIndex = !handle.readIndex;
    }
}

function s2h_ui_set_state(handle/*:s2h_UiHandle*/, uiStateSampler/*:shader_sampler*/, resolutionUniform/*:shader_uniform*/)/*->void*/ {
    s2h_UiHandle.__handleCurrent = handle;
    s2h_UiHandle.__uiStateSampler = uiStateSampler;
    s2h_UiHandle.__resolutionUniform = resolutionUniform;
}

function s2h_ui_reset_state()/*->void*/ {
    s2h_UiHandle.__handleCurrent = undefined;
}

function s2h_ui_draw_surface(id/*:surface*/, x/*:number*/, y/*:number*/)/*->void*/ {
    var handle/*:s2h_UiHandle?*/ = s2h_UiHandle.__handleCurrent;
    if (handle == undefined) {
        throw $"{_S2H_ERROR} s2h_ui_draw_surface :: UI handle is undefined, call s2h_ui_set_state() before drawing!";
    }
    
    s2h_UiHandle.__drawFunc = draw_surface;
    s2h_UiHandle.__draw(id, x, y);
}

function s2h_ui_draw_surface_ext(id/*:surface*/, x/*:number*/, y/*:number*/, xscale/*:number*/, yscale/*:number*/, rot/*:number*/, col/*:int*/, alpha/*:number*/)/*->void*/ {
    var handle/*:s2h_UiHandle?*/ = s2h_UiHandle.__handleCurrent;
    if (handle == undefined) {
        throw $"{_S2H_ERROR} s2h_ui_draw_surface_ext :: UI handle is undefined, call s2h_ui_set_state() before drawing!";
    }
    
    s2h_UiHandle.__drawFunc = draw_surface_ext;
    s2h_UiHandle.__draw(id, x, y, xscale, yscale, rot, col, alpha);
}