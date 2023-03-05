function GameAction() constructor {
    static type = undefined;
    static planColor = c_white;
    
    static drawPlanned = function(_unit, _fromHex) {}
    
    static getEndPosition = function(_unit, _fromHex) {
        return _fromHex;
    }
}