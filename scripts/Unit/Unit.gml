function Unit(_unitType) constructor {
    type = global.unitTypeMap[? _unitType];
    facing = 1;
    myTile = pointer_null;
    
    self.setAnimState(UnitAnimState.Idle);
    
    static toString = function() {
        var _typeName = type.name;
        return string("{0}", _typeName);
    }
    
    static destroy = function () {
        myTile = pointer_null;
    };
    
    static setAnimState = function (_state) {
        var _animSprite = type.getAnim(_state);
        if (is_undefined(_animSprite)) {
            return false;
        }
        
        animState = _state;
        animSprite = _animSprite;
        animProgress = 0;
        animLength = sprite_get_number(animSprite);
        animSpeed = sprite_get_speed(animSprite) / 1000; // sprites have to use frames per second, not per game frame!
        
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
        setAnimState(choose(UnitAnimState.Idle, UnitAnimState.Moving, UnitAnimState.Attacking, UnitAnimState.ReceivingHit, UnitAnimState.Death));
    };
}