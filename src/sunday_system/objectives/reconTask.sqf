params ["_objData", "_realTask", ["_startRecon", true]];
private ["_taskName", "_taskDesc", "_taskTitle", "_markerName", "_taskType", "_taskPos", "_reconComplete"];

_taskName = _objData select 0;
_taskDesc = _objData select 1;
_taskTitle = _objData select 2;
_markerName = _objData select 3;
_taskType = _objData select 4;
_taskPos = _objData select 5;
_markerName setMarkerAlpha 0;

_taskPosFakeTemp = getMarkerPos _markerName;
_taskPosFake = _taskPos getPos [random 60, random 360];//[(_taskPosFakeTemp select 0), (_taskPosFakeTemp select 1), 0];

_reconTaskName = format ["task%1", floor(random 100000)];
_reconTaskDesc = format ["Recon the area at grid %1 from a safe observation distance.", (mapGridPosition _taskPosFake)];
_reconTaskTitle = "Observe";		

_reconMarkerName = format["reconMkr%1", floor(random 100000)];		
_reconMarker = createMarker [_reconMarkerName, _taskPosFake];
_reconMarker setMarkerShape "ICON";
_reconMarker setMarkerAlpha 0;
_reconMarkerPos = [(_taskPosFake select 0), (_taskPosFake select 1), 0];

_id = [_reconTaskName, true, [_reconTaskDesc, _reconTaskTitle, _reconMarkerName], _reconMarkerPos, "CREATED", 1, false, true, "scout", true] call BIS_fnc_setTask;

if (_realTask) then {
	taskIDs pushBack _id;	
	allObjectives pushBack _reconTaskName;
	[_reconMarkerPos, _reconTaskName, 4] execVM "sunday_system\objectives\addTaskExtras.sqf";
};

_reconComplete = false;

missionNamespace setVariable [_taskName, 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

diag_log format["DRO: Recon task %1 for regular task %2 all data:", _reconTaskName, _taskName];
diag_log format["      %1", _reconTaskName];
diag_log format["      %1", _reconTaskDesc];
diag_log format["      %1", _reconTaskTitle];
diag_log format["      %1", _reconMarkerName];
diag_log format["      %1", _reconMarkerPos];


if (_startRecon) then {
	while {!_reconComplete} do {
		sleep 5;	
		{		
			_unit = _x;
			if (isPlayer _unit) then {
				[_taskName, _reconMarkerPos] remoteExec ["dro_detectPosMP", _unit, false];			
			};
		} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
		
		if ((missionNamespace getVariable _taskName) >= 2 && !_reconComplete) exitWith {
			diag_log "DRO: Observe task completed";
			_reconComplete = true;
			_hideMarker = if (["clear", (_objData select 2)] call BIS_fnc_inString) then {false} else {true};
			[_objData, true, true, _hideMarker, true] call sun_assignTask;		
			[_reconTaskName, "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
			_splitString = (_objData select 2) splitString ":";
			_text = switch (_splitString select 0) do {
				case "Destroy Artillery": {(selectRandom ["that's an important artillery asset that we need destroyed.", "take out that artillery while we have the opportunity.", "let's make sure that artillery isn't going to be a problem for us."])};
				case "Destroy Cache": {(selectRandom ["looks like you've found a weapons cache. Let's make sure the enemy can't use it.", "take out that cache while we have the opportunity."])};
				case "Clear Area": {(selectRandom ["it looks like there's a build up of enemy troops in that area, pacify it before you continue.", "a troop build up here could cause us problems later, clear that area."])};
				case "Destroy Mortar Emplacement": {(selectRandom ["that's an important mortar asset that we need destroyed.", "take out that mortar position while we have the opportunity.", "let's make sure that mortar position isn't going to be a problem for us."])};
				case "Destroy Helicopter": {
					selectRandom [
						(format ["that's an important %1 that we need destroyed.", ((configFile >> "CfgVehicles" >> (typeOf (_objData select 8)) >> "displayName") call BIS_fnc_GetCfgData)]),
						(format ["take out that %1 while we have the opportunity.", ((configFile >> "CfgVehicles" >> (typeOf (_objData select 8)) >> "displayName") call BIS_fnc_GetCfgData)]),
						(format ["let's make sure that %1 isn't going to be a problem for us.", ((configFile >> "CfgVehicles" >> (typeOf (_objData select 8)) >> "displayName") call BIS_fnc_GetCfgData)])
					]
				};
				case "HVT": {
					if (count ((_objData select 8) getVariable ["captureTask", ""]) == 0) then {
						selectRandom [
							(format ["looks like you've turned up %1, one of our high value targets. Take him out while we have the chance.", name (_objData select 8)]),
							"I'd recognise that guy anywhere, he's been on our kill list for a while. Take him out while we have the opportunity."
						]
					} else {
						selectRandom [
							(format ["looks like you've turned up %1, one of our high value targets. Capture him out while we have the chance.", name (_objData select 8)]),
							"I'd recognise that guy anywhere, he's been on our capture list for a while. Grab him out while we have the opportunity."
						]
					}				
				};
				case "Captive": {
					selectRandom [
						(format ["that's %1, one of our rescue targets! Get them back before they are moved out of our reach.", name (_objData select 8)]),
						(format ["that's someone we weren't expecting to find here! Get %1 back before they are moved out of reach.", name (_objData select 8)])
					]
				};
				case "Destroy Vehicle": {
					selectRandom [
						(format ["that's an important %1 that we need destroyed.", ((configFile >> "CfgVehicles" >> (typeOf (_objData select 8)) >> "displayName") call BIS_fnc_GetCfgData)]),
						(format ["take out that %1 while we have the opportunity.", ((configFile >> "CfgVehicles" >> (typeOf (_objData select 8)) >> "displayName") call BIS_fnc_GetCfgData)]),
						(format ["let's make sure that %1 isn't going to be a problem for us.", ((configFile >> "CfgVehicles" >> (typeOf (_objData select 8)) >> "displayName") call BIS_fnc_GetCfgData)])
					]
				};
				case "Steal Vehicle": {
					selectRandom [
						(format ["that's an important %1 that we need stolen.", ((configFile >> "CfgVehicles" >> (typeOf (_objData select 8)) >> "displayName") call BIS_fnc_GetCfgData)]),
						(format ["steal that %1 while we have the opportunity.", ((configFile >> "CfgVehicles" >> (typeOf (_objData select 8)) >> "displayName") call BIS_fnc_GetCfgData)]),
						(format ["let's make sure that %1 isn't going to be used by the enemy.", ((configFile >> "CfgVehicles" >> (typeOf (_objData select 8)) >> "displayName") call BIS_fnc_GetCfgData)])
					]
				};
				default {(selectRandom ["we've got more work to do here.", "you've turned up something interesting."])};
			};
			["OBSERVE_SUCCEED", "Command", [_text]] spawn dro_sendProgressMessage;
		};	
	};
};