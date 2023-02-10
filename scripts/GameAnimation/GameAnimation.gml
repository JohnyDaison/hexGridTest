function GameAnimation(_hexMap) constructor {
    hexMap = _hexMap;
    ds_list_add(hexMap.gameAnimations, self);
    
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
            
            if(!is_undefined(onAnimStart))
                onAnimStart(self);
        } else if (!paused && !ended) {
            progress += delta_time / 1000000;
            
            if (progress >= duration) {
                animationEnd();
                ended = true;
                
                if(!is_undefined(onAnimEnd))
                    onAnimEnd(self);
            } else {
                animationStep();
            }
        }
    }
    
    static destroy = function() {
        var _index = ds_list_find_index(hexMap.gameAnimations, self);
        ds_list_delete(hexMap.gameAnimations, _index);
    }
}
