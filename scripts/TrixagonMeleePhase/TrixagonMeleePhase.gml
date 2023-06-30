function TrixagonMeleePhase(_gameController) : GamePhase(_gameController) constructor {
    type = PhaseType.TrixagonMelee;
    interactive = false;
    
    static toString = function() {
        return "TRIXAGON MELEE";
    }
    
    static phaseStartLogic = function () {
        if (gameController.roundCounter > 1) {
            array_foreach(gameController.activePlayer.units, function (_unit) {
                _unit.combat.planTrixagonMeleeAttack();
                
                if (_unit.currentAction == pointer_null) {
                    _unit.startNextAction();
                }
            });
        }
    }
}