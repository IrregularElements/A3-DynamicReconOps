params ["_AOIndex"];

_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];

diag_log format["DRO: Task seeking a position in: %1", str (((AOLocations select _AOIndex) select 2) select 4)];

_thisPos = [(((AOLocations select _AOIndex) select 2) select 4)] call sun_selectRemove;

_grid = [_thisPos, 3, 3, 5.5] call sun_defineGrid;
_gridSorted = [(_grid select 0), (_grid select 3), (_grid select 6), (_grid select 7), (_grid select 8), (_grid select 5), (_grid select 2), (_grid select 1)];
_dirOut = 225;

_allBoxes = [];
_constructPool = [["Land_SandbagBarricade_01_F", "Land_SandbagBarricade_01_half_F", "Land_SandbagBarricade_01_F"], ["Land_SandbagBarricade_01_F", "Land_SandbagBarricade_01_half_F", "Land_SandbagBarricade_01_F"], ["Land_SandbagBarricade_01_F", "Land_SandbagBarricade_01_hole_F", "Land_SandbagBarricade_01_F"]];
{
	_thisGridPos = _x;
	_select = [];
	if (_forEachIndex == 0) then {		
		_select = ["Land_SandbagBarricade_01_F", "Land_Mil_WiredFence_Gate_F", "Land_SandbagBarricade_01_F"];
	} else {
		_select = selectRandom _constructPool;
	};
	_distShift = 0;
	if (_forEachIndex == 1 || _forEachIndex == 3 || _forEachIndex == 5 || _forEachIndex == 7) then {
		_distShift = 1.8;
	};
	_box = [_thisGridPos, _select, _dirOut, _distShift] call dro_addConstructPoint;
	_allBoxes pushBack _box;
	_dirOut = _dirOut - 45;
} forEach _gridSorted;

/*
{
	_x hideObjectGlobal true;
} forEach _allSpheres;
*/

// Marker
_markerName = format["fortifyMkr%1", floor(random 10000)];
_markerFortify = createMarker [_markerName, _thisPos];			
_markerFortify setMarkerShape "ICON";
_markerFortify setMarkerType "loc_Bunker";
_markerFortify setMarkerSize [2.5, 2.5];
_markerText = format ["OP %1", ([FOBNames] call sun_selectRemove)];
_markerFortify setMarkerText _markerText;
_markerFortify setMarkerColor markerColorPlayers;		
_markerFortify setMarkerAlpha 0;
	
_taskDesc = selectRandom [
	(format ["As we prepare to make a move into %2 you are tasked with constructing an operating post in the area. Move to the marked location and fortify it.", enemyFactionName, aoLocationName]),
	(format ["With increased %1 activity we can expect them to move into %2 at some point in the future. Fortify this location in preparation.", enemyFactionName, aoLocationName])	
];	

// Create task
_taskTitle = "Construct Fortifications";
_taskType = "use";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

// Completion trigger
[_allBoxes, _taskName, _markerName, _markerText] spawn {
	waitUntil {sleep 5; ({isNull _x} count (_this select 0)) == count (_this select 0)};
	[(_this select 1), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
	missionNamespace setVariable [format ['%1Completed', (_this select 1)], 1, true];
	(_this select 2) setMarkerAlpha 1;
	
	taskCreationInProgress = true;
	
	_allGroups = [];
	_messageSent = false;
	_defendTaskName = format ["task%1", floor(random 100000)];
	_defendTaskDesc = (format ["Hold and defend %2 from the attacking %1 force.", enemyFactionName, (_this select 3)]);
	_defendTaskTitle = "Defend";
	_defendTaskType = "defend";
	
	_spawnPos = [];		
	_attempts = 0;
	_scan = true;
	while {_scan} do {
		_thisPos = [(getMarkerPos (_this select 2)), 250, 450, 2, 0, 1, 0] call BIS_fnc_findSafePos;		
		if ([objNull, "VIEW"] checkVisibility [(getMarkerPos (_this select 2)), _thisPos] < 0.2) then {_spawnPos = _thisPos; _scan = false;};		
		if (_attempts > 200) then {_scan = false};
		_attempts = _attempts + 1;
	};	
	_spawnPos2 = [];
	if (count _spawnPos > 0) then {
		_dir = _spawnPos getDir (getMarkerPos (_this select 2));
		_thisPos2 = _spawnPos getPos [(random [50, 100, 75]), (selectRandom [_dir - 90, _dir + 90])];
		if ([objNull, "VIEW"] checkVisibility [(getMarkerPos (_this select 2)), _thisPos2] < 0.2) then {_spawnPos2 = _thisPos2; _scan = false;};
	};	
	
	for "_i" from 0 to ([2, 4] call BIS_fnc_randomInt) step 1 do {		
		_spawnGroup = if (count _spawnPos > 0) then {
			if (count _spawnPos2 > 0) then {
				[(getMarkerPos (_this select 2)), (selectRandom [_spawnPos, _spawnPos2])] call dro_triggerAmbushSpawn;
			} else {
				[(getMarkerPos (_this select 2)), _spawnPos] call dro_triggerAmbushSpawn;
			};			
		} else {		
			[(getMarkerPos (_this select 2))] call dro_triggerAmbushSpawn;		
		};
		if (!isNull _spawnGroup) then {
			_allGroups pushBack _spawnGroup;
			//_spawnGroup deleteGroupWhenEmpty false;
		};
		if (!_messageSent && !isNull _spawnGroup) then {
			_messageSent = true;
			["AMBUSHOP"] spawn dro_sendProgressMessage;									
			//_id = [_defendTaskName, true, [_defendTaskDesc, _defendTaskTitle, (_this select 2)], (getMarkerPos (_this select 2)), "CREATED", 1, false, true, _defendTaskType, true] call BIS_fnc_setTask;			
			[
				[
					_defendTaskName,
					_defendTaskDesc,
					_defendTaskTitle,
					(_this select 2),
					_defendTaskType,
					(getMarkerPos (_this select 2)),
					0,
					nil,
					nil,
					0
				],
				true,
				true,
				false,
				true
			] call sun_assignTask;
			taskCreationInProgress = false;
		};
		sleep 20;		
	};	
	
	if (count _allGroups > 0) then {
		waitUntil {
			sleep 5;
			[_allGroups] call sun_checkAllDeadFleeing
		};
	};
	[_defendTaskName, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
	
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
	nil,
	nil,
	3
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];