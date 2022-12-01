#include "..\warlords_constants.hpp"

{
	missionNamespace setVariable [format ["WL2_currentTarget_%1", _x], objNull, TRUE];

	[_x, _forEachIndex] spawn {
		
		params ["_side", "_sideIndex"];
		
		_votingResetVar = format ["WL2_resetTargetSelection_server_%1", _side];
		_votingReset = {missionNamespace getVariable [_votingResetVar, FALSE]};
		
		_calculateMostVotedSector = {
			_allSectorsVotedFor = [];
			{
				_allSectorsVotedFor pushBackUnique _x;
			} forEach _votesPool;
			_allSectorsVotedFor = _allSectorsVotedFor apply {_sector = _x; [{_x == _sector} count _votesPool, _sector]};
			_allSectorsVotedFor sort FALSE;
			(_allSectorsVotedFor # 0) # 1
		};
		
		while {!WL2_missionEnd} do {
			_t = WL_SYNCED_TIME + 10 + random 10;
			_tNoPlayers = WL_SYNCED_TIME + 2 + random 5;
			_variablesPool = [];
			_votesPool = [];
			_npcsVoted = FALSE;
			missionNamespace setVariable [_votingResetVar, FALSE];
			
			waitUntil {
				sleep WL_TIMEOUT_SHORT;
				_warlords = WL2_allWarlords select {side group _x == _side};
				_players = _warlords select {isPlayer _x};
				_npcs = _warlords select {!isPlayer _x};
				_noPlayers = count (WL2_playerIDArr # _sideIndex) == 0;
				_playerVotingVariableNames = _players apply {format ["WL2_targetVote_%1", getPlayerUID _x]};
				(call _votingReset) || ((_playerVotingVariableNames findIf {!isNull (missionNamespace getVariable [_x, objNull])} != -1) || (if (count _npcs > 0) then {if (_noPlayers) then {WL_SYNCED_TIME > _tNoPlayers} else {if (WL2_allowAIVoting) then {WL_SYNCED_TIME > _t} else {FALSE}}} else {FALSE}))
			};
			
			if !(call _votingReset) then {
				_votingEnd = WL_SYNCED_TIME + WL2_targetVotingDuration;
				_nextUpdate = time;
				
				while {WL_SYNCED_TIME < _votingEnd && !(call _votingReset)} do {
					_warlords = WL2_allWarlords select {side group _x == _side};
					_players = _warlords select {isPlayer _x};
					_noPlayers = count (WL2_playerIDArr # _sideIndex) == 0;
					
					if (!_npcsVoted && (WL2_allowAIVoting || _noPlayers)) then {
						_npcsVoted = TRUE;
						_npcs = _warlords select {!isPlayer _x};
						{
							_votesPool pushBack selectRandom ((WL2_sectorsArrays # _sideIndex) # 1);
						} forEach _npcs;
					};
					
					_playerVotingVariableNames = _players apply {format ["WL2_targetVote_%1", getPlayerUID _x]};
					
					{
						_variableName = _x;
						_vote = missionNamespace getVariable [_variableName, objNull];
						if !(isNull _vote) then {
							_i = _variablesPool find _variableName;
							if (_i == -1) then {
								_variablesPool pushBack _variableName;
								_votesPool pushBack _vote;
							} else {
								_votesPool set [_i, _vote];
							};
						};
					} forEach _playerVotingVariableNames;
					
					if (time >= _nextUpdate) then {
						missionNamespace setVariable [format ["WL2_mostVoted_%1", _side], [call _calculateMostVotedSector, _votingEnd], TRUE];
						_nextUpdate = time + WL_TIMEOUT_STANDARD;
					};
					
					sleep WL_TIMEOUT_SHORT;
				};

				if !(call _votingReset) then {
					[_side, call _calculateMostVotedSector] call WL2_fnc_selectTarget;
					
					["server", TRUE] call WL2_fnc_updateSectorArrays;

					waitUntil {sleep WL_TIMEOUT_STANDARD; isNull (missionNamespace getVariable [format ["WL2_currentTarget_%1", _side], objNull])};
				};
			};
			
			{missionNamespace setVariable [_x, objNull]} forEach _variablesPool;
		};
	};
} forEach WL2_competingSides;