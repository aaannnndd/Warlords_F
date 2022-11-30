#include "..\warlords_constants.inc"

params ["_sector"];

_marker = (_sector getVariable "WL2_markers") # 1;
_nextPossibleWarn = 0;

while {!WL2_missionEnd} do {
	waitUntil {sleep WL_TIMEOUT_LONG; (_sector getVariable "WL2_owner") == WL2_playerSide};
	
	while {(_sector getVariable "WL2_owner") == WL2_playerSide} do {
		waitUntil {sleep WL_TIMEOUT_STANDARD; count (_sector getVariable ["WL2_seizingInfo", []]) == 3};
		private _seizingInfo = _sector getVariable "WL2_seizingInfo";
		
		_seizingInfo params ["_side"];
		if (_side == WL2_enemySide) then {
			if (WL_SYNCED_TIME > _nextPossibleWarn) then {
				_nextPossibleWarn = WL_SYNCED_TIME + WL_LOSING_SECTOR_WARN_FREQ;
				"under_attack" call WL2_fnc_announcer;
				[toUpper format [localize "STR_A3_WL_popup_losing_sector", WL2_enemySide call WL2_fnc_sideToFaction, _sector getVariable "WL2_name"]] spawn WL2_fnc_smoothText;
			};
			
			while {count (_sector getVariable ["WL2_seizingInfo", []]) == 3 && (_sector getVariable "WL2_owner") == WL2_playerSide} do {
				_marker setMarkerBrushLocal "Solid";
				_marker setMarkerColorLocal WL2_colorMarkerEnemy;
				sleep WL_TIMEOUT_MEDIUM;
				
				if ((_sector getVariable "WL2_owner") == WL2_playerSide) then {
					_marker setMarkerBrushLocal "Border";
					_marker setMarkerColorLocal WL2_colorMarkerFriendly;
					sleep WL_TIMEOUT_MEDIUM;
				};
			};
		};
	};
};