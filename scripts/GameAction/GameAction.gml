function GameAction() constructor {
    static type = undefined;
    static planColor = c_white;
    static pointCost = 1;
    static instant = false;
    aborted = false;
    
    static drawPlanned = function(_unit, _fromHex) {}
    
    static getEndPosition = function(_unit, _fromHex) {
        return _fromHex;
    }
}