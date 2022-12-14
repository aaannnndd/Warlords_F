#include "..\warlords_constants.hpp"

params ["_sector", "_side"];

private _spawnPosArr = _sector call WL2_fnc_findSpawnPositions;
private _connectedToBase = count (WL_BASES arrayIntersect (_sector getVariable "WL2_connectedSectors")) > 0;

if (_side == WL2_localSide) then {
	if (count (_sector getVariable "WL2_vehiclesToSpawn") == 0 && !_connectedToBase) then {
		private _roads = ((_sector nearRoads 300) select {count roadsConnectedTo _x > 0}) inAreaArray (_sector getVariable "objectAreaComplete");
		if (count _roads > 0) then {
			private _road = selectRandom _roads;
			_vehicleArray = [position _road, _road getDir selectRandom (roadsConnectedTo _road), selectRandomWeighted (WL2_factionVehicleClasses # (WL2_sidesArray find _side)), _side] call BIS_fnc_spawnVehicle;
			_vehicleArray params ["_vehicle", "_crew", "_group"];
			
			_vehicle setVariable ["WL2_parentSector", _sector];
			[objNull, _vehicle] call WL2_fnc_newAssetHandle;
			
			{
				_x setVariable ["WL2_parentSector", _sector];
				[objNull, _x] call WL2_fnc_newAssetHandle;
			} forEach _crew;
			
			[_group, 0] setWaypointPosition [position _vehicle, 0];
			_group deleteGroupWhenEmpty TRUE;
			
			_wp = _group addWaypoint [position _road, 200];
			_wp setWaypointType "SAD";
			
			_wp = _group addWaypoint [position _road, 0];
			_wp setWaypointType "CYCLE";
		};
	} else {
		{
			_vehicleInfo = _x;
			_vehicleInfo params ["_type", "_pos", "_dir", "_lock", "_waypoints"];
			_vehicleArray = [_pos, _dir, _type, _side] call BIS_fnc_spawnVehicle;
			_vehicleArray params ["_vehicle", "_crew", "_group"];
			
			_vehicle setVariable ["WL2_parentSector", _sector];
			[objNull, _vehicle] call WL2_fnc_newAssetHandle;
			
			{
				_x setVariable ["WL2_parentSector", _sector];
				[objNull, _x] call WL2_fnc_newAssetHandle;
			} forEach _crew;
			
			_vehicle lock _lock;
			[_group, 0] setWaypointPosition [_pos, 0];
			_group deleteGroupWhenEmpty TRUE;
			
			{
				_x params ["_pos", "_type", "_speed", "_behavior", "_timeout"];
				_wp = _group addWaypoint [_pos, 0];
				_wp setWaypointType _type;
				_wp setWaypointSpeed _speed;
				_wp setWaypointBehaviour _behavior;
				_wp setWaypointTimeout _timeout;
			} forEach _waypoints;
			uiSleep WL_TIMEOUT_MIN;
		} forEach (_sector getVariable "WL2_vehiclesToSpawn");
	};
	if (!_connectedToBase && "H" in (_sector getVariable "WL2_services")) then {
		private _neighbors = (_sector getVariable "WL2_connectedSectors") select {(_x getVariable "WL2_owner") == _side};
		if (count _neighbors > 0) then {
			_vehicleArray = [position selectRandom _neighbors, 0, selectRandomWeighted (WL2_factionAircraftClasses # (WL2_sidesArray find _side)), _side] call BIS_fnc_spawnVehicle;
			_vehicleArray params ["_vehicle", "_crew", "_group"];
			
			_vehicle setVariable ["WL2_parentSector", _sector];
			[objNull, _vehicle] call WL2_fnc_newAssetHandle;
			
			{
				_x setVariable ["WL2_parentSector", _sector];
				[objNull, _x] call WL2_fnc_newAssetHandle;
			} forEach _crew;
			
			[_group, 0] setWaypointPosition [position _vehicle, 0];
			_group deleteGroupWhenEmpty TRUE;
			
			_wp1 = _group addWaypoint [position _sector, 200];
			_wp1 setWaypointType "SAD";
			
			_wp2 = _group addWaypoint [position _sector, 200];
			_wp2 setWaypointType "SAD";
			
			_wp3 = _group addWaypoint [waypointPosition _wp1, 0];
			_wp3 setWaypointType "CYCLE";
		};
	};
};

if (count _spawnPosArr == 0) exitWith {};

private _garrisonSize = (_sector getVariable "WL2_value") * 2;
private _unitsPool = WL2_factionUnitClasses # (WL2_sidesArray find _side);

_i = 0;

while {_i < _garrisonSize} do {
	private _pos = selectRandom _spawnPosArr;
	private _newGrp = createGroup _side;
	private _grpSize = floor (WL_GARRISON_GROUP_SIZE_MIN + random (WL_GARRISON_GROUP_SIZE_MAX - WL_GARRISON_GROUP_SIZE_MIN));
	
	for [{_i2 = 0}, {_i2 < _grpSize && _i < _garrisonSize}, {_i2 = _i2 + 1; _i = _i + 1}] do {
		_newUnit = _newGrp createUnit [selectRandomWeighted _unitsPool, _pos, [], 5, "NONE"];
		_newUnit setVariable ["WL2_parentSector", _sector];
		[objNull, _newUnit] call WL2_fnc_newAssetHandle;
		uiSleep WL_TIMEOUT_MIN;
	};
	
	_newGrp setBehaviour "SAFE";
	_newGrp setSpeedMode "LIMITED";
	[_newGrp, 0] setWaypointPosition [_pos, 0];
	_newGrp deleteGroupWhenEmpty TRUE;
	
	for [{_i3 = 0}, {_i3 < 5}, {_i3 = _i3 + 1}] do {
		_newWP = _newGrp addWaypoint [selectRandom _spawnPosArr, 0];
	};
	
	_newWP = _newGrp addWaypoint [_pos, 0];
	_newWP setWaypointType "CYCLE";
};