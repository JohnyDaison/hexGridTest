function Player(_number, _name, _color) constructor {
    gameController = pointer_null;
    hexMap = pointer_null;
    
    number = _number;
    name = _name;
    color = _color;
    units = array_create(0);
    
    hasLost = false;
    hasWon = false;
    
    static checkLossCondition = function() {
        if (array_length(units) == 0) {
            hasLost = true;
            hasWon = false;
        }
        
        return hasLost;
    }
    
    static checkWinCondition = function() { 
        var _allOthersLost = true;
        
        for(var i = 1; i <= gameController.playerCount; i++) {
            var _player = gameController.getPlayer(i);
            
            if (_player && _player != self && !_player.hasLost) {
                _allOthersLost = false;
            }
        }
        
        if (_allOthersLost) {
            hasWon = true;
        }
        
        return hasWon;
    }
    
    static addUnit = function(_unit) {
        if (_unit.player == self) {
            return;
        }
        
        if (_unit.player) {
            _unit.player.removeUnit(_unit);
        }
        
        _unit.player = self;
        
        array_push(units, _unit);
    }
    
    static removeUnit = function(_unit) {
        var _index = array_get_index(units, _unit);
        array_delete(units, _index, 1);
        
        _unit.player = pointer_null;
    }
}