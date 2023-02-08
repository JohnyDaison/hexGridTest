enum ActionType {
    MoveToHex
}

global.actionTypeMap = ds_map_create();

var _map = global.actionTypeMap;

_map[? ActionType.MoveToHex] = MoveToHexAction;