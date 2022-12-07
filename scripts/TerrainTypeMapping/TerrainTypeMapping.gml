global.TerrainTypeMapping = ds_map_create();
global.TerrainTypeMapping[? TerrainType.Base] = {
    sprBasic: pointer_null,
    sprStack: pointer_null
}
global.TerrainTypeMapping[? TerrainType.Grass] = {
    sprBasic: sprGrassBasic,
    sprStack: sprGrassStack
}
global.TerrainTypeMapping[? TerrainType.Rock] = {
    sprBasic: sprRockBasic,
    sprStack: sprRockStack
}
global.TerrainTypeMapping[? TerrainType.Sand] = {
    sprBasic: sprSandBasic,
    sprStack: sprSandStack
}
global.TerrainTypeMapping[? TerrainType.Snow] = {
    sprBasic: sprSnowBasic,
    sprStack: sprSnowStack
}
global.TerrainTypeMapping[? TerrainType.Water] = {
    sprBasic: sprWaterBasic,
    sprStack: sprWaterStack
}
