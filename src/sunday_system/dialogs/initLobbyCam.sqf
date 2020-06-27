/*
if (!isNil "camLobby") then {
	camLobby cameraEffect ["terminate","back"];
	camDestroy camLobby;
};
*/
_target = if (isNil "camLobbyTarget") then {
	player
} else {
	camLobbyTarget
};
diag_log format ["DRO: Lobby camera target: %1", _target];

_camPos = [(getPos _target), 3.4, (getDir _target)] call BIS_fnc_relPos;
_camPos set [2, 1.1];
_camTarget = [(getPos _target), 0.4, (getDir _target)+90] call BIS_fnc_relPos;
_camTarget set [2, 0.9];
diag_log format ["DRO: Lobby camera position: %1", _camPos];
camLobby = "camera" camCreate _camPos;
camLobby cameraEffect ["internal", "BACK"];
camLobby camSetPos _camPos;
camLobby camSetTarget _camTarget;
camLobby camPrepareFov 0.4;
camLobby camSetFocus [3.4, 1];
camLobby camCommit 0;
camLobbyTarget = _target;
cameraEffectEnableHUD false;
showCinemaBorder false;
diag_log format ["DRO: Lobby cam created: %1", camLobby];
[_target] spawn {
	sleep 0.2;
	_target = _this select 0;
	_class = (configfile >> "CfgVehicles" >> (_target getVariable "unitClass") >> "displayName") call BIS_fnc_getCfgData;
	_weapon	= (configfile >> "CfgWeapons" >> primaryWeapon _target >> "displayName") call BIS_fnc_getCfgData;
	_string = format ["%2%1%3%1%4%1%5", "\n", name _target, rank _target, _class, _weapon];
	((findDisplay 626262) displayCtrl 1160) ctrlSetText _string;
};

