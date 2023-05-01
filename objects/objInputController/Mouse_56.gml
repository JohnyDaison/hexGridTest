/// @description DRAG END

updateFacingDrag();

if (dragStartTile && facingDragValid) {
    objHexMap.handleDrag(dragStartTile, facingDragNormalizedHex);
}

dragStartTile = pointer_null;
facingDragValid = false;