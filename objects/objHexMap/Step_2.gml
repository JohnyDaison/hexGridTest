/// @description DEBUG TEXT
debugText = string("{0} ", objGameCamera.zoomLevel);

if (!is_undefined(cursorHex)) {
    debugText += string("Hex {0},{1}", cursorHex.q, cursorHex.r);
    debugText += string(": {0}", ds_list_size(cursorTile.neighbors));
} else {
    debugText += string("Pos {0},{1}", cursorPos.q, cursorPos.r);
}

debugText += "\n";
debugText += string("{0} {1}", string(selectedUnit), string(moveTargetTile));
