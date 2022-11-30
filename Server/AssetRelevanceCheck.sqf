#include "..\warlords_constants.inc"

params ["_asset"];

private _parentSector = _asset getVariable ["WL2_parentSector", objNull];

if !(isNull _parentSector) then {
	[_asset, _parentSector] spawn {
		params ["_asset", "_parentSector"];
		_originalOwner = (_parentSector getVariable "WL2_owner");
		waitUntil {sleep WL_TIMEOUT_MAX; (_parentSector getVariable "WL2_owner") != _originalOwner && WL2_allWarlords findIf {_x distance2D _asset < WL_ASSET_IRRELEVANT_RANGE} == -1};
		_asset setDamage 1;
	};
};