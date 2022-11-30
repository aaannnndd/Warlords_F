#include "..\warlords_constants.inc"

params ["_side"];

if (isServer) then {
	(WL2_sectorsArrays # (WL2_competingSides find _side)) # 4;
} else {
	if (_side == WL2_playerSide) then {WL2_sectorsArray # 4} else {WL2_sectorsArrayEnemy # 4};
};