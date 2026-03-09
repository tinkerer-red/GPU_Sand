function ShaderMouse() constructor {
    x = -1;
    y = -1;
    z = -1;
    w = -1;
    
    static update = function(isMouseDown/*:bool*/, mouseX/*:number*/, mouseY/*:number*/, posOnMouseDown/*:bool*/ = true)/*->void*/ {
        if (sign(z) == 1) {
            if (sign(w) == 1) {
                w *= -1;
            }
        }
        
        if (!posOnMouseDown) {
            x = mouseX;
            y = mouseY;
        }
        
        if (isMouseDown) {
            if (posOnMouseDown) {
                x = mouseX;
                y = mouseY;
            }
            
            if (sign(z) == -1) {
                z = mouseX;
                w = mouseY;
            }
        } else {
            if (sign(z) == 1) {
                z *= -1;
            }
        }
    }
    
    static sendUniform = function(shaderUniform/*:shader_uniform*/)/*->void*/ {
        shader_set_uniform_f(shaderUniform, x, y, z, w);
    }
}