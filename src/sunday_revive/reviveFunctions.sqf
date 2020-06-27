rev_AIListen = {
	params ["_aiUnits"];
	{
		//diag_log reviveUnits;
		//diag_log format ["%5 - rev_downed: %1, rev_beingAssisted: %2, rev_dragged: %3, rev_beingRevived: %4", (_x getVariable ["rev_downed", false]), (_x getVariable ["rev_beingAssisted", false]), (_x getVariable ["rev_dragged", false]), (_x getVariable ["rev_beingRevived", false]), _x];
		if ((_x getVariable ["rev_downed", false]) && !(_x getVariable ["rev_beingAssisted", false]) && !(_x getVariable ["rev_dragged", false]) && !(_x getVariable ["rev_beingRevived", false]) && (side _x != sideEnemy)) then {			
			_downedUnit = _x;
			_availableMedics = [];
			_medicWeights = [];
			// Get medic weights
			{
				_medic = _x;				
				if (alive _medic && !(_medic getVariable ["rev_downed", false]) && !(_medic getVariable ["rev_revivingUnit", false])) then {
					_thisWeight = 0;
					// Check for medikits and FAKS
					if ("Medikit" in (items _medic)) then {
						_thisWeight = _thisWeight + 0.7;
					};
					if ("FirstAidKit" in (items _medic)) then {
						_thisWeight = _thisWeight + 0.1;
					};
					// If no medikits or FAKS are present exit without giving a weight - this unit will not be used
					if (_thisWeight == 0) exitWith {
						if (isPlayer _downedUnit) then {							
							[_medic] remoteExec ["rev_findFAK", _medic];
						};
					};
					// Apply distance weighting
					_dist = _medic distance _downedUnit;
					if (_dist <= 200) then {
						_thisWeight = (_thisWeight + ((1-(_dist/100))*0.5)) max 0;
					};										
					// Apply timeout weighting
					_thisWeight = _thisWeight - ((_medic getVariable ["rev_timeoutCounter", 0])*0.9);
					_thisWeight = _thisWeight max 1;
					_availableMedics pushBack _medic;
					_medicWeights pushBack _thisWeight;
				};				
			} forEach _aiUnits;	
			
			if (count _availableMedics > 0) then {
				diag_log _availableMedics;
				diag_log _medicWeights;
				_chosenMedic = _availableMedics selectRandomWeighted _medicWeights;
				[_chosenMedic, _downedUnit] remoteExec ["rev_AIHeal", _chosenMedic];
				_chosenMedic setVariable ["rev_revivingUnit", true, true];	
			};			
		};
	} forEach reviveUnits;	
};

rev_addReviveToUnit = {
	params ["_unit", "_unitOld"];
	_unit setVariable ["rev_beingAssisted", false, true];		
	_unit setVariable ["rev_beingRevived", false, true];
	_unit setVariable ["rev_revivingUnit", false, true];
	_unit setVariable ["rev_downed", false, true];
	_unit setVariable ["rev_dragged", false, true];	
	_unit setVariable ["rev_lastPatient", objNull, true];		
	_unit setVariable ["rev_timeoutCounter", 0, true];		
	
	if (isMultiplayer) then {
		if (!isPlayer _unit) then {
			_handlerLocal = [_unit, ["Local", rev_changeLocal]] remoteExec ["addEventHandler", 0, true];
		};
		_handlerDamage = [_unit, ["HandleDamage", rev_handleDamage]] remoteExec ["addEventHandler", _unit, true];	
		_handlerKilled = [_unit, ["Killed", rev_handleKilled]] remoteExec ["addEventHandler", _unit, true];
		_handlerRespawn = [_unit, ["Respawn", {
			(_this select 0) removeAllEventHandlers "HandleDamage";		
			(_this select 0) removeAllEventHandlers "Killed";				
			_handlerDamage = (_this select 0) addEventHandler ["HandleDamage", rev_handleDamage];
			_handlerKilled = (_this select 0) addEventHandler ["Killed", rev_handleKilled];
			(_this select 0) setCaptive false;
			reviveUnits = reviveUnits - [(_this select 1)];
			reviveUnits pushBack (_this select 0);
			publicVariable 'reviveUnits';
			private _allPlayers = allPlayers;
			_allPlayers = _allPlayers - [(_this select 0)];	
			[(_this select 0)] remoteExec ["rev_reviveActionAdd", _allPlayers, true];
			[(_this select 0)] remoteExec ["rev_dragActionAdd", _allPlayers, true];
			[(format ["Revive actions added for unit %1 called for %2", (_this select 0), _allPlayers])] remoteExec ["diag_log", 2];	
		}]] remoteExec ["addEventHandler", _unit, true];			
	} else {
		_handlerDamage = _unit addEventHandler ["HandleDamage", rev_handleDamage];
		_handlerKilled = _unit addEventHandler ["Killed", rev_handleKilled];		
	};	
	if (!isNil "_unitOld") then {			
		reviveUnits = reviveUnits - [_unitOld];			
	};
	_unit setCaptive false;
	reviveUnits pushBack _unit;
	
	private _allPlayers = allPlayers;
	_allPlayers = _allPlayers - [_unit];	
	[_unit] remoteExec ["rev_reviveActionAdd", _allPlayers, true];
	[_unit] remoteExec ["rev_dragActionAdd", _allPlayers, true];	
	if (player == _unit) then {
		{
			if (_x != _unit) then {
				[_x] call rev_reviveActionAdd;
				[_x] call rev_dragActionAdd;				
			};
		} forEach reviveUnits;
	};
	diag_log format ["Revive actions add for unit %1 called for %2", _unit, _allPlayers];
	[(format ["Revive actions add for unit %1 called for %2", _unit, _allPlayers])] remoteExec ["diag_log", 2];	
	
	publicVariable 'reviveUnits';
	[(format ["Revive added to unit %1", _unit])] remoteExec ["diag_log", 2];
	//diag_log format ["Revive added to unit %1", _unit];	
};

rev_resetAI = {
	params ["_unit"];	
	private _startGroup = group _unit;
	private _loadout = (getUnitLoadout _unit);
	private _varName = vehicleVarName _unit;
	private _id = parseNumber ((str _unit) select [1]);
	_id = _id - 1;
	private _class = (typeOf _unit);
	private _firstName = ((nameLookup select _id) select 0);
	private _lastName = ((nameLookup select _id) select 1);
	private _speaker = ((nameLookup select _id) select 2);
	private _face = ((nameLookup select _id) select 3);
	private _pos = [(getPos _unit), 0, 50, 1, 0, -1, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
	if (_pos isEqualTo [0,0,0]) then {
		_pos = [(getPos player), 0, 50, 1, 0, -1, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
	};
	if (_pos isEqualTo [0,0,0]) exitWith {
		hint "No valid location found for unit reset!";
	};
	private _grp = createGroup playersSide;
	private _unitNew = _grp createUnit [_class, _pos, [], 0, "NONE"];
	diag_log format ["DRO: reset - created unit %1 in group %2, side %3", _unitNew, _grp, playersSide];
	if (reviveDisabled < 3) then {	
		[_unitNew, _unit] call rev_addReviveToUnit;
	};
	deleteVehicle _unit;
	[_unitNew, _varName] remoteExec ["setVehicleVarName", 0, true];
	diag_log format ["DRO: reset - unit %1 given var name %2", _unitNew, _varName];
	diag_log format ["DRO: reset - unit %1 new var name is %2", _unitNew, vehicleVarName _unitNew];
	[_unitNew, ([format ["%1 %2", _firstName, _lastName], _firstName, _lastName])] remoteExec ["setName", 0, true];
	[_unitNew, _lastName] remoteExec ["setNameSound", 0, true];
	[_unitNew, _firstName, _lastName, _speaker, _face] remoteExec ['sun_setNameMP', 0, true];
	diag_log "DRO: reset - names set";
	_unitNew joinAsSilent [_playerGroup, _id];
	diag_log format ["DRO: reset - unit %1 joined to group %2 in position %3", _unitNew, _playerGroup, _id];
	_unitNew setUnitLoadout _loadout;
	_unitNew setVariable ["respawnLoadout", (getUnitLoadout _unitNew), true];
	_unitNew setUnitTrait ["Medic", true];
	_unitNew setUnitTrait ["engineer", true];
	_unitNew setUnitTrait ["explosiveSpecialist", true];
	_unitNew setUnitTrait ["UAVHacker", true];
	if ((paramsArray select 0) == 1) then {
		[_unitNew, ["respawn", {
			_unitNew = (_this select 0);				
			deleteVehicle _unitNew
		}]] remoteExec ["addEventHandler", _unitNew, true];
	} else {
		[_unitNew, ["killed", {[(_this select 0)] execVM "sunday_system\player_setup\fakeRespawn.sqf"}]] remoteExec ["addEventHandler", _unitNew, true];
		[_unitNew, ["respawn", {
			_unitNew = (_this select 0);				
			deleteVehicle _unitNew
		}]] remoteExec ["addEventHandler", _unitNew, true];				
	};
	deleteGroup _grp;
	_unitNew
};

rev_findFAK = {
	params ["_unit"];
	_list = _unit nearSupplies 150;
	_FAKLocations = [];
	{
		if ("FirstAidKit" in (items _x)) then {
			_FAKLocations pushBack _x;
		};
	} forEach _list;
	if (count _FAKLocations > 0) then {		
		_nearFAKs = [_FAKLocations,[],{_unit distance _x},"ASCEND"] call BIS_fnc_sortBy;
		_nearestFAK = _nearFAKs select 0;			
		[_unit, "I'm going to find a first aid kit!"] remoteExec ["groupChat", 0];
		_unit setVariable ["rev_revivingUnit", true, true];
		[_unit, _nearestFAK] spawn {
			_unit = _this select 0;
			_nearestFAK = _this select 1;
			while {(_unit distance _nearestFAK) >= 4} do {
				sleep 1;
				_unit doMove (getPos _nearestFAK);
				_unit moveTo (getPosATL _nearestFAK);
			};		
			_unit playAction "PutDown";	
			_nearestFAK removeItem "FirstAidKit";
			_unit addItem "FirstAidKit";
			_unit setVariable ["rev_revivingUnit", false, true];
		};
	};
};

rev_changeLocal = {
	params ["_unit", "_local"];
	(format ["Revive: Attempting locality change for unit %1", _unit]) remoteExec ["diag_log", 2];
	if (_local) then {
		_unit removeAllEventHandlers "HandleDamage";		
		_unit removeAllEventHandlers "Killed";		
		_handlerDamage = [_unit, ["HandleDamage", rev_handleDamage]] remoteExec ["addEventHandler", _unit, true];	
		_handlerKilled = [_unit, ["Killed", rev_handleKilled]] remoteExec ["addEventHandler", _unit, true];
		_handlerRespawn = [_unit, ["Respawn", {
			_handlerDamage = (_this select 0) addEventHandler ["HandleDamage", rev_handleDamage];
			_handlerKilled = (_this select 0) addEventHandler ["Killed", rev_handleKilled];
			(_this select 0) setCaptive false;
			reviveUnits = reviveUnits - [(_this select 1)];
			reviveUnits pushBack (_this select 0);
			publicVariable 'reviveUnits';
		}]] remoteExec ["addEventHandler", _unit, true];		
		
		private _reviveUnits = reviveUnits;
		_reviveUnits = _reviveUnits - [_unit];
		if !((_reviveUnits select 0) getVariable ["rev_downed", false]) then {
			if (group _unit != group (_reviveUnits select 0)) then {
				[_unit] joinSilent group (_reviveUnits select 0);
			};
		};
		
		(format ["Revive: Locality changed for unit %1", _unit]) remoteExec ["diag_log", 2];
		//diag_log (format ["Revive: Locality changed for unit %1", _unit]);		
		 
	};
};

rev_reviveUnit = {
	private ["_unit", "_medic"];
	_unit = _this select 0;
	_medic = _this select 1;
	
	//diag_log format ["DRO: Unit %1 is revived by medic %2", _unit, _medic];	
	if (isPlayer _unit) then {
		//diag_log format ["DRO: Revive of %1 processed as a player unit", _unit];		
		[] remoteExec ["rev_resetCamera", _unit];	
		[_unit, false] remoteExec ["setUnconscious", _unit];		
		[_unit, true] remoteExec ["allowDamage", _unit];
		[_unit, false] remoteExec ["setCaptive", _unit];		
	} else {
		if (local _unit) then {
			//diag_log format ["DRO: Revive of %1 processed as a local AI unit", _unit]; 
			_unit setUnconscious false;			
			_unit allowDamage true;
			_unit setCaptive false;
		} else {
			//diag_log format ["DRO: Revive of %1 processed as a non-local AI unit", _unit]; 
			[_unit, false] remoteExec ["setUnconscious", _unit];		
			[_unit, true] remoteExec ["allowDamage", _unit];
			[_unit, false] remoteExec ["setCaptive", _unit];
		};
	};

	[(format ["DRO: Unit %1 is revived by medic %2", _unit, _medic])] remoteExec ["diag_log", 2];
	
	if ("Medikit" in (items _medic)) then {
		_unit setDamage 0;	
	} else {
		if ("FirstAidKit" in (items _medic)) then {
			_medic removeItem "FirstAidKit";
			if !(isClass(configFile >> "CfgPatches" >> "ace_medical")) then {_unit setDamage 0.4};					
		} else {
			if !(isClass(configFile >> "CfgPatches" >> "ace_medical")) then {_unit setDamage 0.75};			
		};
	};

	if !("FirstAidKit" in (items _medic) OR "Medikit" in (items _medic)) then {
		diag_log format ["Revive: %1 is out of medical supplies", _medic];
		_string = selectRandom ["I'm out of medical supplies.", "That was my last first aid kit.", "Going to need more medical supplies."];
		[_medic, _string] remoteExec ["groupChat", 0];
		
	};

	_unit setVariable ["rev_downed", false, true];
	_unit setVariable ["rev_beingAssisted", false, true];
	_unit setVariable ["rev_beingRevived", false, true];
	_unit setVariable ["rev_dragged", false, true];
		
	/*
	if (group _unit != group _medic) then {
		[_unit] joinSilent group _medic;
	};
	*/
};

rev_reviveActionAdd = {	
	private _id = [
		(_this select 0),
		"Revive",
		"\A3\Ui_f\data\IGUI\Cfg\Revive\overlayIcons\u100_ca.paa",
		"\A3\Ui_f\data\IGUI\Cfg\Revive\overlayIcons\r100_ca.paa",
		"((_this distance _target) < 3) && (alive _target) && (_target getVariable ['rev_downed', false]) && !(_target getVariable ['rev_dragged', false])",
		"((_caller distance _target) < 3) && (alive _target) && (_target getVariable ['rev_downed', false]) && !(_target getVariable ['rev_dragged', false])",
		{(_this select 0) setVariable ["rev_beingRevived", true, true]},
		{},
		{			
			[(_this select 0), (_this select 1)] remoteExec ["rev_reviveUnit", (_this select 1)];
		},
		{(_this select 0) setVariable ["rev_beingRevived", false, true]},
		[],
		reviveTime,
		1000,
		false,
		false
	] call BIS_fnc_holdActionAdd;
	diag_log format ["Revive: Revive action ID %1 added for unit %1", _id, (_this select 0)];
	[(format ["Revive: Revive action ID %1 added for unit %1", _id, (_this select 0)])] remoteExec ["diag_log", 2];
	(_this select 0) setVariable ["rev_holdActionID", _id, true];
};

rev_handleDamage = {
	params ["_unit", "_selection", "_damage","_source","","_index"];
	/*
	if (_unit getVariable ["rev_downed", false]) then {
		_damage = 0;
	};
	*/
	if(alive _unit && _selection == "" && _damage >= 0.9 && !(_unit getVariable ["rev_downed", false])) then {
		_unit setVariable ["rev_downed", true, true];
		[(format ["Revive: Lethal damage handled for %1", _unit])] remoteExec ["diag_log", 2];
		//diag_log (format ["Revive: Lethal damage handled for %1", _unit]);		
		_unit setVariable ["rev_beingRevived", false, true];		
		_unit setDamage 0.95;
		_unit setCaptive true;		
		if(vehicle _unit != _unit) then {moveOut _unit};	
		_unit setUnconscious true;		
		
		// Player PP effects
		if (_unit == player) then {					
			VAR_CAMERA_VIEW = cameraView;
		
			bis_revive_ppColor = ppEffectCreate ["ColorCorrections", 1632];
			bis_revive_ppVig = ppEffectCreate ["ColorCorrections", 1633];
			bis_revive_ppBlur = ppEffectCreate ["DynamicBlur", 525];

			bis_revive_ppColor ppEffectAdjust [1,1,0.15,[0.3,0.3,0.3,0],[0.3,0.3,0.3,0.3],[1,1,1,1]];
			bis_revive_ppVig ppEffectAdjust [1,1,0,[0.15,0,0,1],[1.0,0.5,0.5,1],[0.587,0.199,0.114,0],[1,1,0,0,0,0.2,1]];
			bis_revive_ppBlur ppEffectAdjust [0];
			{_x ppEffectCommit 0; _x ppEffectEnable true; _x ppEffectForceInNVG true} forEach [bis_revive_ppColor, bis_revive_ppVig, bis_revive_ppBlur];			
		};
		
		_damage = 0;
		_string = selectRandom ["I'm hit!", "Need medical attention!", "I'm down!"];		
		[_unit, _string] remoteExec ["groupChat", 0];				
		
		[_unit] execVM "sunday_revive\bleedout.sqf";			
	};	
	
	if(_damage >= 1) then {_damage = 0.85};	
	//diag_log (format ["Revive: %1 _damage = %2", _unit, _damage]);
	//[(format ["Revive: %1 _damage = %2", _unit, _damage])] remoteExec ["diag_log", 2];
	_damage
};

rev_suicideActionAdd = {
	private ["_id"];
	_id = [
		(_this select 0),
		"Suicide",
		"\A3\Ui_f\data\IGUI\Cfg\Revive\overlayIcons\d50_ca.paa",
		"\A3\Ui_f\data\IGUI\Cfg\Revive\overlayIcons\d100_ca.paa",
		"alive _target",
		"alive _target",
		{},
		{},
		{			
			(_this select 0) setDamage 1;
			//[(_this select 0), (_this select 2)] remoteExec ["bis_fnc_holdActionRemove", 0, true];			
		},
		{},
		[],
		3,
		1000,
		true,
		true
	] call BIS_fnc_holdActionAdd;
	[(format ["Revive: Suicide action ID %1 added for unit %1", _id, (_this select 0)])] remoteExec ["diag_log", 2];
	_id
};

rev_resetCamera = {
	if (!isNil "VAR_CAMERA_VIEW") then {		
		[] spawn
		{
			titleCut ["","BLACK OUT",0.5];
			sleep 0.5;
			if (cameraView != VAR_CAMERA_VIEW) then {
				player switchCamera VAR_CAMERA_VIEW;
			};
			{_x ppEffectCommit 0; _x ppEffectEnable false; _x ppEffectForceInNVG false} forEach [bis_revive_ppColor, bis_revive_ppVig, bis_revive_ppBlur];
			titleCut ["","BLACK IN",0.5];
		};		
	} else {
		[] spawn
			{
				titleCut ["","BLACK OUT",0.5];
				sleep 0.5;
				player switchCamera "INTERNAL";
				{_x ppEffectCommit 0; _x ppEffectEnable false; _x ppEffectForceInNVG false} forEach [bis_revive_ppColor, bis_revive_ppVig, bis_revive_ppBlur];
				titleCut ["","BLACK IN",0.5];
			};
	};
};

rev_dragActionAdd = {	
	private _id = (_this select 0) addAction [
		"Drag",
		{[_this select 0] call rev_drag},
		nil,
		10,
		false,
		true,
		"",
		"alive _target && (_target getVariable ['rev_downed', false]) && !(_target getVariable ['rev_dragged', false]) && !(_target getVariable ['rev_beingRevived', false])",
		3,
		false];
	(_this select 0) setVariable ["rev_dragActionID", _id, true];
	[(format ["Revive: added drag action %2 for %1", (_this select 0), _id])] remoteExec ["diag_log", 2];
	//diag_log format ["Revive: added drag action %2 for %1", (_this select 0), _id];
};

rev_drag = {
	private ["_target"];
	_target = _this select 0;
	playerDragging = true;
	_target setVariable ["rev_dragged", true, true];
	sleep 0.5;
	player playMoveNow "AcinPknlMstpSrasWrflDnon";
	_target attachTo [player, [0, 1.18, 0.08]];
	[_target, 180] remoteExec ["setDir", 0];
	
	_target enableSimulationGlobal false;	
	_dropID = player addAction ["<img image='\A3\ui_f\data\map\markers\military\end_CA.paa'/>Release", {playerDragging = false; (_this select 0) removeAction (_this select 2);}, [], 10, true, true, "", ""];
		
	while {alive player && !(player getVariable ["rev_downed", false]) && (_target getVariable ["rev_downed", true]) && playerDragging} do {
		sleep 0.2;
	};
	
	_target enableSimulationGlobal true;
				
	if(alive player && !(player getVariable ["rev_downed", false])) then { 
		player playMove "amovpknlmstpsraswrfldnon";
	};
	
	playerDragging = false;	
	detach _target;
	sleep 2;
	_target setVariable ["rev_dragged", false, true];	
};

rev_handleKilled = {	
	private ["_unit"];	
	_unit = (_this select 0);
	_unit setVariable ["rev_beingAssisted", false, true];		
	_unit setVariable ["rev_beingRevived", false, true];
	_unit setVariable ["rev_revivingUnit", false, true];
	_unit setVariable ["rev_downed", false, true];
	_unit setVariable ["rev_dragged", false, true];
	if (_unit == player) then {
		if (!isNil "bis_revive_ppColor") then {
			{_x ppEffectCommit 0; _x ppEffectEnable false; _x ppEffectForceInNVG false} forEach [bis_revive_ppColor, bis_revive_ppVig, bis_revive_ppBlur];
		};
	};
	[(format ["Revive: handleKilled fired for %1", _unit])] remoteExec ["diag_log", 2];
};

rev_AIHeal = {	
	private ["_medic","_target","_moveTimeout","_cancelRevive","_previousMedicCommand","_previousBehaviour","_previousMedicPos"];

	_medic = (_this select 0);
	_target = (_this select 1);
	_targetPos = getPos _target;
	
	_medic enableAI "MOVE";
	
	endRevive = {	
		_medic enableAI "AUTOTARGET";
		_medic enableAI "TARGET";
		_medic enableAI "MOVE";		
		//_medic setCaptive false;
		_medic allowDamage true;	
		if (!isNil "_previousMedicCommand") then {
			if (count _previousMedicCommand == 0) then {
				_medic doFollow (leader group _medic);
			} else {
				_medic doMove _previousMedicPos;
				_medic moveTo _previousMedicPos;
			};
		} else {
			if (!isNil "_previousMedicPos") then {
				_medic doMove _previousMedicPos;
				_medic moveTo _previousMedicPos;
			};
		};
		/*
		if (count _previousBehaviour > 0) then {
			[_medic, _previousBehaviour] remoteExec ["switchBehaviour", 2];
		} else {
			[_medic, "AWARE"] remoteExec ["switchBehaviour", 2];
		};
		//["AWARE"] call switchBehaviour;
		*/
		_medic setVariable ["rev_revivingUnit", false, true];
		_target setVariable ["rev_beingAssisted", false, true];
	};

	switchBehaviour = {
		params ["_medic", "_behaviour", "_startGroup", "_tempGroup"];				
		_startGroup = (group _medic);
		_tempGroup = createGroup (side _medic);
		diag_log format ["Revive: medic switchBehaviour _startGroup: %1", _startGroup];
		diag_log format ["Revive: medic switchBehaviour _tempGroup: %1", _tempGroup];
		diag_log format ["Revive: medic switchBehaviour _behaviour: %1", _behaviour];
		[_medic] joinSilent _tempGroup;	
		_medic setBehaviour _behaviour;	
		diag_log format ["Revive: medic joinGroup: %1", _startGroup];		
		//[_medic] joinSilent _startGroup;					
		[_medic] joinSilent (reviveGroup call BIS_fnc_groupFromNetId);					
	};

	_medic setVariable ["rev_revivingUnit", true, true];
	_target setVariable ["rev_beingAssisted", true, true];
	
	[(format ["Revive: AI medic %1 activated for target %2", _medic, _target])] remoteExec ["diag_log", 2];
	//diag_log format ["Revive: AI medic %1 activated for target %2", _medic, _target];

	_previousMedicCommand = currentCommand _medic;
	_previousBehaviour = "";
	_previousBehaviour = behaviour (leader _medic);
	_previousMedicPos = getPosATL _medic;
	_cancelRevive = false;

	_medic allowDamage false;
	//_medic setCaptive true;
	_medic stop false;				
	_medic disableAI "AUTOTARGET";
	_medic disableAI "TARGET";
	//[_medic, "CARELESS"] remoteExec ["switchBehaviour", 2];
	//["CARELESS"] call switchBehaviour;
	//doStop _medic;
	_moveTimeout = time + 60;

	_lastName = "";
	if (!isPlayer _target) then {
		if (count (nameSound _target) > 0) then {
			_lastName = nameSound _target;
		} else {
			_name = name _target;
			_lastName = if (isPlayer _target) then {
				_name
			} else {
				_splitName = _name splitString " ";
				_splitName select (count _splitName - 1)
			};
		};
	} else {
		_name = name _target;
		_lastName = if (isMultiplayer) then {
			_name
		} else {
			_splitName = _name splitString " ";
			_splitName select (count _splitName - 1)
		};				
	};

	_string = selectRandom [format ["Assisting %1, sit tight!", _lastName], format ["I'm attending to %1!", _lastName], format ["Hold on %1, medic on the way!", _lastName]];
	[_medic, _string] remoteExec ["groupChat", 0];
	
	while {(_medic distance _target) >= 4} do {
		sleep 1;
		_medic doMove (getPos _target);
		_medic moveTo (getPosATL _target);
		sleep 2;
		if (!alive _target) exitWith {
			diag_log format ["Revive: AI %1 cancelling revive due to target death", _medic];
			_cancelRevive = true;	
		};
		if(!alive _medic) exitWith {
			diag_log format ["Revive: AI %1 cancelling revive due to medic death", _medic];
			_cancelRevive = true;	
		};
		if (_target getVariable ["rev_beingRevived", false]) exitWith {
			diag_log format ["Revive: AI %1 cancelling revive due to target already being revived", _medic];
			_cancelRevive = true;
		};
		if (_target getVariable ["rev_dragged", false]) exitWith {
			diag_log format ["Revive: AI %1 cancelling revive due to target being dragged", _medic];
			_cancelRevive = true;
		};
		if (time > _moveTimeout) exitWith {
			diag_log format ["Revive: AI %1 forced revive due to timeout", _medic];
			_medic setVariable ["rev_timeoutCounter", ((_medic getVariable ['rev_timeoutCounter', 0])+1), true];	
			//_cancelRevive = true;			
			_medic setPos (_target getPos [1, (random 360)]);
		};		
	};

	if (_cancelRevive) exitWith {
		[] call endRevive;
	};
	waitUntil {_medic distance _target <= 4};
	/*
	if(!alive _medic || (_target getVariable "rev_beingRevived") == 1 || (_target getVariable ["rev_dragged", false])) exitWith {		
		hint "cancel 2";
		[] call endRevive;
	};
	*/
	//_medic setCaptive true;
	//_medic allowDamage false;
	_medic disableAI "MOVE";
	_medic setDir ([_medic, _targetPos] call BIS_fnc_dirTo);

	_startTime = time;
	_medic playMoveNow "AinvPknlMstpSnonWnonDnon_medic0S";
	//_target setVariable ["rev_beingRevived", true, true];
	while {time < _startTime + reviveTime} do {	
		_medic playMoveNow "AinvPknlMstpSnonWnonDnon_medic0S";
		
		if (!alive _target) exitWith {
			_medic playMoveNow "AinvPknlMstpSnonWnonDnon_medicEnd";
			sleep 3;
			_cancelRevive = true;	
		};
		if (_target getVariable ["rev_beingRevived", false])  exitWith {
			_medic playMoveNow "AinvPknlMstpSnonWnonDnon_medicEnd";
			sleep 3;
			_cancelRevive = true;	
		};
		if (_target getVariable ["rev_dragged", false]) exitWith {
			_medic playMoveNow "AinvPknlMstpSnonWnonDnon_medicEnd";
			sleep 3;
			_cancelRevive = true;
		};
		if !(_target getVariable ["rev_downed", false]) exitWith {
			_medic playMoveNow "AinvPknlMstpSnonWnonDnon_medicEnd";
			sleep 3;
			_cancelRevive = true;
		};
	};
	_medic playMoveNow "AinvPknlMstpSnonWnonDnon_medicEnd";
	sleep 3;

	if (_cancelRevive) exitWith {	
		[] call endRevive;
	};

	[_target, _medic] call rev_reviveUnit;
	_medic setVariable ["rev_timeoutCounter", 0, true];
	[] call endRevive;
};
