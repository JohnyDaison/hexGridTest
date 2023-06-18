enum PhaseType {
    HexagonGeneral,
    TrixagonMovement,
    TrixagonMelee,
    TrixagonRanged
}

global.phaseTypeMap = ds_map_create();

var _map = global.phaseTypeMap;

_map[? PhaseType.HexagonGeneral] = HexagonGeneralPhase;
_map[? PhaseType.TrixagonMovement] = TrixagonMovementPhase;
_map[? PhaseType.TrixagonMelee] = TrixagonMeleePhase;
_map[? PhaseType.TrixagonRanged] = TrixagonRangedPhase;