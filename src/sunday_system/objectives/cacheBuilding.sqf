params ["_AOIndex"];

_reconChance = (random 1);
_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];

// Find a random building in the area
_building = [(((AOLocations select _AOIndex) select 2) select 7)] call sun_selectRemove;
_buildingClass = typeOf _building;		
_buildingPos = getPos _building;
	
// Populate building
_buildingPositions = [_building] call BIS_fnc_buildingPositions;
_buildingPositionsShuffled = _buildingPositions call BIS_fnc_arrayShuffle;
_buildingDir = getDir _building;

_targetArray = if (395180 in (getDLCs 1)) then {
	["Box_Syndicate_WpsLaunch_F", "Box_Syndicate_Wps_F", "Box_IED_Exp_F"]
} else {
	["Box_IND_Ammo_F", "Box_IND_WpsLaunch_F", "Box_IND_AmmoOrd_F"]
};
_spawnedObjects = [];
_infCount = 0;
_totalInf = round (5 * aiMultiplier);
{
	if ((count _spawnedObjects) < 3) then {
		_thisTarget = selectRandom _targetArray;
		_object = createVehicle [_thisTarget, _x, [], 0, "CAN_COLLIDE"];		
		_object = [_object] call sun_checkVehicleSpawn;
		if (!isNull _object) then {		
			_spawnedObjects pushBack _object;
			_object setDir (selectRandom [_buildingDir, _buildingDir+90]);
		};
	} else {	
		if (_infCount < _totalInf) then {
			_group = [_x, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
			_unit = ((units _group) select 0);									
			if (!isNil "_unit") then {
				_unit setUnitPos "UP";
				_infCount = _infCount + 1;
			};					
		};
	};		
} forEach _buildingPositionsShuffled;

if (count _spawnedObjects == 0) exitWith {
	diag_log "DRO: No valid building cache object positions found";
	[(AOLocations call BIS_fnc_randomIndex)] call fnc_selectObjective
};

// Spawn enemies to guard the building
_minAI = round (2 * aiMultiplier);
_maxAI = round (5 * aiMultiplier);
_spawnedSquad2 = [getPos _building, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;				
if (!isNil "_spawnedSquad2") then {
	[_spawnedSquad2, getPos _building, 100] call bis_fnc_taskPatrol;
};

// Marker
_markerName = format["cacheMkr%1", floor(random 10000)];
[(_spawnedObjects select 0), _taskName, _markerName, _intelSubTaskName, markerColorEnemy, 400] execVM "sunday_system\objectives\followingMarker.sqf";

// Create task
_taskTitle = "Destroy Cache";
_buildingName = ((configFile >> "CfgVehicles" >> _buildingClass >> "displayName") call BIS_fnc_GetCfgData);
_taskDesc = selectRandom [
	(format ["%1 is hiding a weapons cache somewhere in the %2 region. Intelligence given to us by local contacts implies that these weapons are going to arm an independent insurgent group willing to carry out attacks on the civilian population. Destroy the cache.", enemyFactionName, aoLocationName]),
	(format ["A %2 local recently stumbled on a hidden %1 ammunition dump in the %2 region. You are tasked with locating and destroying that cache before it can be moved again.", enemyFactionName, aoLocationName, playersFactionName]),
	(format ["Since the beginning of the %3 offensive we have been unable to make serious headway against the %1 supply operation, however recent information provided to us by a guerilla element places a %1 weapons cache in this area. Find and destroy it.", enemyFactionName, aoLocationName, playersFactionName])
];
_taskType = "destroy";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

// Create intel subtasks	
_subTaskDesc = format ["Collect all intelligence on the target to narrow down your search. Collecting intel will reduce the size of your search radius. Check the bodies of %1 team leaders, search marked intel locations and complete any intel tasks.", enemyFactionName];
_subTaskTitle = "Optional: Collect Intel";
_subTasks pushBack [_intelSubTaskName, _subTaskDesc, _subTaskTitle, "documents"];
missionNamespace setVariable [(format ["%1_taskType", _intelSubTaskName]), "documents", true];

[_spawnedObjects, _taskName] call dro_addSabotageAction;

// Create trigger				
_trgComplete = createTrigger ["EmptyDetector", _buildingPos, true];
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
	_buildingPos,
	_reconChance,
	_subTasks
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];