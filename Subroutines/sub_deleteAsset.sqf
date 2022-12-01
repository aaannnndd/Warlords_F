#include "..\warlords_constants.hpp"

params ["_asset"];

private _groupUnit = local _asset && _asset isKindOf "Man";

if (isServer) then {
	if (getNumber (configFile >> "CfgVehicles" >> typeOf _asset >> "isUav") == 1) then {
		private _grp = group effectiveCommander _asset;
		{_asset deleteVehicleCrew _x} forEach crew _asset;
		deleteGroup _grp;
	} else {
		{_x setPos position _asset} forEach crew _asset;
	};
	deleteVehicle _asset;
} else {
	["deleteAsset", [_asset]] call WL2_fnc_sendClientRequest;
};

if (_groupUnit) then {
	[] spawn {
		sleep 0.5;
		[] spawn WL2_fnc_refreshOSD;
	};
};