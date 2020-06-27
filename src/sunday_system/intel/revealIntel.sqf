params ["_numReveals", ["_revealUnits", true], ["_caller", objNull], ["_intelSource", objNull]];
_unitRevealUsed = false;
_markerRevealUsed = 0;
_markerZoneShrunk = false;

// TASK INTEL
_radioTaskIntel = "";	
_thisTask = [];
if (count taskIntel > 0) then {
	for "_i" from 1 to ((round((count taskIntel)*0.4)) max 1) step 1 do {		
		_thisTask = [taskIntel] call sun_selectRemove;	
		
		if ([_thisTask select 0] call BIS_fnc_taskExists) then {
			_taskDescData = [_thisTask select 0] call BIS_fnc_taskDescription;						
			_taskData = _thisTask select 1;
			_subTask = _thisTask select 2;
			_intelType = _thisTask select 3;			
			_taskDesc = (_taskDescData select 0) select 0;
			_taskTitle = (_taskDescData select 1) select 0;
			_taskMarker = (_taskDescData select 2) select 0;				
			switch (_intelType) do {
				case "MARKER": {
					_marker = _taskData getVariable "followMarker";
					diag_log format ["DRO: Revealing intel for followMarker %1 - %2", _taskTitle, _marker];										
					_realPos = getPos _taskData;
					_markerSize = getMarkerSize _marker;
					_newSize = if ((_markerSize select 0) > 300) then {
						(_markerSize select 0) - ((_markerSize select 0)*0.4)
					} else {
						(_markerSize select 0) - 150
					};
					if (_newSize < 0) then {_newSize = 0};
					_markerSize set [0, _newSize];
					_markerSize set [1, _newSize];
					_markerShiftAmount = (_markerSize select 0) min (_markerSize select 1);
					_markerPos = [_realPos, random(_markerShiftAmount-(_markerShiftAmount*0.1)), (random 360)] call BIS_fnc_relPos;
					_marker setMarkerPos [(_markerPos select 0), (_markerPos select 1)];
					_marker setMarkerSize _markerSize;
					diag_log format ["DRO: followMarker %1 set to size %2", _marker, _markerSize];					
					[_thisTask select 0, _marker] call BIS_fnc_taskSetDestination;							
					_markerZoneShrunk = true;
					// Add marker back if it's still too big
					if ((_markerSize select 0) > 0) then {						
						taskIntel pushBack [_thisTask select 0, _taskData, _subTask, "MARKER"];
						diag_log format ["DRO: followMarker %1 too big to complete and added to taskIntel", _marker];
					} else {						
						[_thisTask select 0, [_taskData, true]] call BIS_fnc_taskSetDestination;	
						diag_log format ["DRO: followMarker %1 completed and task %2 fixed to %3", _marker, (_thisTask select 0), _taskData];
					};
				};
				case "WEARABLE": {
					if (["HVT", _taskTitle, true] call BIS_fnc_inString) then {
						// Reveal wearable							
						_itemName = (configfile >> "CfgWeapons" >> _taskData >> "displayName") call BIS_fnc_getCfgData;
						if (isNil "_itemName") then {
							_itemName = (configfile >> "CfgGlasses" >> _taskData >> "displayName") call BIS_fnc_getCfgData;
						};
						_taskString = format ["<br /><br />HVT is wearing a %1", _itemName];
						_descString = _taskDesc + _taskString;						
						[_thisTask select 0, [_descString, _taskTitle, _taskMarker]] call BIS_fnc_taskSetDescription;
						_radioTaskFirst = selectRandom ["How about that, turns out our target is wearing a ", "Looks like our target is wearing a ", "Intel on our target, he's wearing a "];
						_radioTaskIntel = format ["%1%2", _radioTaskFirst, _itemName];
					};
					if (["Captive", _taskTitle, true] call BIS_fnc_inString) then {					
						// Reveal wearable	
						if (_taskData == "U_IG_Guerilla3_1" OR _taskData == "U_IG_Guerilla3_2") then {
							_taskString = "<br /><br />Captive has been dressed in civilian clothes.";
							_descString = _taskDesc + _taskString;						
							[_thisTask select 0, [_descString, _taskTitle, _taskMarker]] call BIS_fnc_taskSetDescription;								
							_radioTaskIntel = selectRandom ["Our captive has been dressed to blend in."];
						} else {
							_taskString = "<br /><br />Captive is still wearing his uniform.";
							_descString = _taskDesc + _taskString;						
							[_thisTask select 0, [_descString, _taskTitle, _taskMarker]] call BIS_fnc_taskSetDescription;								
							_radioTaskIntel = selectRandom ["Our captive is still wearing his uniform."];
						};
						// Reveal a patrol waypoint							
						
					};	
				};
				case "NAME": {
					if (["HVT", _taskTitle, true] call BIS_fnc_inString) then {						
						// Reveal name
						_taskString = format ["<br /><br />HVT is named %1", _taskData];
						_descString = _taskDesc + _taskString;					
						[_thisTask select 0, [_descString, _taskTitle, _taskMarker]] call BIS_fnc_taskSetDescription;
						_radioTaskFirst = selectRandom ["Got a name for our target - ", "Intel reveals our target is named ", "Okay, we're looking for "];
						_radioTaskIntel = format ["%1%2", _radioTaskFirst, _taskData];						
					};	
				};
				case "WAYPOINT": {
					if (["HVT", _taskTitle, true] call BIS_fnc_inString) then {					
						// Get HVT codename
						_codename = ((_taskTitle splitString " ") select 1);
						// Reveal a patrol waypoint							
						_markerName = format ["hvtWP%1", random 10000];
						_markerWP = createMarker [_markerName, _taskData];						
						_markerWP setMarkerShape "ICON";
						_markerWP setMarkerType "hd_flag";
						_markerWP setMarkerText format ["%1 patrol location", _codename];
						_markerWP setMarkerColor markerColorEnemy;						
						_radioTaskIntel = format ["Intel shows our target is going to pass through %1. Marked it on the map.", mapGridPosition _taskData];
					};
					if (["Captive", _taskTitle, true] call BIS_fnc_inString) then {					
						// Get POW name
						_name = ((_taskTitle splitString " ") select 1);
						// Reveal a patrol waypoint							
						_markerName = format ["powWP%1", random 10000];
						_markerWP = createMarker [_markerName, _taskData];						
						_markerWP setMarkerShape "ICON";
						_markerWP setMarkerType "hd_flag";
						_markerWP setMarkerText format ["%1 travel location", _name];
						_markerWP setMarkerColor markerColorEnemy;						
						_radioTaskIntel = format ["Intel shows %2 is being taken through %1. Marked it on the map.", mapGridPosition _taskData, _name];
					};
					if (["Vehicle", _taskTitle, true] call BIS_fnc_inString) then {							
						// Reveal a patrol waypoint							
						_markerName = format ["vehWP%1", random 10000];
						_markerWP = createMarker [_markerName, _taskData];						
						_markerWP setMarkerShape "ICON";
						_markerWP setMarkerType "hd_flag";
						_markerWP setMarkerText "Vehicle waypoint";
						_markerWP setMarkerColor markerColorEnemy;						
						_radioTaskIntel = format ["Intel shows a target vehicle will drive through %1. Marked it on the map.", mapGridPosition _taskData];
					};
					if (["Helicopter", _taskTitle, true] call BIS_fnc_inString) then {							
						// Reveal a patrol waypoint							
						_markerName = format ["heliWP%1", random 10000];
						_markerWP = createMarker [_markerName, _taskData];						
						_markerWP setMarkerShape "ICON";
						_markerWP setMarkerType "hd_flag";
						_markerWP setMarkerText "Heli landing zone";
						_markerWP setMarkerColor markerColorEnemy;						
						_radioTaskIntel = format ["Intel shows a target helicopter will land at %1. Marked it on the map.", mapGridPosition _taskData];
					};	
				};				
			};
					
			// Complete intel subtask if no intel left
			if (({(_x select 0) == (_thisTask select 0)} count taskIntel) == 0) then {
				[_subTask, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;	
			};	
		} else {
			taskIntel pushBack _thisTask;			
		};		
	};	
};
publicVariable "taskIntel";

// REGULAR INTEL & ZONES
_chanceUnitReveal = if (_revealUnits) then {random 1} else {0};
_sortedGroups = [];
if (_chanceUnitReveal > 0.4) then {
	_enemyGroups = [];
	{
		if (side _x == enemySide) then {
			_enemyGroups pushBack _x;
		};
	} forEach allGroups;
	if (count _enemyGroups > 0) then {
		_sortedGroups = [_enemyGroups, [_caller], {_input0 distance (leader _x)}, "ASCEND", {_input0 knowsAbout (leader _x) == 0}] call BIS_fnc_sortBy;
	};
};
for "_i" from 1 to _numReveals step 1 do {	
	if (_chanceUnitReveal > 0.4) then {
		if (count _sortedGroups > 0) then {
			_thisGroup = _sortedGroups select 0;
			_sortedGroups deleteAt 0;
			{
				[(grpNetId call BIS_fnc_groupFromNetId), [_x, 3.5]] remoteExec ["reveal", 0];
			} forEach (units _thisGroup);
			_unitRevealUsed = true;
		};			
	};
	//diag_log format ["DRO: enemyIntelMarkers = %1", enemyIntelMarkers];
	if (count enemyIntelMarkers > 0) then {
		_sortedMarkers = [enemyIntelMarkers, [_caller], {_input0 distance (getMarkerPos _x)}, "ASCEND"] call BIS_fnc_sortBy;
		_thisMarker = _sortedMarkers select 0;
		enemyIntelMarkers = enemyIntelMarkers - [_thisMarker];
		//_thisMarker = [enemyIntelMarkers] call sun_selectRemove;			
		//diag_log format ["DRO: Revealing marker %1", _thisMarker];
		if (typeName _thisMarker == "ARRAY") then {
						
		} else {	
			_thisMarker setMarkerAlpha 1;					
			_markerRevealUsed = 1;
		};				
	};	
};

if (!isNull _caller) then {
	_radioDescZone = "";
	_radioDescIcon = "";
	_radioDescTroops = "";
	if (_markerZoneShrunk) then {
		_radioDescZone = selectRandom ["This will help narrow our search area a bit. ", "These documents rule out some of our search area. ", "Looks like this message narrows our search area. "];
	};
	if (_markerRevealUsed == 1) then {
		_radioDescIcon = selectRandom ["Found some points of interest and marked them on the map. ", "Interesting, I've marked some positions to watch for. "];
	};
	if (_unitRevealUsed) then {
		_radioDescTroops = selectRandom ["Some of these communications reveal troop placements. They've been marked on the map.", "This map shows where some enemy units should be, I've copied their positions across to ours."];
	};	
	if (((count _radioDescZone) > 0) || ((count _radioDescIcon) > 0) || ((count _radioDescTroops) > 0) || ((count _radioTaskIntel) > 0)) then {
		_firstSentence = if (!isNull _intelSource) then {
			if (_intelSource isKindOf "Man") then {
				format ["%1 has given us some information.", name _intelSource];
			} else {
				selectRandom ["I've got some intel here.", "Heads up, found some intel.", "This might be useful."]
			};
		} else {
			selectRandom ["I've got some intel here.", "Heads up, found some intel.", "This might be useful."]
		};
		_radioDesc = format ["%1%2%3", _radioDescZone, _radioDescIcon, _radioDescTroops];
		[_caller, _firstSentence, _radioDesc, _radioTaskIntel] spawn {
			params ["_caller", "_firstSentence", "_radioDesc", "_radioTaskIntel"];
			dro_messageStack pushBack [
				[
					[name _caller, _firstSentence, 0]	
				],
				false
			];
			["REVEAL_INTEL", name _caller, [_radioDesc, _radioTaskIntel], false] spawn dro_sendProgressMessage;
		};
	} else {
		_phrase = selectRandom [
			"Nothing important here.",
			"I can't find anything interesting here.",
			"Nothing here we don't already know."				
		];
		dro_messageStack pushBack [
			[
				[name _caller, _phrase, 0]
			],
			false
		];		
	};	
};
publicVariable "enemyIntelMarkers";	
