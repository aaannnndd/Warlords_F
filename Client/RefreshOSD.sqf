#include "..\warlords_constants.inc"

params [["_fullRefresh", FALSE]];

call WL2_fnc_sub_purchaseMenuRefresh;

waitUntil {!isNull (uiNamespace getVariable ["WL2_osd_action_voting_title", controlNull])};

(uiNamespace getVariable "WL2_osd_cp_current") ctrlSetStructuredText parseText format ["<t shadow = '2' size = '%2'>%1 CP</t>", WL_PLAYER_FUNDS, 1 call WL2_fnc_sub_purchaseMenuGetUIScale];

if (WL2_fogOfWar != 0) then {
	(uiNamespace getVariable "WL2_osd_income_side_2") ctrlSetStructuredText parseText format ["<t size = '%2' shadow = '2'>%1</t>", (WL2_matesAvailable + 1 - count units group player) max 0, 0.65 call WL2_fnc_sub_purchaseMenuGetUIScale];
};

if (_fullRefresh) then {
	(uiNamespace getVariable "WL2_osd_sectors_side_1") ctrlSetStructuredText parseText format ["<t size = '%2' align = 'center' shadow = '2'>%1</t>", count (WL2_sectorsArray # 0), 0.6 call WL2_fnc_sub_purchaseMenuGetUIScale];
	(uiNamespace getVariable "WL2_osd_income_side_1") ctrlSetStructuredText parseText format ["<t size = '%2' shadow = '2'>+%1</t>", WL2_playerSide call WL2_fnc_income, 0.65 call WL2_fnc_sub_purchaseMenuGetUIScale];
	if (WL2_fogOfWar == 0) then {
		(uiNamespace getVariable "WL2_osd_sectors_side_2") ctrlSetStructuredText parseText format ["<t size = '%2' align = 'center' shadow = '2'>%1</t>", count (WL2_sectorsArrayEnemy # 0), 0.6 call WL2_fnc_sub_purchaseMenuGetUIScale];
		(uiNamespace getVariable "WL2_osd_income_side_2") ctrlSetStructuredText parseText format ["<t size = '%2' shadow = '2'>+%1</t>", WL2_enemySide call WL2_fnc_income, 0.65 call WL2_fnc_sub_purchaseMenuGetUIScale];
	};
};