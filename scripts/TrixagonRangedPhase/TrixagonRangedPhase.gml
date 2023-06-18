function TrixagonRangedPhase(_gameController) : GamePhase(_gameController) constructor {
    static type = PhaseType.TrixagonRanged;
    static interactive = false;
    
    static toString = function() {
        return "TRIXAGON RANGED";
    }
    
    static baseStartPhase = self.startPhase;
    static startPhase = function () {
        if (gameController.roundCounter > 1) {
            array_foreach(gameController.activePlayer.units, function (_unit) {
                _unit.combat.planTrixagonRangedAttack();
                
                if (_unit.currentAction == pointer_null) {
                    _unit.startNextAction();
                }
            });
        }
        
        baseStartPhase();
    }
}