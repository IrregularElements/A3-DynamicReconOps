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
		[_providerName, [2], "", -5, [["expression", "player setVariable ['DRO_SUPP_ammoType', 1]; ['CAS_Heli'] spawn DRO_CASCommit"]], "1", (if (DRO_SUPP_CASUsed) then {"0"} else {"1"}), ""]		
	];
};

if (_CASType == "CAS_Bombing") then {
	DRO_SUPP_MENU =
	[
		["CAS - Bombing", true],
		[_providerName, [2], "", -5, [["expression", "player setVariable ['DRO_SUPP_ammoType', 0]; ['CAS_Bombing'] spawn DRO_CASCommit"]], "1", (if (DRO_SUPP_CASUsed) then {"0"} else {"1"}), ""]		
	];
};

DRO_CASAddWaypoints = {
	params ["_provider", "_supportCoords", "_spawnPos"];
	if ((player getVariable "DRO_SUPP_ammoType") == 0) then {		
		_wp1 = group _provider addWaypoint [_supportCoords, 0];
		_wp1 setWaypointType "Destroy";		
		_wp1 waypointAttachVehicle BIS_SUPP_laserTGT;		
	} else {		
		[_provider, _supportCoords] spawn {
			_entities = (_this select 1) nearEntities 60;
			while {(_this select 0) getVariable "DRO_SUPP_supporting"} do {
				{
					(_this select 0) reveal _x;
				} forEach _entities;				
				sleep 5
			};			
		};		
		_wp1 = group _provider addWaypoint [_supportCoords, 0];
		_wp1 setWaypointType "SAD";
	};
	_wp2 = group _provider addWaypoint [_spawnPos, 0];
    _wp2 setWaypointType "Move";
    _wp2 setWaypointStatements ["TRUE", "deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList;"];
};

DRO_CASCommit = {
	params ["_CASType"];
	DRO_SUPP_CASUsed = true;
	publicVariable "DRO_SUPP_CASUsed";
	_CASClass = player getVariable ["DRO_SUPP_CASClass", ""];
	_supportCoords = (player getVariable ["DRO_SUPP_supportCoords", [0,0,0]]);
	// Create positions
	_height = if (_CASClass isKindOf "Helicopter") then {200} else {1000};
	_spawnPos = [startPos, 3000, ([_supportCoords, startPos] call BIS_fnc_dirTo)] call BIS_fnc_relPos;
	_spawnPos set [2, _height];
	//_destPos = [_pos, 3000, ([startPos, _pos] call BIS_fnc_dirTo)] call BIS_fnc_relPos;
	//_destPos set [2, _height];
	// Create CAS vehicle
	_provider = createVehicle [_CASClass, _spawnPos, [], 0, "FLY"];
	_provider flyInHeight _height/2;
	_provider setPos _spawnPos;
	[_provider, playersSide, false] call sun_createVehicleCrew;	
	
	_speed = if (_CASClass isKindOf "Helicopter") then {200 / 3.6} else {400 / 3.6};
	
	_vectorDir = [_spawnPos, [(_supportCoords select 0), (_supportCoords select 1), (_spawnPos select 2)]] call bis_fnc_vectorFromXtoY;	
	_provider setVectorDir _vectorDir;
	[_provider,0,0] call bis_fnc_setPitchBank;
	_provider setVelocity _vectorDir;

	// Catch helis that refuse to move
	[_provider, _supportCoords] spawn {
		_provider = (_this select 0);
		_supportCoords = (_this select 1);
		sleep 20;
		if (_provider distance _supportCoords < 300) then {
			while {(count (waypoints group _provider)) > 0} do {
				deleteWaypoint ((waypoints group _provider) select 0);
			};
			[_provider, _supportCoords, _spawnPos] call DRO_CASAddWaypoints;
		};
	};
		
	player setVariable ["DRO_SUPP_CASVeh", _provider];
	_provider setVariable ["DRO_SUPP_supporting", true, true];	
	
	if (side group _provider == WEST) then {BIS_SUPP_laserTGT = "LaserTargetW" createVehicle _supportCoords};
	if (side group _provider == EAST) then {BIS_SUPP_laserTGT = "LaserTargetE" createVehicle _supportCoords};
	if (side group _provider == RESISTANCE) then {
		if (WEST getFriend RESISTANCE == 1) then {BIS_SUPP_laserTGT = "LaserTargetW" createVehicle _supportCoords} else {BIS_SUPP_laserTGT = "LaserTargetE" createVehicle _supportCoords}
	};
	BIS_SUPP_laserTGT setPos _supportCoords;
	[_provider, BIS_SUPP_laserTGT] spawn {
		while {(_this select 0) getVariable "DRO_SUPP_supporting"} do {
			_this select 1 setPos position (_this select 1);
			(_this select 0) reveal (_this select 1);
			sleep 5
		};
		sleep 10;
		deleteVehicle (_this select 1)
	};
	
	//[_provider, _supportCoords, _CASType] execVM "sunday_system\supports\CASRun.sqf";
	
	[_provider, _supportCoords,_spawnPos] call DRO_CASAddWaypoints;
	
	vehicle _provider addEventHandler ["Fired", {(_this select 0) setVariable ["DRO_SUPP_supporting", FALSE]}];
	
	_i = 1;
	_mrkrName = format ["BIS_SUPP_mrkr_%1", _i];
	while {markerPos format ["BIS_SUPP_mrkr_%1", _i] distance [0,0,0] > 0} do {_i = _i + 1};
	_mrkrName = format ["BIS_SUPP_mrkr_%1", _i];
	_mrkr = createMarker [_mrkrName, _supportCoords];
	if ((player getVariable "DRO_SUPP_ammoType") == 0) then {_mrkrName setMarkerText localize "STR_A3_mdl_supp_disp_cas_bombing"} else {_mrkrName setMarkerText localize "STR_A3_mdl_supp_disp_cas_heli"};	
	_mrkrName setMarkerType "selector_selectedMission";
	_mrkrName setMarkerColor "ColorBlack";
	_mrkrName setMarkerSize [0.75, 0.75];
		
	[_provider, _mrkrName] spawn {
		_provider = _this select 0;
		_mrkrName = _this select 1;		
		waitUntil {!(_provider getVariable "DRO_SUPP_supporting") || !alive _provider};
		deleteMarker _mrkrName;
		if (alive _provider) then {
			if ((player getVariable "DRO_SUPP_ammoType") == 0) then {
				dro_messageStack pushBack [[[str group ((crew _provider) select 0), "Splash.", 0]], true];				
			} else {
				dro_messageStack pushBack [[[str group ((crew _provider) select 0), "Targets engaged.", 0]], true];				
			};
			
		};
	};
	
};

[] spawn {
	sleep 0.1;
	showCommandingMenu "#USER:DRO_SUPP_MENU";
};




