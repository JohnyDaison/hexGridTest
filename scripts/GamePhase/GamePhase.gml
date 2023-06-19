function GamePhase(_gameController) constructor {
    static gameController = _gameController;
    static type = undefined;
    static interactive = false;
    static startDelay = 100;
    static endDelay = 200;
    
    startTime = 0;
    starting = false;
    started = false;
    endTime = 0;
    ending = false;
    ended = false;
    
    static update = function() {
        if (starting && current_time >= startTime + startDelay) {
            started = true;
            onStart(self);
        }
        
        if (!interactive && !ending) {
            var _units = gameController.units;
            var _unitCount = ds_list_size(_units);
            var _totalActive = 0;
                
            for(var i = 0; i < _unitCount; i++) {
                var _unit = _units[| i];
                if (_unit.currentAction != pointer_null) {
                    _totalActive++;
                }
            }
            
            if (_totalActive == 0) {
                endPhase();
            }
        }
        
        if (ending && current_time >= endTime + endDelay) {
            ended = true;
            onEnd(self);
        }
    }
    
    static isInteractive = function() {
        return interactive && started && !ending && !ended;
    }
    
    static startPhase = function() {
        if (!starting && !started && !ending && !ended) {
            starting = true;
            startTime = current_time;
            
            if (!interactive) {
                gameController.deselectUnit();
            }
        }
    }
    
    static endPhase = function() {
        if (started && !ending && !ended) {
            ending = true;
            endTime = current_time;
        }
    }
    
    static reset = function() {
        startTime = 0;
        starting = false;
        started = false;
        endTime = 0;
        ending = false;
        ended = false;
    }
    
    static onStart = function(_phase) {}
    static onEnd = function(_phase) {}
}