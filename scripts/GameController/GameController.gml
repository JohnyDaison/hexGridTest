function GameController() constructor {
    units = ds_list_create();
    gameAnimations = ds_list_create();
    hexMap = pointer_null;
    
    static destroy = function() {
        destroyMap();

        ds_list_destroy(gameAnimations);
        ds_list_destroy(units);
    }
    
    static createMap = function (_orientation, _size, _origin) {
        if(hexMap != pointer_null) {
            return pointer_null;
        }
        
        hexMap = new HexMap(_orientation, _size, _origin);
        hexMap.stackHeight = 60;
        
        return hexMap;
    }
    
    static destroyMap = function() {
        hexMap.destroy();
        hexMap = pointer_null;
        
        var _gameAnimationCount = ds_list_size(gameAnimations);
        for (var i = _gameAnimationCount - 1; i >= 0; i--) {
            var _gameAnimation = gameAnimations[| i];
            _gameAnimation.destroy();
            delete _gameAnimation;
        }
        
        ds_list_clear(gameAnimations);
        
        var _unitCount = ds_list_size(units);
        for (var i = 0; i < _unitCount; i++) {
            var _unit = units[| i];
            _unit.destroy();
            delete _unit;
        }
        
        ds_list_clear(units);
    }
    
    static addUnit = function(_hexTile, _unitType) {
        var _unit = new Unit(_unitType);
        ds_list_add(units, _unit);
        _unit.gameController = self;
        _unit.hexMap = hexMap;
        
        hexMap.placeUnit(_hexTile, _unit);
        
        return true;
    }
    
    static deleteUnit = function(_unit) {
        hexMap.displaceUnit(_unit);
        
        _unit.destroy();
        
        ds_list_delete(units, ds_list_find_index(units, _unit));
        
        return true;
    }
    
    static animationUpdate = function () {
        gameAnimationsUpdate();
        unitsAnimUpdate();
    }
    
    static unitsAnimUpdate = function () {
        var _unitCount = ds_list_size(units);
        
        for (var i = 0; i < _unitCount; i++) {
            var _unit = units[| i];
            
            _unit.animUpdate();
        }
    }
    
    static gameAnimationsUpdate = function () {
        var _gameAnimationCount = ds_list_size(gameAnimations);
        
        for (var i = 0; i < _gameAnimationCount; i++) {
            var _gameAnimation = gameAnimations[| i];
            
            _gameAnimation.update();
        }
    }
    
    static gameUpdate = function () {
        var _unitCount = ds_list_size(units);
        
        for (var i = _unitCount - 1; i >= 0; i--) {
            var _unit = units[| i];
            
            if (_unit.dead) {
                deleteUnit(_unit);
            }
        }
        
        _unitCount = ds_list_size(units);
        
        for (var i = 0; i < _unitCount; i++) {
            var _unit = units[| i];
            
            _unit.handleCurrentAction();
        }
    }
}