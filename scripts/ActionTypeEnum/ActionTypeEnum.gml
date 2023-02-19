enum ActionType {
    MoveToHex,
    AttackHex,
    AttackUnit,
}

global.actionTypeMap = ds_map_create();

var _map = global.actionTypeMap;

_map[? ActionType.MoveToHex] = MoveToHexAction;
_map[? ActionType.AttackHex] = AttackHexAction;
_map[? ActionType.AttackUnit] = AttackUnitAction;