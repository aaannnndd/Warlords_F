#include "..\warlords_constants.hpp"

params ["_side", "_sector"];

if (!isNull _sector) then {
	missionNamespace setVariable [format ["WL2_currentTarget_%1", _side], _sector, TRUE];
	missionNamespace setVariable [format ["WL2_sectorSelectedTimestamp_%1", _side], WL_SYNCED_TIME, TRUE];
	_seizeControlTrg = ((_sector getVariable "WL2_seizeControlTrgs") select {(_x getVariable "WL2_handledSide") == _side}) # 0;
	_seizeControlTrg enableSimulation TRUE;
	if (_sector in WL_BASES) then {
		["base_vulnerable", _sector getVariable "WL2_originalOwner"] call WL2_fnc_handleRespawnMarkers;
		_sector spawn {
			sleep 30;
			_this setVariable ["WL2_fastTravelEnabled", FALSE, TRUE];
		};
	} else {
		private _owner = _sector getVariable "WL2_owner";
		_spawnedGarrisons = _sector getVariable ["WL2_spawnedGarrisons", []];
		if !(_owner in _spawnedGarrisons) then {
			_spawnedGarrisons pushBack _owner;
			_sector setVariable ["WL2_spawnedGarrisons", _spawnedGarrisons];
			[_sector, _owner] spawn WL2_fnc_populateSector;
		};
	};
} else {
	_prevSector = missionNamespace getVariable format ["WL2_currentTarget_%1", _side];
	missionNamespace setVariable [format ["WL2_currentTarget_%1", _side], objNull, TRUE];
	if !(_side in (_sector getVariable "WL2_previousOwners")) then {
		_seizeControlTrg = ((_prevSector getVariable "WL2_seizeControlTrgs") select {(_x getVariable "WL2_handledSide") == _side}) # 0;
		_seizeControlTrg enableSimulation FALSE;
	};
	if (_prevSector in WL_BASES) then {
		["base_safe", _prevSector getVariable "WL2_originalOwner"] call WL2_fnc_handleRespawnMarkers;
		_prevSector setVariable ["WL2_fastTravelEnabled", TRUE, TRUE];
	};
};