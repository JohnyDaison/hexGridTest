global.terrainTypeMap = ds_map_create();
global.terrainTypeMap[? TerrainType.Base] = {
    name: "Base",
    sprBasic: pointer_null,
    sprStack: pointer_null
}
global.terrainTypeMap[? TerrainType.Grass] = {
    name: "Grass",
    sprBasic: sprGrassBasic,
    sprStack: sprGrassStack
}
global.terrainTypeMap[? TerrainType.Rock] = {
    name: "Rock",
    sprBasic: sprRockBasic,
    sprStack: sprRockStack
}
global.terrainTypeMap[? TerrainType.Sand] = {
    name: "Sand",
    sprBasic: sprSandBasic,
    sprStack: sprSandStack
}
global.terrainTypeMap[? TerrainType.Snow] = {
    name: "Snow",
    sprBasic: sprSnowBasic,
    sprStack: sprSnowStack
}
global.terrainTypeMap[? TerrainType.Water] = {
    name: "Water",
    sprBasic: sprWaterBasic,
    sprStack: sprWaterStack
}

global.terrainTypeMap[? TerrainType.TrixagonDown] = {
    name: "Triangle",
    sprBasic: sprTrixagonTileDownGreen,
    sprStack: pointer_null
}
global.terrainTypeMap[? TerrainType.TrixagonUp] = {
    name: "Triangle",
    sprBasic: sprTrixagonTileUpGreen,
    sprStack: pointer_null
}
