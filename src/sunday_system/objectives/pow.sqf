params ["_AOIndex", "_powStyles"];

_powPos = [];
_powStyle = selectRandom _powStyles;					
_reconChance = (random 1);
_powChar = nil;
_spawnedSquad = nil;
_spawnedSquad2 = nil;

_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];
_joinSubTaskName = format ["subtask%1", floor(random 100000)];
_extractSubTaskName = format ["subtask%1", floor(random 100000)];

_break = false;
switch (_powStyle) do {			
	case "OUTSIDE": {
		// Move to random location	
		_powPos = [(((AOLocations select _AOIndex) select 2) select 6)] call sun_selectRemove;				
		_powPos set [2, 0];
				
		_powSpawnPos = [];
		_powSpawnPos = [_powPos, 0, 150, 1.5, 0, 50, 0, [], [[0,0,0], [0,0,0]]] call BIS_fnc_findSafePos;
		if (_powSpawnPos isEqualTo [0,0,0]) exitWith {
			_break = true;
		};
		_powPos = _powSpawnPos;		
		
		_campObjects = [
			"Land_CampingTable_F",
			"Land_Camping_Light_F",
			"Land_CampingChair_V2_F",
			"Land_GasTank_01_khaki_F",
			"Land_Pillow_old_F",
			"Land_Ground_sheet_khaki_F",
			"Land_TentA_F",
			"Land_TentDome_F",
			"Land_WoodenLog_F",
			"Land_WoodPile_F",
			"Land_WoodPile_large_F",
			"Land_Garbage_square3_F",
			"Land_GarbageBags_F",					
			"Land_JunkPile_F"
		];
		_numCampObjects = [3,8] call BIS_fnc_randomInt;
		for "_i" from 1 to _numCampObjects do {
			_spawnPos = [_powPos, (1.5 + random 3), (random 360)] call dro_extendPos;
			_selectedObject = selectRandom _campObjects;
			_object = createVehicle [_selectedObject, _spawnPos, [], 2, "NONE"];
			_object setDir (random 360);
		};
		
		_group = [_powPos, playersSide, powClass, [], [1, 1], true, "NONE"] call dro_spawnGroupWeighted;
		_powChar = ((units _group) select 0);
		//_group = createGroup playersSide;
		//_powChar = _group createUnit [powClass, _powPos, [], 0, "NONE"];
		_dist = 10;
		while {([_powChar] call sun_checkIntersect) && (_dist < 100)} do {
			[_group, (_powPos getPos [_dist, (random 360)])] call sun_moveGroup;
			_dist = _dist + 5;
		};
		/*
		if ([_powChar] call sun_checkIntersect) then {
			deleteVehicle _powChar;
			_powSpawnPos = _powPos findEmptyPosition [25, 50, powClass];
			_powChar = _group createUnit [powClass, _powSpawnPos, [], 0, "NONE"];
		};
		*/
	};
	case "INSIDE": {	
		// If nearby building possible then move to that building and spawn guards
		_building = [(((AOLocations select _AOIndex) select 2) select 7)] call sun_selectRemove;
		_buildingPlaces = [_building] call BIS_fnc_buildingPositions;
		_thisBuildingPlace = [0,((count _buildingPlaces)-1)] call BIS_fnc_randomInt;				
		_powPos = getPos _building;
		_group = [_powPos, playersSide, powClass, [], [1, 1], true, "NONE"] call dro_spawnGroupWeighted;
		_powChar = ((units _group) select 0);
		
		//_group = createGroup playersSide;
		//_powChar = _group createUnit [powClass, _powPos, [], 0, "NONE"];			
		_powChar setPosATL (_building buildingPos _thisBuildingPlace);	
	};		
};

if (_break) exitWith {
	[(AOLocations call BIS_fnc_randomIndex), false] call fnc_selectObjective;
};

_powChar setCaptive true;
_powChar removeWeaponGlobal (primaryWeapon _powChar);
_powChar removeWeaponGlobal (secondaryWeapon _powChar);
_powChar removeWeaponGlobal (handgunWeapon _powChar);
removeHeadgear _powChar;
removeGoggles _powChar;
removeAllItems _powChar;
{_powChar removeMagazine _x} forEach magazines _powChar;
//if (powClass == "C_journalist_F" OR powClass == "C_scientist_F") then {		
	removeVest _powChar;	
	removeBackpack _powChar;	
//};
[[_powChar], "sun_aiNudge"] call BIS_fnc_MP;	


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

diag_log format ["_travelPositions = %1", _travelPositions];

_spawnStationary = false;
if (count _travelPositions > 0) then {
	if (random 1 < 0.6) exitWith {
		_spawnStationary = true;
	};
	// TRAVELLING					
	_minAI = round (2 * aiMultiplier);
	_maxAI = round (3 * aiMultiplier);
	_guardGroup = [_powPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;
	_guardGroup2 = [_powPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;
	waitUntil {!isNil "_guardGroup"};	
	waitUntil {!isNil "_guardGroup2"};	
	_allGuards = (units _guardGroup) + (units _guardGroup2);
	[_powChar] join _guardGroup;					
	(units _guardGroup2) join _guardGroup;					
	
	// Initialise route waypoints
	_wpFirst = _guardGroup addWaypoint [_powPos, 0];
	_wpFirst setWaypointType "MOVE";
	_wpFirst setWaypointBehaviour "SAFE";
	_wpFirst setWaypointSpeed "LIMITED";			
	{
		_pos = if (typeName _x == "OBJECT") then {getPos _x} else {_x};
		_wp = _guardGroup addWaypoint [_pos, 50];
		_wp setWaypointType "MOVE";
		_wp setWaypointCompletionRadius 20;
		_wp setWaypointTimeout [20, 30, 45];
		if (_reconChance < baseReconChance) then {
			taskIntel pushBack [_taskName, _pos, _intelSubTaskName, "WAYPOINT"];
		};
	} forEach _travelPositions;
	_wpLast = _guardGroup addWaypoint [_powPos, 0];
	_wpLast setWaypointType "CYCLE";		
	_wpLast setWaypointCompletionRadius 20;
	_wpLast setWaypointTimeout [20, 30, 45];
	if (_reconChance < baseReconChance) then {
		taskIntel pushBack [_taskName, _powPos, _intelSubTaskName, "WAYPOINT"];
	};
	
	// Release trigger
	_trgRelease = createTrigger ["EmptyDetector", _powPos, true];
	_trgRelease setTriggerArea [0, 0, 0, false];
	_trgRelease setTriggerActivation ["ANY", "PRESENT", false];
	_trgRelease setTriggerStatements [
		"
			({alive _x} count (thisTrigger getVariable 'allGuards') == 0) OR
			(thisTrigger getVariable 'powChar') distance (leader (grpNetId call BIS_fnc_groupFromNetId)) < 20
		",
		"	
			[(thisTrigger getVariable 'powChar'), 'MOVE'] remoteExec ['enableAI', (thisTrigger getVariable 'powChar')];			
			[(thisTrigger getVariable 'powChar')] joinSilent (grpNetId call BIS_fnc_groupFromNetId);
			[(thisTrigger getVariable 'powChar')] call sun_addResetAction;
			[(thisTrigger getVariable 'powChar'), false] remoteExec ['setCaptive', (thisTrigger getVariable 'powChar'), true];
			[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
			'mkrAOC' setMarkerAlpha 1;				
		", 
		""];
	_trgRelease setVariable ["powChar", _powChar, true];		
	_trgRelease setVariable ["thisTask", _joinSubTaskName, true];
	_trgRelease setVariable ["allGuards", _allGuards, true];	
} else {
	_spawnStationary = true;
};

if (_spawnStationary) then {
	_powChar disableAI "MOVE";
	_powChar switchMove "Acts_AidlPsitMstpSsurWnonDnon_loop";
	_powChar setVariable["hostageBound", true, true];
	_powChar setVariable["hostageActionID", 0, true];
	_powChar setVariable["taskName", "", true];
	[
		_powChar,
		"Unbind Hostage",
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
		"(alive _target) && (_target getVariable['hostageBound', false]) && ((_this distance _target) < 3)",
		"true",
		{
			
		},
		{
			/*
			if ((_this select 4) % 3 == 0) then {
				_sound = selectRandom ["A3\Sounds_F_Characters\human-sfx\Other\medikit1.wss"];
				playSound3D [_sound, (_this select 1)];
			};
			*/
		},
		{
			[(_this select 0), (_this select 1)] call dro_hostageRelease;		
		},
		{},
		[],
		5,
		10,
		true,
		false
	] remoteExec ["bis_fnc_holdActionAdd", 0, true];	
	// Spawn patrolling guards
	_minAI = round (2 * aiMultiplier);
	_maxAI = round (3 * aiMultiplier);
	_spawnedSquad = [_powPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;						
	if (!isNil "_spawnedSquad") then {
		[_spawnedSquad, _powPos, [10, 30], "limited"] execVM "sunday_system\orders\patrolArea.sqf";	
	};
	_spawnedSquad2 = [_powPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;		
	if (!isNil "_spawnedSquad2") then {			
		[_spawnedSquad2, getPos _powChar] call bis_fnc_taskDefend;
	};
};

if (_break) exitWith {
	[(AOLocations call BIS_fnc_randomIndex), false] call fnc_selectObjective;
};

// Setup identity
_firstNameClass = (configFile >> "CfgWorlds" >> "GenericNames" >> pGenericNames >> "FirstNames");
_firstNames = [];
for "_i" from 0 to count _firstNameClass - 1 do {
	_firstNames pushBack (getText (_firstNameClass select _i));
};
_lastNameClass = (configFile >> "CfgWorlds" >> "GenericNames" >> pGenericNames >> "LastNames");
_lastNames = [];
for "_i" from 0 to count _lastNameClass - 1 do {
	_lastNames pushBack (getText (_lastNameClass select _i));
};
_firstName = "";
_lastName = "";
if ((count _firstNames > 0) && (count _lastNames > 0)) then {
	_firstName = (selectRandom _firstNames);
	_lastName = (selectRandom _lastNames);
	[_powChar, _firstName, _lastName, (speaker _powChar), (selectRandom pFacesArray)] remoteExec ["sun_setNameMP", 0, true];
};
if (random 1 > 0.5) then {
	removeUniform _powChar;	
	_powChar forceAddUniform (selectRandom ["U_IG_Guerilla3_1", "U_IG_Guerilla3_2"]);	
};
taskIntel pushBack [_taskName, uniform _powChar, _intelSubTaskName, "WEARABLE"];

// Marker
_markerName = format["powMkr%1", floor(random 10000)];
[_powChar, _taskName, _markerName, _intelSubTaskName, markerColorPlayers] execVM "sunday_system\objectives\followingMarker.sqf";

// Create Task		
_powName = ((configFile >> "CfgVehicles" >> powClass >> "displayName") call BIS_fnc_GetCfgData);
_taskTitle = format ["Captive: %1", _lastName];
_taskDesc = switch (powClass) do {
	case "C_scientist_F": {
		selectRandom [
			(format ["One of the science team behind an experimental %1 weapons project is being held in the area. It's possible that they have turned against %1 interests and command has ordered his capture and extraction for questioning.", enemyFactionName]),
			(format ["While performing routine checks on a military installation, one of our scientists, %1 %2, was taken captive by %3 and is being held somewhere in the AO.", _firstName, _lastName, enemyFactionName]),
			(format ["A civilian scientist named %1 %2 was abducted by %3 from his home a week ago. Intelligence sources in the region have pointed to him currently being moved through the area.", _firstName, _lastName, enemyFactionName])
		];
	};
	case "C_journalist_F": {
		selectRandom [
			(format ["A journalist, %1 %2, was abducted by %3 forces late last night. They are being held on invented charges and it is our belief that they face interrogation or execution if not quickly located.", _firstName, _lastName, enemyFactionName]),
			(format ["The current conflict has brought a number of war reporters to the region and one of them, %1 %2, has been detained by %3 forces. Threats against his life have been made and it is important that they do not become a focus for enemy propaganda.", _firstName, _lastName, enemyFactionName]),
			(format ["An incendiary article by %1 %2 has brought %3 him to %3 attention after they travelled to the %4 region against military advice. We believe that factions within the %3 command would like to use %2 as a propaganda device and command is intent on that not happening.", _firstName, _lastName, enemyFactionName, aoLocationName])
		];
	};
	default {
		selectRandom [
			(format ["Late last night a %1 by the name of %2 %3 disappeared from his post. It is unknown at this time whether they left voluntarily or were captured by %4 elements, but intelligence within the last hour places him in the %5 region.", _powName, _firstName, _lastName, enemyFactionName, aoLocationName]),
			(format ["After nearly a year in captivity we have new intelligence on the location of missing %1 %2 %3. He is being moved through the %5 area by %4, possibly for a handoff in the near future, so the timing of this mission is critical.", _powName, _firstName, _lastName, enemyFactionName, aoLocationName]),
			(format ["Command has word that there was a survivor from a recent recon team that were caught behind %4 lines. %1 %2 %3 is being held somewhere in the %5 area and today presents our first opportunity to retrieve him.", _powName, _firstName, _lastName, enemyFactionName, aoLocationName])
		];
	};
};
_taskType = "meet";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
_powChar setVariable["taskName", _taskName, true];
/*
{
	_joinSubTaskName = format ["blah%1", random 100000];
	_joinSubTaskDesc = "";
	_joinSubTaskTitle = configName _x;
	_subTasks pushBack [_joinSubTaskName, _joinSubTaskDesc, _joinSubTaskTitle, configName _x];	
} forEach ("true" configClasses (configFile / "CfgTaskTypes"));
*/
// Create join subtasks	
_joinSubTaskDesc = format ["Locate  and retrieve %1.", _lastName];
_joinSubTaskTitle = format ["Locate %1", _lastName];
_subTasks pushBack [_joinSubTaskName, _joinSubTaskDesc, _joinSubTaskTitle, "help"];
_powChar setVariable ["joinTask", _joinSubTaskName, true];
powJoinTasks pushBack _joinSubTaskName;

// Create extraction subtask
_extractSubtaskDesc = format ["Once %1 is under your control get him out of the AO.", _lastName];
_extractSubtaskTitle = format ["Extract %1", _lastName];
_subTasks pushBack [_extractSubTaskName, _extractSubtaskDesc, _extractSubtaskTitle, "exit"];
_powChar setVariable ["extractTask", _extractSubTaskName, true];

// Create intel subtasks	
_subTaskDesc = format ["Collect all intelligence on the target to narrow down your search. Intel may reduce the size of your search radius and locate any positions they're being moved through. Check the bodies of %1 team leaders, search marked intel locations and complete any intel tasks.", enemyFactionName];
_subTaskTitle = "Optional: Collect Intel";
_subTasks pushBack [_intelSubTaskName, _subTaskDesc, _subTaskTitle, "documents"];

// Add triggers
// Failure trigger
_trgFail = createTrigger ["EmptyDetector", _powPos, true];
_trgFail setTriggerArea [0, 0, 0, false];
_trgFail setTriggerActivation ["ANY", "PRESENT", false];
_trgFail setTriggerStatements [
	"
		!alive (thisTrigger getVariable 'powChar')
	",
	"				
		[(thisTrigger getVariable 'thisTask'), 'FAILED', true] spawn BIS_fnc_taskSetState;										
	", 
	""];
_trgFail setVariable ["powChar", _powChar, true];		
_trgFail setVariable ["thisTask", _taskName, true];

// Extract trigger
_trgExtract = [objNull, "mkrAOC"] call BIS_fnc_triggerToMarker;
_trgExtract setTriggerActivation ["ANY", "PRESENT", false];
_trgExtract setTriggerStatements [
	"
		(alive (thisTrigger getVariable 'powChar')) && 
		!(vehicle (thisTrigger getVariable 'powChar') in thisList) && 
		(thisTrigger getVariable 'powChar') in (units (grpNetId call BIS_fnc_groupFromNetId))
	",
	"				
		[(thisTrigger getVariable 'powChar')] joinSilent grpNull;
		(thisTrigger getVariable 'powChar') remoteExec ['removeAllActions', 0, true];
		(thisTrigger getVariable 'powChar') allowDamage true;
		[(thisTrigger getVariable 'thisSubtask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;		
		(thisTrigger getVariable 'markerName') setMarkerAlpha 0;
	", 
	""];
_trgExtract setVariable ["powChar", _powChar];		
_trgExtract setVariable ["thisSubtask", _extractSubTaskName];
_trgExtract setVariable ["markerName", _markerName];

// Listener for extraction task completion
[_taskName, _extractSubTaskName] spawn {
	waitUntil {playersReady == 1};
	waitUntil {sleep 2; [(_this select 1)] call BIS_fnc_taskCompleted};
	if (((_this select 1) call BIS_fnc_taskState) == "SUCCEEDED") then {
		[(_this select 0), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;	
		missionNamespace setVariable [format ["%1Completed", (_this select 0)], 1, true];	
	};
};

/*
_trgExecute = createTrigger ["EmptyDetector", _powPos, true];
_trgExecute setTriggerArea [200, 200, 0, false];
_trgExecute setTriggerActivation ["ANY", "PRESENT", false];
_trgExecute setTriggerStatements [
	"
		({alive _x} count (thisTrigger getVariable 'allGuards')) < ((count (thisTrigger getVariable 'allGuards')) * 0.2)
	",
	"				
		(thisTrigger getVariable 'pow') setCaptive false;				
	", 
	""];
_trgExecute setVariable ["allGuards", _allGuards];
_trgExecute setVariable ["pow", _powChar];
*/

sleep 0.5;

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_powPos,
	_reconChance,
	_subTasks,
	_powChar
];
publicVariable "taskIntel";
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];