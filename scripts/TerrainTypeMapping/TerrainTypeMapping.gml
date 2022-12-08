global.terrainTypeMap = ds_map_create();
global.terrainTypeMap[? TerrainType.Base] = {
    sprBasic: pointer_null,
    sprStack: pointer_null
}
global.terrainTypeMap[? TerrainType.Grass] = {
    sprBasic: sprGrassBasic,
    sprStack: sprGrassStack
}
global.terrainTypeMap[? TerrainType.Rock] = {
    sprBasic: sprRockBasic,
    sprStack: sprRockStack
}
global.terrainTypeMap[? TerrainType.Sand] = {
    sprBasic: sprSandBasic,
    sprStack: sprSandStack
}
global.terrainTypeMap[? TerrainType.Snow] = {
    sprBasic: sprSnowBasic,
    sprStack: sprSnowStack
}
global.terrainTypeMap[? TerrainType.Water] = {
    sprBasic: sprWaterBasic,
    sprStack: sprWaterStack
}
