#include "..\warlords_constants.hpp"

missionNamespace setVariable ["WL2_base1", blufor_base, TRUE];
missionNamespace setVariable ["WL2_base2", opfor_base, TRUE];

{
	_side = WL2_competingSides # _forEachIndex;
	_base = _x;
	_base setVariable ["WL2_owner", _side, TRUE];
	_base setVariable ["WL2_originalOwner", _side, TRUE];
	_base setVariable ["WL2_previousOwners", [_side], TRUE];
	if (WL2_fogOfWar == 2) then {
		_base setVariable ["WL2_revealedBy", [_side], TRUE];
	} else {
		_base setVariable ["WL2_revealedBy", WL2_competingSides, TRUE];
	};
} forEach WL_BASES;

_nonBaseSectorsCnt = (count WL2_allSectors) - 2;

_sectorsToGiveSide1 = floor (_nonBaseSectorsCnt * (WL2_initialProgress # 0));
_sectorsToGiveSide2 = floor (_nonBaseSectorsCnt * (WL2_initialProgress # 1));

while {_sectorsToGiveSide1 > 0 || _sectorsToGiveSide2 > 0} do {
	if (_sectorsToGiveSide1 > 0) then {
		_side = WL2_competingSides # 0;
		_available = ([_side] call WL2_fnc_sortSectorArrays) # 1;
		_available = _available select {(_x getVariable ["WL2_owner", sideUnknown]) == sideUnknown};
		if (count _available > 0) then {
			_sector = selectRandom _available;
			_sector setVariable ["WL2_owner", _side, TRUE];
			_sector setVariable ["WL2_previousOwners", [_side], TRUE];
			if (WL2_fogOfWar != 0) then {
				_sector setVariable ["WL2_revealedBy", [_side], TRUE];
			} else {
				_sector setVariable ["WL2_revealedBy", WL2_competingSides, TRUE];
			};
			_sectorsToGiveSide1 = _sectorsToGiveSide1 - 1;
		} else {
			_sectorsToGiveSide1 = 0;
			_sectorsToGiveSide2 = 0;
		};
	};
	if (_sectorsToGiveSide2 > 0) then {
		_side = WL2_competingSides # 1;
		_available = ([_side] call WL2_fnc_sortSectorArrays) # 1;
		_available = _available select {(_x getVariable ["WL2_owner", sideUnknown]) == sideUnknown};
		if (count _available > 0) then {
			_sector = selectRandom _available;
			_sector setVariable ["WL2_owner", _side, TRUE];
			_sector setVariable ["WL2_previousOwners", [_side], TRUE];
			if (WL2_fogOfWar != 0) then {
				_sector setVariable ["WL2_revealedBy", [_side], TRUE];
			} else {
				_sector setVariable ["WL2_revealedBy", WL2_competingSides, TRUE];
			};
			_sectorsToGiveSide2 = _sectorsToGiveSide2 - 1;
			if (count _available == 1) then {
				_sectorsToGiveSide1 = 0;
			};
		} else {
			_sectorsToGiveSide2 = 0;
		};
	};
};

{
	_sector = _x;
	_sectorPos = position _sector;
	
	if ((_sector getVariable ["WL2_owner", sideUnknown]) == sideUnknown) then {
		_sector setVariable ["WL2_owner", WL2_localSide, TRUE];
		_sector setVariable ["WL2_previousOwners", [], TRUE];
		if (WL2_fogOfWar != 0) then {
			_sector setVariable ["WL2_revealedBy", [], TRUE];
		} else {
			_sector setVariable ["WL2_revealedBy", WL2_competingSides, TRUE];
		};
	};
	
	_zoneRestrictionTrg1 = createTrigger ["EmptyDetector", _sectorPos, FALSE];
	_zoneRestrictionTrg2 = createTrigger ["EmptyDetector", _sectorPos, FALSE];
	
	_sector setVariable ["WL2_zoneRestrictionTrgs", [_zoneRestrictionTrg1, _zoneRestrictionTrg2]];
	
	{
		_handledSide = WL2_competingSides # _forEachIndex;
		if (_handledSide in (_sector getVariable "WL2_previousOwners")) then {
			deleteVehicle _x;
		} else {
			_x enableSimulation FALSE;
			_x setVariable ["WL2_handledSide", _handledSide];
		};
	} forEach [_zoneRestrictionTrg1, _zoneRestrictionTrg2];
	
	_area = _sector getVariable "objectArea";
	_area set [4, WL_MAX_SEIZING_HEIGHT];
	
	_seizeControlTrg1 = createTrigger ["EmptyDetector", _sectorPos, FALSE];
	_seizeControlTrg2 = createTrigger ["EmptyDetector", _sectorPos, FALSE];
	_sector setVariable ["WL2_seizeControlTrgs", [_seizeControlTrg1, _seizeControlTrg2]];
	
	_area params ["_a", "_b", "_angle", "_isRectangle"];
	_size = _a * _b * (if (_isRectangle) then {4} else {pi});
	
	{
		_handledSide = WL2_competingSides # _forEachIndex;
		_seizingTime = (WL_SEIZING_TIMEOUT_MIN max (_size / 3000)) min WL_SEIZING_TIMEOUT_MAX;
		_x setVariable ["WL2_handledSide", _handledSide];
		_x setVariable ["WL2_sector", _sector];
		_x setTriggerArea _area;
		_x setTriggerActivation [["WEST SEIZED", "EAST SEIZED", "GUER SEIZED"] # (WL2_sidesArray find _handledSide), "PRESENT", TRUE];
		_x setTriggerTimeout [_seizingTime * 0.75, _seizingTime, _seizingTime * 1.25, TRUE];
		_x setTriggerStatements [format ["this && triggerTimeoutCurrent (((thisTrigger getVariable 'WL2_sector') getVariable 'WL2_seizeControlTrgs') # %1) == -1 && if ((thisTrigger getVariable 'WL2_sector') getVariable 'WL2_owner' == %2) then {TRUE} else {!((thisTrigger getVariable 'WL2_sector') in ((WL2_sectorsArrays # %3) # 7)) || (thisTrigger getVariable 'WL2_sector') == (missionNamespace getVariable [format ['WL2_currentTarget_%2'], objNull])}", if (_forEachIndex == 0) then {1} else {0}, _handledSide, _forEachIndex], format ["if ((thisTrigger getVariable 'WL2_sector') getVariable 'WL2_owner' != %1) then {[thisTrigger getVariable 'WL2_sector', %1] call WL2_fnc_changeSectorOwnership}", _handledSide], ""];
		if !(_handledSide in (_sector getVariable "WL2_previousOwners")) then {
			_x enableSimulation FALSE;
		};
		[_x, _sector, _handledSide] spawn {
			params ["_trigger", "_sector", "_side"];
			while {!WL2_missionEnd} do {
				waitUntil {sleep WL_TIMEOUT_STANDARD; (triggerTimeoutCurrent _trigger) != -1 && (_sector getVariable "WL2_owner") != _side};
				_sector setVariable ["WL2_seizingInfo", [_side, WL_SYNCED_TIME, WL_SYNCED_TIME + triggerTimeoutCurrent _trigger], TRUE];
				waitUntil {(triggerTimeoutCurrent _trigger) == -1};
				_sector setVariable ["WL2_seizingInfo", [], TRUE];
			};
		};
	} forEach [_seizeControlTrg1, _seizeControlTrg2];
	
	if (count (_sector getVariable "WL2_revealedBy") != 2) then {
		_detectionTrg1 = createTrigger ["EmptyDetector", _sectorPos, FALSE];
		_detectionTrg2 = createTrigger ["EmptyDetector", _sectorPos, FALSE];
		_sector setVariable ["WL2_detectionTrgs", [_detectionTrg1, _detectionTrg2]];
		
		{
			_handledSide = WL2_competingSides # _forEachIndex;
			_x setVariable ["WL2_handledSide", _handledSide];
			_x setVariable ["WL2_sector", _sector];
			_x setTriggerArea _area;
			_x setTriggerActivation [["WEST", "EAST", "GUER"] # (WL2_sidesArray find _handledSide), "PRESENT", FALSE];
			_x setTriggerStatements [format ["this && ((thisTrigger getVariable 'WL2_sector') in ((WL2_sectorsArrays # %1) # 3))", _forEachIndex], format ["(thisTrigger getVariable 'WL2_sector') setVariable ['WL2_revealedBy', ((thisTrigger getVariable 'WL2_sector') getVariable 'WL2_revealedBy') + [%1], TRUE]", _handledSide], ""];
		} forEach [_detectionTrg1, _detectionTrg2];
	};

	private _sectorVehicles = [];//vehicles inAreaArray (_sector getVariable "objectAreaComplete");
	private _sectorVehiclesArray = [];
	
	{
		private _vehicle = _x;
		private _group = group effectiveCommander _vehicle;
		private _array = [typeOf _vehicle, position _vehicle, direction _vehicle, locked _vehicle];
		private _waypoints = +(waypoints _group);
		reverse _waypoints;
		_waypoints resize ((count _waypoints) - 1);
		reverse _waypoints;
		_waypoints = _waypoints apply {[waypointPosition _x, waypointType _x, waypointSpeed _x, waypointBehaviour _x, waypointTimeout _x]};
		_array pushBack _waypoints;
		_sectorVehiclesArray pushBack _array;
		{_vehicle deleteVehicleCrew _x} forEach crew _vehicle;
		if (count units _group == 0) then {deleteGroup _group};
		deleteVehicle _vehicle;
	} forEach _sectorVehicles;
	
	_sector setVariable ["WL2_vehiclesToSpawn", _sectorVehiclesArray];
	
	_agentGrp = createGroup CIVILIAN;
	_agent = _agentGrp createUnit ["Logic", _sectorPos, [], 0, "CAN_COLLIDE"];
	_agent enableSimulationGlobal FALSE;
	_sector setVariable ["WL2_agentGrp", _agentGrp, TRUE];
} forEach WL2_allSectors;