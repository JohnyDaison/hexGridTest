dragStartTile = pointer_null;
facingDragValid = false;
facingDragMouseHex = pointer_null;
facingDragNormalizedHex = pointer_null;
facingDragTile = pointer_null;

updateFacingDrag = function() {
    if (!dragStartTile || is_undefined(objHexMap.cursorHex) || dragStartTile.position.equals(objHexMap.cursorHex)) {
        facingDragValid = false;
        facingDragMouseHex = pointer_null;
        facingDragNormalizedHex = pointer_null;
        facingDragTile = pointer_null;
        return;
    }
    
    if (facingDragMouseHex != objHexMap.cursorHex) {
        facingDragMouseHex = objHexMap.cursorHex;
        var _normalized = facingDragMouseHex.subtract(dragStartTile.position).normalize();
        
        facingDragNormalizedHex = dragStartTile.position.add(_normalized);
        facingDragTile = objHexMap.hexMap.getTile(facingDragNormalizedHex);
        
        facingDragValid = !!facingDragTile;
    }
}