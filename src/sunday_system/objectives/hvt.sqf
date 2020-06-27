params ["_AOIndex", "_hvtStyles"];
_break = false;
_reconChance = (random 1);
// Get HVT unit
_hvtType = [];
if (count eOfficerClasses > 0) then {
	_hvtType = selectRandom eOfficerClasses;
} else {
	_hvtType = selectRandom eInfClasses;
};							
_hvtChar = nil;
_hvtPos = [];
_allGuards = [];
_subTasks = [];

_evidenceChance = if (missionPreset == 2) then {0} else {random 1};

_hvtCodename = [hvtCodenames] call sun_selectRemove;
_taskName = format ["task%1", floor(random 100000)];
_elimSubtaskName = format ["subtask%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];

// Select style
_hvtStyle = selectRandom _hvtStyles;
switch (_hvtStyle) do {
	case "INSIDE": {				
		_building = [(((AOLocations select _AOIndex) select 2) select 7)] call sun_selectRemove;
		_buildingPlaces = [_building] call BIS_fnc_buildingPositions;
		_thisBuildingPlace = [0,((count _buildingPlaces)-1)] call BIS_fnc_randomInt;
		
		// Create HVT unit
		_hvtGroup = [getPos _building, enemySide, _hvtType, [], [1, 1], true, "NONE"] call dro_spawnGroupWeighted;		
		_hvtChar = ((units _hvtGroup) select 0);
		//_hvtGroup = createGroup enemySide;
		//_hvtChar = _hvtGroup createUnit [_hvtType, getPos _building, [], 0, "NONE"];			
		_hvtChar setPosATL (_building buildingPos _thisBuildingPlace);					
		_hvtPos	= getPos _building;
		
		_nearBuildings = (getPos player) nearObjects ["House", 60];
		if (count _nearBuildings > 0) then {
			for "_i" from 0 to ([2,5] call BIS_fnc_randomInt) step 1 do {
				_buildingNext = selectRandom _nearBuildings;
				if ([_buildingNext] call BIS_fnc_isBuildingEnterable) then {
					_buildingPlaces = [_buildingNext] call BIS_fnc_buildingPositions;
					_thisBuildingPlace = [0,((count _buildingPlaces)-1)] call BIS_fnc_randomInt;
					_wp = _hvtGroup addWaypoint [getPos _buildingNext, 0];
					_wp setWaypointHousePosition _thisBuildingPlace;
					_wp setWaypointType "MOVE";
					_wp setWaypointBehaviour "SAFE";
					_wp setWaypointSpeed "LIMITED";	
					_wp setWaypointCompletionRadius 2;
					_wp setWaypointTimeout [60, 45, 90];				
				};
			};
			_wpLast = _hvtGroup addWaypoint [_hvtPos, 0];
			_wpLast setWaypointType "CYCLE";		
			_wpLast setWaypointCompletionRadius 2;
			_wpLast setWaypointTimeout [60, 45, 90];
		};
	};
	case "OUTSIDE": {		
		_hvtPos = [(((AOLocations select _AOIndex) select 2) select 4)] call sun_selectRemove;	
		_hvtPos set [2,0];					
		
		// STATIONARY
		_sceneType = selectRandom ["MEETINGS", "FOBS"];
		switch (_sceneType) do {
			case "FOBS": {				
				_objects = selectRandom compositionsFOBs;
				_spawnedObjects = [_hvtPos, (random 360), _objects] call BIS_fnc_ObjectsMapper;					
				{
					if (typeOf _x == "Sign_Arrow_Blue_F") then {								
						_guardGroup = [getPos _x, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
						_guardUnit = ((units _guardGroup) select 0);
						if (!isNil "_guardUnit") then {	
							_guardUnit setFormDir (getDir _x);
							_guardUnit setDir (getDir _x);
						};
						deleteVehicle _x;
					};
				} forEach _spawnedObjects;					
				// Create HVT unit						
				_hvtSpawnPos = _hvtPos findEmptyPosition [0, 15, _hvtType];
				//_hvtGroup = createGroup enemySide;
				//_hvtChar = _hvtGroup createUnit [_hvtType, _hvtSpawnPos, [], 0, "NONE"];
				_hvtGroup = [_hvtSpawnPos, enemySide, _hvtType, [], [1, 1], true, "NONE"] call dro_spawnGroupWeighted;
				_hvtChar = ((units _hvtGroup) select 0);
				
				_dist = 10;
				while {([_hvtChar] call sun_checkIntersect) && (_dist < 100)} do {
					[_hvtGroup, (_hvtSpawnPos getPos [_dist, (random 360)])] call sun_moveGroup;
					_dist = _dist + 5;
				};
				/*
				if ([_hvtChar] call sun_checkIntersect) then {
					deleteVehicle _hvtChar;
					_hvtSpawnPos = _hvtPos findEmptyPosition [25, 50, _hvtType];
					_hvtChar = _hvtGroup createUnit [_hvtType, _hvtSpawnPos, [], 0, "NONE"];
				};
				*/				
			};
			case "MEETINGS": {
				// Create HVT unit
				_hvtSpawnPos = _hvtPos findEmptyPosition [0, 15, _hvtType];
				_hvtGroup = [_hvtSpawnPos, enemySide, _hvtType, [], [1, 1], true, "NONE"] call dro_spawnGroupWeighted;
				_hvtChar = ((units _hvtGroup) select 0);
				//_hvtGroup = createGroup enemySide;
				//_hvtChar = _hvtGroup createUnit [_hvtType, _hvtSpawnPos, [], 0, "NONE"];						
				_hvtChar setPos _hvtPos;
			
				_civArray = ["C_man_p_beggar_F", "C_man_1", "C_man_polo_1_F", "C_man_polo_2_F", "C_man_polo_3_F", "C_man_polo_4_F", "C_man_polo_5_F", "C_man_polo_6_F", "C_man_shorts_1_F", "C_man_1_1_F", "C_man_1_2_F", "C_man_1_3_F", "C_man_w_worker_F"];				
				_objects = selectRandom compositionsMeetings;
				_spawnedObjects = [_hvtPos, (random 360), _objects] call BIS_fnc_ObjectsMapper;
				
				{
					if (typeOf _x == "Sign_Arrow_Blue_F") then {
						_pos = getPos _x;
						_dir = getDir _x;
						deleteVehicle _x;								
						_guardGroup = [_pos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
						_guardUnit = ((units _guardGroup) select 0);
						if (!isNil "_guardUnit") then {
							_guardUnit setFormDir (_dir);
							_guardUnit setDir (_dir);
						};
					};
					if (typeOf _x == "Sign_Arrow_F") then {
						_pos = getPos _x;
						_dir = getDir _x;
						deleteVehicle _x;
						_hvtChar setPos _pos;
						_hvtChar setFormDir _dir;
						_hvtChar setDir _dir;									
					};
					if (typeOf _x == "Sign_Arrow_Yellow_F") then {
						_civType = selectRandom _civArray;
						_pos = getPos _x;
						_dir = getDir _x;
						deleteVehicle _x;
						_group = createGroup civilian;
						_spawnedCiv = _group createUnit [_civType, _pos, [], 0, "CAN_COLLIDE"];										
						_spawnedCiv setFormDir _dir;
						_spawnedCiv setDir _dir;
						[_spawnedCiv] call dro_civDeathHandler;						
					};
				} forEach _spawnedObjects;						
			};
		};	
									
	};
	case "OUTSIDETRAVEL": {
		_possibleLocTypes = [];		
		if (count (((AOLocations select _AOIndex) select 2) select 0) > 0) then {_possibleLocTypes pushBack 0};
		if (count (((AOLocations select _AOIndex) select 2) select 2) > 0) then {_possibleLocTypes pushBack 2};
		if (count (((AOLocations select _AOIndex) select 2) select 3) > 0) then {_possibleLocTypes pushBack 3};
		if (count (((AOLocations select _AOIndex) select 2) select 4) > 0) then {_possibleLocTypes pushBack 4};		
		diag_log format ["_possibleLocTypes for OUTSIDETRAVEL HVT spawn = %1", _possibleLocTypes];
		_selectedPos = selectRandom _possibleLocTypes;
		diag_log format ["_selectedPos for OUTSIDETRAVEL HVT spawn = %1", _selectedPos];
		_hvtPos = [(((AOLocations select _AOIndex) select 2) select _selectedPos)] call sun_selectRemove;
	
		// Get a selection of possible new travel locations if chance allows
		_travelPositions = [];			
		_possibleLocsMaxIndex = (count AOLocations)-1;
		if (_possibleLocsMaxIndex > 0) then {
			for "_i" from 0 to ([0, _possibleLocsMaxIndex] call BIS_fnc_randomInt) step 1 do {		
				_possibleLocTypes = [];
				if (_i == _AOIndex) then {
					if (count (((AOLocations select _i) select 2) select 7) > 0) then {_possibleLocTypes pushBack 7};
					if (count (((AOLocations select _i) select 2) select 0) > 0) then {_possibleLocTypes pushBack 0};
					if (count (((AOLocations select _i) select 2) select 8) > 0) then {_possibleLocTypes pushBack 8};
					if (count (((AOLocations select _i) select 2) select 2) > 0) then {_possibleLocTypes pushBack 2};
				} else {
					if (((AOLocations select _i) select 3) isEqualTo "ROUTE") then {
						diag_log "Location route found";
						if (count (((AOLocations select _i) select 2) select 7) > 0) then {_possibleLocTypes pushBack 7};
						if (count (((AOLocations select _i) select 2) select 0) > 0) then {_possibleLocTypes pushBack 0};
						if (count (((AOLocations select _i) select 2) select 8) > 0) then {_possibleLocTypes pushBack 8};
						if (count (((AOLocations select _i) select 2) select 2) > 0) then {_possibleLocTypes pushBack 2};
					};
				};
				diag_log format ["_possibleLocTypes = %1", _possibleLocTypes];		
				if (count _possibleLocTypes > 0) then {
					if (_i == 0) then {
						_selectedPosArray = ((((AOLocations select _i) select 2) select (selectRandom _possibleLocTypes)));					
						_selectedPos = [_selectedPosArray] call sun_selectRemove;					
						_travelPositions pushBack _selectedPos;
					} else {
						if (random 1 > 0.5) then {
							_selectedPosArray = ((((AOLocations select _i) select 2) select (selectRandom _possibleLocTypes)));					
							_selectedPos = [_selectedPosArray] call sun_selectRemove;					
							_travelPositions pushBack _selectedPos;
						};
					};
				};		
			};
		};
		//_hvtGroup = createGroup enemySide;
		_hvtPos set [2, 0];
		//_hvtChar = _hvtGroup createUnit [_hvtType, _hvtPos, [], 0, "NONE"];
		_hvtGroup = [_hvtPos, enemySide, _hvtType, [], [1, 1], true, "NONE"] call dro_spawnGroupWeighted;
		_hvtChar = ((units _hvtGroup) select 0);
		_dist = 10;
		while {([_hvtChar] call sun_checkIntersect) && (_dist < 100)} do {
			[_hvtGroup, (_hvtSpawnPos getPos [_dist, (random 360)])] call sun_moveGroup;
			_dist = _dist + 5;
		};
		/*
		if ([_hvtChar] call sun_checkIntersect) then {
			deleteVehicle _hvtChar;
			_hvtSpawnPos = _hvtPos findEmptyPosition [25, 50, _hvtType];
			_hvtChar = _hvtGroup createUnit [_hvtType, _hvtSpawnPos, [], 0, "NONE"];
		};
		*/
		_hvtChar setRank "MAJOR";
		_minAI = round (4 * aiMultiplier);
		_maxAI = round (6 * aiMultiplier);
		_guardGroup = [_hvtPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI], false] call dro_spawnGroupWeighted;
		waitUntil {!isNil "_guardGroup"};
		(units _guardGroup) join (group _hvtChar);
		{_allGuards pushBack _x} forEach (units _guardGroup);	
	
		if (count _travelPositions > 0) then {
			// TRAVELLING						
			// Initialise route waypoints
			_wpFirst = _hvtGroup addWaypoint [_hvtPos, 0];
			_wpFirst setWaypointType "MOVE";
			_wpFirst setWaypointBehaviour "SAFE";
			_wpFirst setWaypointSpeed "LIMITED";			
			{
				_pos = if (typeName _x == "OBJECT") then {getPos _x} else {_x};
				_wp = _hvtGroup addWaypoint [_pos, 50];
				_wp setWaypointType "MOVE";
				_wp setWaypointCompletionRadius 20;
				_wp setWaypointTimeout [20, 30, 45];
				if (_reconChance < baseReconChance) then {
					taskIntel pushBack [_taskName, _pos, _intelSubTaskName, "WAYPOINT"];
				};
			} forEach _travelPositions;
			_wpLast = _hvtGroup addWaypoint [_hvtPos, 0];
			_wpLast setWaypointType "CYCLE";		
			_wpLast setWaypointCompletionRadius 20;
			_wpLast setWaypointTimeout [20, 30, 45];
			if (_reconChance < baseReconChance) then {
				taskIntel pushBack [_taskName, _hvtPos, _intelSubTaskName, "WAYPOINT"];
			};
		} else {
			[_hvtGroup, (getPos _hvtChar), 100] spawn BIS_fnc_taskPatrol;
		};
	};
};

if (_break) exitWith {[(AOLocations call BIS_fnc_randomIndex), false] call fnc_selectObjective};

_markerName = format["hvtMkr%1", floor(random 10000)];	

// Setup identity
_firstNameClass = (configFile >> "CfgWorlds" >> "GenericNames" >> eGenericNames >> "FirstNames");
_firstNames = [];
for "_i" from 0 to count _firstNameClass - 1 do {
	_firstNames pushBack (getText (_firstNameClass select _i));
};
_lastNameClass = (configFile >> "CfgWorlds" >> "GenericNames" >> eGenericNames >> "LastNames");
_lastNames = [];
for "_i" from 0 to count _lastNameClass - 1 do {
	_lastNames pushBack (getText (_lastNameClass select _i));
};
if ((count _firstNames > 0) && (count _lastNames > 0)) then {		
	[_hvtChar, (selectRandom _firstNames), (selectRandom _lastNames), (speaker _hvtChar), (selectRandom eFacesArray)] remoteExec ["sun_setNameMP", 0, true];
};
if (random 1 > 0.5) then {
	removeAllWeapons _hvtChar;
};
if (random 1 > 0.3) then {
	_hvtChar addHeadgear (selectRandom ["H_Beret_red", "H_Hat_brown", "H_Hat_tan", "H_MilCap_blue", "H_MilCap_gry", "H_ShemagOpen_tan", "H_ShemagOpen_khk"]);
};
if (random 1 > 0.3) then {
	_hvtChar addGoggles (selectRandom ["G_Aviator", "G_Balaclava_blk", "G_Balaclava_oli", "G_Bandanna_blk", "G_Bandanna_khk", "G_Bandanna_shades", "G_Spectacles", "G_Squares_Tinted", "G_Spectacles_Tinted"]);
};

// Create Task
_hvtName = ((configFile >> "CfgVehicles" >> _hvtType >> "displayName") call BIS_fnc_GetCfgData);
_taskDescriptions = [
	(format ["We believe that the high value target codenamed '%1' is active somewhere in the AO. This target has been on our kill list for a long time and recent intelligence reports from an undercover source puts him here. It goes without saying that neutralizing this %2 would be a great blow to %3 efforts in the region.", _hvtCodename, toLower _hvtName, enemyFactionName]),
	(format ["'%1' has recently resurfaced in the region after a prolonged absence from our surveillance. Command is anxious not to let this target disappear again and resume covert operations against %2 forces.", _hvtCodename, playersFactionName]),
	(format ["Reports have come in that our target is responsible for a number of atrocities in the %1 area. Despite his willingness to use civilians as shields for his operations, he still commands great influence with the local populace. While alive, %2 represents a large threat to both civilian and the nearby %3 forces.", aoLocationName, _hvtCodename, playersFactionName]),
	(format ["A little known %1 commander has begun to make a name for himself with attacks on civilian targets in the %2 region. Though the casualty count from his operations remains thankfully low, recent intelligence points to his involvement in a planned attempt to overthrow the governing civilian body, a destabilising risk we cannot allow.", enemyFactionName, aoLocationName]),
	(format ["From his base of operations at %1 our target codenamed '%2' commands a fierce guerilla operation. Other information related to his past and planned actions are currently classified, just make sure that whatever those plans might be never come to fruition.", aoLocationName, _hvtCodename])
];

_evidenceDescriptions = [];
if (_evidenceChance > 0.6) then {
	_evidenceDescriptions = [
		(format ["Our most recent photographic records of %1 are over two decades old at this point. We are going to need DNA confirmation that our intelligence is correct and you'll be required to collect that after neutralizing the target.", _hvtCodename]),
		(format ["Intelligence is shaky where the identity of %1 is concerned. We'll need you to take DNA evidence from the body once the target is down.", _hvtCodename]),
		(format ["High command requires this mission to go by the book. With the current conflict playing out on on the global stage there is no room for error and we'll need you to confirm with DNA evidence that we have our man.", _hvtCodename]),
		(format ["Command expects the elimination of this target to be immediately denied by %1 and will need proof to use against their propaganda machine. Once down, take DNA evidence from the target.", enemyFactionName])
	];
};

_taskDesc = format ["%1<br /><br />%2", (selectRandom _taskDescriptions), (selectRandom _evidenceDescriptions)];
_taskTitle = format ["HVT: %1", _hvtCodename];
_taskType = "kill";
_hvtChar setVariable ["thisTask", _taskName];
_hvtChar setVariable ["markerName", _markerName];
_hvtChar setVariable ["codename", _hvtCodename];
removeFromRemainsCollector [_hvtChar];
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];

// Create elimination subtask
_elimSubtaskDesc = format ["Eliminate the %1 %2 codenamed '%4'. Target is believed to be in the <marker name='%3'>marked area</marker>. Use caution and do not allow the target to escape.", enemyFactionName, toLower _hvtName, _markerName, _hvtCodename];
_elimSubtaskTitle = format ["Eliminate %1", _hvtCodename];
_subTasks pushBack [_elimSubtaskName, _elimSubtaskDesc, _elimSubtaskTitle, "target"];
missionNamespace setVariable [(format ["%1_taskType", _elimSubtaskName]), "target", true];
_hvtChar setVariable ["elimTask", _elimSubtaskName, true];

// Add killed event handler
_hvtChar addEventHandler ["Killed", {[((_this select 0) getVariable ("elimTask")), "SUCCEEDED", true] spawn BIS_fnc_taskSetState; ((_this select 0) getVariable "markerName") setMarkerAlpha 0;}];		

if (_reconChance >= baseReconChance) then {
	_markerRecon = createMarker [_markerName, _hvtPos];						
	_markerRecon setMarkerShape "ICON";		
	_markerRecon setMarkerAlpha 0;
} else {
	if (count (headgear _hvtChar) > 0) then {
		taskIntel pushBack [_taskName, headgear _hvtChar, _intelSubTaskName, "WEARABLE"];
	};
	if (count (goggles _hvtChar) > 0) then {
		taskIntel pushBack [_taskName, goggles _hvtChar, _intelSubTaskName, "WEARABLE"];
	};
	taskIntel pushBack [_taskName, name _hvtChar, _intelSubTaskName, "NAME"];

	// Create intel subtasks	
	_subTaskDesc = format ["Collect all intelligence on the target to narrow down your search. Intel may include information on the target's appearance, their aliases and may reduce the size of your search radius. Check the bodies of %1 team leaders, search marked intel locations and complete any intel tasks.", enemyFactionName];
	_subTaskTitle = "Optional: Collect Intel";
	_subTasks pushBack [_intelSubTaskName, _subTaskDesc, _subTaskTitle, "documents"];
	missionNamespace setVariable [(format ["%1_taskType", _intelSubTaskName]), "documents", true];
	// Following marker
	[_hvtChar, _taskName, _markerName, _intelSubTaskName] execVM "sunday_system\objectives\followingMarker.sqf";
};

// Evidence gathering subtask
if (_evidenceChance > 0.6) then {
	_subTaskName = format ["subtask%1", floor(random 100000)];
	_subTaskDesc = format ["Once eliminated we need proof of the target's identity. Get close and take a DNA sample for the intelligence team.", _hvtCodename];
	_subTaskTitle = "Collect Evidence";
	_subTasks pushBack [_subTaskName, _subTaskDesc, _subTaskTitle, "use"];
	missionNamespace setVariable [(format ["%1_taskType", _subTaskName]), "use", true];
	_hvtChar setVariable ["evidenceTask", _subTaskName, true];
	[
		_hvtChar,
		"Collect Evidence",
		"\A3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa",
		"\A3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa",
		"(!alive _target) && ((_this distance _target) < 3)",
		"((_this distance _target) < 3)",
		{},
		{},
		{		
			[(_this select 0) getVariable "evidenceTask", "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
			[(_this select 0), (_this select 2)] remoteExec ["bis_fnc_holdActionRemove", 0, true];			
		},
		{},
		[],
		5,
		10,
		true,
		false
	] remoteExec ["bis_fnc_holdActionAdd", 0, true];
	
	// Listener for elimination task completion and evidence gathering completion
	[_taskName, _elimSubtaskName, _subTaskName] spawn {
		waitUntil {playersReady == 1};
		waitUntil {sleep 3; [(_this select 1)] call BIS_fnc_taskCompleted && [(_this select 2)] call BIS_fnc_taskCompleted};
		if (([(_this select 1)] call BIS_fnc_taskState) == "Succeeded") then {
			[(_this select 0), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
			
		} else {
			[(_this select 0), "CANCELED", true] spawn BIS_fnc_taskSetState;
		};
		for "_i" from ((count taskIntel)-1) to 0 step -1 do {
			if (((taskIntel select _i) select 0) == (_this select 0)) then {taskIntel deleteAt _i};
		};
		publicVariable "taskIntel";
		missionNamespace setVariable [format ["%1Completed", (_this select 0)], 1, true];
	};	
} else {
	// Listener for elimination task completion
	[_taskName, _elimSubtaskName] spawn {
		waitUntil {playersReady == 1};
		waitUntil {[(_this select 1)] call BIS_fnc_taskCompleted};
		if (([(_this select 1)] call BIS_fnc_taskState) == "Succeeded") then {
			[(_this select 0), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
			
		} else {
			[(_this select 0), "CANCELED", true] spawn BIS_fnc_taskSetState;
		};
		for "_i" from ((count taskIntel)-1) to 0 step -1 do {
			if (((taskIntel select _i) select 0) == (_this select 0)) then {taskIntel deleteAt _i};
		};
		publicVariable "taskIntel";
		missionNamespace setVariable [format ["%1Completed", (_this select 0)], 1, true];
	};
};

if (dynamicSim == 0) then {
	_hvtChar enableDynamicSimulation true;
};

// Spawn patrols
if (_hvtStyle == "INSIDE" OR _hvtStyle == "OUTSIDE") then {
	_minAI = round (2 * aiMultiplier);
	_maxAI = round (5 * aiMultiplier);
	_spawnedSquad = [_hvtPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxAI]] call dro_spawnGroupWeighted;		
	if (!isNil "_spawnedSquad") then {
		[_spawnedSquad, _hvtPos, [10, 30], "limited"] execVM "sunday_system\orders\patrolArea.sqf";	
		{_allGuards pushBack _x} forEach (units _spawnedSquad);			
	};
};

// Create fail state
/*	
_trgFlee = createTrigger ["EmptyDetector", _hvtPos, true];
_trgFlee setTriggerArea [0, 0, 0, false];
_trgFlee setTriggerActivation ["ANY", "PRESENT", false];
_trgFlee setTriggerStatements [
	"
		({alive _x} count (thisTrigger getVariable 'allGuards')) < ((count (thisTrigger getVariable 'allGuards')) * 0.5)				
	",
	"				
		(thisTrigger getVariable 'hvt') allowFleeing 1;					
	", 
	""];
_trgFlee setVariable ["allGuards", _allGuards];
_trgFlee setVariable ["hvt", _hvtChar];

_trgFail = [objNull, "mkrAOC"] call BIS_fnc_triggerToMarker;
_trgFail setTriggerActivation ["ANY", "PRESENT", false];
_trgFail setTriggerStatements [
	"
		(alive (thisTrigger getVariable 'hvt')) && 
		!((thisTrigger getVariable 'hvt') in thisList) && 
		((thisTrigger getVariable 'hvt') distance u1 > 1000)
	",
	"				
		[(thisTrigger getVariable 'thisTask'), 'FAILED', true] spawn BIS_fnc_taskSetState;
		hideObject (thisTrigger getVariable 'hvt');				
		for '_i' from ((count taskIntel)-1) to 0 step -1 do {
			if (((taskIntel select _i) select 0) == (thisTrigger getVariable 'thisTask')) then {taskIntel deleteAt _i};
		};
		publicVariable 'taskIntel';
	", 
	""];
_trgFail setVariable ["hvt", _hvtChar];
_trgFail setVariable ["thisTask", _taskName];
*/
sleep 0.5;

missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];
allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_hvtPos,
	_reconChance,
	_subTasks,
	_hvtChar
];
publicVariable "taskIntel";
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];
