params ["_AOIndex"];
private ["_reconComplete"];

_taskPos = [];
_reconPossiblePositions =(((AOLocations select _AOIndex) select 2) select 7) + (((AOLocations select _AOIndex) select 2) select 6) + (((AOLocations select _AOIndex) select 2) select 4) + (((AOLocations select _AOIndex) select 2) select 0);
if (count _reconPossiblePositions > 0) then {
	_taskPos = selectRandom _reconPossiblePositions;
} else {
	_taskPos = [((AOLocations select _AOIndex) select 0), 0, (aoSize/3), 0, 1, 0.5, 0] call BIS_fnc_findSafePos;
};

_taskName = format ["task%1", floor(random 100000)];
_taskDesc = format ["Recon the area at grid %1 from a safe observation distance.", (mapGridPosition _taskPos)];
_taskTitle = "Observe";
_taskType = "scout";

_markerName = format["reconMkr%1", floor(random 10000)];		
_reconMarker = createMarker [_markerName, _taskPos];
_reconMarker setMarkerShape "ICON";
_reconMarker setMarkerAlpha 0;

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_taskPos,
	1
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];

_reconComplete = false;
missionNamespace setVariable [_taskName, 0, true];
while {!_reconComplete} do {
	sleep 5;
	{		
		_unit = _x;
		if (isPlayer _unit) then {			
			[_taskName, _taskPos] remoteExec ["dro_detectPosMP", _unit, false];			
		};
	} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
	
	if ((missionNamespace getVariable _taskName) >= 2) then {
		_reconComplete = true;		
		[_taskName, "SUCCEEDED", true] spawn BIS_fnc_taskSetState;		
	};
	
};

