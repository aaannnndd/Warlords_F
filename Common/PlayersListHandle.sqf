#include "..\warlords_constants.hpp"

WL2_allWarlords = +(playableUnits + switchableUnits) select {(side group _x) in WL2_competingSides && !(_x getVariable ["WL2_ignore", FALSE])};

[] spawn WL2_fnc_refreshIconsToDraw;

[] spawn {
	while {TRUE} do {
		WL2_allWarlords = WL2_allWarlords - [objNull];
		{WL2_allWarlords pushBackUnique _x} forEach ((playableUnits + switchableUnits) select {(side group _x) in WL2_competingSides && !(_x getVariable ["WL2_ignore", FALSE])});
		call WL2_fnc_refreshIconsToDraw;
		uiSleep WL_TIMEOUT_LONG
	};
};