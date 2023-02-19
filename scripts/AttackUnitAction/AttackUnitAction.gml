function AttackHexAction(_hex) : GameAction() constructor {
    type = ActionType.AttackHex;
    hex = _hex;
    
    static toString = function() {
        return string("ATTACK HEX: {0}", string(hex));
    }
}