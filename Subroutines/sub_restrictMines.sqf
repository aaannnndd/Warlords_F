#include "..\warlords_constants.hpp"

params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

if (toLower _weapon == "put") then {
	if !(WL2_playerBase in [WL2_currentSector_WEST, WL2_currentSector_EAST]) then {
		if (_projectile inArea (WL2_playerBase getVariable "objectArea")) then {
			deleteVehicle _projectile;
			_unit addMagazine _magazine;
			playSound "AddItemFailed";
			[toUpper localize "STR_A3_WL_hint_no_mines"] spawn WL2_fnc_smoothText;
		};
	};
};