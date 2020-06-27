params ["_target", "_numbers"];
// _target can be marker name string or unit

_min = round ((_numbers select 0) * aiMultiplier);
_max = round ((_numbers select 1) * aiMultiplier);		

private _debug = 0;

// Convert target to center position array if not already
_targetPos = switch (typeName _target) do {
	case "STRING": {getMarkerPos _target};
	case "OBJECT": {getPos _target};
	case "ARRAY": {_target};
};

_bestDist = ((AOLocations select 0) select 0) distance _targetPos;
_AOIndex = 0;
{
	_thisDist = ((_x select 0) distance _targetPos);
	if (_thisDist < _bestDist) then {
		_bestDist = _thisDist;
		_AOIndex = _forEachIndex;
	};	
} forEach AOLocations;

_numReinforcements = [_min, _max] call BIS_fnc_randomInt;

for "_i" from 1 to _numReinforcements do {	
	diag_log "DRO: Reinforcing";
	// Check available reinforcement types
	_styles = ["INFANTRY"];
	if (count enemyGVTPool > 0) then {	
		_styles pushBackUnique "CAR";	
	};
	if (count enemyGVPool > 0) then {
		{
			if (([_x] call sun_getTrueCargo) >= 4) exitWith {			
				_styles pushBackUnique "CARTRANSPORT";
			};
		} forEach enemyGVPool;		
	};
	if (count enemyHeliPool > 0 && count (((AOLocations select _AOIndex) select 2) select 4) > 0) then {
		{
			if (([_x] call sun_getTrueCargo) >= 4) exitWith {		
				_styles pushBackUnique "HELI";
			};
		} forEach enemyHeliPool;
	};
	_weights = [];
	{
		switch (_x) do {
			case "INFANTRY": {_weights pushBack 0.2};			
			case "CARTRANSPORT": {_weights pushBack 0.8};			
			case "CAR": {_weights pushBack 0.1};			
			case "HELI": {_weights pushBack 0.7};
		};
	} forEach _styles;	
	
	_reinforceType = [_styles, _weights] call BIS_fnc_selectRandomWeighted;
	
	if (!isNil "_reinforceType") then {
		switch (_reinforceType) do {
			case "INFANTRY": {
				// Get position data			
				_spawnPos = [_targetPos,900,1100,1,0,100,0] call BIS_fnc_findSafePos;
				
				if ((({(_spawnPos distance _x) < 600} count (units group player)) == 0)) then {
									
					// Debug marker
					if (_debug == 1) then {
						hint "REINFORCING";
						_markerRB = createMarker [format ["rbMkr%1",(random 10000)], _spawnPos];
						_markerRB setMarkerShape "ICON";
						_markerRB setMarkerColor "ColorOrange";
						_markerRB setMarkerType "mil_objective";
					};
					
					// Spawn units
					_minAI = 4*aiMultiplier;
					_maxAI = 8*aiMultiplier;					
					_reinfGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxAI], false] call dro_spawnGroupWeighted;				
					if (!isNil "_reinfGroup") then {
						[_reinfGroup, _targetPos] call BIS_fnc_taskAttack;
						//[_reinfGroup, _targetPos, [50, 300], "FULL"] execVM "sunday_system\orders\patrolArea.sqf";											
						diag_log format ["REINFORCEMENT: Infantry group %1 spawned at %2",_reinfGroup, _spawnPos];
					};
				};
			};
			
			case "CARTRANSPORT": {
				// Ground type truck
				_initPos = [_targetPos,1500,2000,0,0,30,0] call BIS_fnc_findSafePos;				
				_roadList = [];	
				_spawnPos = [];	
				_roadList = _initPos nearRoads 500;			
			
				if (count _roadList > 0) then {
					_thisRoad = (selectRandom _roadList);
					_spawnPos = getPos _thisRoad;				
				} else {
					_spawnPos = _initPos;
				};
				
				if ((({(_spawnPos distance _x) < 600} count (units group player)) == 0)) then {				
					// Debug marker
					if (_debug == 1) then {
						hint "REINFORCING";
						_markerRB = createMarker [format ["rbMkr%1",(random 10000)], _spawnPos];
						_markerRB setMarkerShape "ICON";
						_markerRB setMarkerColor "ColorOrange";
						_markerRB setMarkerType "mil_objective";
					};				
										
					// Spawn vehicle
					_vehType = [enemyGVPool] call sun_selectRemove;
					_reinfVeh = createVehicle [_vehType, _spawnPos, [], 0, "NONE"];					
					[_reinfVeh, enemySide, false] call sun_createVehicleCrew;
					waitUntil {!isNull (driver _reinfVeh)};
					// Spawn units
					_maxUnits = ([_vehType] call sun_getTrueCargo);
					_minAI = (_maxUnits/2) * aiMultiplier;				
					
					_reinfGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxUnits], false] call dro_spawnGroupWeighted;				
					if (!isNil "_reinfGroup") then {
						[_reinfGroup, _reinfVeh, true] spawn sun_groupToVehicle;												
						[_reinfVeh, _reinfGroup, _targetPos, true] execVM "sunday_system\orders\insertGroup.sqf";																				
						diag_log format ["REINFORCEMENT: Car transport group %1 spawned at %2; inserting at %3",_reinfGroup, _spawnPos, _targetPos];
					};
				};
			};	
			
			case "CAR": {
				_initPos = [_targetPos,1500,2000,0,0,30,0] call BIS_fnc_findSafePos;
				_roadList = [];	
				_spawnPos = [];	
				_roadList = _initPos nearRoads 500;			
					
				if (count _roadList > 0) then {
					_thisRoad = (selectRandom _roadList);
					_spawnPos = getPos _thisRoad;				
				} else {
					_spawnPos = _initPos;
				};
				if ((({(_spawnPos distance _x) < 600} count (units group player)) == 0)) then {				
					// Debug marker
					if (_debug == 1) then {
						hint "REINFORCING";
						_markerRB = createMarker [format ["rbMkr%1",(random 10000)], _spawnPos];
						_markerRB setMarkerShape "ICON";
						_markerRB setMarkerColor "ColorOrange";
						_markerRB setMarkerType "mil_objective";
					};					
					
					// Spawn vehicle
					_vehType = [enemyGVTPool] call sun_selectRemove;
					if (!isNil "_vehType") then {
						_reinfVeh = createVehicle [_vehType, _spawnPos, [], 0, "NONE"];
						[_reinfVeh, enemySide, false] call sun_createVehicleCrew;
						waitUntil {!isNull (driver _reinfVeh)};
						[group(driver _reinfVeh), _targetPos] call BIS_fnc_taskAttack;						
						
						diag_log format ["REINFORCEMENT: Car attack group %1 spawned at %2; inserting at %3",_reinfVeh, _spawnPos, _targetPos];
						if (count _styles > 1) then {
							_styles = _styles - ["CAR"];
						};
					};
				};
			};
		
			case "HELI": {
				// Heli type
				_spawnPos = [_targetPos,2000,3000,0,1,100,0] call BIS_fnc_findSafePos;
				
				_insertPos = selectRandom (((AOLocations select _AOIndex) select 2) select 4);			
				
				_heliInsertType = selectRandom ["LAND", "PARACHUTE"];
				_height = switch (_heliInsertType) do {
					case "LAND": {40};
					case "PARACHUTE": {300};
					default {300};
				};
				_spawnPos set [2,_height];
												
				// Debug marker
				if (_debug == 1) then {
					hint "REINFORCING";
					_markerRB = createMarker [format ["rbMkr%1",(random 10000)], _spawnPos];
					_markerRB setMarkerShape "ICON";
					_markerRB setMarkerColor "ColorOrange";
					_markerRB setMarkerType "mil_objective";
				};
				
				// Spawn vehicle
				_vehType = [enemyHeliPool] call sun_selectRemove;
				_reinfVeh = createVehicle [_vehType, _spawnPos, [], 0, "FLY"];
				_reinfVeh setPos _spawnPos;
				[_reinfVeh, enemySide, false] call sun_createVehicleCrew;
				//createVehicleCrew _reinfVeh;
				waitUntil {!isNull (driver _reinfVeh)};
				// Spawn units
				_maxUnits = ([_vehType] call sun_getTrueCargo);
				_minAI = (_maxUnits/2) * aiMultiplier;								
				_reinfGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxUnits], false] call dro_spawnGroupWeighted;			
				if (!isNil "_reinfGroup") then {
					[_reinfGroup, _reinfVeh, true] spawn sun_groupToVehicle;					
					[_reinfVeh, _reinfGroup, _insertPos, true, _heliInsertType] execVM "sunday_system\orders\insertGroup.sqf";						
					diag_log format ["REINFORCEMENT: Heli transport group %1 spawned at %2; inserting at %3",_reinfGroup, _spawnPos, _insertPos];
				} else {
					{_reinfVeh deleteVehicleCrew _x} forEach crew _reinfVeh;
					deleteVehicle _reinfVeh;
				};
			};
		};		
	};
	
	sleep ([20, 40] call BIS_fnc_randomInt);
	
};

