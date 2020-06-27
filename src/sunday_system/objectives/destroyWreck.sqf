
params ["_AOIndex"];

_reconChance = 0;
_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];

_thisPos = [];
_wreckType = "";

_vehicleTypes = [];
if (count (((AOLocations select _AOIndex) select 2) select 0) > 0) then {
	_vehicleTypes pushBackUnique "GROUNDROAD";	
};
if (count (((AOLocations select _AOIndex) select 2) select 4) > 0) then {
	_vehicleTypes pushBackUnique "HELI";
	_vehicleTypes pushBackUnique "GROUND";
};
if (count (((AOLocations select _AOIndex) select 2) select 2) > 0) then {	
	_vehicleTypes pushBackUnique "GROUND";
};

_pVehicleWreckClasses = if ("HELI" in _vehicleTypes) then {
	pCarClasses + pTankClasses + pHeliClasses;
} else {
	pCarClasses + pTankClasses;
};

_wreckType = selectRandom _pVehicleWreckClasses;

if (_wreckType isKindOf "Helicopter") then {
	diag_log "Wreck type heli, flat pos close";
	if (count (((AOLocations select _AOIndex) select 2) select 4) > 0) then {
		_thisPos = [(((AOLocations select _AOIndex) select 2) select 4)] call sun_selectRemove;
	} else {
		if (count (((AOLocations select _AOIndex) select 2) select 2) > 0) then {
			_thisPos = [(((AOLocations select _AOIndex) select 2) select 2)] call sun_selectRemove;
		};
	};
} else {	
	if ("GROUNDROAD" in _vehicleTypes) then {
		diag_log "Wreck type ground, road";		
		_thisPos = [(((AOLocations select _AOIndex) select 2) select 0)] call sun_selectRemove;
	} else {
		diag_log "Wreck type ground";		
		if (count (((AOLocations select _AOIndex) select 2) select 4) > 0) then {
			_thisPos = [(((AOLocations select _AOIndex) select 2) select 4)] call sun_selectRemove;
		} else {
			if (count (((AOLocations select _AOIndex) select 2) select 2) > 0) then {
				_thisPos = [(((AOLocations select _AOIndex) select 2) select 2)] call sun_selectRemove;
			};
		};
	};	
};

_thisPos set [2, 0];

// Create objective
// Marker
_markerName = format["wreckMkr%1", floor(random 10000)];
_markerWreck = createMarker [_markerName, _thisPos];
_markerWreck setMarkerShape "ICON";
_markerWreck setMarkerType  "n_motor_inf";
_markerWreck setMarkerColor markerColorPlayers;
_markerWreck setMarkerAlpha 0;								

// Create Task				
_wreckName = ((configFile >> "CfgVehicles" >> _wreckType >> "displayName") call BIS_fnc_GetCfgData);

_taskTitle = "Destroy Wreck";
_taskDesc = selectRandom [
	(format ["Deny the enemy use of a wrecked %4 %1 located in the %3 region. Destroy the wreck by any means available.", _wreckName, enemyFactionName, aoLocationName, playersFactionName]),
	(format ["An artillery strike 8 hours ago disabled a %4 %1 in the %3 region. Perform a bomb damage assessment and destroy the vehicle by any means available.", _wreckName, enemyFactionName, aoLocationName, playersFactionName]),
	(format ["A %4 operation in the %3 area has left behind a disabled %1 and command is keen not to let it come of use to %2 forces. Destroy the vehicle by any means available.", _wreckName, enemyFactionName, aoLocationName, playersFactionName])	
];
_taskType = "destroy";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

_wreck = _wreckType createVehicle _thisPos;				
_wreck setVariable ["thisTask", _taskName, true];
[_wreck] call dro_addSabotageAction;
// Add destruction event handler
_wreck addEventHandler ["Killed", {
	[(_this select 1), 7000] remoteExec ["addRating", (_this select 1)];
	//(_this select 1) addRating 7000;
	[((_this select 0) getVariable ('thisTask')), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
	missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
	
} ];				

_wreck setVehicleAmmo 0;
_wreck setDamage 0.7;
_wreck setFuel 0;
_wreck lock true;
_wreck setDir (random 360);

_emitter = "#particlesource" createVehicle _thisPos;
_emitter setParticleClass "BigDestructionSmoke";
_emitter setParticleFire [0.3,1.0,0.1];

// Create guards
_minAI = round (3 * aiMultiplier);
_maxAI = round (5 * aiMultiplier);
_spawnedSquad = [_thisPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxAI]] call dro_spawnGroupWeighted;									
if (!isNil "_spawnedSquad") then {
	[_spawnedSquad, _thisPos, [10, 30], "limited"] execVM "sunday_system\orders\patrolArea.sqf";	
};

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_thisPos,
	_reconChance,
	_subTasks,
	_wreck
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];