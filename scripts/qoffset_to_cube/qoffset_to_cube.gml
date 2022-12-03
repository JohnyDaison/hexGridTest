// Feather ignore all

///@function qoffset_to_cube(a,offset)
///@param hex
///@param offset
function qoffset_to_cube(argument0, argument1) {

	var a = argument0;
	var offset = argument1;

	var q = a[h.q];
	var r = a[h.r] - (a[h.q] + offset * (a[h.q] & 1)) / 2;
	var s = -q - r;

	return Hex(q, r, s);



}
