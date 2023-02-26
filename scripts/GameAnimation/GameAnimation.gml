function GameAnimation(_gameController) constructor {
    gameController = _gameController
    hexMap = gameController.hexMap;
    ds_list_add(gameController.gameAnimations, self);
    
    started = false;
    paused = false;
    ended = false;
    duration = 1; // in seconds
    
    onAnimStart = undefined;
    onAnimEnd = undefined;
    
    static update = function() {
        if (!started) {
            animationStart();
            progress = 0;
            started = true;
            
            if (!is_undefined(onAnimStart))
                onAnimStart(self);
        } else if (!paused && !ended) {
            progress += delta_time / 1000000;
            
            if (progress >= duration) {
                animationEnd();
                ended = true;
                
                if (!is_undefined(onAnimEnd))
                    onAnimEnd(self);
            } else {
                animationStep();
            }
        }
    }
    
    static destroy = function() {
        var _index = ds_list_find_index(gameController.gameAnimations, self);
        ds_list_delete(gameController.gameAnimations, _index);
    }
}
