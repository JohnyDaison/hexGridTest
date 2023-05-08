function CombatStats() constructor {
    self.health = 1;
    self.maxHealth = 1;
    self.attack = 1;
    self.attackRange = 1;
    self.accuracy = 1;
    self.armor = 0;
    self.passive = false;
    
    static copy = function () {
        var _newStats = new CombatStats();
        
        _newStats.health = self.health;
        _newStats.maxHealth = self.maxHealth;
        _newStats.attack = self.attack;
        _newStats.attackRange = self.attackRange;
        _newStats.accuracy = self.accuracy;
        _newStats.armor = self.armor;
        _newStats.passive = self.passive;
        
        return _newStats;
    };
}