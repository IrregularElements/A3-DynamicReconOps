params ["_AOIndex"];

_reconChance = (random 1);
_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];

_thisPos = [(((AOLocations select _AOIndex) select 2) select 6)] call sun_selectRemove;

_targetArray = if (395180 in (getDLCs 1)) then {
	["Box_Syndicate_WpsLaunch_F", "Box_Syndicate_Wps_F", "Box_IED_Exp_F", "Box_FIA_Ammo_F", "Box_FIA_Support_F", "Box_FIA_Wps_F"]
} else {
	["Box_FIA_Ammo_F", "Box_FIA_Support_F", "Box_FIA_Wps_F"]
};
_spawnedObjects = [];

for "_i" from 1 to ([1,3] call BIS_fnc_randomInt) step 1 do {
	//_spawnPos = [_thisPos, 1, 15, 1.5, 0, 0.4, 0, [[]], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
	//if !(_spawnPos isEqualTo [0,0,0]) then {
	
	_thisTarget = selectRandom _targetArray;
	_targetPos = _thisPos findEmptyPosition [1, 15, _thisTarget];
	if (count _targetPos > 0) then {
		_object = createVehicle [_thisTarget, _targetPos, [], 0, "CAN_COLLIDE"];
		_object = [_object] call sun_checkVehicleSpawn;
		if (!isNull _object) then {			
			_spawnedObjects pushBack _object;
			_object setDir (random 360);
		};
	};
};

if (count _spawnedObjects == 0) exitWith {
	diag_log "DRO: No valid cache object positions found";
	[(AOLocations call BIS_fnc_randomIndex)] call fnc_selectObjective;
};

// Spawn enemies to guard the building
_minAI = round (3 * aiMultiplier);
_maxAI = round (5 * aiMultiplier);
_spawnedSquad = [_thisPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxAI]] call dro_spawnGroupWeighted;				
if (!isNil "_spawnedSquad") then {					
	[_spawnedSquad, _thisPos, [10, 30], "limited"] execVM "sunday_system\orders\patrolArea.sqf";	
};

// Marker
_markerName = format["cacheMkr%1", floor(random 10000)];
[(_spawnedObjects select 0), _taskName, _markerName, _intelSubTaskName, markerColorEnemy, 400] execVM "sunday_system\objectives\followingMarker.sqf";

// Create task
_taskTitle = "Destroy Cache";
_taskDesc = selectRandom [
	(format ["%1 is hiding a weapons cache somewhere in the %2 region. Intelligence given to us by local contacts implies that these weapons are going to arm an independent insurgent group willing to carry out attacks on the civilian population. Destroy the cache.", enemyFactionName, aoLocationName]),
	(format ["A %2 local recently stumbled on a hidden %1 ammunition dump in the %2 region. You are tasked with locating and destroying that cache before it can be moved again.", enemyFactionName, aoLocationName, playersFactionName]),
	(format ["Since the beginning of the %3 offensive we have been unable to make serious headway against the %1 supply operation, however recent information provided to us by a guerilla element places a %1 weapons cache in this area. Find and destroy it.", enemyFactionName, aoLocationName, playersFactionName])
];

_taskType = "destroy";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];

// Create intel subtasks	
_subTaskDesc = format ["Collect all intelligence on the target to narrow down your search. Collecting intel will reduce the size of your search radius. Check the bodies of %1 team leaders, search marked intel locations and complete any intel tasks.", enemyFactionName];
_subTaskTitle = "Optional: Collect Intel";
_subTasks pushBack [_intelSubTaskName, _subTaskDesc, _subTaskTitle, "documents"];

[_spawnedObjects, _taskName] call dro_addSabotageAction;

// Create trigger				
_trgComplete = createTrigger ["EmptyDetector", _thisPos, true];
_trgComplete setTriggerArea [0, 0, 0, false];
_trgComplete setTriggerActivation ["ANY", "PRESENT", false];
_trgComplete setTriggerStatements [
	"
		{
			if (!alive _x) exitWith {
				true
			};
		} forEach (thisTrigger getVariable 'objects');				
	",
	"	
		{
			if (alive _x) then {
				_x setDamage 1;
			};
		} forEach (thisTrigger getVariable 'objects');
		[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
		missionNamespace setVariable [format ['%1Completed', (thisTrigger getVariable 'thisTask')], 1, true];
	", 
	""];
_trgComplete setVariable ["objects", _spawnedObjects, true];
_trgComplete setVariable ["thisTask", _taskName, true];

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_thisPos,
	_reconChance,
	_subTasks	
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];