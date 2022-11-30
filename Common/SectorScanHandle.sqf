#include "..\warlords_constants.inc"

params ["_sector"];

if (isServer) then {
	_sector spawn {
		while {!WL2_missionEnd} do {
			waitUntil {sleep WL_TIMEOUT_STANDARD; WL2_competingSides findIf {(_this getVariable [format ["WL2_lastScanEnd_%1", _x], -9999]) > WL_SYNCED_TIME} != -1};
			_revealTrigger = createTrigger ["EmptyDetector", position _this];
			_revealTrigger setTriggerArea (_this getVariable "objectArea");
			_revealTrigger setTriggerActivation ["ANY", "PRESENT", FALSE];
			_this setVariable ["WL2_revealTrigger", _revealTrigger, TRUE];
			[_this, _revealTrigger] spawn {
				params ["_sector", "_revealTrigger"];
				while {!isNull _revealTrigger} do {
					_eligibleSides = WL2_competingSides select {(_sector getVariable [format ["WL2_lastScanEnd_%1", _x], -9999]) > WL_SYNCED_TIME};
					_eligibleWarlords = WL2_allWarlords select {local _x && (side group _x) in _eligibleSides};
					{
						_toReveal = _x;
						{
							_x reveal [_toReveal, 4];
						} forEach _eligibleWarlords;
					} forEach list _revealTrigger;
					sleep WL_TIMEOUT_STANDARD;
				};
			};
			waitUntil {sleep WL_TIMEOUT_SHORT; WL2_competingSides findIf {(_this getVariable [format ["WL2_lastScanEnd_%1", _x], -9999]) > WL_SYNCED_TIME} == -1};
			deleteVehicle _revealTrigger;
		};
	};
};

if !(isDedicated) then {
	_sector spawn {
		while {!WL2_missionEnd} do {
			waitUntil {sleep WL_TIMEOUT_STANDARD; (_this getVariable [format ["WL2_lastScanEnd_%1", WL2_playerSide], -9999]) > WL_SYNCED_TIME && !isNull (_this getVariable ["WL2_revealTrigger", objNull])};
			_revealTrigger = _this getVariable ["WL2_revealTrigger", objNull];
			_revealTrigger setTriggerArea (_this getVariable "objectArea");
			_revealTrigger setTriggerActivation ["ANY", "PRESENT", FALSE];
			WL2_currentlyScannedSectors pushBack _this;
			"Scan" call WL2_fnc_announcer;
			playSound "Beep_Target";
			[toUpper format [localize "STR_A3_WL_popup_scan_active", _this getVariable "WL2_name"]] spawn WL2_fnc_smoothText;
			waitUntil {sleep WL_TIMEOUT_SHORT; {player reveal [_x, 4]} forEach list _revealTrigger; (_this getVariable [format ["WL2_lastScanEnd_%1", WL2_playerSide], -9999]) <= WL_SYNCED_TIME};
			WL2_currentlyScannedSectors = WL2_currentlyScannedSectors - [_this];
			"Scan_terminated" call WL2_fnc_announcer;
			[toUpper format [localize "STR_A3_WL_popup_scan_ended", _this getVariable "WL2_name"]] spawn WL2_fnc_smoothText;
		};
	};
};