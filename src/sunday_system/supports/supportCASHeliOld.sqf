params ["_supportCoords"];


_CASType = player getVariable ["DRO_SUPP_CASType", ""];
_CASClass = player getVariable ["DRO_SUPP_CASClass", ""];

BIS_SUPP_checkBombs = compile preprocessFileLineNumbers "A3\modules_f\supports\procedures\checkBombs.sqf";

player setVariable ["DRO_SUPP_supportCoords", _supportCoords];
player setVariable ["DRO_SUPP_ammoType", -1];

_providerName = ((configfile >> "CfgVehicles" >> _CASClass >> "displayName") call BIS_fnc_GetCfgData);


// Provider
DRO_SUPP_MENU = [];
if (_CASType == "CAS_Heli") then {
	DRO_SUPP_MENU =
	[
		["CAS - Helicopter Run", true],
		[_providerName, [2], "", -5, [["expression", "player setVariable ['DRO_SUPP_ammoType', 1]; ['heliAttack'] spawn DRO_CASCommit"]], "1", (if (DRO_SUPP_CASUsed) then {"0"} else {"1"}), ""]		
	];
};

if (_CASType == "CAS_Bombing") then {
	DRO_SUPP_MENU =
	[
		["CAS - Bombing", true],
		[_providerName, [2], "", -5, [["expression", "[] spawn DRO_menuOpenCASAmmo"]], "1", (if (DRO_SUPP_CASUsed) then {"0"} else {"1"}), ""]		
	];
};

DRO_menuOpenCASAmmo = {
	// Ammo type
	DRO_SUPP_MENU =
	[
			["CAS - Bombing", true],
			[
				"Laser-guided bomb",
				[2],
				"",
				-5,
				[["expression", "player setVariable ['DRO_SUPP_ammoType', 0]; ['bomb'] spawn DRO_CASCommit"]],
				"1",
				"1",
				""
			]
	];	
	DRO_SUPP_MENU = DRO_SUPP_MENU + [
		[
			"Unguided bomb",
			[3],
			"",
			-5,
			[["expression", "player setVariable ['DRO_SUPP_ammoType', 1]; ['bomb'] spawn DRO_CASCommit"]],
			"1",
			"1",
			""
		]
	];
	[] spawn {
		sleep 0.1;
		showCommandingMenu "#USER:DRO_SUPP_MENU";
	};
};


DRO_CASCommit = {
	DRO_SUPP_CASUsed = true;
	publicVariable "DRO_SUPP_CASUsed";
	_CASClass = player getVariable ["DRO_SUPP_CASClass", ""];
	_supportCoords = (player getVariable ["DRO_SUPP_supportCoords", [0,0,0]]);
	// Create positions
	_height = if (_CASClass isKindOf "Helicopter") then {150} else {500};
	_spawnPos = [startPos, 3000, ([_supportCoords, startPos] call BIS_fnc_dirTo)] call BIS_fnc_relPos;
	_spawnPos set [2, _height];
	//_destPos = [_pos, 3000, ([startPos, _pos] call BIS_fnc_dirTo)] call BIS_fnc_relPos;
	//_destPos set [2, _height];
	// Create CAS vehicle
	_provider = createVehicle [_CASClass, _spawnPos, [], 0, "FLY"];
	_provider setPos _spawnPos;
	[_provider, playersSide, false] call sun_createVehicleCrew;	
	_provider flyInHeight _height;
	//_provider setCaptive true;
	player setVariable ["DRO_SUPP_CASVeh", _provider];
	_provider setVariable ["DRO_SUPP_supporting", true, true];	
		
	_ammo = (player getVariable "DRO_SUPP_ammoType");
	
	if (side group _provider == WEST) then {BIS_SUPP_laserTGT = "LaserTargetW" createVehicle _supportCoords};
	if (side group _provider == EAST) then {BIS_SUPP_laserTGT = "LaserTargetE" createVehicle _supportCoords};
	if (side group _provider == RESISTANCE) then {
		if (WEST getFriend RESISTANCE == 1) then {BIS_SUPP_laserTGT = "LaserTargetW" createVehicle _supportCoords} else {BIS_SUPP_laserTGT = "LaserTargetE" createVehicle _supportCoords}
	};
	BIS_SUPP_laserTGT setPos _supportCoords;
	[_provider, BIS_SUPP_laserTGT] spawn {
		while {(_this select 0) getVariable "BIS_SUPP_supporting"} do {
			_this select 1 setPos position (_this select 1);
			(_this select 0) reveal (_this select 1);
			sleep 5
		};
		sleep 10;
		deleteVehicle (_this select 1)
	};
	
	if (_ammo == 0) then {
		
		_wp1 = group _provider addWaypoint [_supportCoords, 0];
		_wp1 setWaypointType "Destroy";
		_wp1 waypointAttachVehicle BIS_SUPP_laserTGT;
	} else {
		_wp1 = group _provider addWaypoint [_supportCoords, 0];
		_wp1 setWaypointType "MOVE";
		[_provider, _supportCoords] spawn {
			waitUntil {(_this select 0) distance (_this select 1) < 600 || !alive (_this select 0)};
			(_this select 0) fireAtTarget [BIS_SUPP_laserTGT];
		};
	};
	
	vehicle _provider addEventHandler ["Fired", {driver (_this select 0) setVariable ["BIS_SUPP_supporting", FALSE]}];
	
	_wp2 = group _provider addWaypoint [_spawnPos, 0];
    _wp2 setWaypointType "Move";
    _wp2 setWaypointStatements ["TRUE", "deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList;"];
	
	_i = 1;
	_mrkrName = format ["BIS_SUPP_mrkr_%1", _i];
	while {markerPos format ["BIS_SUPP_mrkr_%1", _i] distance [0,0,0] > 0} do {_i = _i + 1};
	_mrkrName = format ["BIS_SUPP_mrkr_%1", _i];
	_mrkr = createMarker [_mrkrName, _supportCoords];
	_mrkrName setMarkerText localize "STR_A3_mdl_supp_disp_cas_bombing";
	_mrkrName setMarkerType "selector_selectedMission";
	_mrkrName setMarkerColor "ColorBlack";
	_mrkrName setMarkerSize [0.75, 0.75];
		
	[_provider, _mrkrName] spawn {
		_provider = _this select 0;
		_mrkrName = _this select 1;		
		waitUntil {!(_provider getVariable "DRO_SUPP_supporting") || !alive _provider};
		deleteMarker _mrkrName;
		if (alive _provider) then {
			dro_messageStack pushBack [
				[
					[name (driver _provider), "Splash.", 0]
				],
				true
			];
		};
	};
	
};

[] spawn {
	sleep 0.1;
	showCommandingMenu "#USER:DRO_SUPP_MENU";
};




