
_objects = [];
_transmitter = nil;
{
	if ((_x select 4) == 0) then {
		_towers = (nearestTerrainObjects [(_x select 0), ["TRANSMITTER"], ((_x select 1)/2), false, true]);
		if (count _towers > 0) then {
			{
				_objects pushBack _x;
			} forEach _towers;
		};
	};
} forEach AOLocations;
diag_log format ["DRO: Terrain comms towers = %1", _objects];

if (count _objects > 0) then {
	_transmitter = selectRandom _objects;
} else {
	_validIndexes = [];
	{
		if ((_x select 4) == 0) then {
			if (count ((_x select 2) select 7) > 0) then {
				_validIndexes pushBack _forEachIndex;
			};
		};
	} forEach AOLocations;	
	if (count _validIndexes > 0) then {		
		_thisBuilding = [(((AOLocations select (selectRandom _validIndexes)) select 2) select 7)] call sun_selectRemove;		
		if (!isNil "_thisBuilding") then {
			_wallPositions = [_thisBuilding] call sun_findWallPositions;
			_towerTypes = [
				"Land_Communication_F",
				"Land_TTowerSmall_2_F",
				"Land_TTowerSmall_1_F"				
			];			
			_objects = [];
			{
				_wallPos = (_x select 0);				
				_towerType = selectRandom _towerTypes;
				_spawnPos = _wallPos findEmptyPosition [0, 2.5, _towerType];
				if (count _spawnPos > 0) then {
					_object = createVehicle [_towerType, _spawnPos, [], 0, "NONE"];					
					_objects pushBack _object;
				};	
			} forEach _wallPositions;
			
			if (count _objects == 0) exitWith {};
			
			_transmitter = [_objects] call sun_selectRemove;
			{
				deleteVehicle _x;
			} forEach _objects;			
			_transmitter setVectorUp [0,0,1];				
		};
	};
};

if (!isNil "_transmitter") then {
	
	enemyCommsActive = true;
	
	// Create marker
	_markerName = format["commsMkr%1", floor(random 10000)];
	_markerPower = createMarker [_markerName, (getPos _transmitter)];
	_markerPower setMarkerShape "ICON";
	_markerPower setMarkerType  "mil_triangle_noShadow";
	_markerPower setMarkerSize [0.65, 0.65];
	_markerPower setMarkerColor "ColorBlack";
	_markerPower setMarkerText "Comms Tower";
	_markerPower setMarkerAlpha 1;
	
	_spawnPos = [(getPos _transmitter), 15, (random 360)] call BIS_fnc_relPos;
	_spawnedSquad = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [2,3]] call dro_spawnGroupWeighted;
	waitUntil {!isNil "_spawnedSquad"};
	[_spawnedSquad, (getPos _transmitter), 20] call BIS_fnc_taskPatrol;
	
	waitUntil {(missionNameSpace getVariable ["playersReady", 0]) == 1};
	
	// Create Task
	_taskName = format ["task%1", floor(random 100000)];
	_transmitterName = ((configFile >> "CfgVehicles" >> (typeOf _transmitter) >> "displayName") call BIS_fnc_GetCfgData);	
	_taskTitle = "Optional: Destroy Comms";
	_taskDesc =	format ["Take out the %1 communications network to stop their ability to call in reinforcements. Intel suggests that the communications array for %3 is being transmitted from the marked %2.", enemyFactionName, _transmitterName, aoName];	
	_task = ["commsTask", true, [_taskDesc, _taskTitle, ""], _transmitter, "CREATED", 0, true, true, "danger", true] call BIS_fnc_setTask;		
	_transmitter setVariable ["thisTask", _taskName, true];
	missionNamespace setVariable [(format ["%1_taskType", _taskName]), "danger", true];
	
	// Destruction listener
	[_transmitter] spawn {
		params ["_transmitter"];
		while {alive _transmitter} do {
			sleep 3;
			if (!alive _transmitter) then {				
				["commsTask", "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
				missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
				enemyCommsActive = false;
			};
		};
	};
	
	//[_transmitter] call dro_addSabotageAction;
	
	// Add destruction event handlers
	/*
	_transmitter addEventHandler ["Explosion", {
		diag_log "DRO: Comms tower explosion registered";
		if ((_this select 1) > 0.2) then {
			diag_log "DRO: Comms tower explosion is powerful enough to trigger";
			(_this select 0) setdamage 1;			
			_taskState = ["commsTask"] call BIS_fnc_taskState;		
			if !(_taskState isEqualTo "SUCCEEDED") then {
				["commsTask", "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
				missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
				
			};
			(_this select 0) removeAllEventHandlers "Explosion";
			(_this select 0) removeAllEventHandlers "Killed";
			enemyCommsActive = false;
		};
	}];
	_transmitter addEventHandler ["Killed", {
		diag_log "DRO: Comms tower killed registered";
		_taskState = ["commsTask"] call BIS_fnc_taskState;	
		if !(_taskState isEqualTo "SUCCEEDED") then {
			["commsTask", "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
			missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
			
		};
		(_this select 0) removeAllEventHandlers "Explosion";
		(_this select 0) removeAllEventHandlers "Killed";
		enemyCommsActive = false;
	}];
	*/	

	
};