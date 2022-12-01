#include "..\warlords_constants.hpp"

_trespassersOld = [];

while {TRUE} do {
	sleep (if (count _trespassersOld == 0) then {WL_TIMEOUT_STANDARD} else {WL_TIMEOUT_SHORT});
	
	_trespassers = [];
	_forgivenTrespassers = [];
	
	{
		_side = _x;
		_sideID = _forEachIndex;
		_warlords = WL2_allWarlords select {alive _x && side group _x == _side && WL_SYNCED_TIME > ((_x getVariable ["WL2_detectedByServerSince", 10e10]) + 3)};
		_warlords append (allUnitsUAV select {side group _x == _side});
		_restrictedSectors = WL2_allSectors - ((WL2_sectorsArrays # _sideID) # 3);
		
		{
			_zoneRestrictionTrg = (_x getVariable "WL2_zoneRestrictionTrgs") # _sideID;
			{_trespassers pushBackUnique _x} forEach (_warlords inAreaArray _zoneRestrictionTrg);
		} forEach _restrictedSectors;
	} forEach WL2_competingSides;
	
	{_trespassers pushBackUnique _x} forEach (WL2_allWarlords select {_pos = position _x; alive _x && (_pos # 0) < 0 || (_pos # 1) < 0 || (_pos # 0) > WL2_mapSize || (_pos # 1) > WL2_mapSize});
	
	_trespassersNew = _trespassers - _trespassersOld;
	_trespassersGone = _trespassersOld - _trespassers;
	
	{
		if (isPlayer _x) then {
			_x setVariable ["WL2_zoneRestrictionKillTime", -1, TRUE];
		};
	} forEach _trespassersGone;
	
	{
		_side = _x;
		if (missionNamespace getVariable [format ["WL2_recentTargetReset_%1", _side], FALSE]) then {
			_forgivenTrespassers = _trespassersNew select {side group _x == _side};
			_trespassersNew = _trespassersNew - _forgivenTrespassers;
		};
	} forEach WL2_competingSides;
	
	{
		if (isPlayer _x) then {
			_timeout = WL_ZONE_RESTRICTION_KILL_TIMEOUT_VEHICLES;
			if (vehicle player == player) then {_timeout = WL_ZONE_RESTRICTION_KILL_TIMEOUT_INFANTRY} else {
				if ((vehicle player) isKindOf "Air") then {_timeout = WL_ZONE_RESTRICTION_KILL_TIMEOUT_AIRCRAFT};
			};
			_x setVariable ["WL2_zoneRestrictionKillTime", WL_SYNCED_TIME + _timeout, TRUE];
			[_x, WL_SYNCED_TIME + _timeout] spawn {
				params ["_player", "_timeout"];
				waitUntil {WL_SYNCED_TIME >= _timeout || (_player getVariable "WL2_zoneRestrictionKillTime") == -1};
				if (WL_SYNCED_TIME >= _timeout) then {
					(vehicle _player) setDamage 1;
					_player setDamage 1;
				};
			};
		} else {
			if (isPlayer leader group _x || (isPlayer leader ((UAVControl _x) # 0))) then {
				_x setDamage 1;
			};
			_trespassers = _trespassers - [_x];
		};
	} forEach _trespassersNew;
	
	_trespassersOld = _trespassers - _forgivenTrespassers;
};