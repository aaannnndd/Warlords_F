#include "..\warlords_constants.inc"

waitUntil {sleep WL_TIMEOUT_SHORT; (WL2_base1 getVariable "WL2_owner") == (WL2_base2 getVariable "WL2_owner")};

WL2_missionEnd = TRUE;

private _winner = WL2_base1 getVariable "WL2_owner";

if !(isDedicated) then {
	WL_CONTROL_MAP ctrlRemoveEventHandler ["Draw", missionNamespace getVariable ["WL2_mapDrawHandler", -1]];
	removeMissionEventHandler ["EachFrame", WL2_assetMapHandler];
	removeMissionEventHandler ["MapSingleClick", WL2_assetMapClickHandler];
	removeMissionEventHandler ["Draw3D", missionNamespace getVariable ["WL2_sceneDrawHandler", -1]];
	removeMissionEventHandler ["GroupIconClick", missionNamespace getVariable ["WL2_groupIconClickHandler", -1]];
	removeMissionEventHandler ["GroupIconOverEnter", missionNamespace getVariable ["WL2_groupIconEnterHandler", -1]];
	removeMissionEventHandler ["GroupIconOverLeave", missionNamespace getVariable ["WL2_groupIconLeaveHandler", -1]];
	
	{deleteMarkerLocal _x} forEach ["WL2_targetEnemy", "WL2_targetFriendly"];
	
	{
		(uiNamespace getVariable _x) ctrlShow FALSE;
	} forEach [
		"WL2_osd_cp_current",
		"WL2_osd_icon_side_1",
		"WL2_osd_sectors_side_1",
		"WL2_osd_income_side_1",
		"WL2_osd_icon_side_2",
		"WL2_osd_sectors_side_2",
		"WL2_osd_income_side_2",
		"WL2_osd_progress_background",
		"WL2_osd_progress",
		"WL2_osd_action_title",
		"WL2_osd_progress_voting_background",
		"WL2_osd_progress_voting",
		"WL2_osd_action_voting_title"
	];
	
	_victory = _winner == WL2_playerSide;
	_debriefing = format ["BIS_WL%1%2", if (_victory) then {"Victory"} else {"Defeat"}, WL2_playerSide];
	[_debriefing, _victory] call BIS_fnc_endMission;
} else {
	sleep 15;
	endMission "End1"
};