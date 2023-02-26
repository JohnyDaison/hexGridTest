function insertionSort(_array, _comparator) {
    var _count = array_length(_array);
    
    for (var _sorted = 1; _sorted < _count; _sorted++) {
        var _newValue = _array[_sorted];
        var _insertionIndex = _sorted;
        
        while (_insertionIndex > 0 && _comparator(_newValue, _array[_insertionIndex - 1]) < 0) {
            _array[_insertionIndex] = _array[_insertionIndex - 1];
            _insertionIndex--;
        }
        
        _array[_insertionIndex] = _newValue;
    }
}