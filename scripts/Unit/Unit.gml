function Unit(_unitType) constructor {
    type = global.unitTypeMap[? _unitType];
    scale = type.scale;
    facing = 1;
    hexMap = pointer_null;
    currentTile = pointer_null;
    animState = undefined;
    loopAnimState = undefined;
    
    actionQueue = ds_list_create();
    currentAction = pointer_null;
    lastAction = pointer_null;
    actionStarted = false;
    pauseActions = false;
    onActionStart = undefined;
    onActionEnd = undefined;
    onPlanEnd = undefined;
    plannedFinalPosition = pointer_null;
    
    self.setAnimState(UnitAnimState.Idle);
    
    static toString = function() {
        var _typeName = type.name;
        return string("{0}", _typeName);
    }
    
    static destroy = function () {
        currentTile = pointer_null;
        ds_list_destroy(actionQueue);
    };
    
    static setNextAnimState = function (_state, _loop = false) {
        nextAnimState = _state;
        nextAnimLoop = _loop;
    }
    
    static setAnimState = function (_state, _loop = false) {
        var _animSprite = type.getAnim(_state);
        if (is_undefined(_animSprite)) {
            return false;
        }
        
        setNextAnimState(_state, _loop);
        
        if (animState != _state) {
            resetAnimState(_state, _animSprite);
        }
        
        if (_loop) {
            loopAnimState = _state;
        } else {
            loopAnimState = undefined;
        }
        
        return true;
    }
    
    static resetAnimState = function (_state, _sprite, _progress = 0) {
        if (!sprite_exists(_sprite)) {
            return false;
        }
        
        animState = _state;
        animSprite = _sprite;
        animProgress = _progress;
        animLength = sprite_get_number(animSprite);
        animSpeed = sprite_get_speed(animSprite) / 1000; // sprites have to use frames per second, not per game frame!
        
        return true;
    }
    
    static animUpdate = function () {
        animProgress += animSpeed * delta_time / 1000;
        
        if (nextAnimState != animState || nextAnimLoop != !is_undefined(loopAnimState))
            setAnimState(nextAnimState, nextAnimLoop);
        
        if (animProgress >= animLength) {
            onAnimEnd();
        }
    }
    
    static onAnimEnd = function () {
        if (!is_undefined(loopAnimState)) {
            setNextAnimState(loopAnimState, true);
        } else {
            setNextAnimState(UnitAnimState.Idle);
            setNextAnimState(choose(UnitAnimState.Idle, UnitAnimState.Moving, UnitAnimState.Attacking, UnitAnimState.ReceivingHit, UnitAnimState.Death));
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
        
        if (_action.type == ActionType.MoveToHex) {
            plannedFinalPosition = _action.hex;
        }
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
        
        if(!pauseActions)
            startNextAction();
        
        if(currentAction == pointer_null && ds_list_size(actionQueue) == 0 && !is_undefined(onPlanEnd))
            onPlanEnd();
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
    
    static planMovementToHex = function (_hex) {
        var _actionArray = hexMap.findUnitPath(self, plannedFinalPosition, _hex);
        
        array_foreach(_actionArray, function(_action, _index) {
            enqueueAction(_action);
        });
    }
}