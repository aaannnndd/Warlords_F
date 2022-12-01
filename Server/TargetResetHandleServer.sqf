#include "..\warlords_constants.hpp"

{
	_x spawn {
		_varName = format ["WL2_targetResetVotingSince_%1", _this];
		
		while {!WL2_missionEnd} do {
			waitUntil {sleep WL_TIMEOUT_SHORT; WL_SYNCED_TIME < ((missionNamespace getVariable [_varName, -1]) + WL_TARGET_RESET_VOTING_TIME)};
			
			_terminate = FALSE;
			
			while {!_terminate && WL_SYNCED_TIME < ((missionNamespace getVariable [_varName, -1]) + WL_TARGET_RESET_VOTING_TIME)} do {
				sleep WL_TIMEOUT_SHORT;
				
				_warlords = WL2_allWarlords select {side group _x == _this};
				_limit = ceil ((count _warlords) / 2);
				_votedYes = count (_warlords select {(_x getVariable ["WL2_targetResetVote", -1]) == 1});
				_votedNo = count (_warlords select {(_x getVariable ["WL2_targetResetVote", -1]) == 0});
				
				if (_votedYes >= _limit) then {
					_terminate = TRUE;
					missionNamespace setVariable [format ["WL2_recentTargetReset_%1", _this], TRUE];
					missionNamespace setVariable [format ["WL2_currentTarget_%1", _this], objNull, TRUE];
					["server", TRUE] call WL2_fnc_updateSectorArrays;
					_this spawn {
						sleep (WL_TARGET_RESET_ZONE_RESTRICTION_TOLERANCE min WL2_targetResetTimeout);
						missionNamespace setVariable [format ["WL2_recentTargetReset_%1", _this], FALSE];
					};
				} else {
					if (_votedNo >= _limit) then {
						_terminate = TRUE;
						missionNamespace getVariable [_varName, WL_SYNCED_TIME - WL_TARGET_RESET_VOTING_TIME, TRUE];
					};
				};
			};
			
			{
				if ((_x getVariable ["WL2_targetResetVote", -1]) != -1) then {
					_x setVariable ["WL2_targetResetVote", -1, TRUE];
				};
			} forEach (WL2_allWarlords select {side group _x == _this});
		};
	};
} forEach WL2_competingSides;