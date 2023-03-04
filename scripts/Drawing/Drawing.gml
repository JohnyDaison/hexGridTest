function drawSimpleArrow(_from, _to, _width) {
    var _dirVector = _to.subtract(_from).normalize();
    var _scaledDir = _dirVector.multiplyByScalar(_width);
    var _topOffset = _scaledDir.rotate90(1);
    var _bottomOffset = _scaledDir.rotate90(-1);
    
    var _topVertex = _from.add(_topOffset);
    var _bottomVertex = _from.add(_bottomOffset);
    
    draw_primitive_begin(pr_trianglelist);
    
    draw_vertex(_bottomVertex.x, _bottomVertex.y);
    draw_vertex(_topVertex.x, _topVertex.y);
    draw_vertex(_to.x, _to.y);
    
    draw_primitive_end();
}