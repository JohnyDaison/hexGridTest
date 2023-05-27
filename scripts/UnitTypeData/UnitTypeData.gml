function UnitTypeData(_id, _name) constructor {
    global.unitTypeMap[? _id] = self;
    typeId = _id;
    name = _name;
    tint = c_white;
    
    initiative = 0;
    actionPoints = 0;
    ground = false;
    flying = false;
    water = false;
    movement = new MovementStats();
    combat = new CombatStats();
    
    shadowRadius = 100;
    scale = 1;
    yOffset = 0;
    healthBarOffset = new Vector(0, -110);
    animMovementSpeed = 1000;
    animAttackSpeed = 1000;
    animationMap = ds_map_create();
    drawOverlay = true;
    
    static getAnim = function(_state) {
        return animationMap[? _state];
    }
    
    static setAnim = function(_state, _sprite) {
        animationMap[? _state] = _sprite;
    }
    
    static destroy = function () {
        ds_map_destroy(animationMap);
    }
}