#include "..\warlords_constants.hpp"

params ["_action", "_actionParams"];

waitUntil {!isNull (uiNamespace getVariable ["WL2_osd_action_voting_title", controlNull])};

_osd_cp_current = uiNamespace getVariable "WL2_osd_cp_current";
_osd_icon_side_1 = uiNamespace getVariable "WL2_osd_icon_side_1";
_osd_sectors_side_1 = uiNamespace getVariable "WL2_osd_sectors_side_1";
_osd_income_side_1 = uiNamespace getVariable "WL2_osd_income_side_1";
_osd_icon_side_2 = uiNamespace getVariable "WL2_osd_icon_side_2";
_osd_sectors_side_2 = uiNamespace getVariable "WL2_osd_sectors_side_2";
_osd_income_side_2 = uiNamespace getVariable "WL2_osd_income_side_2";
_osd_progress_background = uiNamespace getVariable "WL2_osd_progress_background";
_osd_progress = uiNamespace getVariable "WL2_osd_progress";
_osd_action_title = uiNamespace getVariable "WL2_osd_action_title";
_osd_progress_voting_background = uiNamespace getVariable "WL2_osd_progress_voting_background";
_osd_progress_voting = uiNamespace getVariable "WL2_osd_progress_voting";
_osd_action_voting_title = uiNamespace getVariable "WL2_osd_action_voting_title";

switch (_action) do {
	case "voting": {
		WL2_OSDEventArr set [0, _actionParams];
		if (count _actionParams == 0) exitWith {WL2_terminateOSDEvent_voting = TRUE};
		WL2_terminateOSDEvent_voting = FALSE;
		_actionParams params ["_tStart", "_tEnd", "_var"];
		_osd_progress_voting_background ctrlSetBackgroundColor [0, 0, 0, 0.25];
		_osd_progress_voting ctrlSetTextColor WL2_colorFriendly;
		while {WL_SYNCED_TIME < _tEnd && !WL2_terminateOSDEvent_voting} do {
			_osd_action_voting_title ctrlSetStructuredText parseText format ["<t shadow = '2' align = 'center' size = '%4'>%1%3: %2</t>", localize "STR_A3_WL_voting_hud_most_voted", ((missionNamespace getVariable _var) # 0) getVariable "WL2_name", if (toLower language == "french") then {" "} else {""}, 1 call WL2_fnc_sub_purchaseMenuGetUIScale];
			_osd_progress_voting progressSetPosition linearConversion [_tStart, _tEnd, WL_SYNCED_TIME, 0, 1];
			sleep WL_TIMEOUT_MIN;
		};
		WL2_terminateOSDEvent_voting = FALSE;
		_osd_progress_voting_background ctrlSetBackgroundColor [0, 0, 0, 0];
		_osd_action_voting_title ctrlSetStructuredText parseText "";
		_osd_progress_voting ctrlSetTextColor [0, 0, 0, 0];
		_osd_progress_voting progressSetPosition 0;
	};
	case "seizing": {
		WL2_OSDEventArr set [1, _actionParams];
		if (count _actionParams == 0) exitWith {WL2_terminateOSDEvent_seizing = TRUE};
		WL2_terminateOSDEvent_trespassing = TRUE;
		WL2_terminateOSDEvent_seizingDisabled = TRUE;
		WL2_terminateOSDEvent_seizing = FALSE;
		_actionParams params ["_sector", "_side", "_tStart", "_tEnd"];
		_osd_progress_background ctrlSetBackgroundColor (WL2_colorsArray # (WL2_sidesArray find (_sector getVariable "WL2_owner")));
		_color = WL2_colorsArray # (WL2_sidesArray find _side);
		_color set [3, 1];
		_osd_progress ctrlSetTextColor _color;
		while {WL_SYNCED_TIME < _tEnd && !WL2_terminateOSDEvent_seizing} do {
			_osd_action_title ctrlSetStructuredText parseText format ["<t shadow = '2' align = 'center' size = '%2'>%1</t>", _sector getVariable "WL2_name", 1 call WL2_fnc_sub_purchaseMenuGetUIScale];
			_osd_progress progressSetPosition linearConversion [_tStart, _tEnd, WL_SYNCED_TIME, 0, 1];
			sleep WL_TIMEOUT_MIN;
		};
		WL2_terminateOSDEvent_seizing = TRUE;
		if (WL2_terminateOSDEvent_trespassing) then {
			_osd_progress_background ctrlSetBackgroundColor [0, 0, 0, 0];
			_osd_action_title ctrlSetStructuredText parseText "";
			_osd_progress ctrlSetTextColor [0, 0, 0, 0];
			_osd_progress progressSetPosition 0;
		};
	};
	case "trespassing": {
		WL2_OSDEventArr set [2, _actionParams];
		if (count _actionParams == 0) exitWith {WL2_terminateOSDEvent_trespassing = TRUE};
		WL2_terminateOSDEvent_seizing = TRUE;
		WL2_terminateOSDEvent_trespassing = FALSE;
		_actionParams params ["_tStart", "_tEnd"];
		_osd_progress_background ctrlSetBackgroundColor [0, 0, 0, 0.25];
		_osd_progress ctrlSetTextColor [1, 0, 0, 1];
		while {WL_SYNCED_TIME < _tEnd && !WL2_terminateOSDEvent_trespassing} do {
			_osd_action_title ctrlSetStructuredText parseText format ["<t shadow = '2' align = 'center' size = '%2'>%1</t>", localize "STR_A3_WL_osd_zone", 1 call WL2_fnc_sub_purchaseMenuGetUIScale];
			_osd_progress progressSetPosition linearConversion [_tStart, _tEnd, WL_SYNCED_TIME, 0, 1];
			sleep WL_TIMEOUT_MIN;
		};
		WL2_terminateOSDEvent_trespassing = TRUE;
		if (WL2_terminateOSDEvent_seizing) then {
			_osd_progress_background ctrlSetBackgroundColor [0, 0, 0, 0];
			_osd_action_title ctrlSetStructuredText parseText "";
			_osd_progress ctrlSetTextColor [0, 0, 0, 0];
			_osd_progress progressSetPosition 0;
		};
	};
	case "seizingDisabled": {
		if (count _actionParams == 0) exitWith {WL2_terminateOSDEvent_seizingDisabled = TRUE};
		WL2_terminateOSDEvent_seizing = TRUE;
		WL2_terminateOSDEvent_seizingDisabled = FALSE;
		_actionParams params ["_owner"];
		_osd_progress_background ctrlSetBackgroundColor (WL2_colorsArray # (WL2_sidesArray find _owner));
		_osd_action_title ctrlSetStructuredText parseText format ["<t shadow = '2' align = 'center' size = '%2'>%1</t>", localize "STR_A3_to_editterrainobject23", 1 call WL2_fnc_sub_purchaseMenuGetUIScale];
		while {!WL2_terminateOSDEvent_seizingDisabled} do {
			sleep WL_TIMEOUT_MIN;
		};
		WL2_terminateOSDEvent_seizingDisabled = TRUE;
		if (WL2_terminateOSDEvent_seizing) then {
			_osd_progress_background ctrlSetBackgroundColor [0, 0, 0, 0];
			_osd_action_title ctrlSetStructuredText parseText "";
			_osd_progress ctrlSetTextColor [0, 0, 0, 0];
			_osd_progress progressSetPosition 0;
		};
	};
};