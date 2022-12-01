#include "..\warlords_constants.hpp"

params ["_unit"];

_unit addEventHandler ["WeaponAssembled", {
	if (count WL_PLAYER_VEHS >= WL2_assetLimit) then {
		(_this # 0) action ["Disassemble", (_this # 1)];
		playSound 'AddItemFailed';
		[toUpper localize 'STR_WL2_popup_asset_limit_reached'] spawn WL2_fnc_smoothText;
		(_this # 1) spawn {
			_pos = position _this;
			sleep 2;
			if (_this distance _pos < 100) then {_this call WL2_fnc_sub_deleteAsset};
		};
	} else {
		[player, (_this # 1), TRUE] call WL2_fnc_newAssetHandle;
	};
}];

_unit addEventHandler ["WeaponDisassembled", {
	_arr = WL_PLAYER_VEHS - vehicles;
	if (count _arr > 0) then {
		_ownedVehiclesVarName = format ["WL2_%1_ownedVehicles", getPlayerUID player];
		missionNamespace setVariable [_ownedVehiclesVarName, WL_PLAYER_VEHS - [_arr # 0]];
		publicVariableServer _ownedVehiclesVarName;
	};
}];