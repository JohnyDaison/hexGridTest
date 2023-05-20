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
            
            var _actionArray = myUnit.hexMap.findUnitPath(myUnit, _hex, myUnit.plannedFinalPosition, stats.attackRange);
            var _lastAction = array_last(_actionArray);
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
    
    // TODO: add logic
    static getAttackCost = function(_fromTile, _action) {
        var _endTile = myUnit.hexMap.getTile(_action.hex);
        
        if (_fromTile == pointer_null || _endTile == pointer_null) {
            return undefined;    
        }
        
        return _action.pointCost;
    }
    
    static attackHex = function (_hex) {
        if (myUnit.gameController.otherActionsChangeFacing) {
            myUnit.movement.faceHex(_hex);
        }
        
        var _endTile = myUnit.hexMap.getTile(_hex);
        var _attackAnimation = new BasicAttackAnimation(myUnit.gameController, myUnit, _endTile);
        
        _attackAnimation.onAnimEnd = method(self, function (_animation) {
            var _targetUnit = _animation.endTile.getTopUnit();
            if (_targetUnit != pointer_null && _targetUnit != self.myUnit) {
                var _attackRoll = random(1);
                
                if (_attackRoll <= stats.accuracy) {
                    dealDamage(stats.attack, _targetUnit);
                }
            }
            
            myUnit.endCurrentAction();
        });
    }
    
    static attackUnit = function (_unit) {
        
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