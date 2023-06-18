function GamePhase(_gameController) constructor {
    static gameController = _gameController;
    static type = undefined;
    static interactive = false;
    
    started = false;
    ended = false;
    
    static startPhase = function() {
        started = true;
        onStart(self);
    }
    
    static endPhase = function() {
        ended = true;
        onEnd(self);
    }
    
    static reset = function() {
        started = false;
        ended = false;
    }
    
    static onStart = function(_phase) {}
    static onEnd = function(_phase) {}
}