enum TerrainBrushShape {
    Hexagon,
    Circle,
    Parallelogram
}

function TerrainBrush(_shape, _radius, _centerHeight, _edgeHeight = -1) constructor {
    shape = _shape;
    radius = _radius;
    centerHeight = _centerHeight;
    edgeHeight = _edgeHeight == -1 ? _centerHeight : _edgeHeight;
}

function TerrainPainter(_hexMap) constructor {
    hexMap = _hexMap;
    
    static paintTerrain = function (_centerHex, _brush, _generatorFunction, _options = undefined) {
        var _radius = _brush.radius;
        var _brushShape = _brush.shape;
        
        if (_radius < 0) {
            return;
        }
        
        if (_brushShape == TerrainBrushShape.Hexagon) {
            var _brushHeight = _brush.centerHeight;
            paintHex(_centerHex.q, _centerHex.r, _centerHex, _brushHeight, _generatorFunction, _options);
        
            for (var _currentRadius = 0; _currentRadius <= _radius; _currentRadius++) {
                var _ringArray = _centerHex.getRing(_currentRadius);
                var _hexCount = array_length(_ringArray);
                _brushHeight = round(lerp(_brush.centerHeight, _brush.edgeHeight, _currentRadius / _radius));
                
                for(var _hexIndex = 0; _hexIndex < _hexCount; _hexIndex++) {
                    var _hex = _ringArray[_hexIndex];
                    paintHex(_hex.q, _hex.r, _centerHex, _brushHeight, _generatorFunction, _options);
                }
            }
        }
    }
    
    static paintHex = function (_q, _r, _centerHex, _brushHeight, _generatorFunction, _options = undefined) {
        var _existingTile = hexMap.grid.getTileQR(_q, _r);
        if (!is_undefined(_existingTile)) {
            return pointer_null;   
        }
        
        var _height = _brushHeight;
        var _generated = _generatorFunction(_q, _r, hexMap, _options);
        
        if (!is_undefined(_generated.height)) {
            _height = _generated.height;
        }
        
        var _type = _generated.type;
        
        return hexMap.addTile(_q, _r, _type, _height);
    }
}

function randomTerrainGenerator(_q, _r, _hexMap, _options) {
    var _type = choose(TerrainType.Grass, TerrainType.Rock, TerrainType.Sand, TerrainType.Snow, TerrainType.Water);
    var _height = undefined;
    
    if (!is_undefined(_options)) {
        if (_options.height) {
            _height = irandom_range(1, 3);
        }
    }
    
    return { type: _type, height: _height };
}