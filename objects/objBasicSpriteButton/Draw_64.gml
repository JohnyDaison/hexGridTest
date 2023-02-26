if (!enabled) {
    image_index = 3;
} else if (pressed) {
    image_index = 2;
} else if (hovered) {
    image_index = 1;
} else {
    image_index = 0;
}

draw_self();