function Unit(_unitType) constructor {
    type = global.unitTypeMap[? _unitType];
    scale = type.scale;
    facing = 1;
    hexMap = pointer_null;
    currentTile = pointer_null;
    loopAnimState = undefined;
    
    actionQueue = ds_list_create();
    currentAction = pointer_null;
    lastAction = pointer_null;
    actionStarted = false;
    onActionStart = undefined;
    onActionEnd = undefined;
    
    self.setAnimState(UnitAnimState.Idle);
    
    static toString = function() {
        var _typeName = type.name;
        return string("{0}", _typeName);
    }
    
    static destroy = function () {
        currentTile = pointer_null;
        ds_list_destroy(actionQueue);
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
    
    static enqueueAction = function(_action) {
        ds_list_add(actionQueue, _action);
    }
    
    static startNextAction = function () {
        if (currentAction != pointer_null) {
            return;   
        }
        
        var _nextAction = actionQueue[| 0];
        
        if (is_undefined(_nextAction)) {
            return;
        }
        
        currentAction = _nextAction;
        actionStarted = false;
        ds_list_delete(actionQueue, 0);
        
        if(!is_undefined(onActionStart))
            onActionStart();
    }
    
    static endCurrentAction = function () {
        lastAction = currentAction;
        currentAction = pointer_null;
        
        if(!is_undefined(onActionEnd))
            onActionEnd();
    }
    
    static handleCurrentAction = function () {
        if (currentAction == pointer_null) {
            return;
        }
        
        if (!actionStarted) {
            if (currentAction.type == ActionType.MoveToHex) {
                moveToHex(currentAction.hex);
            }
            
            actionStarted = true;
        }
    }
    
    static moveToHex = function (_hex) {
        var _endTile = hexMap.getTile(_hex);
        var _movementAnimation = new BasicMovementAnimation(hexMap, self, _endTile);
        hexMap.displaceUnit(self);
    
        _movementAnimation.onAnimEnd = method(self, function (_animation) {
            hexMap.placeUnit(_animation.endTile, self);
            endCurrentAction();
        });
    }
}