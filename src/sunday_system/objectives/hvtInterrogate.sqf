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
_subTasks = [];

_hvtCodename = [hvtCodenames] call sun_selectRemove;
_taskName = format ["task%1", floor(random 100000)];
_captureSubTaskName = format ["subtask%1", floor(random 100000)];
_extractSubTaskName = format ["subtask%1", floor(random 100000)];
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
				_hvtGroup = [_hvtSpawnPos, enemySide, _hvtType, [], [1, 1], true, "NONE"] call dro_spawnGroupWeighted;
				_hvtChar = ((units _hvtGroup) select 0);
				//_hvtGroup = createGroup enemySide;
				//_hvtChar = _hvtGroup createUnit [_hvtType, _hvtSpawnPos, [], 0, "NONE"];
				if ([_hvtChar] call sun_checkIntersect) then {
					deleteVehicle _hvtChar;
					_hvtSpawnPos = _hvtPos findEmptyPosition [25, 50, _hvtType];
					//_hvtChar = _hvtGroup createUnit [_hvtType, _hvtSpawnPos, [], 0, "NONE"];
					_hvtGroup = [_hvtSpawnPos, enemySide, _hvtType, [], [1, 1], true, "NONE"] call dro_spawnGroupWeighted;
					_hvtChar = ((units _hvtGroup) select 0);
				};
				//_hvtChar = createVehicle [_hvtType, _hvtSpawnPos, [], 0, "NONE"];									
				
			};
			case "MEETINGS": {
				// Create HVT unit
				_hvtSpawnPos = _hvtPos findEmptyPosition [0, 15, _hvtType];
				_hvtGroup = [_hvtSpawnPos, enemySide, _hvtType, [], [1, 1], true, "NONE"] call dro_spawnGroupWeighted;
				_hvtChar = ((units _hvtGroup) select 0);
				//_hvtGroup = createGroup enemySide;
				//_hvtChar = _hvtGroup createUnit [_hvtType, _hvtSpawnPos, [], 0, "NONE"];
				//_hvtChar = createVehicle [_hvtType, _hvtSpawnPos, [], 0, "NONE"];				
				_hvtChar setPos _hvtPos;
			
				_civArray = ["C_man_p_beggar_F", "C_man_1", "C_man_polo_1_F", "C_man_polo_2_F", "C_man_polo_3_F", "C_man_polo_4_F", "C_man_polo_5_F", "C_man_polo_6_F", "C_man_shorts_1_F", "C_man_1_1_F", "C_man_1_2_F", "C_man_1_3_F", "C_man_w_worker_F"];				
				_objects = selectRandom compositionsMeetings;
				_spawnedObjects = [_hvtPos, (random 360), _objects] call BIS_fnc_ObjectsMapper;
				
				{
					if (typeOf _x == "Sign_Arrow_Blue_F") then {					
						deleteVehicle _x;							
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
						_spawnedCiv = createVehicle [_civType, _pos, [], 0, "CAN_COLLIDE"];						
						_spawnedCiv setFormDir _dir;
						_spawnedCiv setDir _dir;									
					};
				} forEach _spawnedObjects;						
			};
		};	
									
	};
	case "OUTSIDETRAVEL": {
		diag_log (((AOLocations select _AOIndex) select 2) select 2);
		_hvtPos = [(((AOLocations select _AOIndex) select 2) select 2)] call sun_selectRemove;
	
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
		if (count _travelPositions > 0) then {
			// TRAVELLING			
			_hvtGroup = [_hvtPos, enemySide, _hvtType, [], [1, 1], true, "NONE"] call dro_spawnGroupWeighted;
			_hvtChar = ((units _hvtGroup) select 0);
			//_hvtGroup = createGroup enemySide;
			//_hvtChar = _hvtGroup createUnit [_hvtType, _hvtPos, [], 0, "NONE"];
			if ([_hvtChar] call sun_checkIntersect) then {
				deleteVehicle _hvtChar;
				_hvtSpawnPos = _hvtPos findEmptyPosition [25, 50, _hvtType];
				_hvtChar = _hvtGroup createUnit [_hvtType, _hvtSpawnPos, [], 0, "NONE"];
			};
			_hvtChar setRank "MAJOR";
				
			
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
			_break = true;
		};
	};
};

if (_break) exitWith {[(AOLocations call BIS_fnc_randomIndex), false] call fnc_selectObjective};

// Create guards
_minAI = round (4 * aiMultiplier);
_maxAI = round (6 * aiMultiplier);
_guardGroup = [_hvtPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;
waitUntil {!isNil "_guardGroup"};
_hvtChar setVariable ["guards", (units _guardGroup), true];
(units _guardGroup) join (group _hvtChar);
_hvtChar setCaptive true;

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
removeAllWeapons _hvtChar;
if (random 1 > 0.3) then {
	_hvtChar addHeadgear (selectRandom ["H_Beret_red", "H_Hat_brown", "H_Hat_tan", "H_MilCap_blue", "H_MilCap_gry", "H_ShemagOpen_tan", "H_ShemagOpen_khk"]);
};
if (random 1 > 0.3) then {
	_hvtChar addGoggles (selectRandom ["G_Aviator", "G_Balaclava_blk", "G_Balaclava_oli", "G_Bandanna_blk", "G_Bandanna_khk", "G_Bandanna_shades", "G_Spectacles", "G_Squares_Tinted", "G_Spectacles_Tinted"]);
};

// Create Task
_hvtName = ((configFile >> "CfgVehicles" >> _hvtType >> "displayName") call BIS_fnc_GetCfgData);
_taskDescriptions = [
	(format ["We believe that the high value target codenamed '%1' is active somewhere in the AO. It is believed that he holds important information regarding the overall strategy of %3 forces in the region. Command wants him captured and brought back alive for further questioning.", _hvtCodename, toLower _hvtName, enemyFactionName])	
];

_taskDesc = (selectRandom _taskDescriptions);
_taskTitle = format ["HVT: %1", _hvtCodename];
_taskType = "help";
_hvtChar setVariable ["thisTask", _taskName];
_hvtChar setVariable ["markerName", _markerName];
_hvtChar setVariable ["codename", _hvtCodename];
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

// Create capture subtask
_captureSubtaskDesc = format ["Capture and interrogate the %1 %2 codenamed '%4'. Target is believed to be in the <marker name='%3'>marked area</marker>. Do not allow the target to be killed and eliminate his guards to force his surrender.", enemyFactionName, toLower _hvtName, _markerName, _hvtCodename];
_captureSubtaskTitle = format ["Capture %1", _hvtCodename];
_subTasks pushBack [_captureSubtaskName, _captureSubtaskDesc, _captureSubtaskTitle, "help"];
_hvtChar setVariable ["captureTask", _captureSubtaskName, true];
missionNamespace setVariable [(format ["%1_taskType", _captureSubtaskName]), "help", true];

// Create extract subtask
_extractSubtaskDesc = format ["Once under your control extract %1 from the AO for further questioning by our intelligence services.", toLower _hvtName, _markerName, _hvtCodename];
_extractSubtaskTitle = format ["Extract %1", _hvtCodename];
_subTasks pushBack [_extractSubTaskName, _extractSubtaskDesc, _extractSubtaskTitle, "exit"];
_hvtChar setVariable ["extractTask", _extractSubTaskName, true];
missionNamespace setVariable [(format ["%1_taskType", _extractSubTaskName]), "exit", true];

// Add killed event handler
_hvtChar addEventHandler ["Killed", {[((_this select 0) getVariable "thisTask"), "FAILED", true] spawn BIS_fnc_taskSetState; ((_this select 0) getVariable "markerName") setMarkerAlpha 0;}];		

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

if (dynamicSim == 0) then {
	_hvtChar enableDynamicSimulation true;
};

// Listen for surrender conditions
[_hvtChar] spawn {
	_hvtChar = (_this select 0);
	waitUntil {playersReady == 1};
	waitUntil {
		sleep 3;
		_return = false;
		{
			if ((_x distance _hvtChar) < 10) exitWith {_return = true};
		} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
		if ({alive _x} count (_hvtChar getVariable "guards") == 0) then {
			_return = true
		};
		_return
	};	
	removeAllWeapons _hvtChar;
	(leader (grpNetId call BIS_fnc_groupFromNetId)) action ["Surrender", _hvtChar];
};

[
	_hvtChar,
	"Capture",
	"\A3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa",
	"\A3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa",
	"(alive _target) && ((_this distance _target) < 3)",
	"((_this distance _target) < 3)",
	{},
	{},
	{		
		[(_this select 0) getVariable "captureTask", "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
		[(_this select 0), (_this select 2)] remoteExec ["bis_fnc_holdActionRemove", 0, true];
		[10, false, (_this select 1)] execVM "sunday_system\intel\revealIntel.sqf";
		(_this select 0) switchmove "";
		[(_this select 0)] joinSilent (grpNetId call BIS_fnc_groupFromNetId);
		[(_this select 0)] call sun_addResetAction;
		[(_this select 0) getVariable "extractTask", "ASSIGNED", true] spawn BIS_fnc_taskSetState;
		[(leader (grpNetId call BIS_fnc_groupFromNetId)), "heliExtract"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];
		'mkrAOC' setMarkerAlpha 1;
	},
	{},
	[],
	5,
	10,
	true,
	false
] remoteExec ["bis_fnc_holdActionAdd", 0, true];

// Extract trigger
_trgExtract = [objNull, "mkrAOC"] call BIS_fnc_triggerToMarker;
_trgExtract setTriggerActivation ["ANY", "PRESENT", false];
_trgExtract setTriggerStatements [
	"
		(alive (thisTrigger getVariable 'hvtChar')) && 
		!(vehicle (thisTrigger getVariable 'hvtChar') in thisList) && 
		(thisTrigger getVariable 'hvtChar') in (units (grpNetId call BIS_fnc_groupFromNetId))
	",
	"				
		[(thisTrigger getVariable 'hvtChar')] joinSilent grpNull;
		(thisTrigger getVariable 'hvtChar') remoteExec ['removeAllActions', 0, true];
		(thisTrigger getVariable 'hvtChar') allowDamage true;
		[(thisTrigger getVariable 'thisSubtask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;		
		[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;		
	", 
	""];
_trgExtract setVariable ["hvtChar", _hvtChar];		
_trgExtract setVariable ["thisSubtask", _extractSubTaskName];
_trgExtract setVariable ["thisTask", _taskName];

sleep 0.5;

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
