function SpriteDisplay() constructor {
    enabled = false;
    sprite = undefined;
    imageIndex = 0;
    xScale = 1;
    yScale = 1;
    rotation = 0;
    tint = c_white;
    alpha = 1;
    cursorPulse = false;
    
    static draw = function (_position) {
        if (enabled && !is_undefined(sprite)) {
            var _alpha = alpha;
            if (cursorPulse) {
                _alpha *= objHexMap.cursorPulseCurrent;
            }
            
            draw_sprite_ext(sprite, imageIndex, _position.x, _position.y, xScale, yScale, rotation, tint, _alpha);
        }
    }
    
    /**
     * Function setState
     * @param {bool} _enabled
     * @param {asset.GMSprite} [_sprite]
     * @param {constant.color} [_tint]
     * @param {real} [_alpha]
     */
    static setState = function (_enabled, _sprite = pointer_null, _tint = undefined, _alpha = undefined) {
        if (!_enabled) {
            enabled = false;
            return;
        }
        
        if (!_sprite && !sprite) {
            enabled = false;
            return;
        }
        
        if (_sprite) {
            sprite = _sprite;
        }
        
        enabled = true;
        
        if (!is_undefined(_tint)) {
            tint = _tint;
        }
        
        if (!is_undefined(_alpha)) {
            alpha = _alpha;
        }
    }
}