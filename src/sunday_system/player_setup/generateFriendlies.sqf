params ["_friendlyChance", "_ambFriendlyChance"];

_AONameRendezvous = "";
_AONameAmbient = "";
_thisTrg = objNull;
DRO_beginFriendlyAssault = false;
publicVariable "DRO_beginFriendlyAssault";

_blacklist = [];
{
	_blacklist pushBack [(_x select 0), (_x select 1)];
} forEach AOLocations;

if (_ambFriendlyChance > 0.75) then {
	_holdAOs = [];
	
	_taskAOs = [];
	diag_log format ["DRO: objData = %1", objData];
	{
		_taskPos = (_x select 5);//_x call BIS_fnc_taskDestination;
		diag_log format ["DRO: _taskPos = %1", _taskPos];
		_nearAOs = [AOLocations, [_taskPos], {(_x select 0) distance _input0}, "ASCEND"] call BIS_fnc_sortBy;
		if (((_nearAOs select 0) select 4) == 0) then {
			_taskAOs pushBack (_nearAOs select 0);
		};
	} forEach objData;
	diag_log format ["DRO: _taskAOs = %1", _taskAOs];
	
	if (count _taskAOs > 0) then {
		_taskAOs = _taskAOs call BIS_fnc_consolidateArray;
		diag_log format ["DRO: _taskAOs consolidate = %1", _taskAOs];
		_taskAOs = [_taskAOs, [], {(_x select 1)}, "DESCEND"] call BIS_fnc_sortBy;
		diag_log format ["DRO: _taskAOs consolidate sort = %1", _taskAOs];
		{
			_holdAOs pushBack (_x select 0);
		} forEach _taskAOs;
		diag_log format ["DRO: _holdAOs = %1", _holdAOs];		
	} else {
		{
			if ((_x select 4) == 0) then {
				_holdAOs pushBack _x;
			};
		} forEach AOLocations;	
	};
	
	if (count _holdAOs > 0) then {		
		holdAO = (_holdAOs select 0);
		_AONameAmbient = text (holdAO select 5);
	};
};

_squads = [];

// *****
// Ambient squads
// *****

if (_ambFriendlyChance > 0.75) then {
	_numSquads = 2;
	diag_log format ["DRO: Creating ambient friendlies for %1", text (holdAO select 5)];
	//setGroupIconsVisible [true, false];
	[[true, false]] remoteExec ["setGroupIconsVisible", 0, true];
	droGroupIconsVisible = true;
	publicVariable "droGroupIconsVisible";
	_cars = [];
	_APCs = [];
	_helis = [];
	_tanks = [];
	_styles = ["INFANTRY"];
	_weights = [0.1];
	if (count pCarClasses > 0) then {
		{
			if (([_x] call sun_getTrueCargo) >= 3) exitWith {			
				_cars pushBack _x;			 
			};
		} forEach pCarClasses;		
	};
	if (count _cars == 0) then {
		if (missionPreset == 3) then {_cars = pCarTurretClasses} else {_cars = pCarNoTurretClasses};		
	};
	if (missionPreset == 3) then {
		if (count pAPCClasses > 0) then {
			{
				if (([_x] call sun_getTrueCargo) >= 3) exitWith {			
					_APCs pushBack _x;
				};
			} forEach pAPCClasses;		
		};
		if (count _APCs == 0) then {_APCs = pAPCClasses};
		if (count pTankClasses > 0) then {
			_tanks = pTankClasses;
		};
	};
	{
		if (count _x > 0) then {
			switch (_forEachIndex) do {
				case 0: {_styles pushBack "CAR"; _weights pushBack 0.3;};
				case 1: {_styles pushBack "APC"; _weights pushBack 0.9;};			
				case 2: {_styles pushBack "TANK"; _weights pushBack 0.35;};			
			};
		};
	} forEach [_cars, _APCs];
	
	for "_i" from 1 to _numSquads step 1 do {	
		_thisCallsign = [callsigns] call sun_selectRemove;		
		_centerDir = (getMarkerPos "mkrAOC") getDir (holdAO select 0);
		_startPos = (holdAO select 0) getPos [900, _centerDir];
		_spawnPos = [_startPos, 0, 1800, 1, 0, 0.7, 0, _blacklist, [[0,0,0], [0,0,0]]] call BIS_fnc_findSafePos;
		if !(_spawnPos isEqualTo [0,0,0]) then {
			diag_log format ["DRO: Ambient friendly spawn pos: %1", _spawnPos];
			_style = _styles selectRandomWeighted _weights;
			_thisSquad = nil;
			diag_log format ["DRO: Ambient friendly style: %1", _style];
			switch (_style) do {
				case "INFANTRY": {
					// Create friendly squad
					_minAI = (round (6 * aiMultiplier) min 6);
					_maxAI = (round (8 * aiMultiplier) min 8);
					_thisSquad = [_spawnPos, playersSide, pInfClassesForWeights, pInfClassWeights, [_minAI, _maxAI], false] call dro_spawnGroupWeighted;					
					waitUntil {!isNil "_thisSquad"};
					_iconSide = switch (playersSide) do {
						case west: {"b_inf"};
						case east: {"o_inf"};
						case resistance: {"n_inf"};
						default {"b_inf"};
					};	
					_thisSquad addGroupIcon [_iconSide, [0, 0]];			
					_thisSquad setGroupIconParams [colorPlayers, _thisCallsign, 1, true];
					_thisSquad setGroupIdGlobal [_thisCallsign];
					diag_log format ["DRO: Created ambient friendly group %1", _thisSquad];				
				};
				case "CAR": {
					_roadList = _spawnPos nearRoads 500;			
					if (count _roadList > 0) then {
						_closestRoads = [_roadList, [], {_spawnPos distance _x}, "ASCEND"] call BIS_fnc_sortBy;
						_thisRoad = (_closestRoads select 0);
						_spawnPos = getPos _thisRoad;				
					};
					_thisCarClass = selectRandom _cars;
					_thisCar = createVehicle [_thisCarClass, _spawnPos, [], 0, "NONE"];
					//_slots = [_thisCarClass] call sun_getTrueCargo; //((configFile >> "CfgVehicles" >> _thisCarClass >> "transportSoldier") call BIS_fnc_GetCfgData);							
					_roles = [_thisCarClass] call BIS_fnc_vehicleRoles;
					_slots = count _roles;
					_thisSquad = createGroup playersSide;
					if (_slots > 0) then {
						_thisSquad = [_spawnPos, playersSide, pInfClassesForWeights, pInfClassWeights, [_slots, _slots], false] call dro_spawnGroupWeighted;
						waitUntil {(count (units _thisSquad)) > 0};
					};
					
					_unitCount = 0;
					{						
						switch (_x select 0) do {
							case "Driver": {((units _thisSquad) select _unitCount) assignAsDriver _thisCar};
							case "Turret": {((units _thisSquad) select _unitCount) assignAsTurret [_thisCar, (_x select 1)]};
							case "Commander": {((units _thisSquad) select _unitCount) assignAsCommander _thisCar};
							case "Cargo": {((units _thisSquad) select _unitCount) assignAsCargo _thisCar};
						};
						_unitCount = _unitCount + 1;
					} forEach _roles;
					(units _thisSquad) orderGetIn true;
					
					//[_thisCar, playersSide, false] call sun_createVehicleCrew;			
					//waitUntil {!isNull (driver _thisCar)};				
					//(crew _thisCar) joinSilent _thisSquad;
					//[_thisSquad, _thisCar, true] spawn sun_groupToVehicle;
					_iconSide = switch (playersSide) do {
						case west: {"b_motor_inf"};
						case east: {"o_motor_inf"};
						case resistance: {"n_motor_inf"};
						default {"b_motor_inf"};
					};	
					diag_log _iconSide;
					_thisSquad addGroupIcon [_iconSide, [0, 0]];
					diag_log colorPlayers;
					_thisSquad setGroupIconParams [colorPlayers, _thisCallsign, 1, true];
					_thisSquad setGroupIdGlobal [_thisCallsign];
					diag_log format ["DRO: Created ambient friendly group %1", _thisSquad];	
				};
				case "APC": {
					_roadList = _spawnPos nearRoads 500;
					if (count _roadList > 0) then {
						_closestRoads = [_roadList, [], {_spawnPos distance _x}, "ASCEND"] call BIS_fnc_sortBy;
						_thisRoad = (_closestRoads select 0);
						_spawnPos = getPos _thisRoad;				
					};
					_thisCarClass = selectRandom _APCs;
					_thisCar = createVehicle [_thisCarClass, _spawnPos, [], 0, "NONE"];
					//_slots = [_thisCarClass] call sun_getTrueCargo; //((configFile >> "CfgVehicles" >> _thisCarClass >> "transportSoldier") call BIS_fnc_GetCfgData);
					_roles = [_thisCarClass] call BIS_fnc_vehicleRoles;
					_slots = count _roles;
					_thisSquad = createGroup playersSide;
					if (_slots > 0) then {
						_thisSquad = [_spawnPos, playersSide, pInfClassesForWeights, pInfClassWeights, [_slots, _slots], false] call dro_spawnGroupWeighted;
						waitUntil {(count (units _thisSquad)) > 0};
					};
					
					_unitCount = 0;
					{						
						switch (_x select 0) do {
							case "Driver": {((units _thisSquad) select _unitCount) assignAsDriver _thisCar};
							case "Turret": {((units _thisSquad) select _unitCount) assignAsTurret [_thisCar, (_x select 1)]};
							case "Commander": {((units _thisSquad) select _unitCount) assignAsCommander _thisCar};
							case "Cargo": {((units _thisSquad) select _unitCount) assignAsCargo _thisCar};
						};
						_unitCount = _unitCount + 1;
					} forEach _roles;
					(units _thisSquad) orderGetIn true;
					
					//_thisSquad addVehicle _thisCar;
					
					
					//[_thisCar, playersSide, false] call sun_createVehicleCrew;
					//waitUntil {!isNull (driver _thisCar)};				
					//(crew _thisCar) joinSilent _thisSquad;
					//[_thisSquad, _thisCar, true] spawn sun_groupToVehicle;
					_iconSide = switch (playersSide) do {
						case west: {"b_mech_inf"};
						case east: {"o_mech_inf"};
						case resistance: {"n_mech_inf"};
						default {"b_mech_inf"};
					};	
					diag_log _iconSide;
					_thisSquad addGroupIcon [_iconSide, [0, 0]];
					diag_log colorPlayers;
					_thisSquad setGroupIconParams [colorPlayers, _thisCallsign, 1, true];
					_thisSquad setGroupIdGlobal [_thisCallsign];
					diag_log format ["DRO: Created ambient friendly group %1", _thisSquad];	
				};
				case "TANK": {
					_roadList = _spawnPos nearRoads 500;
					if (count _roadList > 0) then {
						_closestRoads = [_roadList, [], {_spawnPos distance _x}, "ASCEND"] call BIS_fnc_sortBy;
						_thisRoad = (_closestRoads select 0);
						_spawnPos = getPos _thisRoad;				
					};
					_thisCarClass = selectRandom _tanks;
					_thisCar = createVehicle [_thisCarClass, _spawnPos, [], 0, "NONE"];
					//_slots = [_thisCarClass] call sun_getTrueCargo; //((configFile >> "CfgVehicles" >> _thisCarClass >> "transportSoldier") call BIS_fnc_GetCfgData);
					_roles = [_thisCarClass] call BIS_fnc_vehicleRoles;
					_slots = count _roles;
					_thisSquad = createGroup playersSide;
					if (_slots > 0) then {
						_thisSquad = [_spawnPos, playersSide, pInfClassesForWeights, pInfClassWeights, [_slots, _slots], false] call dro_spawnGroupWeighted;
						waitUntil {(count (units _thisSquad)) > 0};
					};
					
					_unitCount = 0;
					{						
						switch (_x select 0) do {
							case "Driver": {((units _thisSquad) select _unitCount) assignAsDriver _thisCar};
							case "Turret": {((units _thisSquad) select _unitCount) assignAsTurret [_thisCar, (_x select 1)]};
							case "Commander": {((units _thisSquad) select _unitCount) assignAsCommander _thisCar};
							case "Cargo": {((units _thisSquad) select _unitCount) assignAsCargo _thisCar};
						};
						_unitCount = _unitCount + 1;
					} forEach _roles;
					(units _thisSquad) orderGetIn true;
					
					//_thisSquad addVehicle _thisCar;
					
					
					//[_thisCar, playersSide, false] call sun_createVehicleCrew;
					//waitUntil {!isNull (driver _thisCar)};				
					//(crew _thisCar) joinSilent _thisSquad;
					//[_thisSquad, _thisCar, true] spawn sun_groupToVehicle;
					_iconSide = switch (playersSide) do {
						case west: {"b_armor"};
						case east: {"o_armor"};
						case resistance: {"n_armor"};
						default {"b_armor"};
					};	
					diag_log _iconSide;
					_thisSquad addGroupIcon [_iconSide, [0, 0]];
					diag_log colorPlayers;
					_thisSquad setGroupIconParams [colorPlayers, _thisCallsign, 1, true];
					_thisSquad setGroupIdGlobal [_thisCallsign];
					diag_log format ["DRO: Created ambient friendly group %1", _thisSquad];	
				};
			};
			_thisSquad allowFleeing 0;
			_squads pushBack _thisSquad;
			[_thisSquad] spawn {
				params ["_thisSquad"];
				//waitUntil {sleep 10; !isNil "trgExtract" || !isNil "trgExtract_b"};
				waitUntil {sleep 10; DRO_beginFriendlyAssault};
				_waypoints = [];
				_wp0 = _thisSquad addWaypoint [(getPos (leader _thisSquad)), 0];
				_wp0 setWaypointType "MOVE";
				_wp0 setWaypointSpeed "NORMAL";
				_wp0 setWaypointBehaviour "AWARE";
				_wp0 setWaypointCombatMode "BLUE";

				_wp1Pos = ((holdAO select 0) getPos [300, ((holdAO select 0) getDir (getPos (leader _thisSquad)))]);
				_wp1 = _thisSquad addWaypoint [_wp1Pos, 0];
				_wp1 setWaypointType "MOVE";				
				_wp1 setWaypointCombatMode "GREEN";
				_waypoints pushBack [_wp1Pos, 0];
				
				for "_i" from 0 to 2 do {
					_randomPos = [[[getMarkerPos "mkrHold", 50]], ["water"]] call BIS_fnc_randomPos;
					_wp = _thisSquad addWaypoint [_randomPos, 0];
					_wp setWaypointType "MOVE";
					_wp setWaypointCombatMode "YELLOW";
					_waypoints pushBack [_randomPos, 0];
				};
				
				[_thisSquad, _waypoints] spawn sun_waypointCheck;
				
			};
		};
	};
};

// *****
// Rendezvous sqaud
// *****

if (_friendlyChance > 0.75) then {
	
	_rendezvousPos = [0,0,0];
	_spawnPos = [0,0,0];
	
	if (_ambFriendlyChance > 0.75) then {
		// Create random position for this squad based on holdAO
		_thisTrg = (holdAO select 6);
		_spawnPos = [(getPos _thisTrg), 1000, 1600, 1, 0, 0.7, 0, _blacklist, [[0,0,0], [0,0,0]]] call BIS_fnc_findSafePos;
		_rendezvousPos = [(getPos _thisTrg), 0, 200, 1, 0, 0.7, 0, [], [[0,0,0], [0,0,0]]] call BIS_fnc_findSafePos;
		_AONameRendezvous = text (holdAO select 5);
	} else {
		// Create random position for this squad only
		_spawnPos = [(getPos trgAOC), 1000, 1600, 1, 0, 0.7, 0, _blacklist, [[0,0,0], [0,0,0]]] call BIS_fnc_findSafePos;
		if !(_spawnPos isEqualTo [0,0,0]) then {
			_distance = 9999999;
			{	
				if (!([_spawnPos, (_x select 0)] call sun_checkRouteWater)) then {
					_thisDist = _spawnPos distance (_x select 0);
					if (_thisDist < _distance) then {
						_distance = _thisDist;
						_thisTrg = (_x select 6);
						_AONameRendezvous = text (_x select 5);
					};
				};
			} forEach AOLocations;
			if (!isNull _thisTrg) then {			
				_rendezvousPos = [(getPos _thisTrg), 0, 1500, 1, 0, 0.7, 0, _blacklist, [[0,0,0], [0,0,0]]] call BIS_fnc_findSafePos;			
			};
		};
	};

	if !(_rendezvousPos isEqualTo [0,0,0]) then {
		_thisCallsign = [callsigns] call sun_selectRemove;
		// Create friendly squad
		_minAI = (round (4 * aiMultiplier) min 6);
		_maxAI = (round (6 * aiMultiplier) min 8);
		friendlySquad = [_spawnPos, playersSide, pInfClassesForWeights, pInfClassWeights, [_minAI, _maxAI], false] call dro_spawnGroupWeighted;					
		waitUntil {!isNil "friendlySquad"};
		_iconSide = switch (side friendlySquad) do {
			case west: {"b_inf"};
			case east: {"o_inf"};
			case resistance: {"n_inf"};
			default {"b_inf"};
		};	
		friendlySquad addGroupIcon [_iconSide, [0, 0]];
		friendlySquad setGroupIconParams [colorPlayers, _thisCallsign, 1, true];
		friendlySquad setGroupIdGlobal [_thisCallsign];
		//setGroupIconsVisible [true, false];
		[[true, false]] remoteExec ["setGroupIconsVisible", 0, true];
		droGroupIconsVisible = true;
		publicVariable "droGroupIconsVisible";
		
		{
			_x setCaptive true;
			_x setUnitPos "MIDDLE";
		} forEach (units friendlySquad);

		// Create visual markers		
		_markerMidPos = [[_spawnPos, _thisTrg]] call sun_avgPos;		
		_mkrMid = createMarker ["mkrRendezvousMid1", _markerMidPos];
		_mkrMid setMarkerShape "ICON";
		_mkrMid setMarkerType "mil_ambush_noShadow";
		_mkrMid setMarkerColor markerColorPlayers;
		_mkrMid setMarkerSize [1.5, 1.5];
		_mkrMid setMarkerAlpha 0.5;
		_mkrMid setMarkerDir ((_spawnPos getDir _thisTrg) - 90);
		
		if (_ambFriendlyChance <= 0.75) then {
			_markerMid2Pos = [[_thisTrg, _rendezvousPos]] call sun_avgPos;		
			_mkrMid2 = createMarker ["mkrRendezvousMid2", _markerMid2Pos];
			_mkrMid2 setMarkerShape "ICON";
			_mkrMid2 setMarkerType "mil_arrow2_noShadow";
			_mkrMid2 setMarkerColor markerColorPlayers;
			_mkrMid2 setMarkerSize [1.5, 2.5];	
			_mkrMid2 setMarkerAlpha 0.5;
			_mkrMid2 setMarkerDir (_thisTrg getDir _rendezvousPos);
		};
		
		_mkrEnd = createMarker ["mkrRendezvous", _rendezvousPos];
		_mkrEnd setMarkerShape "ICON";
		_mkrEnd setMarkerType "mil_join_noShadow";
		_mkrEnd setMarkerColor markerColorPlayers;
		_mkrEnd setMarkerText (format ["%1 Rendezvous", _thisCallsign]);
		[_thisTrg, _rendezvousPos] spawn {
			params ["_thisTrg", "_rendezvousPos"];			
			//waitUntil {sleep 10; triggerActivated trgAOC};			
			waitUntil {sleep 10; DRO_beginFriendlyAssault};			
			["FRIENDLY_START", groupId friendlySquad] spawn dro_sendProgressMessage;
			{
				_x setCaptive false;
				_x setUnitPos "UP";
				_x setUnitPos "AUTO";
			} forEach (units friendlySquad);
			
			_waypoints = [];
			_wp0 = friendlySquad addWaypoint [(getPos (leader friendlySquad)), 0];
			_wp0 setWaypointType "MOVE";
			_wp0 setWaypointSpeed "NORMAL";
			_wp0 setWaypointBehaviour "AWARE";
			_wp0 setWaypointCombatMode "GREEN";
			
			for "_i" from 0 to 2 do {
				_randomPos = [[_thisTrg], ["water"]] call BIS_fnc_randomPos;
				_wp = friendlySquad addWaypoint [_randomPos, 0];
				_wp setWaypointType "MOVE";
				_waypoints pushBack [_randomPos, 0];
			};

			_wp = friendlySquad addWaypoint [_rendezvousPos, 0];
			_wp setWaypointType "MOVE";
			_waypoints pushBack [_rendezvousPos, 0];
			
			[friendlySquad, _waypoints] spawn sun_waypointCheck;
			
		};
		
	};
};

// *****
// Briefing
// *****

if (count _squads > 0) then {
	_groupIDs = [];
	{
		_groupIDs pushBack (groupId _x);
	} forEach _squads;
	_squadCommaList = [_groupIDs] call sun_stringCommaList;
	
	if (!isNil "friendlySquad") then {
		// Rendezvous squad and ambient squads - Rendezvous then hold
		friendlyText = format ["<br /><br />You will be operating alongside %1 who will be conducting a sweep into <marker name='mkrRendezvous'>%2</marker> as you move into the AO. Once your objectives are complete link up with them and assist the wider force including %3 to take %4.", groupId friendlySquad, _AONameRendezvous, _squadCommaList, _AONameAmbient];		
	} else {
		// Ambient squads - Hold
		friendlyText = selectRandom [
			(format [" We have %1 units on standby: %2. Once your tasking is complete they will move in to take control of %3.", (count _squads), _squadCommaList, _AONameAmbient]),
			(format [" %1 are on standby in the %2 area and are tasked with taking control of it once you have knocked out the %3 defences and completed your objectives.", _squadCommaList, _AONameAmbient, enemyFactionName])
		];		
	};
} else {
	if (!isNil "friendlySquad") then {
		_mkrRendezvousName = format ["mkr%1", floor (random 100000)];
		_mkrRendezvous = createMarker [_mkrRendezvousName, (getPos _thisTrg)];
		_mkrRendezvous setMarkerShape "ICON";	
		_mkrRendezvous setMarkerAlpha 0;
		// Rendezvous squad - Rendezvous then extract
		friendlyText = format ["<br /><br />You will be operating alongside %1 who will be conducting a sweep into <marker name=%3>%2</marker> as you move into the AO. Once your objectives are complete link up with them at the <marker name='mkrRendezvous'>rendezvous point.</marker>", groupId friendlySquad, _AONameRendezvous, _mkrRendezvous];	
	};
};
publicVariable "friendlyText";




