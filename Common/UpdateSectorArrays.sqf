#include "..\warlords_constants.inc"

params ["_caller", ["_fullRecalc", FALSE]];

waitUntil {!WL2_sectorUpdateInProgress};

WL2_sectorUpdateInProgress = TRUE;

if (_caller == "server") then {
	WL2_sectorsArrays = [[WL2_competingSides # 0, _fullRecalc] call WL2_fnc_sortSectorArrays, [WL2_competingSides # 1, _fullRecalc] call WL2_fnc_sortSectorArrays];
} else {
	if (isServer && WL_SYNCED_TIME == 0 && !_fullRecalc) then {
		WL2_sectorsArray = WL2_sectorsArrays # (WL2_competingSides find WL2_playerSide);
		WL2_sectorsArrayEnemy = WL2_sectorsArrays # (WL2_competingSides find WL2_enemySide);
	} else {
		WL2_sectorsArray = [WL2_playerSide, _fullRecalc] call WL2_fnc_sortSectorArrays;
		WL2_sectorsArrayEnemy = [WL2_enemySide, _fullRecalc] call WL2_fnc_sortSectorArrays;
	};
	[TRUE] spawn WL2_fnc_refreshOSD;
};

WL2_sectorUpdateInProgress = FALSE;