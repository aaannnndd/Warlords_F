#include "..\warlords_constants.inc"

params ["_side"];

if !(_side in WL2_competingSides) then {
	objNull
} else {
	if ((WL2_base1 getVariable "WL2_originalOwner") == _side) then {
		WL2_base1
	} else {
		WL2_base2
	};
};