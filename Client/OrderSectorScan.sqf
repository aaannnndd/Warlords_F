#include "..\warlords_constants.hpp"

params ["_toContested"];

"Sector" call WL2_fnc_announcer;
[toUpper localize "STR_A3_WL_popup_scan"] spawn WL2_fnc_smoothText;
[player, -WL2_scanCost] call WL2_fnc_fundsControl;
["RequestMenu_close"] call WL2_fnc_setupUI;
if !(visibleMap) then {
	processDiaryLink createDiaryLink ["Map", player, ""];
	WL_CONTROL_MAP ctrlMapAnimAdd [0, 1, [WL2_mapSize / 2, WL2_mapSize / 2]];
	ctrlMapAnimCommit WL_CONTROL_MAP;
};
WL2_targetSector = objNull;
WL2_currentSelection = WL_ID_SELECTION_SCAN;

sleep 0.25;

"scan" spawn WL2_fnc_sectorSelectionHandle;

waitUntil {sleep WL_TIMEOUT_MIN; !isNull WL2_targetSector || !visibleMap || WL2_currentSelection == WL_ID_SELECTION_VOTING || !alive player || lifeState player == "INCAPACITATED"};

["scan", "end"] call WL2_fnc_sectorSelectionHandle;

if (WL2_currentSelection == WL_ID_SELECTION_SCAN) then {
	WL2_currentSelection = WL_ID_SELECTION_NONE;
};

if (isNull WL2_targetSector) exitWith {
	"Canceled" call WL2_fnc_announcer;
	[toUpper localize "STR_A3_WL_scan_canceled"] spawn WL2_fnc_smoothText;
	[player, WL2_scanCost] call WL2_fnc_fundsControl;
};

WL2_targetSector setVariable [format ["WL2_lastScanEnd_%1", WL2_playerSide], WL_SYNCED_TIME + WL_SCAN_DURATION, TRUE];