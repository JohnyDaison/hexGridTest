///@function qoffset_from_cube(hex,offset)
///@param hex
///@param offset
function qoffset_from_cube(argument0, argument1) {

	var a = argument0;
	var offset = argument1;

	var col = a[h.q];
	var row = a[h.r] + (a[h.q] + offset * (a[h.q] & 1)) / 2;
	return OffsetCoord(col, row);



}
