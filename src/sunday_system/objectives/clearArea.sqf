params ["_AOIndex"];

// Find suitable posision
_posArr = [];
_thisPos = [];


if (count (((AOLocations select _AOIndex) select 2) select 4) > 0) then {
	_posArr pushBack "AO_flatPositions";
};
if (count (((AOLocations select _AOIndex) select 2) select 6) > 0) then {
	_posArr pushBack "AO_forestPositions";
};
if (count (((AOLocations select _AOIndex) select 2) select 6) > 0) then {
	_posArr pushBack "AO_groundPosClose";
};

_posSelect = selectRandom _posArr;
switch (_posSelect) do {
	case "AO_flatPositions": {
		_thisPos = [(((AOLocations select _AOIndex) select 2) select 4)] call sun_selectRemove;
	};
	case "AO_forestPositions": {
		_thisPos = [(((AOLocations select _AOIndex) select 2) select 6)] call sun_selectRemove;
	};
	case "AO_groundPosClose": {
		_thisPos = [(((AOLocations select _AOIndex) select 2) select 2)] call sun_selectRemove;
	};
};

_tempPos = [(_thisPos select 0), (_thisPos select 1), 0];
_thisPos = _tempPos;	

// Create area marker
_markerName = format["areaMkr%1", floor(random 10000)];
_markerArea = createMarker [_markerName, _thisPos];
_markerArea setMarkerShape "ELLIPSE";
_markerArea setMarkerBrush "Solid";
_markerArea setMarkerColor markerColorEnemy;
_markerArea setMarkerSize [150, 150];
_markerArea setMarkerAlpha 0;
		
// Create guards
//_spawnPos = [_thisPos, 0, 100, 1, 0, 30, 0] call BIS_fnc_findSafePos;
for "_i" from 0 to 1 do {
	_minAI = round (2 * aiMultiplier);
	_maxAI = round (4 * aiMultiplier);
	_spawnedSquad = [_thisPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;				
	if (!isNil "_spawnedSquad") then {
		diag_log "spawned";
		[_spawnedSquad, _thisPos, [0, 120], "LIMITED"] execVM "sunday_system\orders\patrolArea.sqf";
		_dist = 10;
		while {([leader _spawnedSquad] call sun_checkIntersect) && (_dist < 100)} do {
			[_spawnedSquad, (_thisPos getPos [_dist, (random 360)])] call sun_moveGroup;
			_dist = _dist + 5;
		};
	};
};

// Create Task
_taskName = format ["task%1", floor(random 100000)];
_taskTitle = "Clear Area";
_taskDesc = format ["Clear <marker name='%1'>marked area</marker> held by %2 troops.", _markerName, enemyFactionName];
_taskType = "attack";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
	
// Create triggers
_trgAreaClear = createTrigger ["EmptyDetector", _thisPos, true];
_trgAreaClear setTriggerArea [150, 150, 0, false, 20];
_trgAreaClear setTriggerActivation ["ANY", "PRESENT", false];
_trgAreaClear setTriggerStatements [
	"
		(({(side _x == enemySide) && alive _x} count thisList) <= 0)
	",
	"				
		(thisTrigger getVariable 'markerName') setMarkerAlpha 0;
		[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
		missionNamespace setVariable [format ['%1Completed', (thisTrigger getVariable 'thisTask')], 1, true];		
	", 
	""];			
_trgAreaClear setTriggerTimeout [5, 8, 10, true];	
_trgAreaClear setVariable ["markerName", _markerName, true];	
_trgAreaClear setVariable ["thisTask", _taskName, true];	

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_thisPos,
	(random 1)
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];