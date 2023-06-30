function TrixagonMovementPhase(_gameController) : GamePhase(_gameController) constructor {
    type = PhaseType.TrixagonMovement;
    interactive = true;
    
    static toString = function() {
        return "TRIXAGON MOVEMENT";
    }
}