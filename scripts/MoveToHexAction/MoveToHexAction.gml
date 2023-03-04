function MoveToHexAction(_hex) : GameAction() constructor {
    static type = ActionType.MoveToHex;
    static planColor = c_green;
    hex = _hex;
    
    static toString = function() {
        return string("MOVE TO HEX: {0}", string(hex));
    }
}