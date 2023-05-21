function Unit(_unitType) constructor {
    type = global.unitTypeMap[? _unitType];
    scale = type.scale;
    initiative = type.initiative;
    actionPoints = type.actionPoints;
    facing = 0;
    animations = ds_list_create();
    
    static shadowAlpha = 0.3;
    static shadowRatio = 0.4;
    static actionPlanStartAlpha = 0.7;
    static actionPlanEndAlpha = 0.4;
    static healthBarSize = new Vector(120, 20);
    static healthBarColor = Colors.friendlyGreen;
    static facingArrowAlpha = 0.5;
    
    initiativeAccumulated = 0;
    actionPointsUsed = 0;
    turnCounter = 0;
    spriteFacing = 1;
    hexMap = pointer_null;
    currentTile = pointer_null;
    animState = undefined;
    loopAnimState = undefined;
    dying = false;
    dead = false;
    
    movement = new MovementModule(self, type.movement);
    combat = new CombatModule(self, type.combat);
    
    actionQueue = ds_list_create();
    currentAction = pointer_null;
    lastAction = pointer_null;
    actionStarted = false;
    pauseActions = false;
    onActionStart = undefined;
    onActionEnd = undefined;
    onPlanEnd = undefined;
    nextPosition = pointer_null;
    plannedFinalPosition = pointer_null;
    
    self.setAnimState(UnitAnimState.Idle);
    
    static toString = function() {
        var _typeName = type.name;
        return string("{0}", _typeName);
    }
    
    static destroy = function () {
        currentTile = pointer_null;
        ds_list_destroy(actionQueue);
        movement.destroy();
        ds_list_destroy(animations);
    };
    
    static setNextAnimState = function (_state, _loop = false) {
        nextAnimState = _state;
        nextAnimLoop = _loop;
    }
    
    static hasAnimStateSprite = function (_state) {
        var _animSprite = type.getAnim(_state);
        if (is_undefined(_animSprite)) {
            return false;
        }
        
        return true;
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
        var _prevProgress = animProgress;
        if (!dead) {
            animProgress += animSpeed * delta_time / 1000;
        }
        
        if (nextAnimState != animState || nextAnimLoop != !is_undefined(loopAnimState))
            setAnimState(nextAnimState, nextAnimLoop);
        
        if (animProgress >= animLength) {
            onAnimEnd();
            
            if (dead) {
                animProgress = _prevProgress;
            }
        }
    }
    
    static onAnimEnd = function () {
        if (dying) {
            if (hasAnimStateSprite(UnitAnimState.Death) && animState != UnitAnimState.Death) {
                setNextAnimState(UnitAnimState.Death);
            } else {
                dead = true;
            }
        }
        else if (!is_undefined(loopAnimState)) {
            setNextAnimState(loopAnimState, true);
        } else {
            setNextAnimState(UnitAnimState.Idle);
        }
    };
    
    static draw = function (_x, _y) {
        var _yOffset = type.yOffset;
        var _tint = type.tint;
        
        var _shadowRadiusX = type.shadowRadius * scale;
        var _shadowRadiusY = type.shadowRadius * scale * shadowRatio;
        
        draw_set_color(c_black);
        draw_set_alpha(shadowAlpha);
        
        draw_ellipse(_x - _shadowRadiusX, _y - _shadowRadiusY,
                    _x + _shadowRadiusX, _y + _shadowRadiusY, false);
        
        draw_sprite_ext(animSprite, animProgress,
            _x, _y + scale * _yOffset,
            scale * spriteFacing, scale, 0, _tint, 1);
    }
    
    static drawOverlay = function(_center) {
        drawFacingArrow(_center.x, _center.y, facingArrowAlpha);
            
        var _healthBarPosition = _center.add(type.healthBarOffset);
            
        if (gameController.trixagon) {
            drawHealthNumber(_healthBarPosition);
        } else {
            drawHealthBar(_healthBarPosition);
        }
    }
    
    static drawFacingArrow = function (_x, _y, _alpha) {
        var _tint = Colors.enemyRed;
        var _arrowSprite = sprHexFacingArrow;
        
        if (gameController.selectedUnit == self) {
            _tint = Colors.friendlyGreen;
        }
        
        if (gameController.trixagon) {
            _tint = c_black;
            _alpha = 1;
            _arrowSprite = sprHexFacingArrowTrixagon;
        }
        
        draw_sprite_ext(_arrowSprite, facing, _x, _y, 1, 1, 0, _tint, _alpha);
    }
    
    static drawHealthBar = function (_position, _halign = fa_center, _valign = fa_middle) {
        var _healthRatio = combat.stats.health / combat.stats.maxHealth;
        drawBar(_position, healthBarSize, healthBarColor, _healthRatio, _halign, _valign);
    }
    
    static drawHealthNumber = function (_position, _halign = fa_center, _valign = fa_middle) {
        draw_set_alpha(0.8);
        draw_set_color(c_black);
        draw_circle(_position.x, _position.y, 48, false);
        
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fontHealthNumber);
        draw_text(_position.x + 2, _position.y + 4, string(combat.stats.health));
    }
    
    static enqueueAction = function(_action) {
        var _actionCount = ds_list_size(actionQueue);
        var _lastAction = actionQueue[| _actionCount - 1];
        
        if (!is_undefined(_lastAction) && _lastAction.type == ActionType.FaceHex) {
            ds_list_delete(actionQueue, _actionCount - 1);
        }
        
        ds_list_add(actionQueue, _action);
        
        if (_action.type == ActionType.MoveToHex) {
            plannedFinalPosition = _action.hex;
        }
    }
    
    static clearActionQueue = function() {
        ds_list_clear(actionQueue);
        
        plannedFinalPosition = nextPosition;
    }
    
    static drawPlannedActions = function () {
        var _count = ds_list_size(actionQueue);
        var _currentHex = nextPosition;
        
        for(var _index = 0; _index < _count; _index++) {
            var _action = actionQueue[| _index];
            var _actionAlpha = lerp(actionPlanStartAlpha, actionPlanEndAlpha, _index / _count);
            
            draw_set_alpha(_actionAlpha);
            _action.drawPlanned(self, _currentHex);
            
            _currentHex = _action.getEndPosition(self, _currentHex);
        }
    }
    
    static getActionCost = function (_fromTile, _action) {
        switch (_action.type) {
            case ActionType.FaceHex: {
                return movement.getMovementCost(_fromTile, _action);
            }
            case ActionType.MoveToHex: {
                return movement.getMovementCost(_fromTile, _action);
            }
            case ActionType.AttackHex: {
                return combat.getAttackCost(_fromTile, _action);
            }
        }
    }
    
    static getNextAction = function () {
        var _nextAction = actionQueue[| 0];
        
        if (is_undefined(_nextAction)) {
            return pointer_null;
        }
        
        return _nextAction;
    }
    
    static getFirstFacingAction = function () {
        if (currentAction && currentAction.type == ActionType.FaceHex) {
            return currentAction;
        }
        
        var _nextAction = getNextAction();
        
        if (_nextAction && _nextAction.type == ActionType.FaceHex) {
            return _nextAction;
        }
        
        return pointer_null;
    }
    
    static startNextAction = function () {
        if (currentAction != pointer_null) {
            return;
        }
        
        var _nextAction = actionQueue[| 0];
        
        if (is_undefined(_nextAction)) {
            return;
        }
        
        var _actionCost = getActionCost(currentTile, _nextAction);
        
        if (is_undefined(_actionCost)) {
            ds_list_delete(actionQueue, 0);
            startNextAction();
            return;
        }
        
        if (_actionCost > actionPoints - actionPointsUsed) {
            return;
        }
        
        actionPointsUsed += _actionCost;
        currentAction = _nextAction;
        actionStarted = false;
        nextPosition = _nextAction.getEndPosition(self, nextPosition);
        ds_list_delete(actionQueue, 0);
        
        if (!is_undefined(onActionStart))
            onActionStart();
    }
    
    static endCurrentAction = function () {
        lastAction = currentAction;
        currentAction = pointer_null;
        
        if (!is_undefined(onActionEnd))
            onActionEnd();
        
        if (!pauseActions)
            startNextAction();
        
        if (currentAction == pointer_null && ds_list_size(actionQueue) == 0 && !is_undefined(onPlanEnd))
            onPlanEnd();
    }
    
    static handleCurrentAction = function () {
        if (currentAction == pointer_null) {
            return;
        }
        
        if (!actionStarted) {
            switch (currentAction.type) {
                case ActionType.FaceHex: {
                    var _origFacing = facing;
                    movement.faceHex(currentAction.hex);
                    
                    if (_origFacing == facing) {
                        var _actionCost = getActionCost(currentTile, currentAction);
                        actionPointsUsed -= _actionCost;
                    }
                    break;
                }
                case ActionType.MoveToHex: {
                    movement.moveToHex(currentAction.hex);
                    break;
                }
                case ActionType.AttackHex: {
                    combat.attackHex(currentAction.hex);
                    break;
                }
            }
            
            actionStarted = true;
            
            if (currentAction.instant) {
                endCurrentAction();
            }
        }
    }
    
    static getQueueEndAction = function () {
        var _actionCount = ds_list_size(actionQueue);
        return actionQueue[| _actionCount - 1];
    }
    
    static die = function () {
        dying = true;
    }
    
    static updateInitiative = function () {
        initiativeAccumulated += initiative;
        if (initiativeAccumulated < 0) {
            initiativeAccumulated = 0;
        }
    }
    
    static onRoundStart = function () {
        updateInitiative();
        
        actionPointsUsed = 0;
    }
    
    static updateFacing = function (_facing = -1) {
        if (_facing != -1) {
            facing = _facing;
        }
        
        if (gameController.trixagon && currentTile) {
            constrainTrixagonFacing();
        }
        
        spriteFacing = sign(2.5 - facing);
    }
    
    static rotateFacing = function (_angle) {
        updateFacing(modulo(facing + _angle, 6));
    }
    
    static constrainTrixagonFacing = function () {
        var _triangleRight = hexMap.isTrixagonRight(currentTile.position);
        var _facingOdd = facing % 2;
            
        if ((_triangleRight && !_facingOdd) || (!_triangleRight && _facingOdd)) {
            var _updateDone = false;
            var _prevFacing = modulo(facing - 1, 6);
            var _nextFacing = modulo(facing + 1, 6);
            var _facingAction = getFirstFacingAction();
            
            if (_facingAction) {
                var _actionFacing = movement.getFacingToHex(_facingAction.hex);
                    
                if (_actionFacing == _prevFacing || _actionFacing == _nextFacing) {
                    facing = _actionFacing;
                    _updateDone = true;
                }
            }
            
            if (!_updateDone) {
                facing = _prevFacing;
            }
        }
    }
    
    static getUnitInFrontOfMe = function () {
        if (!nextPosition) {
            return pointer_null;
        }
        
        var _frontPosition = nextPosition.add(global.hexDirections[facing]);
        var _frontTile = hexMap.getTile(_frontPosition);
        
        if (_frontTile) {
            return _frontTile.getTopUnit();
        }
        
        return pointer_null;
    }
}