params ["_AOIndex"];

_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelTaskName = format ["subtask%1", floor(random 100000)];
_subTaskName = format ["subtask%1", floor(random 100000)];

diag_log format["DRO: Task seeking a position in: %1", str (((AOLocations select _AOIndex) select 2) select 0)];

_thisPos = [(((AOLocations select _AOIndex) select 2) select 0)] call sun_selectRemove;
	
// Create disarm targets
_IEDPool = ["IEDLandBig_F", "IEDUrbanBig_F", "IEDLandSmall_F", "IEDUrbanSmall_F"];

// Create roadside IED
_road = ((_thisPos nearRoads 10) select 0);
_roadDir = ([_road] call sun_getRoadDir);
_IED = createMine [(selectRandom _IEDPool), (_thisPos getPos [4, _roadDir + (selectRandom [-90, 90])]), [], 0];
_IEDPos = (getPos _IED);

if (random 1 > 0.75) then {
	if (count civCarClasses > 0) then {	
		_class = (selectRandom civCarClasses);		
		_veh = createVehicle [_class, _IEDPos, [], 0, "CAN_COLLIDE"];		
		_veh setDir _roadDir;
	};
};

// Marker
_markerName = format["disarmMkr%1", floor(random 10000)];
[_IED, _taskName, _markerName, _intelTaskName, "ColorRed", 150, "Cross"] execVM "sunday_system\objectives\staticMarker.sqf";

// Random ambush
[_thisPos] spawn {
	params ["_thisPos"];
	waitUntil {sleep 10; (missionNameSpace getVariable ["playersReady", 0] == 1)};
	if (random 1 > 0.3) then {
		//_trgArea = [objNull, _markerName] call BIS_fnc_triggerToMarker;
		_trgArea = createTrigger ["EmptyDetector", _thisPos, true];
		_trgArea setTriggerArea [100, 100, 0, false];
		_trgArea setTriggerActivation ["ANY", "PRESENT", false];
		_trgArea setTriggerStatements ["(({(group _x) == (grpNetId call BIS_fnc_groupFromNetId)} count thisList) > 0)", "[thisTrigger] spawn {sleep (random[30, 45, 60]); [getPos (_this select 0)] call dro_triggerAmbushSpawn}", ""];		
	};
};

// Create task
_taskTitle = "Locate and Disarm";
_taskType = "mine";
_taskDesc = selectRandom [
	(format ["A recently captured bomb maker revealed that roadside IEDs are being used in the %2 region. We know at least one is present in the area and we need to ensure it is made safe to reduce the potential for friendly and civilian casualties.", enemyFactionName, aoLocationName]),
	(format ["%1 have been employing the use of roadside IEDs in the %2 region for some time and we need the area made safe to reduce the potential for friendly and civilian casualties.", enemyFactionName, aoLocationName])	
];
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

_trgIED = objNull;
_triggerMan = objNull;
if (hostileCivsEnabled) then {
	_attempts = 0;
	_scan = true;
	_spawnPos = [];	
	while {_scan} do {
		_scanPos = [_IEDPos, 15, 70, 1, 0, 1, 0] call BIS_fnc_findSafePos;		
		if ([objNull, "VIEW"] checkVisibility [_IEDPos, _scanPos] > 0.2) then { _spawnPos = _scanPos; _scan = false;};		
		if (_attempts > 100) then {_scan = false};
		_attempts = _attempts + 1;
	};
	if ((count _spawnPos) == 0) then {
		_spawnPos = [_IEDPos, 15, 70, 1, 0, 1, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;		
	};
	diag_log format ["DRO: IED triggerman spawnPos = %1", _spawnPos];
	if (count _spawnPos > 0 && !(_spawnPos isEqualTo [0,0,0])) then {	
		_civType = selectRandom civClasses;
		_group = createGroup civilian;
		_triggerMan = _group createUnit [_civType, _spawnPos, [], 0, "NONE"];			
		_triggerMan setVariable ["ISHOSTILE", true, true];
		
		_triggerMan setUnitPos "MIDDLE";
		//_triggerMan disableAI "PATH";
		_triggerMan commandWatch _IEDPos;
		_triggerMan allowFleeing 0;
		_triggerMan setVariable ["attachedIED", _IED, true];
		_triggerMan setVariable ["IEDTask", _subTaskName, true];
		[_triggerMan] execVM "sunday_system\civilians\hostileCivilians.sqf";
		_triggerMan addEventHandler ["killed", {diag_log ((_this select 0) getVariable 'IEDTask'); [((_this select 0) getVariable 'IEDTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;}];
		//_triggerMan setSkill ["courage", 1];
		
		// Create subtasks	
		_subTaskDesc = "Considering the hostility of the local population we expect that any IEDs will be live and operated by a triggerman. Search the area for anyone suspicious and neutralise them if you see hostile intent. They will probably be waiting somewhere with a line of sight on the IED.";
		_subTaskTitle = "Neutralise Triggerman";
		_subTasks pushBack [_subTaskName, _subTaskDesc, _subTaskTitle, "kill"];
				
		// Trigger
		/*		
		_trgIED = createTrigger ["EmptyDetector", _IEDPos, true];
		_trgIED setTriggerArea [10, 10, 0, false];
		_trgIED setTriggerActivation ["ANY", "PRESENT", false];
		_trgIED setTriggerStatements ["(({(group _x) == (thisTrigger getVariable 'DROgroupPlayers')} count thisList) > 0)", "hint 'BOOM!'; [(thisTrigger getVariable 'IED')] spawn {sleep (random[0, 2, 3]); (_this select 0) setDamage 1;}", ""];
		_trgIED setVariable ["DROgroupPlayers", (grpNetId call BIS_fnc_groupFromNetId)];
		_trgIED setVariable ["IED", _IED];
		*/
		
	};
};

// Completion trigger
[_IED, _taskName, _markerName, _trgIED, _triggerMan, _subTaskName] spawn {
	params ["_IED", "_taskName", "_markerName", "_trgIED", "_triggerMan", "_subTaskName"];
	/*
	if (!isNull _trgIED) then {
		while {sleep 1; mineActive _IED} do {		
			if (fleeing _triggerMan || !alive _triggerMan) exitWith {deleteVehicle _trgIED; [_subTaskName, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState; true};			
		};
	};
	*/
	waitUntil {sleep 5; !mineActive _IED};
	[_taskName, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
	missionNamespace setVariable [format ['%1Completed', _taskName], 1, true];
	_markerName setMarkerAlpha 0;	
};

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_thisPos,
	0,
	_subTasks,
	nil,
	0
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];