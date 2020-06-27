params ["_AOIndex"];

_taskStyles = ["SINGLE"];

/*
if (count (((AOLocations select _AOIndex) select 2) select 0) > 0 && reconPatrolUnused) then {
	_taskStyles pushBack "ROAD";
};
*/
_taskStyle = selectRandom _taskStyles;

//_taskStyle = "ROAD";
switch (_taskStyle) do {
	case "ROAD": {
		reconPatrolUnused = false;
		_break = false;
		_roadArray = [];
		_startRoad = roadAt (selectRandom (((AOLocations select _AOIndex) select 2) select 0));
		_connectedRoads = roadsConnectedTo _startRoad;	
		_roadChoice1 = nil;
		_roadChoice2 = nil;	

		switch (count _connectedRoads) do {
			case 0: {
				_roadChoice1 = nil;
				_roadChoice2 = nil;
			};
			case 1: {
				_roadChoice1 = (_connectedRoads select 0);
				_roadChoice2 = nil;
			};		
			default {
				_roadChoice1 = selectRandom _connectedRoads;
				_connectedRoads = _connectedRoads - [_roadChoice1];
				_roadChoice2 = selectRandom _connectedRoads;
			};
		};

		if (!isNil "_roadChoice1") then {

			_roadArray = [_roadChoice1];
			_lastRoad = _roadChoice1;
			for "_i" from 0 to 29 do {
				_connectedRoads = roadsConnectedTo _lastRoad;
				if (count _connectedRoads > 0) then {
					
					_filteredRoadArray = _connectedRoads;
					{
						if (_x in _roadArray) then {
							_filteredRoadArray = _filteredRoadArray - [_x];
						};
					} forEach _connectedRoads;
								
					if (count _filteredRoadArray == 0) exitWith {};				
					
					_thisRoad = selectRandom _filteredRoadArray;
					
					if (!(_thisRoad inArea [((AOLocations select _AOIndex) select 0), ((AOLocations select _AOIndex) select 1), ((AOLocations select _AOIndex) select 1), 0, true])) exitWith {};
					
					_roadArray pushBack _thisRoad;
					_lastRoad = _thisRoad;				
				};
			};
			
			if (count _roadArray < 15) then {
				if (!isNil "_roadChoice2") then {
					_roadArray = [_roadChoice2];
					_lastRoad = _roadChoice2;
					for "_i" from 0 to 29 do {
						_connectedRoads = roadsConnectedTo _lastRoad;
						if (count _connectedRoads > 0) then {
							
							_filteredRoadArray = _connectedRoads;
							{
								if (_x in _roadArray) then {
									_filteredRoadArray = _filteredRoadArray - [_x];
								};
							} forEach _connectedRoads;
										
							if (count _filteredRoadArray == 0) exitWith {};
							
							_thisRoad = selectRandom _filteredRoadArray;
							_roadArray pushBack _thisRoad;
							_lastRoad = _thisRoad;						
						};
					};
				} else {
					_break = true;
				};
			};
		};
		
		if (_break) exitWith {[(AOLocations call BIS_fnc_randomIndex)] call fnc_selectObjective};
		
		_roadPoints = [];
		_numPoints = [2,4] call BIS_fnc_randomInt;	
		_iterator = ((count _roadArray) / _numPoints);
		for "_n" from 0 to _numPoints do {		
			_roadPoints pushBack (getPos(_roadArray select (_n * _iterator)));		
		};
		if (count _roadPoints == 0) exitWith {[(AOLocations call BIS_fnc_randomIndex)] call fnc_selectObjective};
		_taskName = format ["task%1", floor(random 100000)];
		_taskDesc = format ["Perform recon patrol on route in %1 territory.", enemyFactionName];
		_taskTitle = "Recon Patrol";		
		_taskType = "walk";
		_taskPos = [_roadPoints] call sun_avgPos;
		if (_taskPos isEqualTo [0,0,0]) exitWith {[(AOLocations call BIS_fnc_randomIndex)] call fnc_selectObjective};
		missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];
		
		_markerName = format["reconMkr%1", floor(random 100000)];
		_markerRecon= createMarker [_markerName, _taskPos];
		_markerRecon setMarkerShape "ICON";		
		_markerRecon setMarkerAlpha 0;	
		
		//[(group u1), _taskName, [_taskDesc, _taskTitle, ""], _taskPos, "CREATED", 10, false, _taskType, false] call BIS_fnc_taskCreate;
		//_id = [_taskName, (group u1), [_taskDesc, _taskTitle, ""], _taskPos, "CREATED", 1, false, true, _taskType, true] call BIS_fnc_setTask;
		//taskIDs pushBack _id;
		//[_taskPos, _taskName] execVM "sunday_system\objectives\addTaskExtras.sqf";

		diag_log format ["DRO: Recon road _roadPoints: %1", _roadPoints];
		
		{
			_subTaskName = format ["task%1", floor(random 100000)];
			_subTaskDesc = format ["Patrol point %1", _forEachIndex+1];
			_subTaskTitle = format ["Point %1", _forEachIndex+1];	
			_subTaskType = format ["move%1",_forEachIndex+1];
			missionNamespace setVariable [(format ["%1_taskType", _subTaskType]), (format ["move%1",_forEachIndex+1]), true];
			[(grpNetId call BIS_fnc_groupFromNetId), [_subTaskName, _taskName], [_subTaskDesc, _subTaskTitle, ""], _x, "CREATED", 10, false, _subTaskType, false] call BIS_fnc_taskCreate;
			
			_trgPoint = createTrigger ["EmptyDetector", _x, true];
			_trgPoint setTriggerArea [20, 20, 0, true];
			_trgPoint setTriggerActivation ["ANY", "PRESENT", false];
			_trgPoint setTriggerStatements [
				"		
					({vehicle _x in thisList} count (units (grpNetId call BIS_fnc_groupFromNetId)) >= 1)
				",
				"
					[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;				
				",
				""
			];
			_trgPoint setVariable ['thisTask', _subTaskName, true];			
		} forEach _roadPoints;
				
		objData pushBack [
			_taskName,
			_taskDesc,
			_taskTitle,
			_markerName,
			_taskType,
			_taskPos,
			0
		];
		allObjectives pushBack _taskName;
		
		diag_log format ["DRO: Recon road subtasks: %1", ([_taskName] call BIS_fnc_taskChildren)];
		sleep 2;		
		waitUntil {({taskCompleted ([_x, leader(grpNetId call BIS_fnc_groupFromNetId)] call BIS_fnc_taskReal)} count ([_taskName] call BIS_fnc_taskChildren)) >= _numPoints};
		[_taskName, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
		
	};
	case "SINGLE": {
		_taskPos = [];
		_reconPossiblePositions = (((AOLocations select _AOIndex) select 2) select 7) + (((AOLocations select _AOIndex) select 2) select 6) + (((AOLocations select _AOIndex) select 2) select 4) + (((AOLocations select _AOIndex) select 2) select 0);
		if (count _reconPossiblePositions > 0) then {
			_taskPos = selectRandom _reconPossiblePositions;
		} else {
			_taskPos = [((AOLocations select _AOIndex) select 0), 0, (aoSize/3), 0, 1, 0.5, 0] call BIS_fnc_findSafePos;
		};

		_taskName = format ["task%1", floor(random 100000)];
		_taskDesc = format ["Travel to grid %1 and recon the area.", (mapGridPosition _taskPos)];
		_taskTitle = "Point Recon";
		_taskType = "move";
		
		_markerName = format["reconMkr%1", floor(random 100000)];
		_markerRecon= createMarker [_markerName, _taskPos];
		_markerRecon setMarkerShape "ICON";		
		_markerRecon setMarkerAlpha 0;
		
		//[(group u1), _taskName, [_taskDesc, _taskTitle, ""], _taskPos, "CREATED", 10, false, _taskType, false] call BIS_fnc_taskCreate;
		//_id = [_taskName, (group u1), [_taskDesc, _taskTitle, ""], _taskPos, "CREATED", 1, false, true, _taskType, true] call BIS_fnc_setTask;
		//taskIDs pushBack _id;
		//[_taskPos, _taskName] execVM "sunday_system\objectives\addTaskExtras.sqf";
		
		trgPoint = createTrigger ["EmptyDetector", _taskPos, true];
		trgPoint setTriggerArea [20, 20, 0, true];
		trgPoint setTriggerActivation ["ANY", "PRESENT", false];
		trgPoint setTriggerStatements [
			"		
				({vehicle _x in thisList} count (units(grpNetId call BIS_fnc_groupFromNetId)) >= 1)
			",
			"
				[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;				
			",
			""
		];
		trgPoint setVariable ['thisTask', _taskName, true];		
		
		allObjectives pushBack _taskName;
		
		objData pushBack [
			_taskName,
			_taskDesc,
			_taskTitle,
			_markerName,
			_taskType,
			_taskPos,
			0
		];
		diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
		diag_log format ["DRO: objData: %1", objData];
		diag_log format ["DRO: allObjectives is now %1", allObjectives];
		
	};

};

/*

*/