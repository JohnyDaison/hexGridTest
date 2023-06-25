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
    
    static planTrixagonMeleeAttack = function () {
        myUnit.enqueueAction(new TrixagonMeleeAttackAction());
    }
    
    static planTrixagonRangedAttack = function () {
        myUnit.enqueueAction(new TrixagonRangedAttackAction());
    }
    
    static planTrixagonExplode = function () {
        myUnit.enqueueAction(new TrixagonExplodeAction());
    }
    
    // TODO: add logic
    static getAttackCost = function(_fromTile, _action) {
        var _endTile = myUnit.hexMap.getTile(_action.hex);
        
        if (_fromTile == pointer_null || _endTile == pointer_null) {
            return undefined;
        }
        
        return _action.pointCost;
    }
    
    static attackHex = function (_hex, _attackChance = 1, _animationScale = 1, _endAction = true) {
        if (myUnit.gameController.rules.otherActionsChangeFacing) {
            myUnit.movement.faceHex(_hex);
        }
        
        var _endTile = myUnit.hexMap.getTile(_hex);
        
        if (!_endTile) {
            return;
        }
        
        var _combat = self;
        var _attackAnimation = new BasicAttackAnimation(myUnit.gameController, myUnit, _endTile, _animationScale);
        _attackAnimation.endAction = _endAction;
        
        _attackChance *= stats.accuracy;
        
        _attackAnimation.onAnimEnd = method({combat: _combat, attackChance: _attackChance}, function (_animation) {
            var _targetUnit = _animation.endTile.getTopUnit();
            if (_targetUnit != pointer_null && _targetUnit != combat.myUnit) {
                var _attackRoll = random(1);
                
                if (_attackRoll > 0 && _attackRoll <= attackChance) {
                    combat.dealDamage(combat.stats.attack, _targetUnit);
                }
            }
            
            if (_animation.endAction)
                combat.myUnit.endCurrentAction();
        });
    }
    
    static attackUnit = function (_unit) {
        
    }
    
    static getTrixagonMeleeAttackChanceAgainstHex = function (_meleeHex) {
        var _meleeTile = myUnit.hexMap.getTile(_meleeHex);
        var _meleeTarget = _meleeTile ? _meleeTile.getTopUnit() : pointer_null;
        
        return getTrixagonMeleeAttackChanceAgainstUnit(_meleeTarget);
    }
    
    static getTrixagonMeleeAttackChanceAgainstUnit = function (_meleeTarget) {
        var _trixagon = myUnit.gameController.trixagon;
        var _meleeAttackChance = _trixagon.highAttackChance;
        
        if (_meleeTarget && _meleeTarget.getUnitInFrontOfMe() == myUnit) {
            _meleeAttackChance = _trixagon.lowAttackChance;
        }
        
        return _meleeAttackChance;
    }
    
    static trixagonMeleeAttackValid = function () {
        var _meleeTarget = myUnit.getUnitInFrontOfMe();
        if (!_meleeTarget) {
            return false;
        }
        
        var _isFriend = _meleeTarget.player == myUnit.player;
        var _isIndestructible = _meleeTarget.type.indestructible;
        
        if (_isFriend || _isIndestructible) {
            return false;
        }
        
        return true;
    }
    
    static trixagonMeleeAttack = function () {
        if (!trixagonMeleeAttackValid()) {
            myUnit.currentAction.aborted = true;
            return;
        }
        
        var _meleeTarget = myUnit.getUnitInFrontOfMe();
        var _meleeHex = _meleeTarget.nextPosition;
        var _meleeAttackChance = getTrixagonMeleeAttackChanceAgainstUnit(_meleeTarget);
        
        attackHex(_meleeHex, _meleeAttackChance, _meleeAttackChance);
    }
    
    static trixagonRangedAttackValid = function (_rangedTarget) {
        if (!_rangedTarget) {
            return false;
        }
        
        var _isIndestructible = _rangedTarget.type.indestructible;
        
        if (_isIndestructible) {
            return false;
        }
        
        return true;
    }
    
    static trixagonRangedAttack = function () {
        var _trixagon = myUnit.gameController.trixagon;
        var _myHex = myUnit.nextPosition;
        var _trunc = _myHex.getTrixagonTrunc();
        var _rangedAttackChance = _trixagon.lowAttackChance;
        
        for (var _index = 0; _index < 3; _index++) {
            var _hex = _myHex.add(_trunc.ranged[_index]);
            
            attackHex(_hex, _rangedAttackChance, _rangedAttackChance);
        }
    }
    
    static trixagonExplode = function () {
        var _trixagon = myUnit.gameController.trixagon;
        var _myHex = myUnit.nextPosition;
        var _trunc = _myHex.getTrixagonTrunc();
        var _rangedAttackChance = _trixagon.lowAttackChance;
        
        for (var _index = 0; _index < 3; _index++) {
            var _hex = _myHex.add(_trunc.melee[_index]);
            var _meleeAttackChance = getTrixagonMeleeAttackChanceAgainstHex(_hex);
            
            attackHex(_hex, _meleeAttackChance, _meleeAttackChance, false);
        }
        
        for (var _index = 0; _index < 6; _index++) {
            var _hex = _myHex.add(_trunc.movement[_index]);
            
            attackHex(_hex, _rangedAttackChance, _rangedAttackChance);
        }
    }
    
    static dealDamage = function (_damage, _toUnit) {
        _toUnit.combat.receiveDamage(_damage, myUnit);
    }
    
    static receiveDamage = function (_damage, _fromUnit) {
        if (!myUnit.type.indestructible) {
            var _origHealth = stats.health;
            stats.health -= max(0, _damage - stats.armor);
            stats.health = max(0, stats.health);
            
            if (stats.health < _origHealth) {
                myUnit.healthLossAnimation.start();
            }
        }
        
        myUnit.setNextAnimState(UnitAnimState.ReceivingHit);
        
        if (stats.health <= 0 && !myUnit.dying) {
            myUnit.die();
        }
    }
}