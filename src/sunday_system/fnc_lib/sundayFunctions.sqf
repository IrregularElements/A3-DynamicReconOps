sun_extractIdentities = {
	params ["_baseClass", ["_side", civilian]];
	
	// Names
	_genericNames = ((configFile >> "CfgVehicles" >> _baseClass >> "genericNames") call BIS_fnc_GetCfgData);		
	_genericNames = if (isNil "_genericNames") then {"CivMen"} else {_genericNames};
	_firstNameClass = (configFile >> "CfgWorlds" >> "GenericNames" >> _genericNames >> "FirstNames");
	_firstNames = [];
	for "_i" from 0 to count _firstNameClass - 1 do {
		_firstNames pushBack (getText (_firstNameClass select _i));
	};
	_lastNameClass = (configFile >> "CfgWorlds" >> "GenericNames" >> _genericNames >> "LastNames");
	_lastNames = [];
	for "_i" from 0 to count _lastNameClass - 1 do {
		_lastNames pushBack (getText (_lastNameClass select _i));
	};
	
	// Voices
	_identityTypes = ((configFile >> "CfgVehicles" >> _baseClass >> "identityTypes") call BIS_fnc_GetCfgData);
	// Extract voice data
	_speakersArray = [];
	{
		_thisVoice = (configName _x);	
		_scopeVar = typeName ((configFile >> "CfgVoice" >> _thisVoice >> "scope") call BIS_fnc_GetCfgData);
		switch (_scopeVar) do {
			case "STRING": {
				if ( ((configFile >> "CfgVoice" >> _thisVoice >> "scope") call BIS_fnc_GetCfgData) == "public") then {		
					{
						if (typeName _x == "STRING") then {
							_thisVoiceID = _x;
							{
								if ([_x, _thisVoiceID, false] call BIS_fnc_inString) then {						
									_speakersArray pushBack _thisVoice;
								};
							} forEach _identityTypes;						
						};
					} forEach ((configFile >> "CfgVoice" >> _thisVoice >> "identityTypes") call BIS_fnc_GetCfgData);
				};	
			};		
			case "SCALAR": {
				if ( ((configFile >> "CfgVoice" >> _thisVoice >> "scope") call BIS_fnc_GetCfgData) == 2) then {		
					{			
						if (typeName _x == "STRING") then {
							_thisVoiceID = _x;
							{
								if ([_x, _thisVoiceID, false] call BIS_fnc_inString) then {						
									_speakersArray pushBack _thisVoice;
								};
							} forEach _identityTypes;
						};
					} forEach ((configFile >> "CfgVoice" >> _thisVoice >> "identityTypes") call BIS_fnc_GetCfgData);
				};	
			};		
		};	
	} forEach ("true" configClasses (configFile / "CfgVoice"));

	if (count _speakersArray == 0) then {	
		switch (_side) do {
			case west: {_speakersArray = ["Male01ENG", "Male02ENG", "Male03ENG", "Male04ENG", "Male05ENG", "Male06ENG", "Male07ENG", "Male08ENG", "Male10ENG", "Male11ENG", "Male12ENG", "Male01ENGB", "Male02ENGB", "Male03ENGB", "Male04ENGB", "Male05ENGB"]};
			case east: {_speakersArray = ["Male01PER", "Male02PER", "Male03PER"]};
			case resistance: {_speakersArray = ["Male01GRE", "Male02GRE", "Male03GRE", "Male04GRE", "Male05GRE", "Male06GRE"]};
			case civilian: {_speakersArray = ["Male01GRE", "Male02GRE", "Male03GRE", "Male04GRE", "Male05GRE", "Male06GRE"]};
		};	
	};
	
	// Faces	
	_faces = [];	
	{
		{		
			_thisFace = (configName _x);
			{
				_thisIDType = _x;
				{
					if ([_thisIDType, _x, false] call BIS_fnc_inString) then {						
						_faces pushBack _thisFace;
					};
				} forEach _identityTypes;				
			} forEach ((_x >> "identityTypes") call BIS_fnc_GetCfgData);
		} forEach ([(configFile >> "CfgFaces" >> (configName _x)), 0, false] call BIS_fnc_returnChildren);
	} forEach ("true" configClasses (configFile / "CfgFaces"));
	
	[_firstNames, _lastNames, _speakersArray, _faces]
};

sun_waypointCheck = {
	params ["_group", "_waypoints"];	
	_pos = getPos leader _group;
	sleep 30;
	if (alive leader _group) then {
		if (getPos leader _group distance _pos < 30) then {			
			while {(count (waypoints _group)) > 0} do {
				deleteWaypoint ((waypoints _group) select 0);
			};
			{
				_group addWaypoint [(_x select 0), (_x select 1)];
			} forEach _waypoints;
		};
	};
};

sun_loopSounds = {
	params ["_pos", "_type", "_condition"];
	_sounds = switch (_type) do {
		case "BASE_RADIO": {
			[
				["A3\Sounds_F\sfx\UI\uav\UAV_01.wss", 4],
				["A3\Sounds_F\sfx\UI\uav\UAV_02.wss", 10],
				["A3\Sounds_F\sfx\UI\uav\UAV_03.wss", 5],
				["A3\Sounds_F\sfx\UI\uav\UAV_04.wss", 7],
				["A3\Sounds_F\sfx\UI\uav\UAV_05.wss", 7],
				["A3\Sounds_F\sfx\UI\uav\UAV_06.wss", 17],
				["A3\Sounds_F\sfx\UI\uav\UAV_07.wss", 10],
				["A3\Sounds_F\sfx\UI\uav\UAV_08.wss", 1],
				["A3\Sounds_F\sfx\UI\uav\UAV_09.wss", 1]
			]
		};
	};
	while {({(_x distance _pos) < 100} count units (grpNetId call BIS_fnc_groupFromNetId)) > 0} do {
		//sleep 3;
		_thisSound = (selectRandom _sounds);
		playSound3D [(_thisSound select 0), _pos, false, (getPosASL _pos), 2, (random [0.8, 1, 1]), 0];
		sleep (_thisSound select 1);
	};
};

sun_briefingJIP = {
	params ["_briefingString"];	
	player createDiaryRecord ["Diary", ["Briefing", _briefingString]];
};
sun_checkAllDeadFleeing = {
	params ["_checkGroups"];
	_return = false;
	_removeGroups = [];
	{
		_keepGroup = false;
		{
			if (!fleeing _x && alive _x) then {
				_keepGroup = true;
			};
		} forEach (units _x);
		if (!_keepGroup) then {
			_removeGroups pushBack _forEachIndex;
		};
	} forEach _checkGroups;
	{_checkGroups deleteAt _x} forEach _removeGroups;
	if (count _checkGroups == 0) then {_return = true};
	_return
};

sun_getCfgSide = {
	params ["_sideValue"];
	private _return = west;	
	if (typeName _sideValue == "TEXT") then {
		if ((["west", _sideValue, false] call BIS_fnc_inString)) then {
			_sideValue = 1;
		};
		if ((["east", _sideValue, false] call BIS_fnc_inString)) then {
			_sideValue = 0;
		};
		if ((["guer", _sideValue, false] call BIS_fnc_inString) || (["ind", _sideValue, false] call BIS_fnc_inString)) then {
			_sideValue = 2;
		};
	};			
	if (typeName _sideValue == "SCALAR") then {
		if (_sideValue <= 3 && _sideValue > -1) then {
			switch (_sideValue) do {
				case 0: {_return = east};
				case 1: {_return = west};
				case 2: {_return = resistance};
				case 3: {_return = civilian};
			};
		};	
	};	
	_return
};

sun_getCfgUnitSide = {
	params ["_configName"];
	private _return = west;
	_sideNum = (((configFile >> "CfgVehicles" >> _configName >> "side")) call BIS_fnc_GetCfgData);
	if (!isNil "_sideNum") then {
		if (typeName _sideNum == "TEXT") then {
			if ((["west", _sideNum, false] call BIS_fnc_inString)) then {
				_sideNum = 1;
			};
			if ((["east", _sideNum, false] call BIS_fnc_inString)) then {
				_sideNum = 0;
			};
			if ((["guer", _sideNum, false] call BIS_fnc_inString) || (["ind", _sideNum, false] call BIS_fnc_inString)) then {
				_sideNum = 2;
			};
		};			
		if (typeName _sideNum == "SCALAR") then {
			if (_sideNum <= 3 && _sideNum > -1) then {
				switch (_sideNum) do {
					case 0: {_return = east};
					case 1: {_return = west};
					case 2: {_return = resistance};
					case 3: {_return = civilian};
				};
			};	
		};
	};
	_return
};

sun_findWallPositions = {
	params ["_building"];
	_buildingDir = getDir _building;
	private _posArr = [];
	private _return = [];
	for "_i" from 0 to 270 step 90 do {
		_thisPos = ([getPos _building, 20, _buildingDir+_i] call BIS_fnc_relPos);	
		_posArr pushBack [_thisPos, _i];	
	};
	{
		_thisPos = (_x select 0);
		_thisDir = (_x select 1);
		_thisPos set [2, 1.5];
		_buildingPos = getPos _building;
		_buildingPos set [2, 1.5];
		_intersects = lineIntersectsSurfaces [
			AGLToASL _thisPos,
			AGLToASL _buildingPos,
			objNull,
			objNull,
			true,
			1,
			"GEOM"
		];		
		{
			if ((_x select 2) == _building) then {
				_return pushBack [(ASLToAGL (_x select 0)), _thisDir];
			};
		} forEach _intersects; 
	} forEach _posArr;	
	_return
};

sun_checkIntersect = {
	params ["_subject", ["_blacklist", objNull]];
	private _object = objNull;
	lineIntersectsSurfaces [ 
		getPosWorld _subject,  
		getPosWorld _subject vectorAdd [0, 0, 20],  
		_subject, _blacklist, true, 1, 'GEOM', 'NONE' 
	] select 0 params ['','','','_object'];
	_return = false;
	if (!isNull _object) then {
		if (_object isKindOf 'House') then {		
			_return = true;
		};
	};
	_return
};

sun_getRoadDir = {
	params ["_road", "_roadsConnectedTo", "_connectedRoad", "_dir"];
	if (_road isEqualType []) then {
		_road = ((_road nearRoads 10) select 0);
	};
	_roadsConnectedTo = roadsConnectedTo _road;
	_dir = if (count _roadsConnectedTo > 0) then {
		_connectedRoad = _roadsConnectedTo select 0;
		[_road, _connectedRoad] call BIS_fnc_DirTo
	} else {
		(random 360)
	};
	_dir
};

sun_findRoadRoute = {
	params ["_startRoad", "_maxRoads"];	
	private _roadArray = [_startRoad];
	_connectedRoads = roadsConnectedTo _startRoad;	
	_roadChoice1 = nil;	

	// Get initial connected road, selecting randomly if there are more than one
	switch (count _connectedRoads) do {
		case 0: {
			_roadChoice1 = nil;			
		};
		case 1: {
			_roadChoice1 = (_connectedRoads select 0);			
		};		
		default {
			_roadChoice1 = selectRandom _connectedRoads;					
		};
	};	
	
	if (!isNil "_roadChoice1") then {
		// Add the second connected road and start searching for the next		
		_roadArray pushBack _roadChoice1;
		_lastRoad = _roadChoice1;
		for "_i" from 1 to (_maxRoads-1) step 1 do {
			// Check for new connected roads
			_connectedRoads = roadsConnectedTo _lastRoad;
			if (count _connectedRoads > 0) then {
				// Filter out any roads that have been used already
				_filteredRoadArray = _connectedRoads;
				{
					if (_x in _roadArray) then {
						_filteredRoadArray = _filteredRoadArray - [_x];
					};
				} forEach _connectedRoads;
				// If no new roads are found then exit loop
				if (count _filteredRoadArray == 0) exitWith {};				
				// Add new road to the array and use it to start the next loop
				_thisRoad = selectRandom _filteredRoadArray;								
				_roadArray pushBack _thisRoad;
				_lastRoad = _thisRoad;				
			};
		};
	};
	_roadArray
};

sun_createVehicleCrew = {
	params ["_vehicle", ["_side", enemySide], ["_enableDynSim", true]];
	createVehicleCrew _vehicle;	
	private _group = createGroup _side;
	(crew _vehicle) joinSilent _group;
	if (dynamicSim == 0 && _enableDynSim) then {
		_group enableDynamicSimulation true;
	};
};

sun_getTrueCargo = {	
	private _allTurrets = ([(_this select 0)] call BIS_fnc_getTurrets);	
	private _cargoTurretCount = {([_x >> "isPersonTurret"] call BIS_fnc_getCfgData) == 1} count _allTurrets;
	diag_log format ["sun_getTrueCargo: %1 = %2", (_this select 0), _cargoTurretCount];
	(_cargoTurretCount + ((configFile >> "CfgVehicles" >> (_this select 0) >> "transportSoldier") call BIS_fnc_GetCfgData))
};

sun_checkVehicleSpawn = {
	params [["_vehicle", objNull]];
	if (!isNull _vehicle) then {		
		if (!alive _vehicle) then {
			_thisPos = (getPos _vehicle) findEmptyPosition [15, 200, _vehicleType];
			if (count _thisPos > 0) then {
				_vehicle = _vehicleType createVehicle _thisPos;
			} else {
				_vehicle = objNull;
			};	
		};
	};
	_vehicle
};

sun_stringCommaList = {
	params ["_strings"];
	_stringsCommas = "";	
	_stringsLast = "";
	if (count _strings > 1) then {
		_stringsLast = _strings call BIS_fnc_arrayPop;
		_stringsCommas = _strings joinString ", ";		
	} else {
		_stringsCommas = _strings select 0;
	};
	_stringsFull = if (count _stringsLast > 0) then {
		format ["%1 and %2", _stringsCommas, _stringsLast];
	} else {
		_stringsCommas
	};
	_stringsFull
};

sun_helicopterCanFly = {
	params ["_heli", "_return"];
	_return = true;
	
	if (alive _heli && alive (driver _heli)) then {
		_damageTypes = [
			["HitEngine",0.4],
			["HitHRotor",0.5],
			["HitVRotor",0.5],
			["HitTransmission",1.0],
			["HitHydraulics",0.9]
		];		
		{
			if (_heli getHitPointDamage (_x select 0) > (_x select 1)) exitWith {
				_return = false;
			};			
		} forEach _damageTypes;		  
	} else {
		_return = false;
	};
	_return
};

sun_checkRouteWater = {
	params ["_startPos", "_endPos", ["_returnLastLand", false]];
	_dir = _startPos getDir _endPos;
	_checkPos = _startPos;
	_landPos = [];											
	_lastPos = [];
	_lastPosIsWater = false;
	_break = false;
	_return = false;
	while {(_startPos distance _checkPos) < (_startPos distance _endPos)} do {				
		_checkPos = _checkPos getPos [50, _dir];			
		if (surfaceIsWater _checkPos) then {
			if (_lastPosIsWater) then {
				_break = true;
				if (_returnLastLand) then {
					_return = _lastPos;
				} else {
					_return = true;
				};
			} else {
				_lastPosIsWater = true;
			};			
		} else {
			_lastPosIsWater = false;
		};
		if (_break) exitWith {};
		_lastPos = _checkPos;
	};
	_return
};

sun_assignTask = {
	params ["_taskData", ["_pushToArray", true], ["_addExtras", true], ["_hideMarker", false], ["_notify", false]];	
	private _taskName = _taskData select 0;
	private _taskDesc = _taskData select 1;
	private _taskTitle = _taskData select 2;
	private _markerName = _taskData select 3;
	private _taskType = _taskData select 4;
	private _taskPos = _taskData select 5;
	private _reconChance = _taskData select 6;	
	private _subTasks = if (count _taskData > 7) then {_taskData select 7};	
	private _extraData = if (count _taskData > 8) then {_taskData select 8};	
	private _reinfType = if (count _taskData > 9) then {_taskData select 9} else {1};
	
	diag_log format["DRO: Task %1 all data:", _taskName];
	{		
		if (isNil '_x') then {
			diag_log format["      nil", -1];
		} else {
			diag_log format["      %1", _x];
		};
	} forEach _taskData;
	
	_createType = "CREATED";
	_completed = (missionNamespace getVariable [(format ["%1Completed", _taskName]), 0]);
	if (_completed == 1) then {
		_createType = "SUCCEEDED";
	};	
	// Create task from task data
	diag_log "DRO: Assigning regular task";
	_markerPos = getMarkerPos _markerName;		
	_markerPos set [2,0];
	diag_log format ["DRO: Task %1 _markerPos = %2", _taskName, _markerPos];
	_id = [_taskName, true, [_taskDesc, _taskTitle, _markerName], _markerPos, _createType, 1, _notify, true, _taskType, true] call BIS_fnc_setTask;
	diag_log format ["DRO: Assigned task %1: %2", _taskName, _taskTitle];
	if (_pushToArray) then {
		taskIDs pushBackUnique _id;
		diag_log ["DRO: taskIDs is now: %1", taskIDs];
	};	
	if (_addExtras) then {		
		[_taskPos, _taskName, _reinfType] execVM "sunday_system\objectives\addTaskExtras.sqf";				
	};
	if (_hideMarker) then {
		_markerName setMarkerAlpha 0;
		_markerName setMarkerSize [1, 1];
	} else {
		if (markerShape _markerName == "ICON") then {} else {_markerName setMarkerAlpha 0.5};
	};	
	if (!isNil "_subTasks") then {		
		diag_log format ["DRO: Task %1 subTasks = %2", _taskName, _subTasks];
		if (count _subTasks > 0) then {
			{
				_subTaskName = _x select 0;
				_subTaskDesc = _x select 1;
				_subTaskTitle = _x select 2;
				_subTaskType = _x select 3;
				_id = [[_subTaskName, _taskName], true, [_subTaskDesc, _subTaskTitle, _markerName], objNull, "CREATED", 1, false, true, _subTaskType, true] call BIS_fnc_setTask;
			} forEach _subTasks;	
		};		
	};
	if (_reconChance >= baseReconChance) then {
		if (!isNil "_extraData") then {
			[_taskName, _extraData] call BIS_fnc_taskSetDestination;
		};
	};
	
};

sun_setPlayerGroup = {
	params ["_newPos"];
	_newGroup = createGroup playersSide;
	units (grpNetId call BIS_fnc_groupFromNetId) joinSilent _newGroup;
	grpNetId = _newGroup call BIS_fnc_netId;
	publicVariable "grpNetId";
	{
		_x setPos _newPos;
		_x enableAI "ALL";
		[_x, false] remoteExec ["setCaptive", _x, true];		
	} forEach units (grpNetId call BIS_fnc_groupFromNetId);
	
	newUnitsReady = true;
	publicVariable "newUnitsReady";
	diag_log grpNetId;
};

sun_newUnit = {
	params ["_oldUnit", "_newPos"];	
	diag_log format ["DRO: Changing unit %1", _oldUnit];
	private _loadout = getUnitLoadout _oldUnit;
	private _face = face _oldUnit;
	private _speaker = speaker _oldUnit;
	private _class = _oldUnit getVariable ["unitClass", ""];
	private _identity = (_oldUnit getVariable ["respawnIdentity", []]);	
	if (count _class == 0) then {
		_class = ((selectRandom unitList) select 0);
	};	
	private _tempGroup = createGroup playersSide;
	private _newUnit = _tempGroup createUnit [_class, _newPos, [], 0, "NONE"];
	setPlayable _newUnit;
	addSwitchableUnit _newUnit;	
	if (isPlayer _oldUnit) then {
		 _newUnit remoteExec ["selectPlayer", _oldUnit];
	};	
	private _varName = format ["u%1", ((vehicleVarName _oldUnit) select [1])];
	diag_log format ["DRO: New unit %1 created for %2 with class %3", _newUnit, _oldUnit, _class];
	deleteVehicle _oldUnit;
	diag_log format ["DRO: Setting new unit %1 to var %2", _newUnit, _varName];
	[_newUnit, _varName] remoteExec ["setVehicleVarName", 0, true];
	missionNamespace setVariable [_varName, _newUnit, true];
	waitUntil {
		diag_log format ["DRO: Waiting for %1", (missionNamespace getVariable _varName)];
		!isNull (missionNamespace getVariable _varName)
	};
	
	_newUnit setUnitLoadout _loadout;	
	if (count _identity > 0) then {
		_newUnit setVariable ["respawnIdentity", [_newUnit,  _identity select 1, _identity select 2, _speaker, _face], true];
		[_newUnit, _identity select 1, _identity select 2, _speaker, _face] remoteExec ["sun_setNameMP", 0, true];		
	};
	//diag_log _newGroup;
	sun_newUnitArray pushBack _newUnit;
	publicVariable "sun_newUnitArray";
	//[_newUnit] joinSilent _newGroup;
	
	_newUnit setVariable ["respawnLoadout", (getUnitLoadout _newUnit), true];
	_newUnit setVariable ["respawnPWeapon", [(primaryWeapon  _newUnit), primaryWeaponItems _newUnit], true];	
	_newUnit setUnitTrait ["Medic", true];
	_newUnit setUnitTrait ["engineer", true];
	_newUnit setUnitTrait ["explosiveSpecialist", true];
	_newUnit setUnitTrait ["UAVHacker", true];		
};

sun_newUnits = {
	params ["_newPos"];
	
	sun_newUnitArray = [];
	publicVariable "sun_newUnitArray";
	{		
		//diag_log _x;	
		[_x, _newPos] remoteExec ["sun_newUnit", _x, true];	
		waitUntil {
			//diag_log format ["DRO: units in sun_newUnitArray = %1, _forEachIndex+1 = %2", (count sun_newUnitArray), (_forEachIndex + 1)];
			((count sun_newUnitArray) >= (_forEachIndex + 1))
		};
	} forEach units (grpNetId call BIS_fnc_groupFromNetId);	
	//diag_log format ["DRO: units _newGroup = %1", (units _newGroup)];
	{
		//diag_log format ["DRO: this vehicleVarName = %1", (vehicleVarName _x)];
		waitUntil {
			//diag_log format ["DRO: this vehicleVarName = %1", (vehicleVarName _x)];
			((vehicleVarName _x) select [0,1]) == "u";
		};
		diag_log format ["DRO: this vehicleVarName after wait = %1", (vehicleVarName _x)];
	} forEach sun_newUnitArray;
	private _newGroup = createGroup playersSide;
	{
		[_x] joinSilent _newGroup;
	} forEach sun_newUnitArray;
	grpNetId = _newGroup call BIS_fnc_netId;
	diag_log format ["DRO: New group %3 with netID %1 containing %2", grpNetId, units (grpNetId call BIS_fnc_groupFromNetId), _newGroup];	
	publicVariable "grpNetId";
	newUnitsReady = true;
	publicVariable "newUnitsReady";	
	
	// Keep grpNetId variable assigned to player group if C2 is present
	if (isClass (configFile >> "CfgPatches" >> "C2_Core")) then {
		[] spawn {	
			while {true} do {
				if (isNil "grpNetId") then {
					grpNetId = (group(([] call BIS_fnc_listPlayers) select 0)) call BIS_fnc_netId;
					publicVariable "grpNetId";
				} else {			
					if (isNull (grpNetId call BIS_fnc_groupFromNetId)) then {
						grpNetId = (group(([] call BIS_fnc_listPlayers) select 0)) call BIS_fnc_netId;
						publicVariable "grpNetId";
					};			
				};
			};
		};
	};
	
};

sun_jipNewUnit = {
params ["_oldUnit", "_newPos"];	
	
	private _class = player getVariable ["unitClass", ""];
	if (count _class == 0) then {
		_class = ((selectRandom unitList) select 0);
	};	
	player setVariable ['unitClass', _class, true];	
	player setUnitLoadout (getUnitLoadout _class);		
	
	_playerID = parseNumber ((str player) select [1, 1]);	
	_identity = (nameLookup select _playerID);	
	player setVariable ["respawnIdentity", [player,  _identity select 0, _identity select 1, _identity select 2, _identity select 3], true];
	[player, _identity select 0, _identity select 1, _identity select 2, _identity select 3] remoteExec ["sun_setNameMP", 0, true];		
	
	
	/*
	private _newUnit = _newGroup createUnit [_class, _newPos, [], 0, "NONE"];
	setPlayable _newUnit;
	addSwitchableUnit _newUnit;	
	selectPlayer _newUnit;	
	private _varName = format ["u%1", ((vehicleVarName _oldUnit) select [1,1])];
	[_newUnit, _varName] remoteExec ["setVehicleVarName", 0, true];
	missionNamespace setVariable [_varName, _newUnit, true];
	waitUntil {!isNull (missionNamespace getVariable _varName)};	
	_newUnit setUnitLoadout _loadout;
	private _identity = (_oldUnit getVariable ["respawnIdentity", []]);	
	if (count _identity > 0) then {
		_newUnit setVariable ["respawnIdentity", [_newUnit,  _identity select 1, _identity select 2, _speaker, _face], true];
		[_newUnit, _identity select 1, _identity select 2, _speaker, _face] remoteExec ["sun_setNameMP", 0, true];		
	};
	diag_log format ["DRO: New unit %1 created for %2 with class %3", _newUnit, _oldUnit, _class];
	//deleteVehicle _oldUnit;
	*/	
	[player] joinSilent (grpNetId call BIS_fnc_groupFromNetId);
	player setPos _newPos;
	player setVariable ["respawnLoadout", (getUnitLoadout player), true];
	player setVariable ["respawnPWeapon", [(primaryWeapon  player), primaryWeaponItems player], true];	
	if (reviveDisabled < 3) then {
		[player] call rev_addReviveToUnit;	
	};	
	player setUnitTrait ["Medic", true];
	player setUnitTrait ["engineer", true];
	player setUnitTrait ["explosiveSpecialist", true];
	player setUnitTrait ["UAVHacker", true];		
};

sun_addResetAction = {
	params ["_unit"];	
	[
		_unit,
		[
			"Reset Unit",
			{[_this select 0, _this select 1] execVM "sunday_system\player_setup\resetAIAction.sqf"},
			nil,
			20,
			false,
			true,
			"",
			"_this == _target"				
		]	
	] remoteExec ["addAction", 0, true];	
};

sun_randomTime = {	
	params ["_time"];
	if (_time == 0) then {_time = [1,4] call BIS_fnc_randomInt};
	_date = date;
	_dawnDusk = date call BIS_fnc_sunriseSunsetTime;
	_dawnNum = _dawnDusk select 0;
	_duskNum = _dawnDusk select 1;
	//_dawnNum = _dawnNum - 0.5;
	_dawnHour = floor _dawnNum;
	_duskHour = _duskNum;
	_dawnMinutes = ((_dawnNum - _dawnHour) * 60);
	_duskMinutes = ((_duskNum - _duskHour) * 60);
	diag_log format ["Raw dawnNum = %1", _dawnNum];
	switch (_time) do {
		case 1: {
			// DAWN		
			//skipTime _dawnNum;
			_date set [3, _dawnHour];
			_date set [4, _dawnMinutes];
			_number = dateToNumber _date;
			_number = _number - 0.00005;
			_date = numberToDate [(date select 0), _number];
			setDate _date;		
		};
		case 2: {
			// DAY
			_dayTime = [_dawnNum+1, _duskNum-1] call BIS_fnc_randomNum;
			//skipTime _dayTime;
			_date set [3, _dayTime];
			setDate _date;	
		};
		case 3: {
			// DUSK			
			//skipTime _duskNum;
			//_date set [3, _duskNum];
			_date set [3, _duskHour];
			//_date set [4, 0];
			setDate _date;		
		};
		case 4: {
			// NIGHT
			_nightTime1 = [(_duskNum + 1), 24] call BIS_fnc_randomNum;
			_nightTime2 = [0, (_dawnNum - 1)] call BIS_fnc_randomNum;
			_nightTime = selectRandom [_nightTime1, _nightTime2];
			_date set [3, _nightTime];
			setDate _date;
			//skipTime _nightTime;						
		};
	};
	diag_log format ["DRO: Set new time as select %1: %2", _time, _date];
	
};

sun_supplyBox = {	
	params ["_box", "_boxName", "_actionStr"];
	_boxName = (configFile >> "CfgVehicles" >> (typeOf _box) >> "displayName") call BIS_fnc_GetCfgData;
	_actionStr = format ["Force rearm at %1", _boxName];
	[_box, [
		_actionStr,
		{
			_unit = (_this select 1);
								
			_primaryWeapon = [primaryWeapon (_this select 1)] call BIS_fnc_baseWeapon;
			_secondaryWeapon = secondaryWeapon (_this select 1);
			//_handgun = [handgunWeapon (_this select 1)] call BIS_fnc_baseWeapon;
			
			if (count _primaryWeapon > 0) then {
				_unit addMagazines [(((configfile >> "CfgWeapons" >> _primaryWeapon >> "magazines") call BIS_fnc_getCfgData) select 0), 5];
			};
			if (count _secondaryWeapon > 0) then {
				_unit addMagazines [(((configfile >> "CfgWeapons" >> _secondaryWeapon >> "magazines") call BIS_fnc_getCfgData) select 0), 2];
			};
			/*
			if (count _handgun > 0) then {
				_unit addMagazines [(((configfile >> "CfgWeapons" >> _handgun >> "magazines") call BIS_fnc_getCfgData) select 0), 2];
			};
			*/			
		},
		[],
		20,
		false,
		false,
		"",
		"!isPlayer (_this)",
		200,
		false
	]] remoteExec ["addAction", 0, true];	
			
};

sun_groupToVehicle = {
	params ["_group", "_vehicle", ["_cargoOnly", false]];
	
	if (typeName _group == "GROUP") then {
		_group = units _group;
	};
	diag_log format ["sun_groupToVehicle called for %1", _group];	
	
	_commanderPositions = _vehicle emptyPositions "Commander";
	_driverPositions = _vehicle emptyPositions "Driver";	
	_gunnerPositions = _vehicle emptyPositions "Gunner";	
	
	if (_cargoOnly) then {
		_commanderPositions = 0;
		_driverPositions = 0;	
		_gunnerPositions = 0;
	};	
	
	_cargoPositions = _vehicle emptyPositions "Cargo";	
	//diag_log format ["sun_groupToVehicle: commander slots = %1", _commanderPositions];
	//diag_log format ["sun_groupToVehicle: driver slots = %1", _driverPositions];
	//diag_log format ["sun_groupToVehicle: gunner slots = %1", _gunnerPositions];
	//diag_log format ["sun_groupToVehicle: cargo slots = %1", _cargoPositions];
	{
		_unit = _x;
		diag_log format ["sun_groupToVehicle: assigning %1", _unit];
		if (_commanderPositions > 0) then {			
			_unit assignAsCommander _vehicle;			
			[_unit, _vehicle] remoteExecCall ["moveInCommander", _unit];
			//diag_log format ["sun_groupToVehicle: remote %1 moveInCommander to %2", _unit, _vehicle];						
			_commanderPositions = _commanderPositions - 1;			
		} else {
			if (_driverPositions > 0) then {			
				_unit assignAsDriver _vehicle;				
				[_unit, _vehicle] remoteExecCall ["moveInDriver", _unit];
				//diag_log format ["sun_groupToVehicle: remote %1 moveInDriver to %2", _unit, _vehicle];			
				_driverPositions = _driverPositions - 1;			
			} else {
				if (_gunnerPositions > 0) then {			
					_unit assignAsGunner _vehicle;					
					[_unit, _vehicle] remoteExecCall ["moveInGunner", _unit];
					//diag_log format ["sun_groupToVehicle: remote %1 moveInDriver to %2", _unit, _vehicle];					
					_gunnerPositions = _gunnerPositions - 1;			
				} else {
					if (_cargoPositions > 0) then {			
						_unit assignAsCargo _vehicle;						
						[_unit, _vehicle] remoteExecCall ["moveInCargo", _unit];
						//diag_log format ["sun_groupToVehicle: remote %1 moveInDriver to %2", _unit, _vehicle];						
						_cargoPositions = _cargoPositions - 1;			
					};
				};
			};
		};		
		waitUntil {vehicle _unit != _unit};
	} forEach _group;	
};

sun_moveGroup = {
	params ["_group", "_pos", "_extendArray", "_posParams"];	
	_extendArray = [];
	{
		_distToLead = (leader _group) distance _x;
		_dirFromLead = [(leader _group), _x] call BIS_fnc_dirTo;
		_extendArray pushBack [_distToLead, _dirFromLead];
	} forEach units _group;	
	(leader _group) setPos _pos;
	{
		_posParams = _extendArray select _forEachIndex;
		_extendPos = _pos getPos [(_posParams select 0), (_posParams select 1)];		
		_x setPos _extendPos;
	} forEach units _group;	
};	

sun_defineGrid = {
	params ["_center", "_numPosX", "_numPosY", "_spacing"];	
	_positions = [];
	_totalXSpacing = _spacing * _numPosX;
	_totalYSpacing = _spacing * _numPosY;
	
	_xOrigin = (_center select 0) - (_totalXSpacing/2);
	_yOrigin = (_center select 1) - (_totalYSpacing/2);
	
	_thisX = 0;
	_thisY = 0;
	for "_i" from 0 to (_numPosY - 1) step 1 do {
		for "_j" from 0 to (_numPosX - 1) step 1 do {
			_thisX = _xOrigin + (_spacing * _i) + (_spacing/2);
			_thisY = _yOrigin + (_spacing * _j) + (_spacing/2);			
			_positions pushBack [_thisX, _thisY, 0];
		};
	};
	_positions	
};

dro_createSimpleObject = {
	params ["_class", "_pos", ["_dir", 0], ["_special", "CAN_COLLIDE"], "_object"];
	_pos set [2, 0];
	_object = createVehicle [_class, _pos, [], 0, _special];		
	_object setDir _dir;
	if (isNil "DRO_simpleObjects") then {DRO_simpleObjects = [_object]} else {DRO_simpleObjects pushBack _object};
	/*
	_vectorUp = (surfaceNormal (getPosATL _object));
	_simpleObject = [_object] call BIS_fnc_replaceWithSimpleObject;
	_simpleObject setVectorUp _vectorUp;
	_simpleObject
	*/
	_object
};

sun_replaceSimpleObject = {
	params ["_object"];	
	_vectorUp = (surfaceNormal (getPosATL _object));
	_simpleObject = [_object] call BIS_fnc_replaceWithSimpleObject;
	_simpleObject setVectorUp _vectorUp;	
	_simpleObject
};

sun_removeEnemyNVG = {
	{
		if (side _x != playersSide) then {
			_unit = _x;		
			_nvgs = hmd _unit;			
			_unit unassignItem _nvgs;
			_unit removeItem _nvgs;			
			_unit removePrimaryWeaponItem "acc_pointer_IR";   
			_unit addPrimaryWeaponItem "acc_flashlight";
			_unit enableGunLights "forceon";		
		};
	} forEach allunits;
};

sun_getUnitPositionId = {
	private ["_vvn", "_str"];
	_vvn = vehicleVarName (_this select 0);
	(_this select 0) setVehicleVarName "";
	_str = str (_this select 0);
	(_this select 0) setVehicleVarName _vvn;
	parseNumber (_str select [(_str find ":") + 1])
};

sun_avgPos = {
	params ["_positions"];
	_xTotal = 0;
	_yTotal = 0;	
	{	
		_pos = switch (typeName _x) do {
			case "STRING": {getMarkerPos _x};
			case "OBJECT": {getPos _x};
			case "ARRAY": {_x};
			default {_x};
		};
		_xTotal = _xTotal + (_pos select 0);
		_yTotal = _yTotal + (_pos select 1);
	} forEach _positions;
	_numPositions = count _positions;	
	([(_xTotal / _numPositions), (_yTotal / _numPositions), 0])
};

dro_extendPos = {
	//private ["_extendCenter", "_dist", "angle", "_x2", "_y2"];
	//_extendCenter = (_this select 0);
	//_dist = (_this select 1);
	//_angle = (_this select 2);
	_x2 = (((_this select 0) select 0) + ((cos (90-(_this select 2))) * (_this select 1)));
	_y2 = (((_this select 0) select 1) + ((sin (90-(_this select 2))) * (_this select 1)));
	[_x2, _y2, 0]
};

dro_selectRemove = {
	_index = [0, (count (_this select 0)-1)] call BIS_fnc_randomInt;	
	private _return = (_this select 0) select _index;
	(_this select 0) deleteAt _index;
	_return
};

sun_selectRemove = {
	_index = [0, (count (_this select 0)-1)] call BIS_fnc_randomInt;	
	private _return = (_this select 0) select _index;
	(_this select 0) deleteAt _index;
	_return
};

sun_backpackFix = {
	// Set backpacks manually as a workaround for a bug with setUnitLoadout	
	_backpackContents = (backpackItems player) + (backpackMagazines player);	
	_backpackClass = backpack player;
	removeBackpackGlobal player;
	player addBackpackGlobal _backpackClass;
	{player addItemToBackpack _x} forEach _backpackContents;
};

dro_getArtilleryRanges = {
	private ["_turrets", "_vehicleMinRange", "_vehicleMaxRange", "_turretMinRange", "_turretMaxRange"];
	_turrets = [(_this select 0)] call BIS_fnc_getTurrets;
	_vehicleMinRange = 100000;
	_vehicleMaxRange = 0;
	{
		_modesToTest = [];
		_thisTurret = _x;
		_weapons = ((_thisTurret >> "weapons") call BIS_fnc_GetCfgData);	
		{		
			_thisWeapon = _x;		
			_modes = ((configfile >> "CfgWeapons" >> _thisWeapon >> "modes") call BIS_fnc_GetCfgData);		
			{
				_weaponChild = _x;
				_weaponChildName = (configName _x);
				{
					if (_x == _weaponChildName) then {					
						_modesToTest pushBackUnique _weaponChild;
					};
				} forEach _modes;
			} forEach ([(configfile >> "CfgWeapons" >> _thisWeapon), 0, true] call BIS_fnc_returnChildren);
			
		} forEach _weapons;	
		_turretMinRange = 100000;
		_turretMaxRange = 0;
		if (count _modesToTest > 0) then {
			{
				_minRange = ((_x >> "minRange") call BIS_fnc_GetCfgData);
				if (_minRange < _turretMinRange) then {_turretMinRange = _minRange};
				_maxRange = ((_x >> "maxRange") call BIS_fnc_GetCfgData);
				if (_maxRange > _turretMaxRange) then {_turretMaxRange = _maxRange};
			} forEach _modesToTest;	
		};	
		
		if (_turretMinRange < _vehicleMinRange) then {_vehicleMinRange = _turretMinRange};	
		if (_turretMaxRange > _vehicleMaxRange) then {_vehicleMaxRange = _turretMaxRange};
		
	} forEach _turrets;

	[_vehicleMinRange, _vehicleMaxRange]
};

dro_heliInsertion = {
	_heli = _this select 0;
	_insertPos = _this select 1;
	_type = _this select 2;
	
	diag_log format ["DRO: Init heli insertion with heli %1 to %2", _heli, _insertPos];
	
	_heliGroup = (group _heli);
	_startPos = [((getPos _heli) select 0), ((getPos _heli) select 1), ((getPos _heli) select 2)];
	_height = getTerrainHeightASL _insertPos; 
	_insertPosHigh = [(_insertPos select 0), (_insertPos select 1), _height+150];
	
	_flyDir = [_startPos, _insertPosHigh] call BIS_fnc_dirTo;
	_flyByPosExtend = [_insertPosHigh, 3000, _flyDir] call dro_extendPos;
	_flyByPos = [(_flyByPosExtend select 0), (_flyByPosExtend select 1), 200];
	
	_heli flyInHeight 200;
	_heliGroup = (group _heli);
	
	_driver = driver _heli;
	_heliGroup setBehaviour "careless";
    _driver disableAI "FSM";
    _driver disableAI "Target";
    _driver disableAI "AutoTarget";
	
	// Clear current waypoints
	while {(count (waypoints _heliGroup)) > 0} do {
		deleteWaypoint ((waypoints _heliGroup) select 0);
	};	
	
	_wp0 = _heliGroup addWaypoint [_startPos, 0];	
	_wp0 setWaypointSpeed "FULL";
	_wp0 setWaypointType "MOVE";	
	_wp0 setWaypointBehaviour "COMBAT";
	
	_wp1 = _heliGroup addWaypoint [_flyByPos, 0];	
	_wp1 setWaypointSpeed "FULL";
	_wp1 setWaypointType "MOVE";	
	
	_trgEject = createTrigger ["EmptyDetector", _insertPosHigh];
	_trgEject setTriggerArea [800, 50, _flyDir, false];
	_trgEject setTriggerActivation ["ANY", "PRESENT", false];
	_trgEject setTriggerStatements ["(thisTrigger getVariable 'heli') in thisList", "[(assignedCargo (thisTrigger getVariable 'heli'))] execVM 'sunday_system\player_setup\callParadrop.sqf';", ""];
	_trgEject setVariable ["heli", _heli];
	
	_trgDelete = createTrigger ["EmptyDetector", _flyByPos];
	_trgDelete setTriggerArea [100, 100, 0, false];
	_trgDelete setTriggerActivation ["ANY", "PRESENT", false];
	_trgDelete setTriggerStatements ["(thisTrigger getVariable 'heli') in thisList", "deleteVehicle (thisTrigger getVariable 'heli');", ""];
	_trgDelete setVariable ["heli", _heli];
	
	
	diag_log format ["DRO: heli waypoints %1, %2", waypointPosition [_heliGroup, 0], waypointPosition [_heliGroup, 1]];
	
};

dro_spawnGroupWeighted = {
	params [["_pos", []], ["_side", enemySide], "_classes", "_weights", "_unitNumbers", ["_addToDyn", true], ["_singleUnitSpecial", "FORM"]];
	
	_unitArr = [];
	_unitArrWeights = [];
	
	if (_classes isEqualType "") then {
		_unitArr pushBack _classes;
		_unitArrWeights pushBack 1;		
	} else {
		_unitArrIndex = [0, (count _classes -1)] call BIS_fnc_randomInt;
		_unitArr = (_classes select _unitArrIndex);
		_unitArrWeights = (_weights select _unitArrIndex);
	};
	
	if (count _pos > 0) then {			
		// Get a random number of units to select between the boundaries
		_minUnits = (_unitNumbers select 0);
		if (_minUnits < 1) then {_minUnits = 1};
		_maxUnits = (_unitNumbers select 1);	
		_limitUnits = [_minUnits, _maxUnits] call BIS_fnc_randomInt;
		
		_unitsToSpawn = [];
		for "_i" from 1 to _limitUnits do {
			_thisUnit = nil;
			if (count _unitArrWeights > 0) then {
				_thisUnit = _unitArr selectRandomWeighted _unitArrWeights;
			} else {
				_thisUnit = selectRandom _unitArr;
			};				
			_unitsToSpawn pushBack _thisUnit;
		};		
		_group = createGroup _side;
		_tempGroup = createGroup _side;	
		if (count _unitsToSpawn == 0) then {
			//_tempGroup createUnit [(_unitsToSpawn select 0), _pos, [], 0, _singleUnitSpecial];
			_tempGroup createUnit ["O_Soldier_F", _pos, [], 0, _singleUnitSpecial];
			["DRO: No valid units found for group %1 in faction %2! Spawned CSAT rifleman instead.", _tempGroup, enemyFaction] call BIS_fnc_error;
		} else {			
			{
				_tempGroup createUnit [_x, _pos, [], 0, _singleUnitSpecial];
			} forEach _unitsToSpawn;
		};
		units _tempGroup joinSilent _group;
		if (!isNil "aiSkill") then {			
			[_group] call dro_setSkillAction;			
		};
		if (_addToDyn && dynamicSim == 0) then {
			_group enableDynamicSimulation true;
		};
		deleteGroup _tempGroup;
		_group
	};	
};

dro_setSkillAction = {
	switch (aiSkill) do {
		case 0: {
			if (typeName (_this select 0) == "OBJECT") then {
				_unit = (_this select 0);
				_unit setSkill ["aimingAccuracy", random [0.06, 0.07, 0.08]];
				_unit setSkill ["aimingShake", random [0.01, 0.015, 0.02]];
				_unit setSkill ["aimingSpeed", random [0.1, 0.1, 0.15]];
				_unit setSkill ["spotDistance", random [0.7, 0.75, 0.8]];
				_unit setSkill ["spotTime", random [0.3, 0.4, 0.5]];
				_unit setSkill ["general", random [0.7, 0.75, 0.8]];	
				_unit setSkill ["courage", random [0.1, 0.2, 0.3]];
				_unit setSkill ["reloadSpeed", random [0.1, 0.1, 0.2]];
			};
			if (typeName (_this select 0) == "GROUP") then {		
				{
					_unit = _x;
					_unit setSkill ["aimingAccuracy", random [0.06, 0.07, 0.08]];
					_unit setSkill ["aimingShake", random [0.01, 0.015, 0.02]];
					_unit setSkill ["aimingSpeed", random [0.1, 0.1, 0.15]];
					_unit setSkill ["spotDistance", random [0.7, 0.75, 0.8]];
					_unit setSkill ["spotTime", random [0.3, 0.4, 0.5]];
					_unit setSkill ["general", random [0.7, 0.75, 0.8]];	
					_unit setSkill ["courage", random [0.1, 0.2, 0.3]];
					_unit setSkill ["reloadSpeed", random [0.1, 0.1, 0.2]];
				} forEach (units (_this select 0));
			};
		};
		case 1: {
			if (typeName (_this select 0) == "OBJECT") then {
				_unit = (_this select 0);
				_unit setSkill ["aimingAccuracy", random [0.15, 0.18, 0.2]];
				_unit setSkill ["aimingShake", random [0.06, 0.08, 0.1]];
				_unit setSkill ["aimingSpeed", random [0.2, 0.2, 0.25]];
				_unit setSkill ["spotDistance", random [0.7, 0.75, 0.8]];
				_unit setSkill ["spotTime", random [0.3, 0.4, 0.5]];
				_unit setSkill ["general", random [0.7, 0.75, 0.8]];	
				_unit setSkill ["courage", random [0.3, 0.4, 0.5]];
				_unit setSkill ["reloadSpeed", random [0.2, 0.3, 0.3]];
			};
			if (typeName (_this select 0) == "GROUP") then {		
				{
					_unit = _x;
					_unit setSkill ["aimingAccuracy", random [0.15, 0.18, 0.2]];
					_unit setSkill ["aimingShake", random [0.06, 0.08, 0.1]];
					_unit setSkill ["aimingSpeed", random [0.2, 0.2, 0.25]];
					_unit setSkill ["spotDistance", random [0.7, 0.75, 0.8]];
					_unit setSkill ["spotTime", random [0.3, 0.4, 0.5]];
					_unit setSkill ["general", random [0.7, 0.75, 0.8]];	
					_unit setSkill ["courage", random [0.3, 0.4, 0.5]];
					_unit setSkill ["reloadSpeed", random [0.2, 0.3, 0.3]];
				} forEach (units (_this select 0));
			};
		};
		default {};
	}; 
	
};


sun_addArsenal = {
	(_this select 0) addAction ["Arsenal", "['Open', true] call BIS_fnc_arsenal", nil, 6];
};	

sun_pasteLoadoutAdd = {
	_target = _this select 0;
	
	_actionIndex = _target addAction [
		"Paste Loadout",
		{
			_unit = _this select 1;
			_target = _this select 0;
			
			// Remove current loadout			
			_target removeWeaponGlobal (primaryWeapon _target);
			_target removeWeaponGlobal (secondaryWeapon _target);
			_target removeWeaponGlobal (handgunWeapon _target);
			removeUniform _target;
			removeVest _target;
			removeHeadgear _target;
			removeGoggles _target;
			removeBackpack _target;
			_target unassignItem "NVGoggles";
			_target removeItem "NVGoggles";	
			
			// Paste player's loadout
			_loadoutName = format ["loadout%1", _unit];
			[_unit, [missionNameSpace, _loadoutName]] call BIS_fnc_saveInventory;
			[_target, [missionNameSpace, _loadoutName]] call BIS_fnc_loadInventory;			
		},
		nil,
		1.5,
		false,
		false
	];
	
	// Record this action index for later removal
	_target setVariable ["loadoutAction", _actionIndex];
	
};

sun_pasteLoadoutRemove = {
	_target = _this select 0;
	_actionIndex = _target getVariable "loadoutAction";		
	_target removeAction _actionIndex;
};

sun_moveInCargo = {
	//_unit = _this select 0;
	_vehicle = _this select 0;
	
	player moveInCargo _vehicle;
	
};

sun_playSubtitleRadio = {	
	_radioArray = [		
		["RadioAmbient2", 9],
		["RadioAmbient6", 6],
		["RadioAmbient8", 11]
	];
	0 fadeSpeech 1;
	_thisSound = (selectRandom _radioArray);
	_endRadio = false;
	_currentSoundTime = 0;
	_soundStartTime = time;
	if (getSubtitleOptions select 0) then {
		0 fadeSpeech 0.15;
		playSound ["TacticalPing4", false];
		while {!_endRadio} do {
			//diag_log format ["currentSoundTime = %1", _currentSoundTime];
			sleep 0.7;
			if (isNil "bis_fnc_showsubtitle_subtitle") then {
				_thisSound = (selectRandom _radioArray);
				_currentSoundTime = (_thisSound select 1);
				_soundStartTime = time;
				//playSound [(_thisSound select 0), true];
			} else {
				if (_currentSoundTime <= 0 && !isNull bis_fnc_showsubtitle_subtitle) then {
					_thisSound = (selectRandom _radioArray);
					_currentSoundTime = (_thisSound select 1);
					_soundStartTime = time;
					//playSound [(_thisSound select 0), true];		
				};		
				_currentSoundTime = (_thisSound select 1) - (time - _soundStartTime);
				//hint str _currentSoundTime;
				if (isNull bis_fnc_showsubtitle_subtitle) then {
					_endRadio = true;
					1 fadeSpeech 0;
					sleep _currentSoundTime + 1;//((_thisSound select 1) - _currentSoundTime);			
					0 fadeSpeech 1;
				};
			};
			sleep 0.3;
		};
		playSound ["TacticalPing4", false];
	};
	/*
	while {!isNull bis_fnc_showsubtitle_subtitle} do {
		
		_radioArray = [		
			"RadioAmbient2",
			"RadioAmbient6",
			"RadioAmbient8"
		];
		playSound [(selectRandom _radioArray), true];
		//sleep 0.5;
		_sound = ASLToAGL [0,0,0] nearestObject "#soundonvehicle";
		diag_log _sound;
		diag_log isNull bis_fnc_showsubtitle_subtitle;
		waitUntil {isNull _sound || isNull bis_fnc_showsubtitle_subtitle};
		format ["DRO: Passed waitUntil with _sound %1 and subtitle %2", isNull _sound, isNull bis_fnc_showsubtitle_subtitle];
		sleep 0.5;
		if (!isNull _sound) then {1 fadeSpeech 0; sleep 1; deleteVehicle _sound; 0 fadeSpeech 1;};		
	};	
	*/
};

sun_playRadioRandom = {
	_radioArray = [		
			"RadioAmbient2",
			"RadioAmbient6",
			"RadioAmbient8"
		];
	playSound [(selectRandom _radioArray), true];	
};

sun_setNameMP = {
	params ["_unit", "_firstName", "_lastName", "_speaker", "_face"];	
	_unit setName [format ["%1 %2", _firstName, _lastName], _firstName, _lastName];
	_unit setNameSound _lastName;
	_unit setSpeaker _speaker;
	_unit setFace _face;
};

sun_goat = {
	{
		if (side _x != playersSide) then {
			_unit = _x;		
			_unit hideObjectGlobal true;
			_goat = createVehicle ["Goat_random_F", getPos _unit, [], 0, "NONE"];
			_goat attachTo [_unit, [0, 0, 0], "Pelvis"];
		};
	} forEach allunits;
};

