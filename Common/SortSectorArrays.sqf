#include "..\warlords_constants.inc"

params ["_side", ["_fullRecalc", FALSE]];

private _base = objNull;
private _pool = WL2_allSectors;
private _owned = _pool select {(_x getVariable ["WL2_owner", sideUnknown]) == _side};
private _available = [];
private _income = 0;
private _services = [];
private _curTarget = missionNamespace getVariable [format ["WL2_currentTarget_%1", _side], objNull];
private _unlocked = _pool select {_x == _curTarget || _side in (_x getVariable ["WL2_previousOwners", []])};
private _baseArr = WL_BASES select {(_x getVariable ["WL2_owner", sideUnknown]) == _side};

{
	private _sector = _x;
	_income = _income + (_sector getVariable ["WL2_value", 0]);
	{_services pushBackUnique _x} forEach (_sector getVariable ["WL2_services", []]);
} forEach _owned;

if (count _baseArr == 0) exitWith {[_owned, [], [], _unlocked, _income, _services, [], []]};

private _base = _baseArr # 0;
private _knots = [_base];
private _linked = _knots;

while {count _knots > 0} do {
	private _knotsCurrent = _knots;
	_knots = [];
	{
		{
			_link = _x;
			if (!(_link in _linked) && (_link in _owned)) then {_linked pushBack _link; _knots pushBack _link}
		} forEach (_x getVariable "WL2_connectedSectors");
	} forEach _knotsCurrent;
};

{
	private _sector = _x;
	if ((_sector getVariable ["WL2_owner", sideUnknown]) != _side && _linked findIf {_sector in (_x getVariable "WL2_connectedSectors")} >= 0) then {
		_available pushBack _sector;
	};
} forEach (_pool - _owned);

if (_fullRecalc) then {
	_enemySectors = WL2_allSectors - _unlocked;
	
	switch (WL2_zoneRestrictionSetting) do {
		case 0: {
			{
				private _sector = _x;
				private _zoneRestrictionAxis = ((_sector getVariable "WL2_distanceToNearestSector") / 3) max (_sector getVariable "WL2_maxAxis");
				if (isServer) then {
					_zoneRestrictionTrigger = ((_sector getVariable "WL2_zoneRestrictionTrgs") select {(_x getVariable "WL2_handledSide") == _side}) # 0;
					_zoneRestrictionTrigger setTriggerArea [_zoneRestrictionAxis, _zoneRestrictionAxis, 0, FALSE];
				};
				
				if !(isNil "WL2_playerSide") then {
					if (_side == WL2_playerSide) then {
						_sector setVariable ["WL2_borderWidth", _zoneRestrictionAxis];
						((_sector getVariable "WL2_markers") # 2) setMarkerSizeLocal [_zoneRestrictionAxis, _zoneRestrictionAxis];
						((_sector getVariable "WL2_markers") # 1) setMarkerBrushLocal "Solid";
					};
				};
			} forEach _enemySectors;
		};
		
		case 1: {
			{
				private _sector = _x;
				_enemySectorsByDistance = _enemySectors apply {[_x distance2D _sector, _x]};
				_enemySectorsByDistance sort TRUE;
				_sector setVariable ["WL2_nearestEnemySectorDistanceHalf", ((_enemySectorsByDistance # 0) # 0) / 2];
				_linkedUnlocked = (synchronizedObjects _sector) select {_x in _unlocked};
				_linkMiddles = [];
				{_linkMiddles pushBack ([_sector, (_sector distance2D _x) / 2, _sector getDir _x] call BIS_fnc_relPos)} forEach _linkedUnlocked;
				_sector setVariable ["WL2_linkMiddles", _linkMiddles];
			} forEach _unlocked;
			
			{
				_sector = _x;
				_unlockedSectorsByDistance = _unlocked apply {[_x distance2D _sector, _x]};
				_unlockedSectorsByDistance sort TRUE;
				_nearestUnlockedSector = (_unlockedSectorsByDistance # 0) # 1;
				_linkMiddles = [];
				{_linkMiddles append (_x getVariable ["WL2_linkMiddles", []])} forEach _unlocked;
				_linkMiddles = _linkMiddles apply {[_x distance2D _sector, _x]};
				_linkMiddles sort TRUE;
				_nearestBorder = if (count _linkMiddles > 0) then {(_linkMiddles # 0) # 1} else {[-10000,-10000,0]};
				_zoneRestrictionAxis = if (_sector != _nearestUnlockedSector) then {((_sector distance2D _nearestUnlockedSector) min (_sector distance2D _nearestBorder)) - (_nearestUnlockedSector getVariable "WL2_nearestEnemySectorDistanceHalf")} else {_nearestUnlockedSector getVariable "WL2_nearestEnemySectorDistanceHalf"};
				
				if (isServer) then {
					_zoneRestrictionTrigger = ((_sector getVariable "WL2_zoneRestrictionTrgs") select {(_x getVariable "WL2_handledSide") == _side}) # 0;
					_zoneRestrictionTrigger setTriggerArea [_zoneRestrictionAxis, _zoneRestrictionAxis, 0, FALSE];
				};
				
				if !(isNil "WL2_playerSide") then {
					if (_side == WL2_playerSide) then {
						_sector setVariable ["WL2_borderWidth", _zoneRestrictionAxis];
						((_sector getVariable "WL2_markers") # 2) setMarkerSizeLocal [_zoneRestrictionAxis, _zoneRestrictionAxis];
						((_sector getVariable "WL2_markers") # 1) setMarkerBrushLocal "Solid";
					};
				};
			} forEach _enemySectors;
		};
		case 2:
		{
			{
				private _sector = _x;
				private _zoneRestrictionAxis = (_sector getVariable "size") * 0.5 + (_sector getVariable "border");
				if (isServer) then {
					_zoneRestrictionTrigger = ((_sector getVariable "WL2_zoneRestrictionTrgs") select {(_x getVariable "WL2_handledSide") == _side}) # 0;
					_zoneRestrictionTrigger setTriggerArea [_zoneRestrictionAxis, _zoneRestrictionAxis, 0, TRUE];
				};
				
				if !(isNil "WL2_playerSide") then {
					if (_side == WL2_playerSide) then {
						_sector setVariable ["WL2_borderWidth", _zoneRestrictionAxis];
						((_sector getVariable "WL2_markers") # 2) setMarkerSizeLocal [_zoneRestrictionAxis, _zoneRestrictionAxis];
						((_sector getVariable "WL2_markers") # 1) setMarkerBrushLocal "Solid";
					};
				};
			} forEach _enemySectors;			
		};
	};
};

[_owned, _available, _linked, _unlocked, _income, _services, _owned - _linked, (_unlocked - _owned) - _available]