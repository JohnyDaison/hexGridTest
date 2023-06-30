function HexagonGeneralPhase(_gameController) : GamePhase(_gameController) constructor {
    type = PhaseType.HexagonGeneral;
    interactive = true;
    
    static toString = function() {
        return "HEXAGON GENERAL";
    }
}