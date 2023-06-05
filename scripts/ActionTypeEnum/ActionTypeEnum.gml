enum ActionType {
    FaceHex,
    MoveToHex,
    AttackHex,
    AttackUnit,
    TrixagonAttack,
    TrixagonExplode
}

global.actionTypeMap = ds_map_create();

var _map = global.actionTypeMap;

_map[? ActionType.FaceHex] = FaceHexAction;
_map[? ActionType.MoveToHex] = MoveToHexAction;
_map[? ActionType.AttackHex] = AttackHexAction;
_map[? ActionType.AttackUnit] = AttackUnitAction;
_map[? ActionType.TrixagonAttack] = TrixagonAttackAction;
_map[? ActionType.TrixagonExplode] = TrixagonExplodeAction;