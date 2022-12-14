#include "..\warlords_constants.hpp"

if !(isNil "WL2_disableSmoothTextEffects") exitWith {};

params [
	["_text", "", [""]],
	["_maxLines", 3, [0]],
	["_onScreenDuration", 5, [0]],
	["_color", [1, 1, 1, 1], [[]], 4],
	["_shadow", TRUE, [FALSE]]
];

addMissionEventHandler ["Loaded", {
	WL2_onScreenMessageID = 0;
	WL2_onScreenMessagesBuffer = [];
	{
		ctrlDelete (WL_DISPLAY_MAIN displayCtrl (9990000 + _x));
	} forEach WL2_onScreenMessagesVisible;
	WL2_onScreenMessagesVisible = [];
}];

disableSerialization;

if (isNil "WL2_onScreenMessageID") then {
	WL2_onScreenMessageID = 0;
	WL2_onScreenMessagesVisible = [];
	WL2_onScreenMessagesBuffer = [];
};

waitUntil {!isNull WL_DISPLAY_MAIN};
_myDisplay = WL_DISPLAY_MAIN;

_box = _myDisplay ctrlCreate ["RscStructuredText", 9990000 + WL2_onScreenMessageID];
_messageID = WL2_onScreenMessageID;
WL2_onScreenMessageID = WL2_onScreenMessageID + 1;

if (WL2_onScreenMessageID > 1000) then {
	WL2_onScreenMessageID = 0;
};

_xDef = safezoneX;
_yDef = safezoneY;
_wDef = safezoneW;
_hDef = safezoneH;

if (count WL2_onScreenMessagesVisible >= _maxLines) then {
	WL2_onScreenMessagesBuffer pushBack _messageID;
	waitUntil {count WL2_onScreenMessagesVisible < _maxLines && (WL2_onScreenMessagesBuffer find _messageID) == 0};
	WL2_onScreenMessagesBuffer = WL2_onScreenMessagesBuffer - [_messageID];
};

WL2_onScreenMessagesVisible pushBack _messageID;

if (count WL2_onScreenMessagesVisible > 1) then {
	{
		_ctrlID = 9990000 + _x;
		_ctrl = WL_DISPLAY_MAIN displayCtrl _ctrlID;
		waitUntil {ctrlCommitted _ctrl || ctrlFade _ctrl > 0};
		_ctrl ctrlSetPosition [_xDef, ((ctrlPosition _ctrl) # 1) + (_hDef / 25), _wDef, _hDef / 25];
		_ctrl ctrlCommit 0.25;
	} forEach (WL2_onScreenMessagesVisible - [_messageID]);
};

_box ctrlSetPosition [_xDef, _yDef + (_hDef / 4), _wDef, _hDef / 25];
_box ctrlSetBackgroundColor [0, 0, 0, 0];
_box ctrlSetTextColor _color;
_box ctrlSetFontHeight (_hDef / 25);
_box ctrlCommit 0;

_textArr = toArray _text;
_charsCnt = count _text;
_textStructured = "";
_finalAlpha = _color # 3;
_baseColor = [_color # 0, _color # 1, _color # 2, 0];
_baseColorHTML = _baseColor call BIS_fnc_colorRGBAtoHTML;
_colorArr = [];
_popupDelay = 0.025;
_fadeDuration = 0.5;
_shadow = if (_shadow) then {2} else {0};

{
	_textStructured = _textStructured + "<t color = '%" + str (_forEachIndex + 1) + "'>" + toString [_x] + "</t>";
	_colorArr pushBack _baseColorHTML;
} forEach _textArr;

_textStructured = "<t size = '" + str ((1 call WL2_fnc_sub_purchaseMenuGetUIScale)) + "' align = 'center' shadow = '" + (str _shadow) + "'>" + _textStructured + "</t>";
_textStructuredFormat = [_textStructured];

_done = FALSE;
_startTime = time;

while {!_done} do {
	_oldTick = time;
	waitUntil {time > _oldTick + 0.04};
	
	_done = TRUE;
	_newLetterColor = [];
	
	{
		_letterFadeInStart = _startTime + (_forEachIndex * _popupDelay);
		if (time >= _letterFadeInStart && time <= (_letterFadeInStart + _fadeDuration)) then {
			_done = FALSE;
			_newAlpha = linearConversion [_letterFadeInStart, _letterFadeInStart + _fadeDuration, time, 0, _finalAlpha];
			_newLetterColor = +_baseColor;
			_newLetterColor set [3, _newAlpha];
			_newLetterColor = _newLetterColor call BIS_fnc_colorRGBAtoHTML;
			_colorArr set [_forEachIndex, _newLetterColor];
		} else {
			if (time > (_letterFadeInStart + _fadeDuration)) then {
				_newLetterColor = +_baseColor;
				_newLetterColor set [3, _finalAlpha];
				_newLetterColor = _newLetterColor call BIS_fnc_colorRGBAtoHTML;
				_colorArr set [_forEachIndex, _newLetterColor];
			};
		};
	} forEach _colorArr;
	
	_textStructuredFormat = [_textStructured];

	{
		_textStructuredFormat pushBack _x;
	} forEach _colorArr;

	_box ctrlSetStructuredText parseText format _textStructuredFormat;
};

sleep _onScreenDuration;

_box ctrlSetFade 1;
_box ctrlCommit 1;

waitUntil {ctrlCommitted _box};

WL2_onScreenMessagesVisible = WL2_onScreenMessagesVisible - [_messageID];
ctrlDelete _box;