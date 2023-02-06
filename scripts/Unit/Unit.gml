function Unit(_unitType) constructor {
    type = global.unitTypeMap[? _unitType];
    scale = type.scale;
    facing = 1;
    currentTile = pointer_null;
    loopAnimState = undefined;
    
    self.setAnimState(UnitAnimState.Idle);
    
    static toString = function() {
        var _typeName = type.name;
        return string("{0}", _typeName);
    }
    
    static destroy = function () {
        currentTile = pointer_null;
    };
    
    static setAnimState = function (_state, _loop = false) {
        var _animSprite = type.getAnim(_state);
        if (is_undefined(_animSprite)) {
            return false;
        }
        
        animState = _state;
        animSprite = _animSprite;
        animProgress = 0;
        animLength = sprite_get_number(animSprite);
        animSpeed = sprite_get_speed(animSprite) / 1000; // sprites have to use frames per second, not per game frame!
        
        if (_loop) {
            loopAnimState = _state;
        } else {
            loopAnimState = undefined;
        }
        
        return true;
    }
    
    static animUpdate = function () {
        animProgress += animSpeed * delta_time / 1000;
        
        if (animProgress >= animLength) {
            onAnimEnd();
        }
        
        if (animProgress >= animLength) {
            setAnimState(UnitAnimState.Idle);
        }
    }
    
    static onAnimEnd = function () {
        if (!is_undefined(loopAnimState)) {
            setAnimState(loopAnimState, true);
        } else {
            setAnimState(choose(UnitAnimState.Idle, UnitAnimState.Moving, UnitAnimState.Attacking, UnitAnimState.ReceivingHit, UnitAnimState.Death));
        }
    };
    
    static draw = function (_x, _y) {
        var _yOffset = type.yOffset;
        
        draw_sprite_ext(animSprite, animProgress,
            _x, _y + scale * _yOffset,
            scale * facing, scale, 0, c_white, 1);
    }
}