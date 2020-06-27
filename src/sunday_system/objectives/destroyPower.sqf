params ["_AOIndex"];
_thisPos = [(((AOLocations select _AOIndex) select 2) select 4)] call sun_selectRemove;

_tempPos = [(_thisPos select 0), (_thisPos select 1), 0];
_thisPos = _tempPos;

// Available classes
_powerObjects = ["Land_spp_Panel_F", "Land_PowLines_Transformer_F", "Land_SolarPanel_1_F", "Land_TTowerSmall_1_F"];
_powerFences = ["Land_Net_Fence_8m_F", "Land_Net_FenceD_8m_F"];
_powerTypes = ["Land_dp_transformer_F", "Land_PowerGenerator_F"];
				
// Create objective generator
_powerType = selectRandom _powerTypes;	

_positionArray = [_thisPos, 3, 3, 8] call sun_defineGrid;
_powerPos = _positionArray select 4;
_positionArray = _positionArray - [_powerPos];

// Create marker
_markerName = format["powerMkr%1", floor(random 10000)];
_markerPower = createMarker [_markerName, _thisPos];
_markerPower setMarkerShape "ICON";
_markerPower setMarkerType  "loc_Power";
_markerPower setMarkerSize [1, 1];
_markerPower setMarkerColor markerColorEnemy;
_markerPower setMarkerAlpha 0;

// Create Task
_powerName = ((configFile >> "CfgVehicles" >> _powerType >> "displayName") call BIS_fnc_GetCfgData);
_powerUnit = _powerType createVehicle _thisPos;
_taskName = format ["task%1", floor(random 100000)];
_taskTitle = "Destroy Power Relay";
_taskDesc = format ["Destroy the %2 to disrupt power to the %1 controlled area.", enemyFactionName, _powerName];
_taskType = "destroy";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

_powerUnit setVariable ["thisTask", _taskName];
				
// Add destruction event handler
_powerUnit addEventHandler ["Explosion", {
	if ((_this select 1) > 0.2) then {
		(_this select 0) setdamage 1;
		{
			deleteVehicle _x;
		} forEach ((_this select 0) getVariable 'objects');
		_taskState = [((_this select 0) getVariable 'thisTask')] call BIS_fnc_taskState;
		diag_log _taskState;
		if (_taskState != "SUCCEEDED") then {
			[((_this select 0) getVariable 'thisTask'), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
			missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
		};
		(_this select 0) removeAllEventHandlers "Explosion";
		(_this select 0) removeAllEventHandlers "Killed";
	};
}];

_powerUnit addEventHandler ["Killed", {			
	{
		deleteVehicle _x;
	} forEach ((_this select 0) getVariable 'objects');
	_taskState = [((_this select 0) getVariable 'thisTask')] call BIS_fnc_taskState;
	diag_log _taskState;
	if (_taskState != "SUCCEEDED") then {
		[((_this select 0) getVariable 'thisTask'), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
		missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
	};
	(_this select 0) removeAllEventHandlers "Explosion";
	(_this select 0) removeAllEventHandlers "Killed";
}];				
						
// Create extra fluff items
{
	_chance = random 100;
	if (_chance > 30) then {
		_objectClass = selectRandom _powerObjects;
		_object = createVehicle [_objectClass, _x, [], 0, "CAN_COLLIDE"];		
	};
} forEach _positionArray;

// Create fences
_startDir = 0;
_rotation = (_startDir);
_dir = (_startDir);
_gateSide = [1,4] call BIS_fnc_randomInt;
for "_i" from 1 to 4 do {

	_fencePos1 = [_thisPos, 12, _dir] call dro_extendPos;					
	_fencePos2 = [_fencePos1, 8, (_dir-90)] call dro_extendPos;					
	_fencePos3 = [_fencePos1, 8, (_dir+90)] call dro_extendPos;	
	
	_fenceClass1 = "";
	if (_i == _gateSide) then {
		_fenceClass1 = "Land_Net_Fence_Gate_F";
	} else {
		_fenceClass1 = selectRandom _powerFences;
	};					
	_fenceClass2 = selectRandom _powerFences;
	_fenceClass3 = selectRandom _powerFences;
	
	_fenceObject1 = createVehicle [_fenceClass1, _fencePos1, [], 0, "CAN_COLLIDE"];
	_fenceObject2 = createVehicle [_fenceClass2, _fencePos2, [], 0, "CAN_COLLIDE"];
	_fenceObject3 = createVehicle [_fenceClass3, _fencePos3, [], 0, "CAN_COLLIDE"];
	_fenceObject1 setDir _rotation;
	_fenceObject2 setDir _rotation;
	_fenceObject3 setDir _rotation;
	
	_dir = _dir + 90;
	_rotation = _rotation + 90;
};		
_minAI = round (3 * aiMultiplier);;
_maxAI = round (5 * aiMultiplier);;
_spawnedSquad = [_thisPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxAI]] call dro_spawnGroupWeighted;				
if (!isNil "_spawnedSquad") then {	
	[_spawnedSquad, _thisPos, [14, 30], "limited"] execVM "sunday_system\orders\patrolArea.sqf";	
};
_powerUnit addEventHandler ["Killed", { 
	{
		_x setHit ["light_1_hitpoint", 0.97];
		_x setHit ["light_2_hitpoint", 0.97];
		_x setHit ["light_3_hitpoint", 0.97];
		_x setHit ["light_4_hitpoint", 0.97];
	} forEach nearestObjects [u1, [
		"Lamps_base_F",
		"PowerLines_base_F",
		"PowerLines_Small_base_F"
	], 500];
} ];

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