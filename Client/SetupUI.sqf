#include "..\warlords_constants.hpp"

params ["_displayClass"];

waitUntil {!isNull WL_DISPLAY_MAIN};

switch (_displayClass) do {
	case "OSD": {
		{
			_x params ["_var", "_type"];
			uiNamespace setVariable [_var, WL_DISPLAY_MAIN ctrlCreate [_type, -1]];
		} forEach [
			["WL2_osd_cp_current", "RscStructuredText"],
			["WL2_osd_icon_side_1", "RscPictureKeepAspect"],
			["WL2_osd_sectors_side_1", "RscStructuredText"],
			["WL2_osd_income_side_1", "RscStructuredText"],
			["WL2_osd_icon_side_2", "RscPictureKeepAspect"],
			["WL2_osd_sectors_side_2", "RscStructuredText"],
			["WL2_osd_income_side_2", "RscStructuredText"],
			["WL2_osd_progress_background", "RscText"],
			["WL2_osd_progress", "RscProgress"],
			["WL2_osd_action_title", "RscStructuredText"],
			["WL2_osd_progress_voting_background", "RscText"],
			["WL2_osd_progress_voting", "RscProgress"],
			["WL2_osd_action_voting_title", "RscStructuredText"]
		];

		_osd_cp_current = uiNamespace getVariable "WL2_osd_cp_current";
		_osd_icon_side_1 = uiNamespace getVariable "WL2_osd_icon_side_1";
		_osd_sectors_side_1 = uiNamespace getVariable "WL2_osd_sectors_side_1";
		_osd_income_side_1 = uiNamespace getVariable "WL2_osd_income_side_1";
		_osd_icon_side_2 = uiNamespace getVariable "WL2_osd_icon_side_2";
		_osd_sectors_side_2 = uiNamespace getVariable "WL2_osd_sectors_side_2";
		_osd_income_side_2 = uiNamespace getVariable "WL2_osd_income_side_2";
		_osd_progress_background = uiNamespace getVariable "WL2_osd_progress_background";
		_osd_progress = uiNamespace getVariable "WL2_osd_progress";
		_osd_action_title = uiNamespace getVariable "WL2_osd_action_title";
		_osd_progress_voting_background = uiNamespace getVariable "WL2_osd_progress_voting_background";
		_osd_progress_voting = uiNamespace getVariable "WL2_osd_progress_voting";
		_osd_action_voting_title = uiNamespace getVariable "WL2_osd_action_voting_title";

		_blockW = safeZoneW / 1000;
		_blockH = safeZoneH / (1000 / (getResolution # 4));

		_displayW = _blockW * 180;
		_displayH = _blockH * 54;
		_displayX = safeZoneW + safeZoneX - _displayW - (_blockW * 10);
		_displayY = safeZoneH + safeZoneY - _displayH - (_blockH * 100);

		_osd_cp_current ctrlSetPosition [_displayX, _displayY, _blockW * 75, _blockH * 16];

		_osd_icon_side_1 ctrlSetPosition [_displayX + (_blockW * 75), _displayY, _blockW * 16, _blockH * 16];
		_osd_icon_side_1 ctrlSetText (WL2_sectorIconsArray # (WL2_sidesArray find WL2_playerSide));
		_osd_icon_side_1 ctrlSetTextColor WL2_colorFriendly;

		_osd_sectors_side_1 ctrlSetPosition [_displayX + (_blockW * 73), _displayY + (_blockH * 3), _blockW * 20, _blockH * 16];

		_osd_income_side_1 ctrlSetPosition [_displayX + (_blockW * 88), _displayY + (_blockH * 3), _blockW * 40, _blockH * 16];

		_osd_icon_side_2 ctrlSetPosition [_displayX + (_blockW * 124), _displayY, _blockW * 16, _blockH * 16];

		_osd_income_side_2 ctrlSetPosition [_displayX + (_blockW * 137), _displayY + (_blockH * 3), _blockW * 40, _blockH * 16];

		if (WL2_fogOfWar != 0) then {
			_osd_icon_side_2 ctrlSetText "\A3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeUnits_ca.paa";
		} else {
			_osd_icon_side_2 ctrlSetText (WL2_sectorIconsArray # (WL2_sidesArray find WL2_enemySide));
			_color = (WL2_colorsArray # (WL2_sidesArray find WL2_enemySide)); _color set [3, 0.5];
			_osd_icon_side_2 ctrlSetTextColor _color;
			
			_osd_sectors_side_2 ctrlSetTextColor [1,1,1,0.5];
			_osd_sectors_side_2 ctrlSetPosition [_displayX + (_blockW * 122), _displayY + (_blockH * 3), _blockW * 20, _blockH * 16];
			
			_osd_income_side_2 ctrlSetTextColor [1,1,1,0.5];
		};

		{
			_x ctrlSetPosition [_displayX, _displayY + (_blockH * 19), _displayW, _blockH * 16];
		} forEach [_osd_progress_background, _osd_progress, _osd_action_title];

		{
			_x ctrlSetPosition [_displayX, _displayY + (_blockH * 38), _displayW, _blockH * 16];
		} forEach [_osd_progress_voting_background, _osd_progress_voting, _osd_action_voting_title];

		{_x ctrlCommit 0} forEach [
			_osd_cp_current,
			_osd_icon_side_1,
			_osd_sectors_side_1,
			_osd_income_side_1,
			_osd_icon_side_2,
			_osd_sectors_side_2,
			_osd_income_side_2,
			_osd_progress_background,
			_osd_progress,
			_osd_action_title,
			_osd_progress_voting_background,
			_osd_progress_voting,
			_osd_action_voting_title
		];

		WL2_OSDEventArr = [[], [], []];

		addMissionEventHandler ["Loaded", {
			{
				[_x, WL2_OSDEventArr # _forEachIndex] spawn WL2_fnc_setOSDEvent;
			} forEach ["voting", "seizing", "trespassing"];
		}];

		[] spawn {
			while {TRUE} do {
				_oldCPValue = WL_PLAYER_FUNDS;
				waitUntil {sleep WL_TIMEOUT_SHORT; WL_PLAYER_FUNDS != _oldCPValue};
				[] spawn WL2_fnc_refreshOSD;
			};
		};
	};
	
	case "RequestMenu_open": {
		WL2_purchaseMenuDiscovered = TRUE;
		
		if (WL2_purchaseMenuVisible) exitWith {};
		
		disableSerialization;
		
		WL2_purchaseMenuVisible = TRUE;
		
		if (random 10 > 7) then {
			playSound selectRandom ["RadioAmbient6", "UAV_01", "UAV_03"];
		};
		
		hintSilent "";

		_xDef = safezoneX;
		_yDef = safezoneY;
		_wDef = safezoneW;
		_hDef = safezoneH;
		
		_myDisplay = WL_DISPLAY_MAIN createDisplay "RscDisplayEmpty";
		
		WL_CONTROL_MAP ctrlEnable FALSE;
		
		_myDisplay displayAddEventHandler ["Unload", {
			_display = _this # 0;
			uiNamespace setVariable ["WL2_purchaseMenuLastSelection", [lbCurSel (_display displayCtrl 100), lbCurSel (_display displayCtrl 101), lbCurSel (_display displayCtrl 109)]];
			if (ctrlEnabled (_display displayCtrl 120)) then {
				playSound "AddItemFailed";
				[player, WL2_fundsTransferCost] call WL2_fnc_fundsControl;
			};
			WL2_purchaseMenuVisible = FALSE;
			WL_CONTROL_MAP ctrlEnable TRUE;
		}];
		
		_myDisplay displayAddEventHandler ["KeyDown", {
			_key = _this # 1;
			if (_key in actionKeys "Gear" && !WL2_gearKeyPressed) then {
				["RequestMenu_close"] call WL2_fnc_setupUI;
				TRUE
			};
		}];
		
		_myDisplay spawn {
			disableSerialization;
			waitUntil {sleep WL_TIMEOUT_SHORT; lifeState player == "INCAPACITATED" || isNull _this};
			["RequestMenu_close"] call WL2_fnc_setupUI;
		};
		
		_myDisplay displayAddEventHandler ["KeyUp", {
			_key = _this # 1;
			if (_key in actionKeys "Gear") then {
				WL2_gearKeyPressed = FALSE;
			};
		}];
		
		_myDisplay spawn {
			_selectedCnt = count ((groupSelectedUnits player) - [player]);
			while {!isNull _this} do {
				waitUntil {sleep WL_TIMEOUT_MIN; count ((groupSelectedUnits player) - [player]) != _selectedCnt};
				_selectedCnt = count ((groupSelectedUnits player) - [player]);
				call WL2_fnc_sub_purchaseMenuRefresh;
			};
		};
		
		_purchase_background = _myDisplay ctrlCreate ["RscText", -1];
		_purchase_background_1 = _myDisplay ctrlCreate ["RscText", -1];
		_purchase_background_2 = _myDisplay ctrlCreate ["RscText", -1];
		_purchase_title_assets = _myDisplay ctrlCreate ["RscStructuredText", -1];
		_purchase_title_details = _myDisplay ctrlCreate ["RscStructuredText", -1];
		_purchase_title_deployment = _myDisplay ctrlCreate ["RscStructuredText", -1];
		_purchase_category = _myDisplay ctrlCreate ["RscListBox", 100];
		_purchase_items = _myDisplay ctrlCreate ["RscListBox", 101];
		_purchase_pic = _myDisplay ctrlCreate ["RscStructuredText", 102];
		_purchase_info = _myDisplay ctrlCreate ["RscStructuredText", 103];
		_purchase_income = _myDisplay ctrlCreate ["RscStructuredText", 104];
		_purchase_info_asset = _myDisplay ctrlCreate ["RscStructuredText", 105];
		_purchase_title_cost = _myDisplay ctrlCreate ["RscStructuredText", 106];
		_purchase_request = _myDisplay ctrlCreate ["RscStructuredText", 107];
		_purchase_title_queue = _myDisplay ctrlCreate ["RscStructuredText", 108];
		_purchase_queue = _myDisplay ctrlCreate ["RscListBox", 109];
		_purchase_remove_item = _myDisplay ctrlCreate ["RscStructuredText", 110];
		_purchase_remove_all = _myDisplay ctrlCreate ["RscStructuredText", 111];
		_purchase_title_drop = _myDisplay ctrlCreate ["RscStructuredText", 114];
		_purchase_drop_sector = _myDisplay ctrlCreate ["RscStructuredText", 112];
		_purchase_drop_player = _myDisplay ctrlCreate ["RscStructuredText", 113];
		_purchase_transfer_background = _myDisplay ctrlCreate ["RscText", 115];
		_purchase_transfer_units = _myDisplay ctrlCreate ["RscListBox", 116];
		_purchase_transfer_amount = _myDisplay ctrlCreate ["RscEdit", 117];
		_purchase_transfer_cp_title = _myDisplay ctrlCreate ["RscStructuredText", 118];
		_purchase_transfer_ok = _myDisplay ctrlCreate ["RscStructuredText", 119];
		_purchase_transfer_cancel = _myDisplay ctrlCreate ["RscStructuredText", 120];
		
		uiNamespace setVariable ["WL2_purchaseMenuDisplay", _myDisplay];
		
		_purchase_background ctrlSetPosition [_xDef, _yDef + (_hDef * 0.15), _wDef, _hDef * 0.7];
		_purchase_title_assets ctrlSetPosition [_xDef, _yDef + (_hDef * 0.15), _wDef / 2, _hDef * 0.045];
		_purchase_title_details ctrlSetPosition [_xDef + (_wDef / 2), _yDef + (_hDef * 0.15), _wDef / 4, _hDef * 0.045];
		_purchase_title_deployment ctrlSetPosition [_xDef + (_wDef * 0.75), _yDef + (_hDef * 0.15), _wDef / 4, _hDef * 0.045];
		_purchase_income ctrlSetPosition [_xDef, _yDef + (_hDef * 0.805), _wDef, _hDef * 0.045];
		_purchase_category ctrlSetPosition [_xDef, _yDef + (_hDef * 0.195), _wDef * 0.25, _hDef * 0.5];
		_purchase_items ctrlSetPosition [_xDef + (_wDef * 0.25), _yDef + (_hDef * 0.195), _wDef * 0.25, _hDef * 0.5];
		_purchase_info ctrlSetPosition [_xDef, _yDef + (_hDef * 0.695), _wDef * 0.5, _hDef * 0.11];
		_purchase_pic ctrlSetPosition [_xDef + (_wDef * 0.5), _yDef + (_hDef * 0.195), _wDef * 0.25, _hDef * 0.23];
		_purchase_info_asset ctrlSetPosition [_xDef + (_wDef * 0.5), _yDef + (_hDef * 0.425), _wDef * 0.25, _hDef * 0.38];
		_purchase_background_1 ctrlSetPosition [_xDef + (_wDef * 0.75), _yDef + (_hDef * 0.195), _wDef, _hDef * 0.1625];
		_purchase_title_cost ctrlSetPosition [_xDef + (_wDef * 0.75), _yDef + (_hDef * 0.195), _wDef / 4, _hDef * 0.04];
		_purchase_request ctrlSetPosition [_xDef + (_wDef * 0.75), _yDef + (_hDef * 0.235), _wDef / 4, _hDef * 0.055];
		_purchase_title_queue ctrlSetPosition [_xDef + (_wDef * 0.75), _yDef + (_hDef * 0.3175), _wDef / 4, _hDef * 0.04];
		_purchase_queue ctrlSetPosition [_xDef + (_wDef * 0.75), _yDef + (_hDef * 0.3575), _wDef / 4, _hDef * 0.1875];
		_purchase_background_2 ctrlSetPosition [_xDef + (_wDef * 0.75), _yDef + (_hDef * 0.5452), _wDef, _hDef * 0.2598];
		_purchase_remove_item ctrlSetPosition [_xDef + (_wDef * 0.75), _yDef + (_hDef * 0.5502), _wDef / 4, _hDef * 0.035];
		_purchase_remove_all ctrlSetPosition [_xDef + (_wDef * 0.75), _yDef + (_hDef * 0.59), _wDef / 4, _hDef * 0.035];
		_purchase_title_drop ctrlSetPosition [_xDef + (_wDef * 0.75), _yDef + (_hDef * 0.6502), _wDef / 4, _hDef * 0.04];
		_purchase_drop_sector ctrlSetPosition [_xDef + (_wDef * 0.75), _yDef + (_hDef * 0.6902), _wDef / 4, _hDef * 0.055];
		_purchase_drop_player ctrlSetPosition [_xDef + (_wDef * 0.75), _yDef + (_hDef * 0.75), _wDef / 4, _hDef * 0.055];
		_purchase_transfer_background ctrlSetPosition [_xDef + (_wDef / 3), _yDef + (_hDef / 3), _wDef / 3, _hDef / 3];
		_purchase_transfer_units ctrlSetPosition [_xDef + (_wDef / 3), _yDef + (_hDef / 3), _wDef / 6, _hDef / 3];
		_purchase_transfer_amount ctrlSetPosition [_xDef + (_wDef / 3) + (_wDef / 6), _yDef + (_hDef * 0.425), _wDef / 12, _hDef * 0.035];
		_purchase_transfer_cp_title ctrlSetPosition [_xDef + (_wDef / 3) + (_wDef / 6) + (_wDef / 12), _yDef + (_hDef * 0.425), _wDef / 12, _hDef * 0.035];
		_purchase_transfer_ok ctrlSetPosition [_xDef + (_wDef / 3) + (_wDef / 6), _yDef + (_hDef * 0.5502), _wDef / 6, _hDef * 0.035];
		_purchase_transfer_cancel ctrlSetPosition [_xDef + (_wDef / 3) + (_wDef / 6), _yDef + (_hDef * 0.59), _wDef / 6, _hDef * 0.035];
		
		{_x ctrlSetFade 1; _x ctrlEnable FALSE; _x ctrlCommit 0} forEach [
			_purchase_transfer_background,
			_purchase_transfer_units,
			_purchase_transfer_amount,
			_purchase_transfer_cp_title,
			_purchase_transfer_ok,
			_purchase_transfer_cancel
		];
		
		{_x ctrlEnable FALSE; _x ctrlCommit 0} forEach [
			_purchase_background,
			_purchase_title_assets,
			_purchase_title_details,
			_purchase_title_deployment,
			_purchase_income,
			_purchase_info,
			_purchase_pic,
			_purchase_info_asset,
			_purchase_background_1,
			_purchase_title_cost,
			_purchase_title_queue,
			_purchase_background_2,
			_purchase_title_drop
		];
		
		{_x ctrlCommit 0} forEach [
			_purchase_category,
			_purchase_items,
			_purchase_request,
			_purchase_queue,
			_purchase_remove_item,
			_purchase_remove_all,
			_purchase_drop_sector,
			_purchase_drop_player
		];

		_purchase_background ctrlSetBackgroundColor [0, 0, 0, 0.5];
		_purchase_title_assets ctrlSetBackgroundColor [0, 0, 0, 0.5];
		_purchase_title_details ctrlSetBackgroundColor [0, 0, 0, 0.5];
		_purchase_title_deployment ctrlSetBackgroundColor [0, 0, 0, 0.5];
		_purchase_income ctrlSetBackgroundColor [0, 0, 0, 0.5];
		_purchase_info ctrlSetBackgroundColor [0, 0, 0, 0.3];
		_purchase_pic ctrlSetBackgroundColor [0, 0, 0, 0.3];
		_purchase_info_asset ctrlSetBackgroundColor [0, 0, 0, 0.3];
		_purchase_background_1 ctrlSetBackgroundColor [0, 0, 0, 0.3];
		_purchase_request ctrlSetBackgroundColor WL2_colorFriendly;
		_purchase_background_2 ctrlSetBackgroundColor [0, 0, 0, 0.3];
		_purchase_remove_item ctrlSetBackgroundColor WL2_colorFriendly;
		_purchase_remove_all ctrlSetBackgroundColor WL2_colorFriendly;
		_purchase_drop_sector ctrlSetBackgroundColor WL2_colorFriendly;
		_purchase_drop_player ctrlSetBackgroundColor WL2_colorFriendly;
		_purchase_transfer_background ctrlSetBackgroundColor [0, 0, 0, 1];
		_purchase_transfer_ok ctrlSetBackgroundColor WL2_colorFriendly;
		_purchase_transfer_cancel ctrlSetBackgroundColor WL2_colorFriendly;

		{_x ctrlSetTextColor [0.65, 0.65, 0.65, 1]} forEach [
			_purchase_title_assets,
			_purchase_title_details,
			_purchase_title_deployment,
			_purchase_income,
			_purchase_info,
			_purchase_info_asset,
			_purchase_title_cost,
			_purchase_title_queue,
			_purchase_title_drop
		];
		
		_purchase_title_assets ctrlSetStructuredText parseText format ["<t size = '%2' align = 'center' shadow = '2'>%1</t>", localize "STR_A3_WL_purchase_menu_title_assets", (1.5 call WL2_fnc_sub_purchaseMenuGetUIScale)];
		_purchase_title_details ctrlSetStructuredText parseText format ["<t size = '%2' align = 'center' shadow = '2'>%1</t>", localize "STR_A3_WL_purchase_menu_title_detail", (1.5 call WL2_fnc_sub_purchaseMenuGetUIScale)];
		_purchase_title_deployment ctrlSetStructuredText parseText format ["<t size = '%2' align = 'center' shadow = '2'>%1</t>", localize "STR_A3_WL_purchase_menu_title_deployment", (1.5 call WL2_fnc_sub_purchaseMenuGetUIScale)];
		_purchase_request ctrlSetStructuredText parseText format ["<t font = 'PuristaLight' align = 'center' shadow = '2' size = '%2'>%1</t>", toUpper localize "STR_A3_WL_menu_request", (1.75 call WL2_fnc_sub_purchaseMenuGetUIScale)];
		_purchase_remove_item ctrlSetStructuredText parseText format ["<t font = 'PuristaLight' align = 'center' shadow = '2' size = '%2'>%1</t>", toUpper localize "STR_xbox_hint_remove", (1.15 call WL2_fnc_sub_purchaseMenuGetUIScale)];
		_purchase_remove_all ctrlSetStructuredText parseText format ["<t font = 'PuristaLight' align = 'center' shadow = '2' size = '%2'>%1</t>", toUpper localize "STR_A3_WL_menu_remove_all", (1.15 call WL2_fnc_sub_purchaseMenuGetUIScale)];
		_purchase_title_drop ctrlSetStructuredText parseText format ["<t size = '%2' align = 'center' shadow = '0'>%1</t>", localize "STR_A3_WL_airdrop_target", (1.25 call WL2_fnc_sub_purchaseMenuGetUIScale)];
		_purchase_drop_sector ctrlSetStructuredText parseText format ["<t font = 'PuristaLight' align = 'center' shadow = '2' size = '%4'>%1</t>", toUpper localize "STR_A3_WL_airdrop_owned_sector", WL2_dropCost, localize "STR_A3_WL_unit_cp", (1.75 call WL2_fnc_sub_purchaseMenuGetUIScale)];
		_purchase_drop_player ctrlSetStructuredText parseText format ["<t font = 'PuristaLight' align = 'center' shadow = '2' size = '%4'>%1</t>", toUpper localize "STR_A3_WL_airdrop_player", WL2_dropCost_far, localize "STR_A3_WL_unit_cp", (1.75 call WL2_fnc_sub_purchaseMenuGetUIScale)];
		_purchase_transfer_cp_title ctrlSetStructuredText parseText format ["<t align = 'center' size = '%2'>%1</t>", localize "STR_A3_WL_unit_cp", (1.25 call WL2_fnc_sub_purchaseMenuGetUIScale)];
		_purchase_transfer_ok ctrlSetStructuredText parseText format ["<t align = 'center' shadow = '2' size = '%2'>%1</t>", localize "STR_A3_WL_button_transfer", (1.25 call WL2_fnc_sub_purchaseMenuGetUIScale)];
		_purchase_transfer_cancel ctrlSetStructuredText parseText format ["<t align = 'center' shadow = '2' size = '%2'>%1</t>", localize "STR_disp_cancel", (1.25 call WL2_fnc_sub_purchaseMenuGetUIScale)];
		
		{
			if (count (WL_PLAYER_REQUISITION_LIST # _forEachIndex) > 0) then {
				_purchase_category lbAdd _x;
			};
			_purchase_category lbSetValue [(lbSize _purchase_category) - 1, _forEachIndex];
		} forEach [
			localize "STR_A3_cfgmarkers_nato_inf",
			localize "STR_dn_vehicles",
			localize "STR_A3_WL_menu_aircraft",
			localize "STR_A3_rscdisplaygarage_tab_naval",
			localize "STR_A3_WL_menu_defences",
			localize "STR_A3_rscdisplaywelcome_exp_parb_list4_title",
			localize "STR_A3_WL_menu_strategy"
		];
		_purchase_category lbSetCurSel ((uiNamespace getVariable ["WL2_purchaseMenuLastSelection", [0, 0, 0]]) # 0);
		_purchase_category ctrlAddEventHandler ["LBSelChanged", {
			(_this # 1) call WL2_fnc_sub_purchaseMenuSetItemsList;
		}];
		
		_purchase_items ctrlAddEventHandler ["LBSelChanged", {
			call WL2_fnc_sub_purchaseMenuSetAssetDetails;
		}];
		
		_purchase_request ctrlAddEventHandler ["MouseEnter", {
			_button = _this # 0;
			if (uiNamespace getVariable ["WL2_purchaseMenuItemAffordable", FALSE]) then {
				_color = WL2_colorFriendly;
				_button ctrlSetBackgroundColor [(_color # 0) * 1.25, (_color # 1) * 1.25, (_color # 2) * 1.25, _color # 3];
				uiNamespace setVariable ["WL2_purchaseMenuButtonHover", TRUE];
				playSound "click";
			};
		}];
		_purchase_request ctrlAddEventHandler ["MouseExit", {
			_button = _this # 0;
			_color = WL2_colorFriendly;
			if (uiNamespace getVariable ["WL2_purchaseMenuItemAffordable", FALSE]) then {
				_button ctrlSetTextColor [1, 1, 1, 1];
				_button ctrlSetBackgroundColor _color;
			} else {
				_button ctrlSetTextColor [0.5, 0.5, 0.5, 1];
				_button ctrlSetBackgroundColor [(_color # 0) * 0.5, (_color # 1) * 0.5, (_color # 2) * 0.5, _color # 3];
			};
			uiNamespace setVariable ["WL2_purchaseMenuButtonHover", FALSE];
		}];
		_purchase_request ctrlAddEventHandler ["MouseButtonDown", {
			if (uiNamespace getVariable ["WL2_purchaseMenuItemAffordable", FALSE]) then {
				_button = _this # 0;
				_button ctrlSetTextColor [0.75, 0.75, 0.75, 1];
			};
		}];
		_purchase_request ctrlAddEventHandler ["MouseButtonUp", {
			if (uiNamespace getVariable ["WL2_purchaseMenuItemAffordable", FALSE]) then {
				_button = _this # 0;
				_button ctrlSetTextColor [1, 1, 1, 1];
			};
		}];
		_purchase_request ctrlAddEventHandler ["ButtonClick", {
			if (uiNamespace getVariable ["WL2_purchaseMenuItemAffordable", FALSE]) then {
				playSound "AddItemOK";
				_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
				_purchase_category = _display displayCtrl 100;
				_category = WL_REQUISITION_CATEGORIES # ((lbCurSel _purchase_category) max 0);
				_purchase_items = _display displayCtrl 101;
				_curSel = (lbCurSel _purchase_items) max 0;
				_assetDetails = (_purchase_items lbData _curSel) splitString "|||";
				
				_assetDetails params [
					"_className",
					"_requirements",
					"_displayName",
					"_picture",
					"_text",
					"_offset"
				];
				
				_cost = _purchase_items lbValue lbCurSel _purchase_items;
				_offset = call compile _offset;
				_requirements = call compile _requirements;
				switch (_className) do {
					case "Arsenal": {call WL2_fnc_orderArsenal};
					case "LastLoadout": {call WL2_fnc_orderLastLoadout};
					//case "SaveLoadout": {"save" call WL2_fnc_orderSavedLoadout};
					//case "SavedLoadout": {"apply" call WL2_fnc_orderSavedLoadout};
					case "Scan": {[] spawn WL2_fnc_orderSectorScan};
					case "FTSeized": {FALSE spawn WL2_fnc_orderFastTravel};
					case "FTConflict": {TRUE spawn WL2_fnc_orderFastTravel};
					case "FundsTransfer": {call WL2_fnc_orderFundsTransfer};
					case "TargetReset": {call WL2_fnc_orderTargetReset};
					case "LockVehicles": {{_x lock TRUE; _x setUserActionText [_x getVariable ["WL2_lockActionID", -1], format ["<t color = '%1'>%2</t>", if ((locked _x) == 2) then {"#4bff58"} else {"#ff4b4b"}, if ((locked _x) == 2) then {localize "STR_A3_cfgvehicles_miscunlock_f_0"} else {localize "STR_A3_cfgvehicles_misclock_f_0"}]]} forEach (WL_PLAYER_VEHS select {alive _x}); [toUpper localize "STR_A3_WL_feature_lock_all_msg"] spawn WL2_fnc_smoothText};
					case "UnlockVehicles": {{_x lock FALSE; _x setUserActionText [_x getVariable ["WL2_lockActionID", -1], format ["<t color = '%1'>%2</t>", if ((locked _x) == 2) then {"#4bff58"} else {"#ff4b4b"}, if ((locked _x) == 2) then {localize "STR_A3_cfgvehicles_miscunlock_f_0"} else {localize "STR_A3_cfgvehicles_misclock_f_0"}]]} forEach (WL_PLAYER_VEHS select {alive _x}); [toUpper localize "STR_A3_WL_feature_unlock_all_msg"] spawn WL2_fnc_smoothText};
					case "RemoveUnits": {{_x call WL2_fnc_sub_deleteAsset} forEach ((groupSelectedUnits player) - [player])};
					default {[_className, _cost, _category, _requirements, _offset] call WL2_fnc_requestPurchase};
				};
			} else {
				playSound "AddItemFailed";
			};
		}];

		{
			_x ctrlAddEventHandler ["MouseEnter", {
				_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
				if (ctrlEnabled (_display displayCtrl 107)) then {
					_button = _this # 0;
					_color = WL2_colorFriendly;
					_button ctrlSetBackgroundColor [(_color # 0) * 1.25, (_color # 1) * 1.25, (_color # 2) * 1.25, _color # 3];
					playSound "click";
				};
			}];
			_x ctrlAddEventHandler ["MouseExit", {
				_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
				if (ctrlEnabled (_display displayCtrl 107)) then {
					_button = _this # 0;
					_color = WL2_colorFriendly;
					_button ctrlSetTextColor [1, 1, 1, 1];
					_button ctrlSetBackgroundColor _color;
				};
			}];
			_x ctrlAddEventHandler ["MouseButtonDown", {
				_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
				if (ctrlEnabled (_display displayCtrl 107)) then {
					_button = _this # 0;
					_button ctrlSetTextColor [0.75, 0.75, 0.75, 1];
				};
			}];
			_x ctrlAddEventHandler ["MouseButtonUp", {
				_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
				if (ctrlEnabled (_display displayCtrl 107)) then {
					_button = _this # 0;
					_button ctrlSetTextColor [1, 1, 1, 1];
				};
			}];
		} forEach [_purchase_remove_item, _purchase_remove_all];
		
		_purchase_remove_item ctrlAddEventHandler ["ButtonClick", {
			_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
			if (ctrlEnabled (_display displayCtrl 107)) then {
				playSound "AddItemOK";
				_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
				_purchase_queue = _display displayCtrl 109;
				_refund = _purchase_queue lbValue lbCurSel _purchase_queue;
				if (_refund > 0) then {
					_class = _purchase_queue lbData lbCurSel _purchase_queue;
					_i = -1;
					{if ((_x # 0) == _class) then {_i = _forEachIndex}} forEach WL2_dropPool;
					_inf = ((WL2_dropPool # _i) # 0) isKindOf "Man";
					WL2_dropPool deleteAt _i;
					[player, _refund] call WL2_fnc_fundsControl;
					if (_inf) then {WL2_matesInBasket = WL2_matesInBasket - 1} else {WL2_vehsInBasket = WL2_vehsInBasket - 1};
					_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
					_purchase_items = _display displayCtrl 101;
					call WL2_fnc_sub_purchaseMenuRefresh;
				};
			};
		}];
		
		_purchase_remove_all ctrlAddEventHandler ["ButtonClick", {
			_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
			if (ctrlEnabled (_display displayCtrl 107)) then {
				playSound "AddItemOK";
				_refundTotal = 0;
				{
					_refundTotal = _refundTotal + (_x # 1);
				} forEach WL2_dropPool;
				[player, _refundTotal] call WL2_fnc_fundsControl;
				WL2_matesInBasket = 0;
				WL2_vehsInBasket = 0;
				WL2_dropPool = [];
				_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
				_purchase_items = _display displayCtrl 101;
				call WL2_fnc_sub_purchaseMenuRefresh;
			};
		}];

		_purchase_drop_sector ctrlSetTooltip format ["%1%4: %2 %3", localize "STR_A3_WL_menu_cost", WL2_dropCost, localize "STR_A3_WL_unit_cp", if (toLower language == "french") then {" "} else {""}];
		_purchase_drop_sector ctrlAddEventHandler ["MouseEnter", {
			if (uiNamespace getVariable ["WL2_purchaseMenuDropSectorAffordable", FALSE]) then {
				uiNamespace setVariable ["WL2_purchaseMenuButtonDropSectorHover", TRUE];
				_button = _this # 0;
				_color = WL2_colorFriendly;
				_button ctrlSetBackgroundColor [(_color # 0) * 1.25, (_color # 1) * 1.25, (_color # 2) * 1.25, _color # 3];
				playSound "click";
			};
		}];
		_purchase_drop_sector ctrlAddEventHandler ["MouseExit", {
			if (uiNamespace getVariable ["WL2_purchaseMenuDropSectorAffordable", FALSE]) then {
				uiNamespace setVariable ["WL2_purchaseMenuButtonDropSectorHover", FALSE];
				_button = _this # 0;
				_color = WL2_colorFriendly;
				_button ctrlSetTextColor [1, 1, 1, 1];
				_button ctrlSetBackgroundColor _color;
			};
		}];
		_purchase_drop_sector ctrlAddEventHandler ["MouseButtonDown", {
			if (uiNamespace getVariable ["WL2_purchaseMenuDropSectorAffordable", FALSE]) then {
				_button = _this # 0;
				_button ctrlSetTextColor [0.75, 0.75, 0.75, 1];
			};
		}];
		_purchase_drop_sector ctrlAddEventHandler ["MouseButtonUp", {
			if (uiNamespace getVariable ["WL2_purchaseMenuDropSectorAffordable", FALSE]) then {
				_button = _this # 0;
				_button ctrlSetTextColor [1, 1, 1, 1];
			};
		}];
		_purchase_drop_sector ctrlAddEventHandler ["ButtonClick", {
			if (uiNamespace getVariable ["WL2_purchaseMenuDropSectorAffordable", FALSE]) then {
				playSound "AddItemOK";
				[FALSE] spawn WL2_fnc_orderAirdrop
			} else {
				playSound "AddItemFailed";
			};
		}];
		
		_purchase_drop_player ctrlSetTooltip format ["%1%4: %2 %3", localize "STR_A3_WL_menu_cost", WL2_dropCost_far, localize "STR_A3_WL_unit_cp", if (toLower language == "french") then {" "} else {""}];
		_purchase_drop_player ctrlAddEventHandler ["MouseEnter", {
			if (uiNamespace getVariable ["WL2_purchaseMenuDropPlayerAffordable", FALSE]) then {
				uiNamespace setVariable ["WL2_purchaseMenuButtonDropPlayerHover", TRUE];
				_button = _this # 0;
				_color = WL2_colorFriendly;
				_button ctrlSetBackgroundColor [(_color # 0) * 1.25, (_color # 1) * 1.25, (_color # 2) * 1.25, _color # 3];
				playSound "click";
			};
		}];
		_purchase_drop_player ctrlAddEventHandler ["MouseExit", {
			if (uiNamespace getVariable ["WL2_purchaseMenuDropPlayerAffordable", FALSE]) then {
				uiNamespace setVariable ["WL2_purchaseMenuButtonDropPlayerHover", FALSE];
				_button = _this # 0;
				_color = WL2_colorFriendly;
				_button ctrlSetTextColor [1, 1, 1, 1];
				_button ctrlSetBackgroundColor _color;
			};
		}];
		_purchase_drop_player ctrlAddEventHandler ["MouseButtonDown", {
			if (uiNamespace getVariable ["WL2_purchaseMenuDropPlayerAffordable", FALSE]) then {
				_button = _this # 0;
				_button ctrlSetTextColor [0.75, 0.75, 0.75, 1];
			};
		}];
		_purchase_drop_player ctrlAddEventHandler ["MouseButtonUp", {
			if (uiNamespace getVariable ["WL2_purchaseMenuDropPlayerAffordable", FALSE]) then {
				_button = _this # 0;
				_button ctrlSetTextColor [1, 1, 1, 1];
			};
		}];
		_purchase_drop_player ctrlAddEventHandler ["ButtonClick", {
			if (uiNamespace getVariable ["WL2_purchaseMenuDropPlayerAffordable", FALSE]) then {
				playSound "AddItemOK";
				[TRUE] spawn WL2_fnc_orderAirdrop
			} else {
				playSound "AddItemFailed";
			};
		}];
		
		_purchase_transfer_ok ctrlAddEventHandler ["MouseEnter", {
			if (uiNamespace getVariable ["WL2_fundsTransferPossible", FALSE]) then {
				_button = _this # 0;
				_color = WL2_colorFriendly;
				_button ctrlSetBackgroundColor [(_color # 0) * 1.25, (_color # 1) * 1.25, (_color # 2) * 1.25, _color # 3];
				playSound "click";
			};
		}];
		_purchase_transfer_ok ctrlAddEventHandler ["MouseExit", {
			if (uiNamespace getVariable ["WL2_fundsTransferPossible", FALSE]) then {
				_button = _this # 0;
				_color = WL2_colorFriendly;
				_button ctrlSetTextColor [1, 1, 1, 1];
				_button ctrlSetBackgroundColor _color;
			};
		}];
		_purchase_transfer_ok ctrlAddEventHandler ["MouseButtonDown", {
			if (uiNamespace getVariable ["WL2_fundsTransferPossible", FALSE]) then {
				_button = _this # 0;
				_button ctrlSetTextColor [0.75, 0.75, 0.75, 1];
			};
		}];
		_purchase_transfer_ok ctrlAddEventHandler ["MouseButtonUp", {
			if (uiNamespace getVariable ["WL2_fundsTransferPossible", FALSE]) then {
				_button = _this # 0;
				_button ctrlSetTextColor [1, 1, 1, 1];
			};
		}];
		_purchase_transfer_ok ctrlAddEventHandler ["ButtonClick", {
			if (uiNamespace getVariable ["WL2_fundsTransferPossible", FALSE]) then {
				_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
				_targetName = (_display displayCtrl 116) lbText lbCurSel (_display displayCtrl 116);
				_amount = (parseNumber ctrlText (_display displayCtrl 117)) min (player getVariable "WL2_funds");
				_targetArr = WL2_allWarlords select {name _x == _targetName};
				if (count _targetArr > 0) then {
					playSound "AddItemOK";
					_target = _targetArr # 0;
					_targetFunds = _target getVariable "WL2_funds";
					_maxTransfer = WL2_maxCP - _targetFunds;
					_finalTransfer = (_amount min _maxTransfer) max 0;
					["fundsTransfer", [_target, _finalTransfer]] call WL2_fnc_sendClientRequest;
					for [{_i = 100}, {_i <= 114}, {_i = _i + 1}] do {
						(_display displayCtrl _i) ctrlEnable TRUE;
					};
					for [{_i = 115}, {_i <= 120}, {_i = _i + 1}] do {
						(_display displayCtrl _i) ctrlEnable FALSE;
						(_display displayCtrl _i) ctrlSetFade 1;
						(_display displayCtrl _i) ctrlCommit 0;
					};
				} else {
					playSound "AddItemFailed";
				};
			};
		}];

		_purchase_transfer_cancel ctrlAddEventHandler ["MouseEnter", {
			_button = _this # 0;
			_color = WL2_colorFriendly;
			_button ctrlSetBackgroundColor [(_color # 0) * 1.25, (_color # 1) * 1.25, (_color # 2) * 1.25, _color # 3];
			playSound "click";
		}];
		_purchase_transfer_cancel ctrlAddEventHandler ["MouseExit", {
			_button = _this # 0;
			_color = WL2_colorFriendly;
			_button ctrlSetTextColor [1, 1, 1, 1];
			_button ctrlSetBackgroundColor _color;
		}];
		_purchase_transfer_cancel ctrlAddEventHandler ["MouseButtonDown", {
			_button = _this # 0;
			_button ctrlSetTextColor [0.75, 0.75, 0.75, 1];
		}];
		_purchase_transfer_cancel ctrlAddEventHandler ["MouseButtonUp", {
			_button = _this # 0;
			_button ctrlSetTextColor [1, 1, 1, 1];
		}];
		_purchase_transfer_cancel ctrlAddEventHandler ["ButtonClick", {
			_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
			for [{_i = 100}, {_i <= 114}, {_i = _i + 1}] do {
				(_display displayCtrl _i) ctrlEnable TRUE;
			};
			for [{_i = 115}, {_i <= 120}, {_i = _i + 1}] do {
				(_display displayCtrl _i) ctrlEnable FALSE;
				(_display displayCtrl _i) ctrlSetFade 1;
				(_display displayCtrl _i) ctrlCommit 0;
			};
			playSound "AddItemFailed";
			[player, WL2_transferCost] call WL2_fnc_fundsControl;
		}];
		
		((uiNamespace getVariable ["WL2_purchaseMenuLastSelection", [0, 0, 0]]) # 0) call WL2_fnc_sub_purchaseMenuSetItemsList;
	};
	
	case "RequestMenu_close": {
		(uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull]) closeDisplay 1;
	};
};