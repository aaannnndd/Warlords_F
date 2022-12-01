#include "..\warlords_constants.hpp"

params ["_toContested"];

"Destination" call WL2_fnc_announcer;
[toUpper localize "STR_A3_WL_popup_destination"] spawn WL2_fnc_smoothText;
private _cost = if (_toContested) then {WL2_fastTravelCostContested} else {WL2_fastTravelCostOwned};
[player, -_cost] call WL2_fnc_fundsControl;
["RequestMenu_close"] call WL2_fnc_setupUI;
if !(visibleMap) then {
	processDiaryLink createDiaryLink ["Map", player, ""];
	if (_toContested) then {
		WL_CONTROL_MAP ctrlMapAnimAdd [0, WL2_mapSizeIndex / 75, WL_TARGET_FRIENDLY];
	} else {
		WL_CONTROL_MAP ctrlMapAnimAdd [0, 1, [WL2_mapSize / 2, WL2_mapSize / 2]];
	};
	ctrlMapAnimCommit WL_CONTROL_MAP;
};
WL2_targetSector = objNull;
WL2_currentSelection = if (_toContested) then {WL_ID_SELECTION_FAST_TRAVEL_CONTESTED} else {WL_ID_SELECTION_FAST_TRAVEL};
private _action = if (_toContested) then {"travelling_contested"} else {"travelling"};
private _marker = "";
private _markerText = "";

if (_toContested) then {
	private _startArr = (synchronizedObjects WL_TARGET_FRIENDLY) select {(_x getVariable "WL2_owner") == WL2_playerSide};
	_startArr = _startArr apply {[_x distance2D player, _x]};
	_startArr sort TRUE;
	private _start = (_startArr # 0) # 1;
	private _area = WL_TARGET_FRIENDLY getVariable "objectArea";
	private _size = (if (_area # 3) then {
		sqrt (((_area # 0) ^ 2) + ((_area # 1) ^ 2));
	} else {
		(_area # 0) max (_area # 1);
	});
	_marker = createMarkerLocal [call WL2_fnc_generateVariableName, [WL_TARGET_FRIENDLY, _size + WL_FAST_TRAVEL_OFFSET, WL_TARGET_FRIENDLY getDir _start] call BIS_fnc_relPos];
	_marker setMarkerShapeLocal "RECTANGLE";
	_marker setMarkerColorLocal WL2_colorMarkerFriendly;
	_marker setMarkerDirLocal (WL_TARGET_FRIENDLY getDir _start);
	_marker setMarkerSizeLocal [_size, WL_FAST_TRAVEL_RANGE_AXIS];
	_markerText = createMarkerLocal [call WL2_fnc_generateVariableName, markerPos _marker];
	_markerText setMarkerColorLocal WL2_colorMarkerFriendly;
	_markerText setMarkerSizeLocal [0, 0];
	_markerText setMarkerTypeLocal "mil_dot";
	_markerText setMarkerTextLocal localize "STR_A3_cfgvehicles_moduletasksetdestination_f_arguments_destination_0";
};

sleep 0.25;

_action spawn WL2_fnc_sectorSelectionHandle;

waitUntil {sleep WL_TIMEOUT_MIN; !isNull WL2_targetSector || !visibleMap || WL2_currentSelection == WL_ID_SELECTION_VOTING || !alive player || lifeState player == "INCAPACITATED"};

[_action, "end"] call WL2_fnc_sectorSelectionHandle;

if (isNull WL2_targetSector) exitWith {
	if (WL2_currentSelection in [WL_ID_SELECTION_FAST_TRAVEL, WL_ID_SELECTION_FAST_TRAVEL_CONTESTED]) then {
		WL2_currentSelection = WL_ID_SELECTION_NONE;
	};
	"Canceled" call WL2_fnc_announcer;
	[toUpper localize "STR_A3_WL_menu_fasttravel_canceled"] spawn WL2_fnc_smoothText;
	deleteMarkerLocal _marker;
	deleteMarkerLocal _markerText;
	[player, _cost] call WL2_fnc_fundsControl;
};

titleCut ["", "BLACK OUT", 1];
openMap [FALSE, FALSE];

private _destination = if (_toContested) then {
		(_marker call WL2_fnc_findSpawnPositions) select {private _pos = _x; WL2_allSectors findIf {_pos inArea ((_x getVariable "WL2_markers") # 2)} == -1};
	} else {
		WL2_targetSector call WL2_fnc_findSpawnPositions;
	};
if (count _destination > 0) then {_destination = selectRandom _destination} else {_destination = if (_toContested) then {markerPos _marker} else {position WL2_targetSector}};

deleteMarkerLocal _marker;
deleteMarkerLocal _markerText;

"Fast_travel" call WL2_fnc_announcer;
[toUpper format [localize "STR_A3_WL_popup_travelling", WL2_targetSector getVariable "WL2_name"], nil, 3] spawn WL2_fnc_smoothText;

sleep 1;

["fastTravel", [_destination]] call WL2_fnc_sendClientRequest;

sleep 2;

if (WL2_currentSelection in [WL_ID_SELECTION_FAST_TRAVEL, WL_ID_SELECTION_FAST_TRAVEL_CONTESTED]) then {
	WL2_currentSelection = WL_ID_SELECTION_NONE;
};

player setDir (player getDir WL2_targetSector);
titleCut ["", "BLACK IN", 1];