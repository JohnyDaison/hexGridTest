function SpriteDisplay() constructor {
    enabled = false;
    sprite = undefined;
    imageIndex = 0;
    xScale = 1;
    yScale = 1;
    rotation = 0;
    tint = c_white;
    alpha = 1;
    
    static draw = function (_position) {
        if (enabled && !is_undefined(sprite)) {
            draw_sprite_ext(sprite, imageIndex, _position.x, _position.y, xScale, yScale, rotation, tint, alpha);
        }
    }
}