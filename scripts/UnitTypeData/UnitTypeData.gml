function UnitTypeData(_id, _name) constructor {
    global.unitTypeMap[? _id] = self;
    typeId = _id;
    name = _name;
    
    ground = false;
    flying = false;
    water = false;
    mobile = false;
    passive = false;
    
    scale = 1;
    yOffset = 0;
    animationMap = ds_map_create();
    
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