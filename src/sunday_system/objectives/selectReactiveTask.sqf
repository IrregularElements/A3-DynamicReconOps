diag_log format ["DRO: Reactive task called"];

_taskList = ["HVT", "VEHICLE"];
if (missionPreset == 2) then {_taskList = ["HVT"]};
_selectedTask = selectRandom _taskList;
diag_log format ["DRO: Reactive task %1 selected", _selectedTask];

_sizeSmall = ((triggerArea trgAOC) select 0) max ((triggerArea trgAOC) select 1);
_sizeLarge = _sizeSmall * 1.5;
_radioDesc = "";

switch (_selectedTask) do {
	case "HVT": {
		// Find start position
		_hvtSpawnPos = [centerPos, _sizeSmall, _sizeLarge, 2, 0, 0, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
		if (_hvtSpawnPos isEqualTo [0,0,0]) exitWith {
			diag_log "DRO: Reactive HVT position not available";
		};
		// Get HVT unit
		_hvtType = [];
		if (count eOfficerClasses > 0) then {
			_hvtType = selectRandom eOfficerClasses;
		} else {
			_hvtType = selectRandom eInfClasses;
		};	
		//_hvtChar = createVehicle [_hvtType, _hvtSpawnPos, [], 0, "FORM"];
		_hvtGroup = [_hvtSpawnPos, enemySide, [_hvtType]] call BIS_fnc_spawnGroup;
		_hvtChar = (units _hvtGroup) select 0;
		_leadSquad = [_hvtSpawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1, round (3 * aiMultiplier)], false] call dro_spawnGroupWeighted;
		_rearSquad = [_hvtSpawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [2, round (3 * aiMultiplier)], false] call dro_spawnGroupWeighted;
		
		(units _hvtGroup) joinSilent _leadSquad;
		(units _rearSquad) joinSilent _leadSquad;
				
		_wp0 = _leadSquad addWaypoint [_hvtSpawnPos, 0];
		_wp0 setWaypointBehaviour "AWARE";
		//_wp0 setWaypointCombatMode "GREEN";
		_wp0 setWaypointSpeed "NORMAL";
		
		_wp1 = _leadSquad addWaypoint [centerPos, 300];		
				
		_arrowMarkerName = format["reactMkr%1", floor(random 10000)];		
		_arrowMarker = createMarker [_arrowMarkerName, _hvtSpawnPos];
		_arrowMarker setMarkerShape "ICON";		
		_arrowMarker setMarkerType "mil_arrow2";
		_arrowMarker setMarkerSize [2,2];
		_arrowMarker setMarkerAlpha 0.5;
		_arrowMarker setMarkerColor markerColorEnemy;
		_arrowMarker setMarkerDir ([_hvtSpawnPos, centerPos] call BIS_fnc_dirTo);
					
		_hvtName = ((configFile >> "CfgVehicles" >> _hvtType >> "displayName") call BIS_fnc_GetCfgData);		
		_taskName = format ["task%1", floor(random 100000)];
		_taskDesc = format ["We have reports that a %1 %2 is entering the AO from the <marker name='%3'>marked direction</marker>. Eliminate him before you extract.", enemyFactionName, _hvtName, _arrowMarkerName];
		_taskTitle = "Eliminate HVT";
		_taskType = "target";
		_hvtChar setVariable ["thisTask", _taskName, true];		
		missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];		
		missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];
		
		_id = [_taskName, true, [_taskDesc, _taskTitle, ""], _hvtSpawnPos, "CREATED", 10, true, true, _taskType, true] call BIS_fnc_setTask;
		_reactiveMkrName = format ["mkr%1", floor(random 100000)];
		[_hvtChar, _id, _reactiveMkrName, nil, markerColorEnemy, 100] execVM "sunday_system\objectives\followingMarker.sqf";
		
		//[(group u1), _taskName, [_taskDesc, _taskTitle, ""], _hvtSpawnPos, "CREATED", 10, true, _taskType, false] call BIS_fnc_taskCreate;
		
		// Add killed event handler
		_hvtChar addEventHandler ["Killed", {[((_this select 0) getVariable ("thisTask")), "SUCCEEDED", true] spawn BIS_fnc_taskSetState; missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];}];		
		
		_radioDesc = format ["We have reports that a %1 %2 is entering the AO. Eliminate him before mission completion.", enemyFactionName, _hvtName];
		
		taskIDs pushBack _id;
		diag_log ["DRO: taskIDs is now: %1", taskIDs];
		[centerPos, _taskName] execVM "sunday_system\objectives\addTaskExtras.sqf";
	};
	case "VEHICLE": {
		if (count eCarClasses > 0) then {
			// Find start position
			_roads = centerPos nearRoads (aoSize/4);
			
			_allRoads = [];
			
			_rotDir = 0;
			for "_i" from 1 to 4 do {
				_rotPos = [centerPos, _sizeLarge, _rotDir] call dro_extendPos;
				_roads = _rotPos nearRoads 500;
				_allRoads = _allRoads + _roads;
				_rotDir = _rotDir + 90;
			};
			
			_vehSpawnPos = [];
			if (count _allRoads > 0) then {
				_vehSpawnPos = (getPos (selectRandom _allRoads));
			} else {		
				_vehSpawnPos = [centerPos, (aoSize*2), (aoSize*3), 2, 0, 0, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;				
			};		
			
			if (_vehSpawnPos isEqualTo [0,0,0]) exitWith {
				diag_log "DRO: Reactive vehicle position not available";
			};
			
			_vehicleType = selectRandom eCarClasses;
			_thisVeh = createVehicle [_vehicleType, _vehSpawnPos, [], 0, "NONE"];			
			[_thisVeh, enemySide, false] call sun_createVehicleCrew;
			//createVehicleCrew _thisVeh;
			
			_nearRoads = _thisVeh nearRoads 50;
			_dir = 0;
			if (count _nearRoads > 0) then {
				_firstRoad = _nearRoads select 0;
				if (count (roadsConnectedTo _firstRoad) > 0) then {			
					_connectedRoad = ((roadsConnectedTo _firstRoad) select 0);
					_dir = [_firstRoad, _connectedRoad] call BIS_fnc_dirTo;
					_thisVeh setDir _dir;
				} else {
					_thisVeh setDir (random 360);
				};
			};
			
			_wp0 = (group _thisVeh) addWaypoint [_vehSpawnPos, 0];
			_wp0 setWaypointBehaviour "SAFE";
			_wp0 setWaypointCombatMode "GREEN";
			_wp0 setWaypointSpeed "LIMITED";
			
			if (count (((AOLocations select 0) select 2) select 0) > 0) then {
				_wp1 = (group _thisVeh) addWaypoint [(selectRandom (((AOLocations select 0) select 2) select 0)), 0];	
			} else {		
				_wp1 = (group _thisVeh) addWaypoint [centerPos, 300];	
			};
			
			_arrowMarkerName = format["reactMkr%1", floor(random 100000)];		
			_arrowMarker = createMarker [_arrowMarkerName, _vehSpawnPos];
			_arrowMarker setMarkerShape "ICON";
			_arrowMarker setMarkerType "mil_arrow2_noShadow";
			_arrowMarker setMarkerSize [2,2];
			_arrowMarker setMarkerAlpha 0.5;
			_arrowMarker setMarkerColor markerColorEnemy;
			_arrowMarker setMarkerDir ([_vehSpawnPos, centerPos] call BIS_fnc_dirTo);
			
			_vehicleName = ((configFile >> "CfgVehicles" >> _vehicleType >> "displayName") call BIS_fnc_GetCfgData);		
			_taskName = format ["task%1", floor(random 100000)];
			_taskDesc = format ["We have reports that a %1 %2 is entering the AO from the <marker name='%3'>marked direction</marker>. The %2 is carrying important cargo and must be destroyed before extraction.", enemyFactionName, _vehicleName, _arrowMarkerName];
			_taskTitle = "Destroy vehicle";		
			_taskType = "destroy";			
			missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];
			_id = [_taskName, true, [_taskDesc, _taskTitle, ""], _vehSpawnPos, "CREATED", 10, true, true, _taskType, true] call BIS_fnc_setTask;
			
			[_thisVeh, _id, nil, nil, markerColorEnemy, 200] execVM "sunday_system\objectives\followingMarker.sqf";			
			
			//[(group u1), _taskName, [_taskDesc, _taskTitle, ""], _vehSpawnPos, "CREATED", 10, true, _taskType, false] call BIS_fnc_taskCreate;
			
			
			_thisVeh setVariable ["thisTask", _taskName, true];
			
			// Add destruction event handler
			_thisVeh addEventHandler ["Killed", {
				[((_this select 0) getVariable ("thisTask")), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
				missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
			} ];
			
			_radioDesc = format ["We have reports that a %1 %2 is entering the AO. The %2 is carrying important cargo and must be destroyed before the mission is complete.", enemyFactionName, _vehicleName];
			
			taskIDs pushBack _id;
			diag_log ["DRO: taskIDs is now: %1", taskIDs];
			[centerPos, _taskName] execVM "sunday_system\objectives\addTaskExtras.sqf";
		};
	};
};

sleep 5;
["REACTIVE_TASK", "Command", [_radioDesc]] spawn dro_sendProgressMessage;
