#include "..\warlords_constants.inc"

WL2_manLost = FALSE;

while {TRUE} do {
	_t = time + 120;
	waitUntil {sleep WL_TIMEOUT_SHORT; time > _t || WL2_manLost};
	if (WL2_manLost) then {
		WL2_manLost = FALSE;
	} else {
		WL2_matesAvailable = (WL2_matesAvailable + 1) min WL2_maxSubordinates;
		[] spawn WL2_fnc_refreshOSD;
	};
};