function draw_hex_text() {
	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	for (var r=0;r<=map_height;r++) {
		var r_offset = floor(r/2);
		for (var q=-r_offset;q<=map_width-r_offset;q++) {
			var hex = Hex(q,r,-q-r);
			if (!hex_exists(hex)) {
				continue;
			}
			var map_key = hex_get_key(hex);
			var map = global.combat_map[? map_key];
			var center_point = hex_to_pixel(hex,layout);
			draw_text(center_point[X],center_point[Y],string(map[? "cost"]));
		}
	}


}
