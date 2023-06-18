enum ActionType {
    FaceHex,
    MoveToHex,
    AttackHex,
    AttackUnit,
    TrixagonMeleeAttack,
    TrixagonRangedAttack,
    TrixagonExplode
}

global.actionTypeMap = ds_map_create();

var _map = global.actionTypeMap;

_map[? ActionType.FaceHex] = FaceHexAction;
_map[? ActionType.MoveToHex] = MoveToHexAction;
_map[? ActionType.AttackHex] = AttackHexAction;
_map[? ActionType.AttackUnit] = AttackUnitAction;
_map[? ActionType.TrixagonMeleeAttack] = TrixagonMeleeAttackAction;
_map[? ActionType.TrixagonRangedAttack] = TrixagonRangedAttackAction;
_map[? ActionType.TrixagonExplode] = TrixagonExplodeAction;