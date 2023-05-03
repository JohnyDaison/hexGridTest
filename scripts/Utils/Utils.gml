function modulo(_aa, _bb) {
    _bb = abs(_bb);
    
    var _result = _aa % _bb;
    if (_result < 0) {
        _result += _bb;
    }
    
    return _result;
}