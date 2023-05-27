function CombatModule(_unit, _stats) constructor {
    myUnit = _unit;
    stats = _stats.copy();
    
    static canAttack = function () {
        return !stats.passive;
    }
    
    static planAttackOnHex = function (_hex) {
        if (!canAttack()) {
            return false;
        }
        
        if (myUnit.plannedFinalPosition.distance(_hex) > stats.attackRange) {
            if (!myUnit.movement.canMove()) {
                return false;
            }
            
            var _path = myUnit.hexMap.findUnitPath(myUnit, _hex, myUnit.plannedFinalPosition, stats.attackRange);
            var _lastAction = array_last(_path.actionArray);
            var _lastHex = _lastAction.hex;
            
            if (!myUnit.movement.planMovementToHex(_lastHex)) {
                return false;
            }
        }
        
        myUnit.enqueueAction(new AttackHexAction(_hex));
        
        return true;
    }
    
    static planAttackOnUnit = function (_unit) {
        myUnit.enqueueAction(new AttackUnitAction(_unit));
    }
    
    static planTrixagonAttack = function () {
        myUnit.enqueueAction(new TrixagonAttackAction());
    }
    
    // TODO: add logic
    static getAttackCost = function(_fromTile, _action) {
        var _endTile = myUnit.hexMap.getTile(_action.hex);
        
        if (_fromTile == pointer_null || _endTile == pointer_null) {
            return undefined;
        }
        
        return _action.pointCost;
    }
    
    static attackHex = function (_hex, _animationScale = 1, _endAction = true) {
        if (myUnit.gameController.rules.otherActionsChangeFacing) {
            myUnit.movement.faceHex(_hex);
        }
        
        var _endTile = myUnit.hexMap.getTile(_hex);
        
        if (!_endTile) {
            return;
        }
        
        var _attackAnimation = new BasicAttackAnimation(myUnit.gameController, myUnit, _endTile, _animationScale);
        _attackAnimation.endAction = _endAction;
        
        _attackAnimation.onAnimEnd = method(self, function (_animation) {
            var _targetUnit = _animation.endTile.getTopUnit();
            if (_targetUnit != pointer_null && _targetUnit != self.myUnit) {
                var _attackRoll = random(1);
                
                if (_attackRoll <= stats.accuracy) {
                    dealDamage(stats.attack, _targetUnit);
                }
            }
            
            if (_animation.endAction)
                myUnit.endCurrentAction();
        });
    }
    
    static attackUnit = function (_unit) {
        
    }
    
    static trixagonAttack = function () {
        var _myHex = myUnit.nextPosition;
        var _meleeHex = _myHex.add(global.hexDirections[myUnit.facing]);
        var _isRight = _myHex.isTrixagonRight();
        var _trunc = _isRight ? global.truncRight : global.truncLeft;
        var _rangedPositions = _trunc.ranged;
        
        var _rangedMapperFunction = method({myHex: _myHex}, function (_position) {
            return myHex.add(_position);
        });
        
        var _rangedHexes = array_map(_rangedPositions, _rangedMapperFunction);
        
        attackHex(_meleeHex, 0.5, false);
        
        array_foreach(_rangedHexes, function (_hex) {
            attackHex(_hex, 0.5);
        });
    }
    
    static dealDamage = function (_damage, _toUnit) {
        _toUnit.combat.receiveDamage(_damage, myUnit);
    }
    
    static receiveDamage = function (_damage, _fromUnit) {
        stats.health -= max(0, _damage - stats.armor);
        myUnit.setNextAnimState(UnitAnimState.ReceivingHit);
        
        if (stats.health <= 0) {
            myUnit.die();
        }
    }
}