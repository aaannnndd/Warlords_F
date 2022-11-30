#include "..\warlords_constants.inc"

params ["_class", "_cost", "_category", "_requirements", "_offset"];

[player, -_cost] call WL2_fnc_fundsControl;

if (_category == "Defences") exitWith {
	["RequestMenu_close"] call WL2_fnc_setupUI;
	[_class, _cost, _offset] spawn WL2_fnc_orderDefence;
};

if (_category == "Aircraft") exitWith {
	["RequestMenu_close"] call WL2_fnc_setupUI;
	[_class, _cost, _requirements] spawn WL2_fnc_orderAircraft;
};

if (_category == "Naval") exitWith {
	["RequestMenu_close"] call WL2_fnc_setupUI;
	[_class, _cost] spawn WL2_fnc_orderNaval;
};

if (_category == "Infantry") then {
	WL2_matesInBasket = WL2_matesInBasket + 1;
} else {
	WL2_vehsInBasket = WL2_vehsInBasket + 1;
};

_display = uiNamespace getVariable ["WL2_purchaseMenuDisplay", displayNull];
_purchase_queue = _display displayCtrl 109;
_purchase_category = _display displayCtrl 100;
_purchase_items = _display displayCtrl 101;

_i = _purchase_queue lbAdd (_purchase_items lbText lbCurSel _purchase_items);
_purchase_queue lbSetValue [_i, _cost];
if (lbCurSel _purchase_queue == -1) then {
	_purchase_queue lbSetCurSel 0;
};

WL2_dropPool pushBack [_class, _cost, _purchase_items lbText lbCurSel _purchase_items, lbCurSel _purchase_category, lbCurSel _purchase_items];

call WL2_fnc_sub_purchaseMenuRefresh;