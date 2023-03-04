function AttackHexAction(_hex) : GameAction() constructor {
    static type = ActionType.AttackHex;
    static planColor = c_red;
    hex = _hex;
    
    static toString = function() {
        return string("ATTACK HEX: {0}", string(hex));
    }
}