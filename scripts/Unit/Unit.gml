function Unit(_unitType) constructor {
    type = global.unitTypeMap[? _unitType];
    scale = type.scale;
    initiative = type.initiative;
    actionPoints = type.actionPoints;
    facing = 0;
    facingUncertain = false;
    animations = ds_list_create();
    player = pointer_null;
    
    static shadowAlpha = 0.3;
    static shadowRatio = 0.4;
    static actionPlanStartAlpha = 0.7;
    static actionPlanEndAlpha = 0.4;
    static healthBarSize = new Vector(120, 20);
    static healthBarColor = Colors.friendlyGreen;
    static facingArrowAlpha = 0.5;
    
    initiativeAccumulated = 0;
    actionPointsUsed = 0;
    actionQueueTotalCost = 0;
    tookActionThisRound = false;
    turnCounter = 0;
    spriteFacing = 1;
    hexMap = pointer_null;
    currentTile = pointer_null;
    animState = undefined;
    loopAnimState = undefined;
    dying = false;
    dead = false;
    destroyed = false;
    
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
    
    healthLossAnimation = {
        blinkTime: 500,
        maxDuration: 1000,
        timeLeft: 0,
        
        start: function () {
            timeLeft = maxDuration;
        },
        
        update: function () {
            timeLeft -= delta_time / 1000;
        },
        
        isBlinking: function () {
            return timeLeft > 0 && (timeLeft mod blinkTime) / blinkTime <= 0.5;
        }
    }
    
    self.setAnimState(UnitAnimState.Idle);
    
    static toString = function() {
        var _typeName = type.name;
        return string("{0}", _typeName);
    }
    
    static destroy = function () {
        if (player) {
            player.removeUnit(self);
        }
        
        currentTile = pointer_null;
        ds_list_destroy(actionQueue);
        movement.destroy();
        ds_list_destroy(animations);
        
        destroyed = true;
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
        
        healthLossAnimation.update();
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
    
    static draw = function (_x, _y, _scale = 1) {
        var _yOffset = type.yOffset;
        var _tint = type.tint;
        var _finalScale = scale * _scale
        
        var _shadowRadiusX = type.shadowRadius * _finalScale;
        var _shadowRadiusY = type.shadowRadius * _finalScale * shadowRatio;
        
        draw_set_color(c_black);
        draw_set_alpha(shadowAlpha);
        
        draw_ellipse(_x - _shadowRadiusX, _y - _shadowRadiusY,
                    _x + _shadowRadiusX, _y + _shadowRadiusY, false);
        
        draw_sprite_ext(animSprite, animProgress,
            _x, _y + _finalScale * _yOffset,
            _finalScale * spriteFacing, _finalScale, 0, _tint, 1);
    }
    
    static drawOverlay = function(_center) {
        if (!type.drawOverlay) {
            return;
        }
        
        if (type.hasFace && !facingUncertain) {
            drawFacingArrow(_center.x, _center.y, facingArrowAlpha);
        }
            
        var _healthBarPosition = _center.add(type.healthBarOffset);
            
        if (gameController.trixagon.active) {
            drawHealthNumber(_healthBarPosition, healthLossAnimation.isBlinking());
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
        
        if (gameController.trixagon.active) {
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
    
    static drawHealthNumber = function (_position, _invert = false, _halign = fa_center, _valign = fa_middle) {
        draw_set_alpha(0.8);
        draw_set_color(c_black);
        if (_invert) {
            draw_set_color(c_white);
        }
        
        draw_circle(_position.x - 1, _position.y - 1, 48, false);
        
        draw_set_color(c_white);
        if (_invert) {
            draw_set_color(c_black);
        }
        
        draw_set_halign(_halign);
        draw_set_valign(_valign);
        draw_set_font(fontHealthNumber);
        draw_text(_position.x + 1, _position.y + 3, string(combat.stats.health));
    }
    
    static enqueueAction = function(_action) {
        var _actionCount = ds_list_size(actionQueue);
        var _lastAction = actionQueue[| _actionCount - 1];
        var _newActionCost = getActionCost(hexMap.getTile(plannedFinalPosition), _action);
        
        if (!gameController.rules.planForFutureTurns &&
            getRemainingActionPoints() < (actionQueueTotalCost + _newActionCost))
            return;
        
        if (!is_undefined(_lastAction) && _lastAction.type == ActionType.FaceHex) {
            ds_list_delete(actionQueue, _actionCount - 1);
        }
        
        ds_list_add(actionQueue, _action);
        
        actionQueueTotalCost += _newActionCost;
        
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
            case ActionType.TrixagonMeleeAttack:
            case ActionType.TrixagonRangedAttack:
            case ActionType.TrixagonExplode:
                return 0;
        }
    }
    
    static getRemainingActionPoints = function () {
        return actionPoints - actionPointsUsed;
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
        
        if (_actionCost > getRemainingActionPoints()) {
            return;
        }
        
        actionPointsUsed += _actionCost;
        actionQueueTotalCost -= _actionCost;
        currentAction = _nextAction;
        actionStarted = false;
        tookActionThisRound = true;
        nextPosition = _nextAction.getEndPosition(self, nextPosition);
        ds_list_delete(actionQueue, 0);
        
        if (!is_undefined(onActionStart))
            onActionStart();
    }
    
    static endCurrentAction = function () {
        lastAction = currentAction;
        currentAction = pointer_null;
        
        if (destroyed) {
            return;
        }
        
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
                    facingUncertain = false;
                    
                    if (_origFacing != facing) {
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
                case ActionType.TrixagonMeleeAttack: {
                    combat.trixagonMeleeAttack();
                    break;
                }
                case ActionType.TrixagonRangedAttack: {
                    combat.trixagonRangedAttack();
                    break;
                }
                case ActionType.TrixagonExplode: {
                    combat.trixagonExplode();
                    break;
                }
            }
            
            actionStarted = true;
            
            if (currentAction.instant || currentAction.aborted) {
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
        
        if (gameController.rules.useUnitQueue) {
            gameController.unitQueue.deleteUnit(self);
        }
        
        if (type.explodesOnDeath) {
            if (gameController.trixagon.active) {
                combat.planTrixagonExplode();
                
                if (currentAction == pointer_null) {
                    startNextAction();
                }
            }
        }
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
        tookActionThisRound = false;
    }
    
    static updateFacing = function (_facing = -1) {
        if (_facing != -1) {
            facing = _facing;
        }
        
        if (gameController.trixagon.active && currentTile) {
            constrainTrixagonFacing();
        }
        
        spriteFacing = sign(2.5 - facing);
    }
    
    static rotateFacing = function (_angle) {
        updateFacing(modulo(facing + _angle, 6));
    }
    
    static constrainTrixagonFacing = function () {
        var _triangleRight = currentTile.position.isTrixagonRight();
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
        if (!nextPosition || !type.hasFace) {
            return pointer_null;
        }
        
        var _frontPosition = nextPosition.neighbor(facing);
        var _frontTile = hexMap.getTile(_frontPosition);
        
        if (_frontTile) {
            return _frontTile.getTopUnit();
        }
        
        return pointer_null;
    }
}