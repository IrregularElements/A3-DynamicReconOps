
_extractStyles = ["LEAVE"];
_extractWeights = [0.3];
if (insertType == "GROUND") then {
	_extractStyles pushBack "RTB";
	_extractWeights pushBack 0.1;
};

if (!isNil "friendlySquad") then {
	if (({alive _x} count (units friendlySquad)) > 0) then {
		_extractStyles = ["RENDEZVOUS"];
		_extractWeights = [];
		if (count holdAO > 0) then {
			_extractWeights pushBack 0;
		} else {
			_extractWeights pushBack 0.5;
		};
	};
};

if (count holdAO > 0) then {
	_extractStyles pushBack "HOLD";
	_extractWeights pushBack 1;
};

_extractStyle = _extractStyles selectRandomWeighted _extractWeights;

// Filter available helicopters for transportation space
_numPassengers = count (units (grpNetId call BIS_fnc_groupFromNetId));
_heliTransports = [];
{
	if ([_x] call sun_getTrueCargo >= _numPassengers) then {
		_heliTransports pushBack _x;
	};
} forEach pHeliClasses;

diag_log format ["DRO: _extractStyles = %1", _extractStyles];
diag_log format ["DRO: _extractWeights = %1", _extractWeights];
diag_log format ["DRO: _extractStyle = %1", _extractStyle];

// Create extract task
switch (_extractStyle) do {
	case "LEAVE": {		
		if (((count _heliTransports) > 0) && !extractHeliUsed) then {	
			_taskCreated = ["taskExtract", true, ["Extract from the AO. A helicopter transport is available to support. Alternatively leave the AO by any means available.", "Extract", ""], objNull, "CREATED", 5, true, true, "exit", true] call BIS_fnc_setTask;	
			diag_log format ["DRO: Extract task created: %1", _taskCreated];
			[(leader (grpNetId call BIS_fnc_groupFromNetId)), "heliExtract"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];	
		} else {	
			_taskCreated = ["taskExtract", true, ["Leave the AO by any means to extract. Helicopter transport is unavailable.", "Extract", ""], objNull, "CREATED", 5, true, true, "exit", true] call BIS_fnc_setTask;	
			diag_log format ["DRO: Extract task created: %1", _taskCreated];
		};
		
		
		// Send new enemies to chase players if stealth is not maintained
		if (!stealthActive) then {
			if (enemyCommsActive) then {
				diag_log 'DRO: Reinforcing due to mission completion';
				[(leader (grpNetId call BIS_fnc_groupFromNetId)), [2,4]] execVM 'sunday_system\reinforce.sqf';
			};
			// Make existing enemies close in on players
			diag_log "DRO: Init staggered attack";	
			[30] execVM 'sunday_system\generate_enemies\staggeredAttack.sqf';
		};
				
		"mkrAOC" setMarkerAlpha 1;
		// Extraction success trigger
		trgExtract = createTrigger ["EmptyDetector", getPos trgAOC, true];
		trgExtract setTriggerArea [(triggerArea trgAOC) select 0, (triggerArea trgAOC) select 1, 0, true];
		trgExtract setTriggerActivation ["ANY", "PRESENT", false];
		trgExtract setTriggerStatements [
			"		
				({vehicle _x in thisList} count allPlayers == 0) &&
				({alive _x} count allPlayers > 0)
			",
			"
				[] execVM 'sunday_system\endMission.sqf';
			",
			""
		];
		["LeadTrack02_F_Mark"] remoteExec ["playMusic", 0];
		["END_LEAVE"] spawn dro_sendProgressMessage;
	};
	case "RTB": {		
		if (((count _heliTransports) > 0) && !extractHeliUsed) then {	
			_taskCreated = ["taskExtract", true, ["Extract from the AO and return to base. A helicopter transport is available to support. Alternatively leave the AO by any means available.", "RTB", ""], objNull, "CREATED", 5, true, true, "exit", true] call BIS_fnc_setTask;	
			diag_log format ["DRO: Extract task created: %1", _taskCreated];
			[(leader (grpNetId call BIS_fnc_groupFromNetId)), "heliExtract"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];	
		} else {	
			_taskCreated = ["taskExtract", true, ["Leave the AO by any means to extract. Helicopter transport is unavailable.", "RTB", ""], objNull, "CREATED", 5, true, true, "exit", true] call BIS_fnc_setTask;	
			diag_log format ["DRO: Extract task created: %1", _taskCreated];
		};
		
		// Send new enemies to chase players if stealth is not maintained
		if (!stealthActive) then {
			if (enemyCommsActive) then {
				diag_log 'DRO: Reinforcing due to mission completion';
				[(leader (grpNetId call BIS_fnc_groupFromNetId)), [2,4]] execVM 'sunday_system\reinforce.sqf';
			};
			// Make existing enemies close in on players
			diag_log "DRO: Init staggered attack";	
			[30] execVM 'sunday_system\generate_enemies\staggeredAttack.sqf';
		};
		
		// Extraction success trigger
		extractPos = (getMarkerPos "campMkr");
		publicVariable "extractPos";
		trgExtract = createTrigger ["EmptyDetector", getMarkerPos "campMkr", true];
		trgExtract setTriggerArea [50, 50, 0, true];
		trgExtract setTriggerActivation ["ANY", "PRESENT", false];
		trgExtract setTriggerStatements [
			"		
				({vehicle _x in thisList} count allPlayers > 0) &&
				({alive _x} count allPlayers > 0)
			",
			"
				[] execVM 'sunday_system\endMission.sqf';
			",
			""
		];
		["LeadTrack02_F_Mark"] remoteExec ["playMusic", 0];
		["END_RTB"] spawn dro_sendProgressMessage;
	};
	case "RENDEZVOUS": {		
		_string = format ["Rendezvous with %1 before leaving the AO.", groupId friendlySquad];
		_taskMeet = ["taskExtract_b", true, [_string, "Rendezvous", ""], (leader friendlySquad), "CREATED", 5, true, true, "exit", true] call BIS_fnc_setTask;
		["END_RENDEZVOUS"] spawn dro_sendProgressMessage;
		waitUntil {sleep 5; ({(_x distance (leader friendlySquad)) < 10} count allPlayers > 0)};
		(units friendlySquad) joinSilent (grpNetId call BIS_fnc_groupFromNetId);	
		['taskExtract_b', 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
		
		// Filter available helicopters for transportation space
		_numPassengers = count (units (grpNetId call BIS_fnc_groupFromNetId));
		_heliTransports = [];
		{
			if ([_x] call sun_getTrueCargo >= _numPassengers) then {
				_heliTransports pushBack _x;
			};
		} forEach pHeliClasses;
		diag_log format ["DRO: _heliTransports = %1", _heliTransports];
		if (((count _heliTransports) > 0) && !extractHeliUsed) then {	
			_taskCreated = ["taskExtract", true, ["Extract from the AO. A helicopter transport is available to support. Alternatively leave the AO by any means available.", "Extract", ""], objNull, "CREATED", 5, true, true, "exit", true] call BIS_fnc_setTask;	
			diag_log format ["DRO: Extract task created: %1", _taskCreated];
			[(leader (grpNetId call BIS_fnc_groupFromNetId)), "heliExtract"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];	
		} else {	
			_taskCreated = ["taskExtract", true, ["Leave the AO by any means to extract. Helicopter transport is unavailable.", "Extract", ""], objNull, "CREATED", 5, true, true, "exit", true] call BIS_fnc_setTask;	
			diag_log format ["DRO: Extract task created: %1", _taskCreated];
		};
		"mkrAOC" setMarkerAlpha 1;
		
		// Send new enemies to chase players if stealth is not maintained
		if (!stealthActive) then {
			if (enemyCommsActive) then {
				diag_log 'DRO: Reinforcing due to mission completion';
				[(leader (grpNetId call BIS_fnc_groupFromNetId)), [2,4]] execVM 'sunday_system\reinforce.sqf';
			};
			// Make existing enemies close in on players
			diag_log "DRO: Init staggered attack";	
			[30] execVM 'sunday_system\generate_enemies\staggeredAttack.sqf';
		};
		
		// Extraction success trigger
		trgExtract = createTrigger ["EmptyDetector", getPos trgAOC, true];
		trgExtract setTriggerArea [(triggerArea trgAOC) select 0, (triggerArea trgAOC) select 1, 0, true];
		trgExtract setTriggerActivation ["ANY", "PRESENT", false];
		trgExtract setTriggerStatements [
			"		
				({vehicle _x in thisList} count allPlayers == 0) &&
				({alive _x} count allPlayers > 0)
			",
			"
				[] execVM 'sunday_system\endMission.sqf';
			",
			""
		];		
		["LeadTrack02_F_Mark"] remoteExec ["playMusic", 0];
	};
	case "HOLD": {
	
		if ("RENDEZVOUS" in _extractStyles) then {
			_string = format ["Rendezvous with %1 and hold the area together.", groupId friendlySquad];
			_taskMeet = ["taskExtract_b", true, [_string, "Rendezvous", ""], (leader friendlySquad), "CREATED", 5, true, true, "exit", true] call BIS_fnc_setTask;			
			[] spawn {
				waitUntil {sleep 5; ({(_x distance (leader friendlySquad)) < 10} count allPlayers > 0)};
				(units friendlySquad) joinSilent (grpNetId call BIS_fnc_groupFromNetId);	
				['taskExtract_b', 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
			};
		};
		
		_groupPositions = [];
		{
			if (side _x == enemySide) then {
				if ((leader _x distance (holdAO select 0)) < (holdAO select 1)) then {
					_groupPositions pushBack (getPos leader _x);
				};
			};
		} forEach allGroups;
		diag_log format ["DRO: _groupPositions = %1", _groupPositions];
		_avgPos = if (count _groupPositions > 0) then {
			[_groupPositions] call sun_avgPos;
		} else {
			(holdAO select 0)
		};
		
		_string = format ["Secure %1 and defend it while %2 forces move in to secure the area. If you cannot achieve this objective then extract from the AO and the rest of the force will attempt the assault alone.", (text (holdAO select 5)), playersFactionName];
		_taskCreated = ["taskExtract", true, [_string, "Take and Hold", ""], _avgPos, "CREATED", 5, true, true, "defend", true] call BIS_fnc_setTask;
		diag_log format ["DRO: Extract task created: %1", _taskCreated];
		
		["END_HOLD"] spawn dro_sendProgressMessage;
		
		_holdAreaSize = ((holdAO select 1) / 4);
		_markerHold = createMarker ["mkrHold", _avgPos];
		_markerHold setMarkerShape "ELLIPSE";
		_markerHold setMarkerSize [_holdAreaSize, _holdAreaSize];
		_markerHold setMarkerBrush "Solid";		
		_markerHold setMarkerColor "ColorGreen";
		_markerHold setMarkerAlpha 0.5;
		
		// Send new enemies to chase players if stealth is not maintained
		diag_log 'DRO: Reinforcing due to mission completion';
		[_avgPos, [3,5]] execVM 'sunday_system\reinforce.sqf';
		if (!stealthActive) then {
			if (enemyCommsActive) then {
				
				// Make existing enemies close in on players
				[15, _markerHold] execVM 'sunday_system\generate_enemies\staggeredAttack.sqf';
				diag_log "DRO: Init staggered attack";	
			};
		};
		
		//sleep 3;
		
		// Extract option
		"mkrAOC" setMarkerAlpha 1;
		// Extraction success trigger
		trgExtract_b = createTrigger ["EmptyDetector", getPos trgAOC, true];
		trgExtract_b setTriggerArea [(triggerArea trgAOC) select 0, (triggerArea trgAOC) select 1, 0, true];
		trgExtract_b setTriggerActivation ["ANY", "PRESENT", false];
		trgExtract_b setTriggerStatements [
			"		
				({vehicle _x in thisList} count allPlayers == 0) &&
				({alive _x} count allPlayers > 0)
			",
			"
				[] execVM 'sunday_system\endMission.sqf';
			",
			""
		];
		
		// Hold success trigger	
		waitUntil {((leader (grpNetId call BIS_fnc_groupFromNetId)) distance _avgPos) < _holdAreaSize};
		_startTime = time;
		trgExtract = createTrigger ["EmptyDetector", _avgPos, true];
		trgExtract setTriggerArea [_holdAreaSize, _holdAreaSize, 0, true];
		trgExtract setTriggerActivation ["ANY", "PRESENT", false];
		trgExtract setTriggerStatements [
			"		
				((({alive _x && side _x == enemySide} count thisList) < round (({alive _x && side _x == playersSide} count thisList)*0.25))) || 
				(({alive _x && side _x == enemySide} count thisList) <= 5) ||
				time > ((this getVariable 'startTime') + 240)
			",
			"
				[] execVM 'sunday_system\endMission.sqf';
			",
			""
		];
		trgExtract setVariable ["startTime", _startTime, true];
		
		
		
		//["LeadTrack02_F_Mark"] remoteExec ["playMusic", 0];
	};
};