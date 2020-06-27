params ["_AOIndex"];

_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];

diag_log format["DRO: Task seeking a position in: %1", str (((AOLocations select _AOIndex) select 2) select 0)];

_styles = [];
if (count (((AOLocations select _AOIndex) select 2) select 0) > 0) then {
	_styles pushBack "ROAD";
};
if (count (((AOLocations select _AOIndex) select 2) select 2) > 0) then {
	_styles pushBack "GROUND";
};
_style = selectRandom _styles;

_thisPos = if (_style == "ROAD") then {
	[(((AOLocations select _AOIndex) select 2) select 0)] call sun_selectRemove;
} else {
	[(((AOLocations select _AOIndex) select 2) select 2)] call sun_selectRemove;	
};

// Create disarm targets
_UXOPool = ["BombCluster_03_UXO1_F", "BombCluster_02_UXO1_F", "BombCluster_01_UXO1_F", "BombCluster_03_UXO4_F", "BombCluster_02_UXO4_F", "BombCluster_01_UXO4_F", "BombCluster_03_UXO2_F", "BombCluster_02_UXO2_F", "BombCluster_01_UXO2_F", "BombCluster_03_UXO3_F", "BombCluster_02_UXO3_F", "BombCluster_01_UXO3_F"];
_disarmTargetsUXO = [];

// Create spread of ordnance
for "_i" from 0 to (floor (random [3, 6, 7])) do {
	_pos = [_thisPos, 10, 50, 0.5, 0, 1, 0] call BIS_fnc_findSafePos;
	if (count _pos > 0) then {
		_UXO = createMine [(selectRandom _UXOPool), _pos, [], 0];
		_disarmTargetsUXO pushBack _UXO;		
	};
};

UXOUsed = true;

// Get marker size
_avgPos = [_disarmTargetsUXO] call sun_avgPos;
_thisPos = _avgPos;

_minX = 9999999;
_maxX = 0;
_minY = 9999999;
_maxY = 0;
{
	_pos = getPos _x;
	_minX = (_pos select 0) min _minX;
	_maxX = (_pos select 0) max _maxX;
	_minY = (_pos select 1) min _minY;
	_maxY = (_pos select 1) max _maxY;
} forEach (_disarmTargetsUXO);

_boundX = _maxX - _minX;
_boundY = _maxY - _minY;

// Marker
_markerName = format["disarmMkr%1", floor(random 10000)];
_markerDisarm = createMarker [_markerName, _thisPos];			
_markerDisarm setMarkerShape "ELLIPSE";
_markerDisarm setMarkerBrush "Cross";
_markerDisarm setMarkerSize [_boundX, _boundY];
_markerDisarm setMarkerColor "ColorRed";		
_markerDisarm setMarkerAlpha 0.5;

// Random ambush
[_thisPos, _boundX, _boundY] spawn {
	params ["_thisPos", "_boundX", "_boundY"];
	waitUntil {sleep 10; (missionNameSpace getVariable ["playersReady", 0] == 1)};
	if (random 1 > 0.3) then {
		//_trgArea = [objNull, _markerName] call BIS_fnc_triggerToMarker;
		_trgArea = createTrigger ["EmptyDetector", _thisPos, true];
		_trgArea setTriggerArea [_boundX, _boundY, 0, false];
		_trgArea setTriggerActivation ["ANY", "PRESENT", false];
		_trgArea setTriggerStatements ["(({(group _x) == (grpNetId call BIS_fnc_groupFromNetId)} count thisList) > 0)", "[thisTrigger] spawn {sleep (random[30, 45, 60]); [getPos (_this select 0)] call dro_triggerAmbushSpawn}", ""];		
	};
};

// Create task
_taskTitle = "Locate and Disarm";
_taskType = "mine";
_taskDesc = selectRandom [
	(format ["The civilian population of %2 is living with the danger of unexploded ordnance from the %1 campaign. If we're going to win the support of the local populace and take the area ourselves we need to make it safe. Locate and make safe any ordnance you can find in the marked area.", enemyFactionName, aoLocationName]),
	(format ["Reports have come to us that there is unexploded ordnance in the %2 region. If we're going to win the support of the local populace and take the area ourselves we need to make it safe. Locate and make safe any ordnance you can find in the marked area.", enemyFactionName, aoLocationName])	
];
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

// Completion trigger
[_disarmTargetsUXO, _taskName, _markerName] spawn {
	_allOrd = (_this select 0);
	while {count _allOrd > 0} do {
		sleep 5;
		_removeList = [];
		{
			if (!mineActive _x) then {
				_removeList pushBack _x;
			};
		} forEach _allOrd;
		_allOrd = _allOrd - _removeList;
	};	
	[(_this select 1), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
	missionNamespace setVariable [format ['%1Completed', (_this select 1)], 1, true];
	(_this select 2) setMarkerAlpha 0;	
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
	0
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];