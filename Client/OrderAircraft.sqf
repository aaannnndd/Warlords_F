#include "..\warlords_constants.inc"

params ["_class", "_cost", "_requirements"];

"Sector" call WL2_fnc_announcer;
[toUpper localize "STR_A3_WL_popup_appropriate_sector_selection"] spawn WL2_fnc_smoothText;
if !(visibleMap) then {
	processDiaryLink createDiaryLink ["Map", player, ""];
	WL_CONTROL_MAP ctrlMapAnimAdd [0, 1, [WL2_mapSize / 2, WL2_mapSize / 2]];
	ctrlMapAnimCommit WL_CONTROL_MAP;
};
WL2_targetSector = objNull;
WL2_currentSelection = WL_ID_SELECTION_ORDERING_AIRCRAFT;
WL2_orderedAssetRequirements = _requirements;
sleep 0.25;

"dropping" spawn WL2_fnc_sectorSelectionHandle;

waitUntil {sleep WL_TIMEOUT_MIN; !isNull WL2_targetSector || !visibleMap || WL2_currentSelection == WL_ID_SELECTION_VOTING};

["dropping", "end"] call WL2_fnc_sectorSelectionHandle;

if (WL2_currentSelection == WL_ID_SELECTION_ORDERING_AIRCRAFT) then {
	WL2_currentSelection = WL_ID_SELECTION_NONE;
};

if (isNull WL2_targetSector) exitWith {
	[player, _cost] call WL2_fnc_fundsControl;
	"Canceled" call WL2_fnc_announcer;
	[toUpper localize "STR_A3_WL_deploy_canceled"] spawn WL2_fnc_smoothText;
};

[toUpper localize "STR_A3_WL_asset_dispatched_TODO_REWRITE"] spawn WL2_fnc_smoothText;

_asset = ["requestAsset", [_class, WL2_targetSector]] call WL2_fnc_sendClientRequest;

[player, _asset] call WL2_fnc_newAssetHandle;