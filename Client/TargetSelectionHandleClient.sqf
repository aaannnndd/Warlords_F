#include "..\warlords_constants.inc"

{_x setMarkerAlphaLocal 0} forEach WL2_sectorLinks;
_mostVotedVar = format ["WL2_mostVoted_%1", WL2_playerSide];

while {!WL2_missionEnd} do {
	_lastTarget = WL_TARGET_FRIENDLY;
	waitUntil {sleep WL_TIMEOUT_STANDARD; isNull WL_TARGET_FRIENDLY};
	["RequestMenu_close"] call WL2_fnc_setupUI;
	WL2_currentSelection = WL_ID_SELECTION_VOTING;
	[] spawn {
		sleep 1;
		if (WL2_missionEnd) exitWith {};
		"Voting" call WL2_fnc_announcer;
		[toUpper localize "STR_A3_WL_popup_voting"] spawn WL2_fnc_smoothText;
		sleep 1;
		waitUntil {visibleMap || !isNull WL_TARGET_FRIENDLY};
		if (visibleMap && isNull WL2_targetVote) then {
			"Sector" call WL2_fnc_announcer;
			[toUpper localize "STR_A3_WL_info_voting_click"] spawn WL2_fnc_smoothText;
		};
	};
	if !(isNull _lastTarget) then {
		_t = WL_SYNCED_TIME + 3;
		waitUntil {(_lastTarget getVariable "WL2_owner") == WL2_playerSide || WL_SYNCED_TIME > _t};
	};
	["client"] call WL2_fnc_updateSectorArrays;
	_mostVotedVar spawn {
		waitUntil {count (missionNamespace getVariable [_this, []]) > 0};
		_data = (missionNamespace getVariable _this);
		["voting", [(_data # 1) - WL2_targetVotingDuration, _data # 1, _this]] spawn WL2_fnc_setOSDEvent;
	};
	
	"voting" spawn WL2_fnc_sectorSelectionHandle;

	[] spawn {
		waitUntil {!(WL2_currentSelection in [WL_ID_SELECTION_VOTING, WL_ID_SELECTION_VOTED]) || WL2_missionEnd || WL2_resetTargetSelection_client};
		
		["voting", "end"] spawn WL2_fnc_sectorSelectionHandle;
	};
	
	if !(isServer) then {
		waitUntil {!isNull WL_TARGET_FRIENDLY || WL2_missionEnd || WL2_resetTargetSelection_client};
	} else {
		_pass = FALSE;
		while {!_pass} do {
			waitUntil {!isNull WL_TARGET_FRIENDLY || WL2_missionEnd || WL2_resetTargetSelection_client};
			if (WL2_resetTargetSelection_client) then {
				sleep WL_TIMEOUT_STANDARD;
				if (WL2_resetTargetSelection_client) then {
					_pass = TRUE;
				};
			} else {
				_pass = TRUE;
			};
		};
	};
	
	WL2_targetVote = objNull;
	
	if (WL2_currentSelection in [WL_ID_SELECTION_VOTING, WL_ID_SELECTION_VOTED]) then {
		WL2_currentSelection = WL_ID_SELECTION_NONE;
	};
		
	missionNamespace setVariable [_mostVotedVar, []];
	missionNamespace setVariable [format ["WL2_targetVote_%1", getPlayerUID player], objNull];
	
	if (WL2_resetTargetSelection_client) then {
		WL2_resetTargetSelection_client = FALSE;
		"Reset" call WL2_fnc_announcer;
		["voting", []] spawn WL2_fnc_setOSDEvent;
		[toUpper localize "STR_A3_WL_voting_reset"] spawn WL2_fnc_smoothText;
		sleep 2;
	} else {
		call WL2_fnc_refreshCurrentTargetData;
		if !(WL2_missionEnd) then {
			waitUntil {sleep WL_TIMEOUT_MIN; !isNull WL_TARGET_FRIENDLY};
			"Selected" call WL2_fnc_announcer;
			[toUpper format [localize "STR_A3_WL_popup_voting_done", WL_TARGET_FRIENDLY getVariable "WL2_name"]] spawn WL2_fnc_smoothText;
			["client", TRUE] call WL2_fnc_updateSectorArrays;
		};
	};
};