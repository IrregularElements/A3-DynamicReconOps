if (!isNull (_this select 0)) then {	
	_unit = _this select 0;
	_unit setVariable ["startReady", false, true];
	closeDialog 1;

	_oldUnit = player;
	if (player != _unit) then {
		selectPlayer _unit;
	};

	// Open arsenal
	["Open", true] call BIS_fnc_arsenal;
	waitUntil {!isNull ( uiNamespace getVariable [ "BIS_fnc_arsenal_cam", objNull ] )};
	
	waitUntil {isNull ( uiNamespace getVariable [ "BIS_fnc_arsenal_cam", objNull ] )};

	if (player != _oldUnit) then {
		selectPlayer _oldUnit;
	};
	//player switchCamera "GROUP";
	_unit setVariable ["unitChoice", "CUSTOM", true];
	publicVariable "unitChoice";
	[_unit, "ALL"] remoteExec ["disableAI", _unit]; 

	_handle = CreateDialog "DRO_lobbyDialog";
	[] execVM "sunday_system\dialogs\populateLobby.sqf";
};
