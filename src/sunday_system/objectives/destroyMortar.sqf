params ["_AOIndex"];

_reconChance = (random 1);
_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];

_thisPos = [(((AOLocations select _AOIndex) select 2) select 4)] call sun_selectRemove;
_thisPos set [2, 0];
				
// Create objective
_mortarType = selectRandom eMortarClasses;
// Create Task
_mortarName = ((configFile >> "CfgVehicles" >> _mortarType >> "displayName") call BIS_fnc_GetCfgData);

_taskTitle = "Destroy Mortar Emplacement";
_taskDesc = selectRandom [
	(format ["%1 is operating a %2 emplacement in the %3 region. Command has ordered the emplacement neutralized in advance of a %4 offensive.", enemyFactionName, _mortarName, aoLocationName, playersFactionName])	
]; 
_taskType = "destroy";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

// Create mortar units
_mortPos = [_thisPos, 3, (random 360)] call dro_extendPos;				
_mortar = _mortarType createVehicle _mortPos;				
_spawnedGunner = [_mortPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1, 1]] call dro_spawnGroupWeighted;		
waitUntil {!isNil "_spawnedGunner"};
((units _spawnedGunner) select 0) assignAsGunner _mortar;
(units _spawnedGunner) orderGetIn true;
			
_mort2Dir = [_mortPos, _thisPos] call BIS_fnc_dirTo;
_mort2Pos = [_thisPos, 3, _mort2Dir] call dro_extendPos;
_mortar2 = _mortarType createVehicle _mort2Pos;				
_spawnedGunner2 = [_mortPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1, 1]] call dro_spawnGroupWeighted;	
waitUntil {!isNil "_spawnedGunner2"};
((units _spawnedGunner2) select 0) assignAsGunner _mortar2;
(units _spawnedGunner2) orderGetIn true;

[[_mortar, _mortar2], _taskName] call dro_addSabotageAction;
// Create trigger				
_trgComplete = createTrigger ["EmptyDetector", _thisPos, true];
_trgComplete setTriggerArea [0, 0, 0, false];
_trgComplete setTriggerActivation ["ANY", "PRESENT", false];
_trgComplete setTriggerStatements [
	"
		!alive (thisTrigger getVariable 'mortar1') && !alive (thisTrigger getVariable 'mortar2') 			
	",
	"				
		[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
		missionNamespace setVariable [format ['%1Completed', (thisTrigger getVariable 'thisTask')], 1, true];
		
	", 
	""];
_trgComplete setVariable ["mortar1", _mortar, true];
_trgComplete setVariable ["mortar2", _mortar2, true];
_trgComplete setVariable ["thisTask", _taskName, true];

// Create guards and fortifications
// Populate corner points		
_cornerFortClasses = ["Land_BagBunker_Small_F"];	
_startDir = random 360;	
_dir = (_startDir - 45);
_rotation = (_startDir - 180);
for "_i" from 1 to 4 do {
	_popChance = (random 100);
	if (_popChance > 40) then {
		_cornerPos = [_thisPos, 10, _dir] call dro_extendPos;
		if (_popChance > 70) then {
			// Corner bunker							
			_cornerClass = selectRandom _cornerFortClasses;
			_corner = [_cornerClass, _cornerPos, _rotation] call dro_createSimpleObject;
							
			// Create guard														
			_group = [_cornerPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
			_unit = ((units _group) select 0);							
			if (!isNil "_unit") then {
				_unitDir = (_rotation-180);
				_unit setFormDir _unitDir;
				_unit setDir _unitDir;
			};
			
		};
		// Corner fortifications
		_cornerFortExtraClasses = ["Land_Razorwire_F", "Land_BagFence_Long_F"];
		_cornerFortPos1 = [_cornerPos, 5, (_dir-45)] call dro_extendPos;
		_cornerFortPos2 = [_cornerPos, 5, (_dir+45)] call dro_extendPos;
		
		_cornerFortClass = selectRandom _cornerFortExtraClasses;
		_cornerFortObject1 = [_cornerFortClass, _cornerFortPos1, (_rotation - 90)] call dro_createSimpleObject;
		_cornerFortObject2 = [_cornerFortClass, _cornerFortPos2, (_rotation)] call dro_createSimpleObject;
		
		_dir = _dir + 90;
		_rotation = _rotation + 90;
	};
};
_randItems = [1,3] call BIS_fnc_randomInt;
_itemsArray = [
	"Land_Cargo10_grey_F",
	"Land_Cargo10_military_green_F",					
	"CargoNet_01_box_F",					
	"Land_Pallet_MilBoxes_F"						
];
for "_i" from 1 to _randItems do {
	_itemPos = [_thisPos, 7, 11, 1, 0, 1, 0] call BIS_fnc_findSafePos;
	_thisItem = selectRandom _itemsArray;
	_item = createVehicle [_thisItem, _itemPos, [], 0, "CAN_COLLIDE"];
	_item setDir (random 360);	
};
_minAI = round (3 * aiMultiplier);
_maxAI = round (5 * aiMultiplier);
_spawnedSquad = [_thisPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxAI]] call dro_spawnGroupWeighted;				
if (!isNil "_spawnedSquad") then {					
	[_spawnedSquad, _thisPos, [10, 30], "limited"] execVM "sunday_system\orders\patrolArea.sqf";	
};

// Marker
_markerName = format["mortarMkr%1", floor(random 10000)];
[_mortar, _taskName, _markerName, _intelSubTaskName, markerColorEnemy, 500] execVM "sunday_system\objectives\followingMarker.sqf";

// Create intel subtasks	
_subTaskDesc = format ["Collect all intelligence on the target to narrow down your search. Collecting intel will reduce the size of your search radius. Check the bodies of %1 team leaders, search marked intel locations and complete any intel tasks.", enemyFactionName];
_subTaskTitle = "Optional: Collect Intel";
_subTasks pushBack [_intelSubTaskName, _subTaskDesc, _subTaskTitle, "documents"];
missionNamespace setVariable [(format ["%1_taskType", _intelSubTaskName]), "documents", true];

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
	_mortar
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];
