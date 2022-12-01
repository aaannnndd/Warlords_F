#include "..\warlords_constants.hpp"

if !(isNull WL_TARGET_FRIENDLY) then {
	_color = if (WL2_playerSide in (WL_TARGET_FRIENDLY getVariable "WL2_revealedBy")) then {
		WL2_colorsArray # (WL2_sidesArray find (WL_TARGET_FRIENDLY getVariable "WL2_owner"))
	} else {
		WL2_colorsArray # 3
	};
	_color set [3, WL2_markersAlpha];
	WL2_currentTargetData = [
		format ["\A3\ui_f\data\map\markers\nato\%1.paa", markerType ((WL_TARGET_FRIENDLY getVariable "WL2_markers") # 0)],
		_color,
		[(position WL_TARGET_FRIENDLY) # 0, (position WL_TARGET_FRIENDLY) # 1, 3]
	];
};