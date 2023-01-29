enum UnitType {
    KnightUnarmedBasic,
    KnightSwordBasic,
    KnightBowBasic,
    SkeletonSwordBasic,
    SkeletonBowBasic,
    BatBasic,
    SpiderBasic,
    TrainingDummy
}

global.unitTypeMap = ds_map_create();
var _unitType;

function landUnitType(_id, _name) {
    var _unitType = new UnitTypeData(_id, _name);
    
    _unitType.ground = true;
    _unitType.mobile = true;
    
    return _unitType;
}

function flyingUnitType(_id, _name) {
    var _unitType = new UnitTypeData(_id, _name);
    
    _unitType.flying = true;
    _unitType.mobile = true;
    _unitType.yOffset = -100;
    
    return _unitType;
}


_unitType = landUnitType(UnitType.KnightUnarmedBasic, "Basic Unarmed Knight");
_unitType.scale = 0.5;
_unitType.setAnim(UnitAnimState.Idle, sprKnight_Idle);
_unitType.setAnim(UnitAnimState.Moving, sprKnight_Walk);
_unitType.setAnim(UnitAnimState.ReceivingHit, sprKnight_Hit);
_unitType.setAnim(UnitAnimState.Death, sprKnight_Die);


_unitType = landUnitType(UnitType.KnightSwordBasic, "Basic Sword Knight");
_unitType.scale = 0.5;
_unitType.setAnim(UnitAnimState.Idle, sprKnight_Idle_Sword);
_unitType.setAnim(UnitAnimState.Moving, sprKnight_Walk_Sword);
_unitType.setAnim(UnitAnimState.Attacking, sprKnight_Attack_Sword_Light);
_unitType.setAnim(UnitAnimState.ReceivingHit, sprKnight_Hit_Sword);
_unitType.setAnim(UnitAnimState.Death, sprKnight_Die_Sword);


_unitType = landUnitType(UnitType.KnightBowBasic, "Basic Bow Knight");
_unitType.scale = 0.5;
_unitType.setAnim(UnitAnimState.Idle, sprKnight_Idle_Bow);
_unitType.setAnim(UnitAnimState.Moving, sprKnight_Walk_Bow);
_unitType.setAnim(UnitAnimState.Attacking, sprKnight_Attack_Bow);
_unitType.setAnim(UnitAnimState.ReceivingHit, sprKnight_Hit_Bow);
_unitType.setAnim(UnitAnimState.Death, sprKnight_Die_Bow);


_unitType = landUnitType(UnitType.SkeletonSwordBasic, "Basic Sword Skeleton");
_unitType.scale = 0.5;
_unitType.setAnim(UnitAnimState.Idle, sprSkeleton_Idle_Sword);
_unitType.setAnim(UnitAnimState.Moving, sprSkeleton_Walk_Sword);
_unitType.setAnim(UnitAnimState.Attacking, sprSkeleton_Attack_Sword_Light);
_unitType.setAnim(UnitAnimState.ReceivingHit, sprSkeleton_Hit_Sword);
_unitType.setAnim(UnitAnimState.Death, sprSkeleton_Die_Sword);


_unitType = landUnitType(UnitType.SkeletonBowBasic, "Basic Bow Skeleton");
_unitType.scale = 0.5;
_unitType.setAnim(UnitAnimState.Idle, sprSkeleton_Idle_Bow);
_unitType.setAnim(UnitAnimState.Moving, sprSkeleton_Walk_Bow);
_unitType.setAnim(UnitAnimState.Attacking, sprSkeleton_Attack_Bow);
_unitType.setAnim(UnitAnimState.ReceivingHit, sprSkeleton_Hit_Bow);
_unitType.setAnim(UnitAnimState.Death, sprSkeleton_Die_Bow);


_unitType = landUnitType(UnitType.SpiderBasic, "Basic Spider");
_unitType.scale = 0.5;
_unitType.setAnim(UnitAnimState.Idle, sprSpider_Idle);
_unitType.setAnim(UnitAnimState.Moving, sprSpider_Walk);
_unitType.setAnim(UnitAnimState.Attacking, sprSpider_Attack);
_unitType.setAnim(UnitAnimState.ReceivingHit, sprSpider_Hit);
_unitType.setAnim(UnitAnimState.Death, sprSpider_Die);


_unitType = flyingUnitType(UnitType.BatBasic, "Basic Bat");
_unitType.scale = 0.5;
_unitType.yOffset = -150;
_unitType.setAnim(UnitAnimState.Idle, sprBat_Idle);
_unitType.setAnim(UnitAnimState.Moving, sprBat_Fly);
_unitType.setAnim(UnitAnimState.Attacking, sprBat_Attack);
_unitType.setAnim(UnitAnimState.ReceivingHit, sprBat_Hit);
_unitType.setAnim(UnitAnimState.Death, sprBat_Die);


_unitType = landUnitType(UnitType.TrainingDummy, "Training Dummy");
_unitType.scale = 0.5;
_unitType.mobile = false;
_unitType.passive = true;
_unitType.setAnim(UnitAnimState.Idle, sprDummy_Idle);
_unitType.setAnim(UnitAnimState.ReceivingHit, sprDummy_Hit);
