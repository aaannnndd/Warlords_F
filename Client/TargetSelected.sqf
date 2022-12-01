#include "..\warlords_constants.hpp"

params ["_sector", "_side", "_selected"];

if (_side != WL2_playerSide) exitWith {
	if (_selected) then {
		"WL2_targetEnemy" setMarkerPosLocal position _sector;
		
		if ((_sector getVariable "WL2_owner") == WL2_playerSide || _sector == WL_TARGET_FRIENDLY) then {
			"Incoming" call WL2_fnc_announcer;
			[toUpper format [localize "STR_A3_WL_incoming", _sector getVariable "WL2_name", WL2_enemySide call WL2_fnc_sideToFaction]] spawn WL2_fnc_smoothText;
		};
		
		if (_sector == WL2_playerBase) then {
			playSound "air_raid";
			[toUpper localize "STR_A3_WL_popup_base_vulnerable"] spawn WL2_fnc_smoothText;
			if !(isServer) then {
				["base_vulnerable", WL2_playerSide] call WL2_fnc_handleRespawnMarkers;
			};
		};
		
		_sector spawn {
			params ["_sector"];
			
			waitUntil {sleep WL_TIMEOUT_STANDARD; WL2_playerSide in (_sector getVariable "WL2_revealedBy") || WL_TARGET_ENEMY != _sector};
			
			if (WL_TARGET_ENEMY == _sector) then {
				"WL2_targetEnemy" setMarkerAlphaLocal 1;
				if (_sector == WL_TARGET_FRIENDLY) then {"WL2_targetEnemy" setMarkerDirLocal 45};
			};
		};
	} else {
		"WL2_targetEnemy" setMarkerAlphaLocal 0;
		"WL2_targetEnemy" setMarkerDirLocal 0;
		if ((markerPos "WL2_targetEnemy") distance2D WL2_playerBase < 1 && !isServer) then {
			["base_safe", WL2_playerSide] call WL2_fnc_handleRespawnMarkers;
		};
	};
};

if (_selected) then {
	((_sector getVariable "WL2_markers") # 2) setMarkerSizeLocal [0, 0];
	((_sector getVariable "WL2_markers") # 1) setMarkerBrushLocal "Border";
	"WL2_targetFriendly" setMarkerPosLocal position _sector;
	"WL2_targetFriendly" setMarkerAlphaLocal 1;
	
	_sector spawn {
		params ["_sector"];
		
		waitUntil {sleep WL_TIMEOUT_STANDARD; WL2_playerSide in (_sector getVariable "WL2_revealedBy") || WL_TARGET_ENEMY != _sector};
		
		if (WL_TARGET_ENEMY == _sector) then {
			if (_sector == WL_TARGET_ENEMY) then {"WL2_targetEnemy" setMarkerDirLocal 45};
		};
	};
} else {
	"WL2_targetFriendly" setMarkerAlphaLocal 0;
	"WL2_targetEnemy" setMarkerDirLocal 0;
	
	_sector spawn {
		params ["_sector"];
		_t = WL_SYNCED_TIME + 3;
		waitUntil {WL_SYNCED_TIME > _t || WL2_playerSide in (_sector getVariable "WL2_previousOwners")};
		if (!(WL2_playerSide in (_sector getVariable "WL2_previousOwners"))) then {
			_area = _sector getVariable "objectArea";
			_borderWidth = _sector getVariable ["WL2_borderWidth", 0];
			((_sector getVariable "WL2_markers") # 2) setMarkerSizeLocal [_borderWidth, _borderWidth];
		};
	};
};