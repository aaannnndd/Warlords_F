#include "..\warlords_constants.inc"

WL2_playerSide spawn {
	_varNameVoting = format ["WL2_targetResetVotingSince_%1", _this];
	_varNameReset = format ["WL2_targetResetOrderedBy_%1", _this];
	
	while {!WL2_missionEnd} do {
		waitUntil {sleep WL_TIMEOUT_STANDARD; WL_SYNCED_TIME < ((missionNamespace getVariable [_varNameVoting, -1]) + WL_TARGET_RESET_VOTING_TIME) && !isNull WL_TARGET_FRIENDLY && (missionNamespace getVariable [_varNameReset, ""]) != ""};
		
		[toUpper format [localize "STR_A3_WL_popup_voting_reset_user_TODO_REWRITE", missionNamespace getVariable _varNameReset]] spawn BIS_fnc_WLSmoothText;
		missionNamespace setVariable [_varNameReset, ""];
		
		if ((player getVariable ["WL2_targetResetVote", -1]) == -1) then {
			"targetResetVoting" call WL2_fnc_hintHandle;
		};
		
		WL2_ctrlDown = FALSE;
		
		WL2_targetResetVoteEH1 = WL_DISPLAY_MAIN displayAddEventHandler ["KeyUp", {
			params ["_display", "_key"];
			
			if (_key == 29) then {WL2_ctrlDown = FALSE};
		}];
		
		WL2_targetResetVoteEH2 = WL_DISPLAY_MAIN displayAddEventHandler ["KeyDown", {
			params ["_display", "_key"];
			
			if (_key == 29) then {WL2_ctrlDown = TRUE};
			if (_key == 44) then {if (WL2_ctrlDown) then {_remove = TRUE; playSound "AddItemOK"; player setVariable ["WL2_targetResetVote", 1, TRUE]}};
			if (_key == 49) then {if (WL2_ctrlDown) then {_remove = TRUE; playSound "AddItemFailed"; player setVariable ["WL2_targetResetVote", 0, TRUE]}};
			if (_remove) then {
				WL_DISPLAY_MAIN displayRemoveEventHandler ["KeyDown", WL2_targetResetVoteEH1];
				WL_DISPLAY_MAIN displayRemoveEventHandler ["KeyUp", WL2_targetResetVoteEH2];
			};
		}];
		
		waitUntil {sleep WL_TIMEOUT_SHORT; WL_SYNCED_TIME >= ((missionNamespace getVariable _varNameVoting) + WL_TARGET_RESET_VOTING_TIME) || isNull WL_TARGET_FRIENDLY || (player getVariable ["WL2_targetResetVote", -1]) != -1};

		["targetResetVoting", FALSE] call WL2_fnc_hintHandle;
	};
};

WL2_playerSide spawn {
	_varName = format ["WL2_recentTargetReset_%1", _this];
	_target = objNull;
	
	while {!WL2_missionEnd} do {
		waitUntil {sleep WL_TIMEOUT_STANDARD; !isNull WL_TARGET_FRIENDLY};
		
		_target = WL_TARGET_FRIENDLY;
		waitUntil {sleep WL_TIMEOUT_STANDARD; isNull WL_TARGET_FRIENDLY};
		
		_t = WL_SYNCED_TIME + 3;
		waitUntil {sleep WL_TIMEOUT_SHORT; WL_SYNCED_TIME > _t || (_target getVariable "WL2_owner") == WL2_playerSide || (missionNamespace getVariable [_varName, FALSE])};
		
		if (missionNamespace getVariable [_varName, FALSE]) then {
			"Reset" call WL2_fnc_announcer;
			
			if (player inArea (_target getVariable "objectAreaComplete")) then {
				["seizing", []] spawn WL2_fnc_setOSDEvent;
			};
			
			if !(isServer) then {
				["client", TRUE] call WL2_fnc_updateSectorArrays;
			};
		};
	};
};

WL2_enemySide spawn {
	_varName = format ["WL2_targetResetOrderedBy_%1", _this];
	_target = objNull;
	
	while {!WL2_missionEnd} do {
		waitUntil {sleep WL_TIMEOUT_STANDARD; !isNull WL_TARGET_ENEMY};
		
		_target = WL_TARGET_ENEMY;
		waitUntil {sleep WL_TIMEOUT_STANDARD; isNull WL_TARGET_ENEMY};
		
		_t = WL_SYNCED_TIME + 3;
		waitUntil {sleep WL_TIMEOUT_SHORT; WL_SYNCED_TIME > _t || (_target getVariable "WL2_owner") == WL2_playerSide || ((missionNamespace getVariable [_varName, ""]) != "")};
		
		if ((missionNamespace getVariable [_varName, ""]) != "") then {
			missionNamespace setVariable [_varName, ""];
			[toUpper format [localize "STR_A3_WL_popup_voting_reset_user", _this call WL2_fnc_sideToFaction]] spawn BIS_fnc_WLSmoothText;
			missionNamespace setVariable [_varName, ""];
		};
	};
};