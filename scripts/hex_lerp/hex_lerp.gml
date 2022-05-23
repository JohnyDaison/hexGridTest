///@function hex_lerp(hex_a, hex_b, time)
///@param hex_a
///@param hex_b
///@param time
function hex_lerp(argument0, argument1, argument2) {

	var a = argument0;
	var b = argument1;
	var t = argument2;

	return Hex(a[h.q] * (1.0 - t) + b[h.q] * t, a[h.r] * (1.0 - t) + b[h.r] * t, a[h.s] * (1.0 - t) + b[h.s] * t);


}
