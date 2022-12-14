#include "..\warlords_constants.hpp"

private ["_ret", "_tooltip", "_class", "_DLCOwned", "_DLCTooltip"];

_ret = TRUE;
_tooltip = "";
_class = _assetDetails # 0;
_DLCOwned = TRUE;
_DLCTooltip = "";

if (_cost > _funds) then {_ret = FALSE; _tooltip = localize "STR_A3_WL_low_funds"};
if (!alive player) then {_ret = FALSE; _tooltip = localize "STR_A3_WL_fasttravel_restr6"};
if (lifeState player == "INCAPACITATED") then {_ret = FALSE; _tooltip = format [localize "STR_A3_Revive_MSG_INCAPACITATED", name player]};

if (_ret) then {
	switch (_class) do {
		case "FTSeized": {
			if (vehicle player != player) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_fasttravel_restr3"};
			if !(WL_TARGET_FRIENDLY getVariable ["WL2_fastTravelEnabled", TRUE]) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_fasttravel_restr2"};
			if (WL2_currentSelection == WL_ID_SELECTION_FAST_TRAVEL) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_menu_resetvoting_restr1"};
			if (triggerActivated WL2_enemiesCheckTrigger) exitWith {_ret = FALSE; _tooltip =  localize "STR_A3_WL_fasttravel_restr4"};
		};
		case "FTConflict": {
			if (isNull WL_TARGET_FRIENDLY) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_no_conflict"};
			if (WL_TARGET_FRIENDLY in WL_BASES) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_fasttravel_restr1"};
			if !(WL_TARGET_FRIENDLY getVariable ["WL2_fastTravelEnabled", TRUE]) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_fasttravel_restr2"};
			if !(WL_TARGET_FRIENDLY in (WL2_sectorsArray # 1)) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_fasttravel_restr5"};
			if (vehicle player != player) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_fasttravel_restr3"};
			if (WL2_currentSelection == WL_ID_SELECTION_FAST_TRAVEL) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_menu_resetvoting_restr1"};
			if (triggerActivated WL2_enemiesCheckTrigger) exitWith {_ret = FALSE; _tooltip =  localize "STR_A3_WL_fasttravel_restr4"};
		};
		case "LastLoadout": {
			if (count WL2_lastLoadout == 0) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_no_loadout_saved"};
			if (WL2_loadoutApplied) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_loadout_reapply_info"};
			_visitedSectorID = (WL2_sectorsArray # 0) findIf {player inArea (_x getVariable "objectAreaComplete")};
			if (_visitedSectorID == -1) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_menu_arsenal_restr1"};
		};
		case "SavedLoadout": {
			if (count WL2_savedLoadout == 0) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_no_loadout_saved"};
			_visitedSectorID = (WL2_sectorsArray # 0) findIf {player inArea (_x getVariable "objectAreaComplete")};
			if (_visitedSectorID == -1) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_menu_arsenal_restr1"};
		};
		case "FundsTransfer": {
			if (count (WL2_allWarlords select {side group _x == side group player}) < 2) exitWith {_ret = FALSE; _tooltip = localize "STR_WL2_transfer_restr1_TODO_REWRITE"};
		};
		case "TargetReset": {
			if (isNull WL_TARGET_FRIENDLY) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_no_conflict"};
			_sectorSelectedTimestampVarID = format ["WL2_sectorSelectedTimestamp_%1", WL2_playerSide];
			_targetResetVotingVarID = format ["WL2_targetResetVotingSince_%1", WL2_playerSide];
			if (WL_SYNCED_TIME < ((missionNamespace getVariable [_sectorSelectedTimestampVarID, 0]) + WL2_targetResetTimeout)) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_menu_resetvoting_restr1"};
			if (WL_SYNCED_TIME < ((missionNamespace getVariable [_targetResetVotingVarID, 0]) + WL_TARGET_RESET_VOTING_TIME + 60)) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_menu_resetvoting_restr1"};
		};
		case "Arsenal": {
			_visitedSectorID = (WL2_sectorsArray # 0) findIf {player inArea (_x getVariable "objectAreaComplete")};
			if (_visitedSectorID == -1) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_menu_arsenal_restr1"};
		};
		case "RemoveUnits": {
			if (count ((groupSelectedUnits player) - [player]) == 0) exitWith {_ret = FALSE; _tooltip = localize "STR_WL2_info_no_units_selected"};
		};
		default {
			_servicesAvailable = WL2_sectorsArray # 5;
			_vehiclesCnt = count WL_PLAYER_VEHS;
			
			if (_requirements findIf {!(_x in _servicesAvailable)} >= 0) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_airdrop_restr1"};
			if (_category == "Infantry" && (count units group player) - 1 + WL2_matesInBasket >= WL2_matesAvailable) exitWith {_ret = FALSE; _tooltip = localize "STR_A3_WL_airdrop_restr2"};
			if (_category in ["Vehicles", "Gear", "Defences", "Aircraft", "Naval"] && _vehiclesCnt + WL2_vehsInBasket >= WL2_assetLimit) exitWith {_ret = FALSE; _tooltip = localize "STR_WL2_popup_asset_limit_reached"};
			if (_category == "Defences") exitWith {
				if (vehicle player != player) then {
					_ret = FALSE;
					_tooltip = localize "STR_A3_WL_defence_restr1"
				} else {
					if (triggerActivated WL2_enemiesCheckTrigger) then {
						_ret = FALSE;
						_tooltip = localize "STR_A3_WL_tooltip_deploy_enemies_nearby";
					} else {
						_visitedSectorID = (WL2_sectorsArray # 0) findIf {player inArea (_x getVariable "objectAreaComplete")};
						if (_visitedSectorID == -1) then {
							_ret = FALSE;
							_tooltip = localize "STR_A3_WL_defence_restr1";
						};
						if (getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") == 1) then {
							if (({getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "isUav") == 1} count WL_PLAYER_VEHS) >= WL2_autonomous_limit) then {
								_ret = FALSE;
								_tooltip = format [localize "STR_A3_WL_tip_max_autonomous", WL2_autonomous_limit];
							};
						};
					};
				};
			};
			_DLCOwned = [_class, "IsOwned"] call WL2_fnc_sub_purchaseMenuHandleDLC;
			_DLCTooltip = [_class, "GetTooltip"] call WL2_fnc_sub_purchaseMenuHandleDLC;
		};
	};
};

[_ret, _tooltip, _DLCOwned, _DLCTooltip]