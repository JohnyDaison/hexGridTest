function TrixagonMovementPhase(_gameController) : GamePhase(_gameController) constructor {
    static type = PhaseType.TrixagonMovement;
    static interactive = true;
    
    static toString = function() {
        return "TRIXAGON MOVEMENT";
    }
}