function HexagonGeneralPhase(_gameController) : GamePhase(_gameController) constructor {
    static type = PhaseType.HexagonGeneral;
    static interactive = true;
    
    static toString = function() {
        return "HEXAGON GENERAL";
    }
}