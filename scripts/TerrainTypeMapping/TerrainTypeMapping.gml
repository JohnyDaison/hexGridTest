global.TerrainTypeMap = ds_map_create();
global.TerrainTypeMap[? TerrainType.Base] = {
    sprBasic: pointer_null,
    sprStack: pointer_null
}
global.TerrainTypeMap[? TerrainType.Grass] = {
    sprBasic: sprGrassBasic,
    sprStack: sprGrassStack
}
global.TerrainTypeMap[? TerrainType.Rock] = {
    sprBasic: sprRockBasic,
    sprStack: sprRockStack
}
global.TerrainTypeMap[? TerrainType.Sand] = {
    sprBasic: sprSandBasic,
    sprStack: sprSandStack
}
global.TerrainTypeMap[? TerrainType.Snow] = {
    sprBasic: sprSnowBasic,
    sprStack: sprSnowStack
}
global.TerrainTypeMap[? TerrainType.Water] = {
    sprBasic: sprWaterBasic,
    sprStack: sprWaterStack
}
