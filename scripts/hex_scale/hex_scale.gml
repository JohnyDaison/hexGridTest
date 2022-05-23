///@function hex_scale(hex, scale);
///@param hex
///@param scale
function hex_scale(argument0, argument1) {
	var a = argument0;
	var k = argument1;

	return Hex(a[h.q] * k, a[h.r] * k, a[h.s] * k);


}
