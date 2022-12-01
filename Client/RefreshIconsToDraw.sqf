#include "..\warlords_constants.hpp"

if !(isDedicated) then {
	waitUntil {!isNil "WL2_playerSide" && !isNil "WL2_playersAlpha"};
	if (WL2_playersAlpha != 0) then {
		WL2_iconDrawArrayMap = WL2_allWarlords select {side group _x == WL2_playerSide};
		WL2_iconDrawArray3D = WL2_iconDrawArrayMap select {isPlayer _x && _x != player && _x distance2D player < WL_PLAYER_ICON_RANGE};
		if (difficultyOption "mapContent" == 1) then {WL2_iconDrawArrayMap = WL2_iconDrawArrayMap - [player]};
	};
};