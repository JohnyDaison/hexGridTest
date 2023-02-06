/// @description ANIMATIONS, DEBUG TEXT

// ANIMATIONS
hexMap.animationUpdate();

// DEBUG TEXT
debugText = "";
debugText += string("{0} | {1}\n", fps, string_format(fps_real, 4, 0));

debugText += string("{0} ", objGameCamera.zoomLevel);

if (!is_undefined(cursorHex)) {
    debugText += string("Hex {0},{1}", cursorHex.q, cursorHex.r);
    debugText += string(": {0}", ds_list_size(cursorTile.neighbors));
} else {
    debugText += string("Pos {0},{1}", cursorPos.q, cursorPos.r);
}

debugText += "\n";
debugText += string("{0} {1}", string(selectedUnit), string(moveTargetTile));
