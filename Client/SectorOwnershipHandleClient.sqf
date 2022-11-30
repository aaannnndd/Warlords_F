#include "..\warlords_constants.inc"

params ["_sector", "_prevOwner"];

while {!WL2_missionEnd} do {
	waitUntil {sleep WL_TIMEOUT_STANDARD; (_sector getVariable "WL2_owner") != _prevOwner};
	_owner = _sector getVariable "WL2_owner";
	if (_prevOwner == WL2_playerSide) then {
		if (_sector in WL_BASES) then {
			"Defeat" call WL2_fnc_announcer;
		} else {
			"Lost" call WL2_fnc_announcer;
		};
	};
	if (_owner == WL2_playerSide) then {
		if (_sector in WL_BASES) then {
			"Victory" call WL2_fnc_announcer;
		} else {
			"Seized" call WL2_fnc_announcer;
		};
	};
	["client"] call WL2_fnc_updateSectorArrays;
	[_sector, _owner] call WL2_fnc_sectorMarkerUpdate;
	private _specialStateArray = (WL2_sectorsArray # 6) + (WL2_sectorsArray # 7);
	{[_x, _x getVariable "WL2_owner", _specialStateArray] call WL2_fnc_sectorMarkerUpdate} forEach (WL2_allSectors - [_sector]);
	if (WL2_playerSide in (_sector getVariable "WL2_revealedBy")) then {
		if (_prevOwner != WL2_playerSide && _owner != WL2_playerSide) then {
			"Enemy_advancing" call WL2_fnc_announcer;
		};
		[toUpper format [localize "STR_A3_WL_popup_sector_seized", _sector getVariable "WL2_name", _owner call WL2_fnc_sideToFaction]] spawn WL2_fnc_smoothText;
	};
	_prevOwner = _owner;
};