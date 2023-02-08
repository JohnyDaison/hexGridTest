function MoveToHexAction(_hex) : GameAction() constructor {
    type = ActionType.MoveToHex;
    hex = _hex;
    
    static toString = function() {
        return string("MOVE TO HEX: {0}", string(hex));
    }
}