function MovementStats() constructor {
    self.mobile = true;
    
    static copy = function () {
        var _newStats = new MovementStats();
        
        _newStats.mobile = self.mobile;
        
        return _newStats;
    };
}