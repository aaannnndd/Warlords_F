#include "..\warlords_constants.hpp"

params ["_event"];

["RequestMenu_close"] call WL2_fnc_setupUI;

if (_event == "save") then {
	WL2_savedLoadout = +getUnitLoadout player;
	[toUpper localize "STR_WL2_loadout_saved"] spawn WL2_fnc_smoothText;
	private _varName = format ["WL2_purchasable_%1", WL2_playerSide];
	private _gearArr = (missionNamespace getVariable _varName) # 5;
	private _savedLoadoutArr = _gearArr # 1;
	private _text = _savedLoadoutArr # 5;
	private _text = format [localize "STR_WL2_saved_loadout_info", "<br/>"];
	_text = _text + "<br/><br/>";
	{
		switch (_forEachIndex) do {
			case 0;
			case 1;
			case 2;
			case 3;
			case 4: {
				if (count _x > 0) then {
					_text = _text + (getText (configFile >> "CfgWeapons" >> _x # 0 >> "displayName")) + "<br/>";
				};
			};
			case 5: {
				if (count _x > 0) then {
					_text = _text + (getText (configFile >> "CfgVehicles" >> _x # 0 >> "displayName")) + "<br/>";
				};
			};
		};
	} forEach WL2_savedLoadout;
	_savedLoadoutArr set [5, _text];
	_gearArr set [1, _savedLoadoutArr];
	(missionNamespace getVariable _varName) set [5, _gearArr];
} else {
	[player, -WL2_savedLoadoutCost] call WL2_fnc_fundsControl;
	player setUnitLoadout WL2_savedLoadout;
	[toUpper localize "STR_A3_WL_loadout_applied"] spawn WL2_fnc_smoothText;
};