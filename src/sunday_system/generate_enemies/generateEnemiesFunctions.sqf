dro_unitTaskObjective = {
	params ["_thisTask"];
	[_thisTask] spawn {
		_thisTask = _this select 0;
		_taskName = format ["task%1", floor(random 100000)];
		missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
		_object = vehicle (leader (_thisTask select 0));
		_groupStrength = count (units (_thisTask select 0));	
		_groupVehicles = [];
		
		// Create trigger
		if (_object == (leader (_thisTask select 0))) then {
			// Trigger if leader is not inside a vehicle
			private _trgClear = createTrigger ["EmptyDetector", getPos _object, true];
			_trgClear setTriggerArea [50, 50, 0, false];
			_trgClear setTriggerActivation ["ANY", "PRESENT", false];
			_trgClear setTriggerStatements [
				"				
					(({alive _x} count (units (thisTrigger getVariable 'group'))) <= ((thisTrigger getVariable 'groupStrength') * 0.2))
				",
				"						
					[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
					missionNamespace setVariable [format ['%1Completed', (thisTrigger getVariable 'thisTask')], 1, true];
				", 
				""
			];				
			_trgClear setVariable ["group", (_thisTask select 0)];			
			_trgClear setVariable ["groupStrength", _groupStrength];			
			_trgClear setVariable ["thisTask", _taskName];	
		} else {
			// Trigger if leader is inside a vehicle
			
			{
				if (vehicle _x != _x) then {
					_groupVehicles pushBackUnique (vehicle _x);
				};
			} forEach (units (_thisTask select 0));
					
			private _trgClear = createTrigger ["EmptyDetector", getPos _object, true];
			_trgClear setTriggerArea [50, 50, 0, false];
			_trgClear setTriggerActivation ["ANY", "PRESENT", false];
			_trgClear setTriggerStatements [
				"				
					(({alive _x} count (thisTrigger getVariable 'groupVehicles')) == 0) OR (({(count (crew _x) > 0)} count (thisTrigger getVariable 'groupVehicles')) == 0)
				",
				"						
					[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
					missionNamespace setVariable [format ['%1Completed', (thisTrigger getVariable 'thisTask')], 1, true];
				", 
				""
			];				
			_trgClear setVariable ["groupVehicles", _groupVehicles];							
			_trgClear setVariable ["thisTask", _taskName];	
		};
		
		// Wait for target reveal
		waitUntil {
			sleep 5;
			(playersSide knowsAbout _object) > 2
		};	
		
		// Marker
		_markerName = format["taskMkr%1", floor(random 100000)];
		_markerTask = createMarker [_markerName, getPos _object];
		_markerTask setMarkerShape "ICON";	
		_markerTask setMarkerAlpha 0;	
		
		_taskTitle = format ["Optional: Eliminate %1", toLower (_thisTask select 1)];
		_taskDesc = format ["We have located a potential %1 target in the AO.", toLower (_thisTask select 1)];
		
		if (count _groupVehicles > 0) then {
			_vehicleStrings = [];
			{
				_vehicleStrings pushBack ((configFile >> "CfgVehicles" >> (typeOf _x) >> "displayName") call BIS_fnc_GetCfgData);
			} forEach _groupVehicles;
			switch (true) do {
				case ((_groupVehicles select 0) isKindOf "Helicopter"): {_taskTitle = format ["Eliminate helicopter%1", (if (count _groupVehicles > 1) then {"s"} else {""})]};
				case ((_groupVehicles select 0) isKindOf "Plane"): {_taskTitle = format ["Eliminate plane%1", (if (count _groupVehicles > 1) then {"s"} else {""})]};
				case ((_groupVehicles select 0) isKindOf "LandVehicle"): {_taskTitle = format ["Eliminate vehicle%1", (if (count _groupVehicles > 1) then {"s"} else {""})]};				
			};
			_taskDesc = format ["Eliminate the %1", ([_vehicleStrings] call sun_stringCommaList)];	
		};
		
		// Create task	

		_id = "";
		if ((missionNamespace getVariable (format ["%1Completed", _taskName])) == 0) then {
			_id = [_taskName, true, [_taskDesc, _taskTitle, _markerName], _object, "CREATED", 1, true, true, "target", true] call BIS_fnc_setTask;
		} else {
			_id = [_taskName, true, [_taskDesc, _taskTitle, _markerName], _object, "SUCCEEDED", 1, true, true, "target", true] call BIS_fnc_setTask;
		};		
		//taskIDs pushBack _id;
		//diag_log ["DCO: taskIDs is now: %1", taskIDs];		
	};
};

dro_triggerAmbushSpawn = {
	params ["_pos", ["_spawnPosOverride", []]];
	_return = grpNull;
	_spawnPos = [];
	if (count _spawnPosOverride == 0) then {	
		_attempts = 0;
		_scan = true;
		while {_scan} do {
			_thisPos = [_pos, 250, 450, 2, 0, 1, 0] call BIS_fnc_findSafePos;
			//_terrainBlocked = terrainIntersect [_pos, _spawnPos];
			//if (_terrainBlocked) then {_scan = false};
			if ([objNull, "VIEW"] checkVisibility [_pos, _thisPos] < 0.2) then { _spawnPos = _thisPos; _scan = false;};		
			if (_attempts > 200) then {_scan = false};
			_attempts = _attempts + 1;
		};
	} else {
		_spawnPos = _spawnPosOverride;
	};
	if (count _spawnPos > 0) then {
		_numInf = round (([2,4] call BIS_fnc_randomInt) * aiMultiplier);			
		_spawnedSquad = nil;	
		_minAI = (round ((4 * aiMultiplier) / (0.4 * _numInf)) min 6);
		_maxAI = (round ((6 * aiMultiplier) / (0.4 * _numInf)) min 8);
		_spawnedSquad = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI], false] call dro_spawnGroupWeighted;					
		waitUntil {!isNil "_spawnedSquad"};	
		_spawnedSquad setBehaviour "AWARE";
		_spawnedSquad setSpeedMode "FULL";
		{_x doMove (_pos getPos [10, (random 360)])} forEach (units _spawnedSquad);		
		/*
		_wpStart = _spawnedSquad addWaypoint[(getPos (leader _spawnedSquad)), 0];
		_wpStart setWaypointBehaviour "AWARE";	
		_wpStart setWaypointType "MOVE";
		_wpStart setWaypointSpeed "FULL";
		
		_wp1 = _spawnedSquad addWaypoint[_pos, 0];								
		_wp1 setWaypointType "MOVE";
		*/
		diag_log "DRO: Spawned ambush attack";
		_return = _spawnedSquad;
	} else {	
		diag_log "DRO: Could not find valid hidden spawn position";
	};
	_return
};

dro_localBuildingPatrol = {
	params [["_maxSpawns", 6]];
	_return = [];
	private _spawns = 0;
	{
		_thisBuildingCollection = _x;
		// Create patrol points	
		{
			if (!isNil "_maxSpawns") then {
				if (_spawns < _maxSpawns) then {
					_thisBuilding = _x;
					diag_log format ["_thisBuilding = %1", _thisBuilding];					
					_houseOuterPos = [(getPos _thisBuilding), 20, 50, 2, 0, 1, 0] call BIS_fnc_findSafePos;
					_garrisonGroup = [_houseOuterPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1, 2]] call dro_spawnGroupWeighted;	
					_spawnTime = time;
					waitUntil {(!isNil "_garrisonGroup") || (time >= (_spawnTime + 5))};					
					diag_log format ["_garrisonGroup = %1", _garrisonGroup];
					/*
					_garMarker = createMarker [format["garMkr%1", random 10000], _thisBuilding];
					_garMarker setMarkerShape "ICON";
					_garMarker setMarkerColor "ColorOrange";
					_garMarker setMarkerType "mil_dot";
					*/
					
					_patrol = random 1;							
					if (!isNil "_garrisonGroup") then {
						_spawns = _spawns + 1;
						_garrisonGroup setBehaviour "SAFE";
						
						deleteWaypoint [_garrisonGroup, currentWaypoint _garrisonGroup];
						
						[_garrisonGroup, 0] setWaypointBehaviour "SAFE";
						
						_wpStart = _garrisonGroup addWaypoint[(getPos (leader _garrisonGroup)), 0];
						_wpStart setWaypointBehaviour "AWARE";
						_wpStart setWaypointSpeed "LIMITED";
						_wpStart setWaypointType "MOVE";	
						
						if (_patrol > 0.65) then {
							{						
								_wpHouse = _garrisonGroup addWaypoint[(getPos _x), 10];						
								_wpHouse setWaypointType "MOVE";					
								
								_buildingPositions = [_x] call BIS_fnc_buildingPositions;
								
								_wpInt1 = _garrisonGroup addWaypoint[(selectRandom _buildingPositions), 0];	
								_wpInt1 setWaypointBehaviour "AWARE";						
								_wpInt1 setWaypointType "MOVE";
								_wpInt1 setWaypointTimeout [120, 125, 130];
								
								_wpInt2 = _garrisonGroup addWaypoint[(selectRandom _buildingPositions), 0];					
								_wpInt2 setWaypointType "MOVE";
								_wpInt1 setWaypointBehaviour "SAFE";
								//_wpInt2 setWaypointTimeout [120, 125, 130];
								
							} forEach _thisBuildingCollection;
											
							_wpCycle = _garrisonGroup addWaypoint[(getPos _x), 10];
							_wpCycle setWaypointBehaviour "SAFE";
							_wpCycle setWaypointType "CYCLE";	
						} else {					
							_wpHouse = _garrisonGroup addWaypoint[_thisBuilding, 10];						
							_wpHouse setWaypointType "MOVE";					
							
							_buildingPositions = [_thisBuilding] call BIS_fnc_buildingPositions;
							
							_wpInt1 = _garrisonGroup addWaypoint[(selectRandom _buildingPositions), 0];					
							_wpInt1 setWaypointType "MOVE";					
						};
														
						_return	pushBack _garrisonGroup;
					};
				};
			};
		} forEach _x;
	} forEach taskBuildings;
	_return
};

dro_spawnEnemyGarrison = {
	_thisBuilding = _this select 0;	
	/*
	_garMarker = createMarker [format["garMkr%1", random 10000], getPos _thisBuilding];
	_garMarker setMarkerShape "ICON";
	_garMarker setMarkerColor "ColorOrange";
	_garMarker setMarkerType "mil_dot";
	*/
	_buildingPositions = [_thisBuilding] call BIS_fnc_buildingPositions;	
	_totalGarrison = [0, ((count _buildingPositions) min 2)] call BIS_fnc_randomInt;
	
	_garrisonCounter = 0;
	_leader = nil;
	{
		if (_garrisonCounter <= _totalGarrison) then {
			_group = [_x, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;			
			if (!isNil "_group") then {
				_unit = ((units _group) select 0);
				_unit setUnitPos "UP";
				if (_garrisonCounter == 0) then {
					_leader = _unit;
				} else {
					[_unit] joinSilent _leader;
					//doStop _unit;
				};
			};
		};
		_garrisonCounter = _garrisonCounter + 1;
	} forEach _buildingPositions;
	
	if (!isNil "_leader") then {
		enemySemiAlertableGroups pushBack (group _leader);
	};
	enemyPosCollection pushBack (getPos _thisBuilding);
	group _leader	
};

