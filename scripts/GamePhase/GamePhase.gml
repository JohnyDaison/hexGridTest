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
    
    static isInProgress = function () {
        return started && !ending && !ended;
    }
    
    static update = function() {
        if (starting && current_time >= startTime + startDelay) {
            starting = false;
            started = true;
            phaseStartLogic();
            onStart(self);
        }
        
        if (!interactive && isInProgress()) {
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
            ending = false;
            ended = true;
            phaseEndLogic();
            onEnd(self);
        }
    }
    
    static isInteractive = function() {
        return interactive && isInProgress();
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
        if (isInProgress()) {
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
    
    static phaseStartLogic = function() {}
    static phaseEndLogic = function() {}
    static onStart = function(_phase) {}
    static onEnd = function(_phase) {}
}