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
            paintHex(_centerHex, _centerHex, _brushHeight, _generatorFunction, _options);
        
            for (var _currentRadius = 0; _currentRadius <= _radius; _currentRadius++) {
                var _ringArray = _centerHex.getRing(_currentRadius);
                var _hexCount = array_length(_ringArray);
                _brushHeight = round(lerp(_brush.centerHeight, _brush.edgeHeight, _currentRadius / _radius));
                
                for (var _hexIndex = 0; _hexIndex < _hexCount; _hexIndex++) {
                    var _hex = _ringArray[_hexIndex];
                    paintHex(_hex, _centerHex, _brushHeight, _generatorFunction, _options);
                }
            }
        }
    }
    
    static paintHex = function (_hex, _centerHex, _brushHeight, _generatorFunction, _options = undefined) {
        var _existingTile = hexMap.grid.getTile(_hex);
        
        if (_existingTile || !hexMap.isValidPosition(_hex)) {
            return pointer_null;
        }
        
        var _height = _brushHeight;
        var _generated = _generatorFunction(_hex, hexMap, _options);
        
        if (!is_undefined(_generated.height)) {
            _height = _generated.height;
        }
        
        var _type = _generated.type;
        
        return hexMap.addTile(_hex.q, _hex.r, _type, _height);
    }
}

function randomTerrainGenerator(_hex, _hexMap, _options) {
    var _type = choose(TerrainType.Grass, TerrainType.Rock, TerrainType.Sand, TerrainType.Snow, TerrainType.Water);
    var _height = undefined;
    
    if (!is_undefined(_options)) {
        if (_options.height) {
            _height = irandom_range(1, 3);
        }
    }
    
    return { type: _type, height: _height };
}

function wavesTerrainGenerator(_hex, _hexMap, _options) {
    var _type = TerrainType.Water;
    var _height = undefined;
    var _maxHeight = 3;
    var _maxHeightOffset = _maxHeight - 1;
    var _waveLength = 5;
    var _waveLengthMaxIndex = _waveLength - 1;
    
    if (!is_undefined(_options)) {
        if (_options.height) {
            var _rem = abs(_hex.r mod _waveLengthMaxIndex);
            
            var _ratio = _rem / _waveLengthMaxIndex;
            if (_ratio > 0.5) {
                _ratio = 1 - _ratio;
            }
            _ratio *= 2;
            
            _height = 1 + round(_ratio * _maxHeightOffset);
        }
    }
    
    return { type: _type, height: _height };
}

function trixagonTerrainGenerator(_hex, _hexMap, _options) {
    var _height = 1;
    var _type = modulo(_hex.s, 2) == 0 ? TerrainType.TrixagonUp : TerrainType.TrixagonDown;
    var _diffMod = modulo(_hex.q - _hex.r, 6);
    
    if (_diffMod == 0 || _diffMod >= 3) {
        _type = modulo(_hex.s, 2) == 0 ? TerrainType.TrixagonDown : TerrainType.TrixagonUp;
    }
    
    return { type: _type, height: _height };
}