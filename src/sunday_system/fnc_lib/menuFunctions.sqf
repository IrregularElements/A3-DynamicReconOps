sun_monthSelChange = {
	params ["_data"];
	month = (_data select 1);
	publicVariable 'month';
	_newDate = date;
	_newDate set [1, month];
	[_newDate] remoteExec ['setDate', 0, true];
	[2301] call dro_inputDaysData;
	profileNamespace setVariable ['DRO_month', (_data select 1)];
	if (menuComplete) then {
		sleep 0.4;
		[timeOfDay] remoteExec ['sun_randomTime', 0, true]
	};
};
sun_daySelChange = {
	params ["_data"];
	day = (_data select 1);
	publicVariable 'day';
	_newDate = date;
	_newDate set [2, day];
	[_newDate] remoteExec ['setDate', 0, true];
	profileNamespace setVariable ['DRO_day', (_data select 1)];
	if (menuComplete) then {
		sleep 0.4;
		[timeOfDay] remoteExec ['sun_randomTime', 0, true]
	};
};

sun_switchButtonSet = {
	params ["_table", "_idc", "_index"];
	_optionData = [_table, _idc] call sun_switchLookup;	
	diag_log _optionData;
	_varStr = (_optionData select 0);	
	_allValues = (_optionData select 2);
	//diag_log _index;
	missionNamespace setVariable [_varStr, _index, true];
	profileNamespace setVariable [(format ["DRO_%1", _varStr]), _index];
	ctrlSetText [(_idc + 3), (_allValues select _index)];	
};

sun_switchLookup = {
	params ["_table", "_idc"];
	_return = [];	
	switch (_table) do {
		case "MAIN": {
			switch (_idc) do {
				case 2020: {
					_return pushBack "aoOptionSelect";
					_return pushBack aoOptionSelect;			
					_return pushBack ["ENABLED", "DISABLED"];			
				};
				case 2030: {
					_return pushBack "aiSkill";
					_return pushBack aiSkill;			
					_return pushBack ["NORMAL", "HARD", "REALISM"];			
				};
				case 2050: {
					_return pushBack "minesEnabled";
					_return pushBack minesEnabled;			
					_return pushBack ["DISABLED", "ENABLED"];			
				};
				case 2060: {
					_return pushBack "civiliansEnabled";
					_return pushBack civiliansEnabled;			
					_return pushBack ["RANDOM", "ENABLED", "ENABLED & HOSTILE", "DISABLED"];			
				};
				case 2070: {
					_return pushBack "stealthEnabled";
					_return pushBack stealthEnabled;			
					_return pushBack ["RANDOM", "ENABLED", "DISABLED"];			
				};
				case 2080: {
					_return pushBack "reviveDisabled";
					_return pushBack reviveDisabled;			
					_return pushBack ["300 SECONDS", "120 SECONDS", "60 SECONDS", "DISABLED"];			
				};
				case 2090: {
					_return pushBack "missionPreset";
					_return pushBack missionPreset;
					_return pushBack ["CURRENT SETTINGS", "RECON OPS", "SNIPER OPS", "COMBINED ARMS"];					
				};
				case 2400: {
					_return pushBack "dynamicSim";
					_return pushBack dynamicSim;			
					_return pushBack ["ENABLED", "DISABLED"];					
				};
				case 3010: {
					_return pushBack "timeOfDay";
					_return pushBack timeOfDay;			
					_return pushBack ["RANDOM", "DAWN", "DAY", "DUSK", "NIGHT"];					
				};
				case 3020: {
					_return pushBack "weatherOvercast";
					_return pushBack weatherOvercast;			
					_return pushBack ["RANDOM", "CUSTOM"];					
				};
				case 3030: {
					_return pushBack "animalsEnabled";
					_return pushBack animalsEnabled;			
					_return pushBack ["ENABLED", "DISABLED"];					
				};
				case 4010: {
					_return pushBack "numObjectives";
					_return pushBack numObjectives;			
					_return pushBack ["RANDOM", "1", "2", "3"];					
				};
			};			
		};
		case "LOBBY": {
			
		};
	};
	_return
};

sun_switchButtonWeather = {
	params ["_table", "_idc", ["_change", true], ["_setVal", -1]];	
	_optionData = [_table, _idc] call sun_switchLookup;
	//diag_log _optionData;
	_varStr = (_optionData select 0);
	_currentIndex = (_optionData select 1);
	if (_currentIndex isEqualType "") then {
		weatherOvercast = 'RANDOM';
		_currentIndex = 0;
	} else {
		if (_currentIndex == 0) then {
			weatherOvercast = 'RANDOM';
		} else {
			weatherOvercast = (round (((sliderPosition 2109)/10) * (10 ^ 3)) / (10 ^ 3));
			//_currentIndex = 1;
		};
	};	
	if (typeName weatherOvercast isEqualTo 'SCALAR') then {
		[weatherOvercast] call BIS_fnc_setOvercast;
	};
	_allValues = (_optionData select 2);
	_newIndex = -1;
	if (_setVal == -1) then {
		if (_change) then {
			if (ctrlText (_idc + 3) == "RANDOM") then {
				_newIndex = 1
			} else {
				_newIndex = 0;
				weatherOvercast = 'RANDOM';
			};	
		} else {
			_newIndex = 0;
			weatherOvercast = 'RANDOM';
		};
	} else {
		_newIndex = _setVal;
	};
	publicVariable 'weatherOvercast';
	profileNamespace setVariable ['DRO_weatherOvercast', weatherOvercast];	
	ctrlSetText [(_idc + 3), (_allValues select _newIndex)];	
};

sun_switchButton = {
	params ["_table", "_idc", ["_change", true], ["_action", "NONE"]];	
	_optionData = [_table, _idc] call sun_switchLookup;
	//diag_log "Called sun_switchButton";
	
	_varStr = (_optionData select 0);
	_currentIndex = (_optionData select 1);	
	_allValues = (_optionData select 2);
	_newIndex = if (_change) then {
		if (_currentIndex == ((count _allValues) - 1)) then {0} else {_currentIndex + 1}
	} else {
		_currentIndex
	};
	if (_newIndex > ((count _allValues) - 1)) then {_newIndex = 0};
	missionNamespace setVariable [_varStr, _newIndex, true];
	profileNamespace setVariable [(format ["DRO_%1", _varStr]), _newIndex];
	ctrlSetText [(_idc + 3), (_allValues select _newIndex)];
	if (_change) then {
		if (_action == "NONE") exitWith {};
		if (_action == "PRESET") exitWith {[_newIndex] call sun_missionPreset};
		if (_action == "TIME") exitWith {[_newIndex] remoteExec ['sun_randomTime', 0, true]};
	};
	diag_log format ["Switched: %1 to %2", _optionData, _newIndex];
};

sun_lobbyReadyButton = {
	if (player getVariable ['startReady', false]) then {
		player setVariable ['startReady', false, true];
		((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseEnter", "(_this select 0) ctrlsettextcolor [0,0,0,1]"];
		((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseExit", "(_this select 0) ctrlsettextcolor [1,1,1,1]"];
		((findDisplay 626262) displayCtrl 1601) ctrlSetTextColor [0,0,0,1];
	} else {
		player setVariable ['startReady', true, true];
		((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseEnter", "(_this select 0) ctrlsettextcolor [0.04, 0.7, 0.4, 1]"];
		((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseExit", "(_this select 0) ctrlsettextcolor [0.05, 1, 0.5, 1]"];
		((findDisplay 626262) displayCtrl 1601) ctrlSetTextColor [0.05, 1, 0.5, 1];
	};
};

sun_clearInsert = {
	deleteMarker 'campMkr';
	{
		[626262, 6006, "Insertion position: RANDOM"] remoteExec ["sun_lobbyChangeLabel", _x];	
	} forEach allPlayers;
};

sun_lobbyMapPreview = {
	closeDialog 1;
	camLobby cameraEffect ["terminate","back"];
	camUseNVG false;
	camDestroy camLobby;	
	_mapOpen = openMap [true, false];
	mapAnimAdd [0, 0.05, markerPos "centerMkr"];
	mapAnimCommit;
	player switchCamera "INTERNAL";
	waitUntil {!visibleMap};	
	_handle = CreateDialog "DRO_lobbyDialog";
	[] execVM "sunday_system\dialogs\populateLobby.sqf";
};

sun_lobbyChangeLabel = {
	disableSerialization;
	params ["_display", "_idc", "_label"];
	if (!isNil "_idc") then {
		if ((ctrlClassName ((findDisplay _display) displayCtrl _idc) == "sundayText") OR (ctrlClassName ((findDisplay _display) displayCtrl _idc) == "sundayTextMT")) then {
			((findDisplay _display) displayCtrl _idc) ctrlSetText _label;
		};
	};
};

sun_lobbyCamTarget = {
	params ["_target"];
	if (camLobbyTarget != _target) then {
		((findDisplay 626262) displayCtrl 1159) ctrlSetPosition [1 * safezoneW + safezoneX, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 1, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 2, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 3];
		((findDisplay 626262) displayCtrl 1159) ctrlCommit 0.1;
		((findDisplay 626262) displayCtrl 1160) ctrlSetText "";
		((findDisplay 626262) displayCtrl 1160) ctrlSetFade 1;
		((findDisplay 626262) displayCtrl 1160) ctrlCommit 0;
		camLobbyTarget = _target;		
		_camPos = [(getPos _target), 3.4, (getDir _target)] call BIS_fnc_relPos;
		_camPos set [2, 1.1];
		_camTarget = [(getPos _target), 0.4, (getDir _target)+90] call BIS_fnc_relPos;
		_camTarget set [2, 0.9];
		camLobby camSetPos _camPos;
		camLobby camSetTarget _camTarget;
		camLobby camSetFocus [3.4, 1];
		camLobby camCommit 1;
		//sleep 1;
		[_target] spawn {
			_target = _this select 0;			
			_class = (configfile >> "CfgVehicles" >> (_target getVariable "unitClass") >> "displayName") call BIS_fnc_getCfgData;		
			_weapon	= (configfile >> "CfgWeapons" >> primaryWeapon _target >> "displayName") call BIS_fnc_getCfgData;			
			_string = format ["%2%1%3%1%4%1%5", "\n", name _target, rank _target, _class, _weapon];
			sleep 0.8;
			((findDisplay 626262) displayCtrl 1159) ctrlSetPosition [0.73 * safezoneW + safezoneX, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 1, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 2, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 3];			
			((findDisplay 626262) displayCtrl 1159) ctrlCommit 0.1;
			sleep 0.1;
			((findDisplay 626262) displayCtrl 1160) ctrlSetText _string;
			((findDisplay 626262) displayCtrl 1160) ctrlSetFade 0;
			((findDisplay 626262) displayCtrl 1160) ctrlCommit 0.2;
		};		
	};
};

dro_menuSlider = {
	disableSerialization;
	params ["_slide", "_display"];
		
	_currentMenu = menuSliderArray select menuSliderCurrent;	
	_selectedMenu = [];
	_menuSliderTarget = 0;
	switch (_slide) do {
		case "LEFT": {
			_menuSliderTarget = if (menuSliderCurrent == 0) then {((count menuSliderArray) - 1)} else {menuSliderCurrent - 1};
			_selectedMenu = menuSliderArray select _menuSliderTarget;
		};
		case "RIGHT": {
			_menuSliderTarget = if (menuSliderCurrent == ((count menuSliderArray) - 1)) then {0} else {menuSliderCurrent + 1};
			_selectedMenu = menuSliderArray select _menuSliderTarget;
		};
	};	
	// Slide current menu out to the left
	{
		if (_forEachIndex != 0) then {
			_thisCtrl = (_display displayCtrl _x);				
			_thisCtrl ctrlSetPosition [-0.4 * safezoneW + safezoneX, (ctrlPosition _thisCtrl) select 1, (ctrlPosition _thisCtrl) select 2, (ctrlPosition _thisCtrl) select 3];
			_thisCtrl ctrlCommit 0.1;
		};
	} forEach _currentMenu;
	sleep 0.1;
	// Slide next menu in from the left
	_leftPos = 0 * pixelGridNoUIScale * pixelW;
	{
		if (_forEachIndex == 0) then {
			_thisCtrl = (_display displayCtrl 1101);
			_thisCtrl ctrlSetText _x;
		} else {
			_thisCtrl = (_display displayCtrl _x);				
			//_thisCtrl ctrlSetPosition [0.01 * safezoneW + safezoneX, (ctrlPosition _thisCtrl) select 1, (ctrlPosition _thisCtrl) select 2, (ctrlPosition _thisCtrl) select 3];
			_thisCtrl ctrlSetPosition [safezoneX, (ctrlPosition _thisCtrl) select 1, (ctrlPosition _thisCtrl) select 2, (ctrlPosition _thisCtrl) select 3];
			_thisCtrl ctrlCommit 0.2;
		};
	} forEach _selectedMenu;			
	menuSliderCurrent = _menuSliderTarget;		
};



dro_menuMap = {
	disableSerialization;
	_map = ((findDisplay 52525) displayCtrl 1200);
	_button = ((findDisplay 52525) displayCtrl 2011);	
	/*
	_worldCenter = (configfile >> "CfgWorlds" >> worldName >> "centerPosition") call BIS_fnc_getCfgData;	
	if (!isNil "_worldCenter") then {
		_map ctrlMapAnimAdd [0, 0.1, _worldCenter];
		ctrlMapAnimCommit _map;
	};
	*/
	if (isNil "mapOpen") then {
		_map ctrlSetPosition [safezoneX + (27 * pixelGridNoUIScale * pixelW), safezoneY + (8 * pixelGridNoUIScale * pixelH), 0, safezoneH - (13 * pixelGridNoUIScale * pixelH)];		
		_map ctrlCommit 0;		
		//_map ctrlMapAnimAdd [0, 1, [worldSize/2, worldSize/2]];
		//ctrlMapAnimCommit _map;		
		_map ctrlSetPosition [safezoneX + (27 * pixelGridNoUIScale * pixelW), safezoneY + (8 * pixelGridNoUIScale * pixelH), safezoneW - (27 * pixelGridNoUIScale * pixelW), safezoneH - (13 * pixelGridNoUIScale * pixelH)];		
		_map ctrlCommit 0.2;
		mapOpen = true;
		_button ctrlSetText "CLOSE MAP";
		_text = composeText ["Select the Area of Operations:", lineBreak, lineBreak, "Click on the map to select the closest AO location.", lineBreak, "Alternatively ALT-click on the map to select an exact custom location."];
		((findDisplay 52525) displayCtrl 1053) ctrlSetStructuredText _text;
		[] spawn {
			disableSerialization;
			{
				_x ctrlSetFade 0;
			} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
			{
				_x ctrlCommit 0.2;
			} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
		};		
		[
			"mapStartSelect",
			"onMapSingleClick",
			{
				playSound "readoutClick";
				deleteMarker "aoSelectMkr";
				aoName = "";
				if (_alt) then {
					markerPlayerStart = createMarker ["aoSelectMkr", _pos];
					markerPlayerStart setMarkerShape "ICON";			
					markerPlayerStart setMarkerType "Select";		
					markerPlayerStart setMarkerAlpha 1;
					markerPlayerStart setMarkerColor "ColorGreen";					
					//_nearLoc = nearestLocation [_pos, ""];					
					_nearLoc = ((nearestLocations [_pos, ["NameLocal", "NameVillage", "NameCity", "NameCityCapital"], 1000, _pos]) select 0);
					if (isNil "_nearLoc") then {
						aoName = format ["Rural %1", ((configfile >> "CfgWorlds" >> worldName >> "description") call BIS_fnc_getCfgData)];
					} else {
						aoName = format ["Near %1", (text _nearLoc)];
					};	
					//aoName = format ["Near %1", text _nearLoc];
					selectedLocMarker setMarkerColor "ColorPink";
					selectedLocMarker = markerPlayerStart;
					selectedLocMarker setMarkerColor "ColorGreen";
				} else {
					_nearestMarker = [locMarkerArray, _pos] call BIS_fnc_nearestPosition;		
					markerPlayerStart = createMarker ["aoSelectMkr", getMarkerPos _nearestMarker];
					markerPlayerStart setMarkerShape "ICON";			
					markerPlayerStart setMarkerType "mil_dot";		
					markerPlayerStart setMarkerAlpha 0;		
					_loc = nearestLocation [getMarkerPos _nearestMarker, ""];
					aoName = text _loc;
					selectedLocMarker setMarkerColor "ColorPink";		
					selectedLocMarker = _nearestMarker;
					_nearestMarker setMarkerColor "ColorGreen";
				};				
				((findDisplay 52525) displayCtrl 2010) ctrlSetText format ["AO Location: %1", aoName];
				publicVariableServer "markerPlayerStart";
				publicVariable "aoName";
				publicVariableServer "selectedLocMarker";
			},
			[]
		] call BIS_fnc_addStackedEventHandler;
	} else {
		if (mapOpen) then {
			["mapStartSelect", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
			_map ctrlSetPosition [safezoneX + (27 * pixelGridNoUIScale * pixelW), safezoneY + (8 * pixelGridNoUIScale * pixelH), 0, safezoneH - (13 * pixelGridNoUIScale * pixelH)];
			_map ctrlCommit 0.1;
			sleep 0.1;
			_map ctrlSetPosition [safezoneX + (27 * pixelGridNoUIScale * pixelW), safezoneY + (8 * pixelGridNoUIScale * pixelH), 0, 0];		
			_map ctrlCommit 0;
			mapOpen = false;
			_button ctrlSetText "OPEN MAP";
			[] spawn {
				disableSerialization;
				{
					_x ctrlSetFade 1;
				} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
				{
					_x ctrlCommit 0.2;
				} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
			};	
		} else {
			_map ctrlSetPosition [safezoneX + (27 * pixelGridNoUIScale * pixelW), safezoneY + (8 * pixelGridNoUIScale * pixelH), 0, safezoneH - (13 * pixelGridNoUIScale * pixelH)];		
			_map ctrlCommit 0;
			_map ctrlSetPosition [safezoneX + (27 * pixelGridNoUIScale * pixelW), safezoneY + (8 * pixelGridNoUIScale * pixelH), safezoneW - (27 * pixelGridNoUIScale * pixelW), safezoneH - (13 * pixelGridNoUIScale * pixelH)];		
			_map ctrlCommit 0.2;
			mapOpen = true;
			_button ctrlSetText "CLOSE MAP";
			_text = composeText ["Select the Area of Operations:", lineBreak, lineBreak, "Click on the map to select the closest AO location.", lineBreak, "Alternatively ALT-click on the map to select an exact custom location."];
			((findDisplay 52525) displayCtrl 1053) ctrlSetStructuredText _text;
			[] spawn {
				disableSerialization;
				{
					_x ctrlSetFade 0;
				} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
				{
					_x ctrlCommit 0.2;
				} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
			};		
			[
				"mapStartSelect",
				"onMapSingleClick",
				{
					deleteMarker "aoSelectMkr";
					aoName = "";
					playSound "readoutClick";
					if (_alt) then {
						markerPlayerStart = createMarker ["aoSelectMkr", _pos];
						markerPlayerStart setMarkerShape "ICON";			
						markerPlayerStart setMarkerType "Select";		
						markerPlayerStart setMarkerAlpha 1;
						markerPlayerStart setMarkerColor "ColorGreen";
						//_nearLoc = nearestLocation [_pos, ""];					
						_nearLoc = ((nearestLocations [_pos, ["NameLocal", "NameVillage", "NameCity", "NameCityCapital"], 1000, _pos]) select 0);
						if (isNil "_nearLoc") then {
							aoName = format ["Rural %1", ((configfile >> "CfgWorlds" >> worldName >> "description") call BIS_fnc_getCfgData)];
						} else {
							aoName = format ["Near %1", (text _nearLoc)];
						};					
						selectedLocMarker setMarkerColor "ColorPink";
						selectedLocMarker = markerPlayerStart;
						selectedLocMarker setMarkerColor "ColorGreen";
					} else {
						_nearestMarker = [locMarkerArray, _pos] call BIS_fnc_nearestPosition;		
						markerPlayerStart = createMarker ["aoSelectMkr", getMarkerPos _nearestMarker];
						markerPlayerStart setMarkerShape "ICON";			
						markerPlayerStart setMarkerType "mil_dot";		
						markerPlayerStart setMarkerAlpha 0;		
						_loc = nearestLocation [getMarkerPos _nearestMarker, ""];
						aoName = text _loc;
						selectedLocMarker setMarkerColor "ColorPink";		
						selectedLocMarker = _nearestMarker;
						_nearestMarker setMarkerColor "ColorGreen";
					};				
					((findDisplay 52525) displayCtrl 2010) ctrlSetText format ["AO Location: %1", aoName];
					publicVariableServer "markerPlayerStart";
					publicVariable "aoName";
					publicVariableServer "selectedLocMarker";
				},
				[]
			] call BIS_fnc_addStackedEventHandler;			
		};
	};	
};

sun_callLoadScreen = {
	params ["_message", "_endVar", "_endValue", "_fadeType"];		
	disableSerialization;	
	_loadDisplay = findDisplay 46 createDisplay "SUN_loadScreen";	
	_loadScreen = _loadDisplay displayCtrl 8888;
	_loadScreenText = _loadDisplay displayCtrl 8889;
	
	_loadScreen ctrlSetFade 1;
	_loadScreenText ctrlSetFade 1;
	_loadScreen ctrlCommit 0;
	_loadScreenText ctrlCommit 0;
	
	_loadScreenText ctrlSetText _message;		
	_loadScreenText ctrlSetTextColor [1, 1, 1, 0.8];
	
	if (toUpper _fadeType == "BLACK") then {
		_loadScreen ctrlSetBackgroundColor [0, 0, 0, 1];
	};	
	
	_loadScreen ctrlSetFade 0;
	_loadScreenText ctrlSetFade 0;
	_loadScreen ctrlCommit 2;
	_loadScreenText ctrlCommit 2;

	sleep 2;	
	waitUntil {missionNameSpace getVariable _endVar == _endValue};
	_loadScreen ctrlSetFade 1;
	_loadScreenText ctrlSetFade 1;
	_loadScreen ctrlCommit 0.5;
	_loadScreenText ctrlCommit 0.5;
	sleep 0.5;
	_loadDisplay closeDisplay 1;	
};

sun_randomCam = {
	params ["_var"];	
	_worldCenterVal = (worldSize/2);
	_worldCenter = [_worldCenterVal, _worldCenterVal, 0];	
	_randomPos = [] call BIS_fnc_randomPos;	
	_randomPos set [2, (random [2, 5, 20])];
	_dir = [_randomPos, _worldCenter] call BIS_fnc_dirTo;
	_targetPos = [_randomPos, 600, _dir] call BIS_fnc_relPos;			
	_cam = "camera" camCreate _randomPos;
	randomCamActive = true;
	_cam cameraEffect ["internal", "BACK"];
	_cam camSetPos _randomPos;
	_cam camSetTarget _targetPos;	
	_cam camCommit 0;
	_preparePos = _randomPos getPos [15, 90];
	_preparePos set [2, (_randomPos select 2)];
	_cam camPreparePos _preparePos;	
	_cam camCommitPrepared 20;
	cameraEffectEnableHUD false;
	showCinemaBorder false;
	["Mediterranean"] call BIS_fnc_setPPeffectTemplate;	
	_end = false;
	_blackOut = false;
	sleep 5;
	while {(missionNameSpace getVariable [_var, 0]) == 0} do {
		_startTime = time;		
		while {time < (_startTime + 10)} do {
			if (sunOrMoon < 1) then {camUseNVG true} else {camUseNVG false};			
			if ((missionNameSpace getVariable [_var, 0]) == 1) exitWith {_end = true};
		};
		if (_end) exitWith {_blackOut = true};
		cutText ["", "BLACK OUT", 2];
		_startTime = time;
		while {time < (_startTime + 2.5)} do {
			if ((missionNameSpace getVariable [_var, 0]) == 1) exitWith {_end = true};
		};		
		if (_end) exitWith {};
		_randomPos = [] call BIS_fnc_randomPos;		
		_targetPos = [];
		if (random 1 > 0.6) then {
			_randomPos set [2, (random [220, 250, 300])];
			_dir = [_randomPos, _worldCenter] call BIS_fnc_dirTo;			
			_targetPos = [_randomPos, 1500, _dir] call BIS_fnc_relPos;
			_targetPos set [2, 0];
			_preparePos = _randomPos getPos [100, 90];
			_preparePos set [2, (_randomPos select 2)];
		} else {
			_randomPos set [2, (random [2, 5, 20])];
			_dir = [_randomPos, _worldCenter] call BIS_fnc_dirTo;
			_targetPos = [_randomPos, 600, _dir] call BIS_fnc_relPos;
			_preparePos = _randomPos getPos [15, 90];
			_preparePos set [2, (_randomPos select 2)];
		};		
		_cam camSetPos _randomPos;
		_cam camSetTarget _targetPos;	
		_cam camCommit 0;
		
		_cam camPreparePos _preparePos;
		_cam camCommitPrepared 20;
		_startTime = time;
		while {time < (_startTime + 2)} do {
			if ((missionNameSpace getVariable [_var, 0]) == 1) exitWith {_end = true};
		};
		if (_end) exitWith {};
		cutText ["", "BLACK IN", 2];
	};
	if (_blackOut) then {
		cutText ["", "BLACK OUT", 2];
		sleep 2;
	};
	_cam cameraEffect ["terminate","back"];
	camUseNVG false;
	camDestroy _cam;
	["Default"] call BIS_fnc_setPPeffectTemplate;
	randomCamActive = false;
	/*
	if (_blackOut) then {
		sleep 1;
		cutText ["", "BLACK IN", 2];		
	};
	*/
	diag_log "DRO: Closed random cam";
};
dro_clearData = {	
	
	// Faction data
	lbSetCurSel [1301, 1];
	lbSetCurSel [1310, 2];
	lbSetCurSel [1321, 0];
	lbSetCurSel [3800, 0];
	lbSetCurSel [3801, 0];
	lbSetCurSel [3802, 0];
	lbSetCurSel [3803, 0];
	lbSetCurSel [3804, 0];
	lbSetCurSel [3805, 0];
	
	// Other data
	//lbSetCurSel [2103, 0];
	lbSetCurSel [2104, 0];		
	lbSetCurSel [2106, 0];
	//lbSetCurSel [2116, 0];
	["MAIN", 2020, 2] call sun_switchButtonSet;
	["MAIN", 2030, 0] call sun_switchButtonSet;
	["MAIN", 2050, 0] call sun_switchButtonSet;		
	["MAIN", 2060, 0] call sun_switchButtonSet;
	["MAIN", 2070, 0] call sun_switchButtonSet;
	["MAIN", 2080, 0] call sun_switchButtonSet;
	["MAIN", 2090, 0] call sun_switchButtonSet;
	["MAIN", 2400, 0] call sun_switchButtonSet;
	["MAIN", 3010, 0] call sun_switchButtonSet;
	['MAIN', 3020, false, 0] call sun_switchButtonWeather;
	["MAIN", 3030, 0] call sun_switchButtonSet;
	["MAIN", 4010, 0] call sun_switchButtonSet;
	sliderSetPosition [2041, 1*10];
	sliderSetPosition [2109, 3];
	[2301] call dro_inputDaysData;	
	
	pFactionIndex = 1;
	publicVariable "pFactionIndex";
	playersFactionAdv = [0,0,0];
	publicVariable "playersFactionAdv";
	eFactionIndex = 2;
	publicVariable "eFactionIndex";
	enemyFactionAdv = [0,0,0];
	publicVariable "enemyFactionAdv";
	cFactionIndex = 0;
	publicVariable "cFactionIndex";
	
	month = 0;
	profileNamespace setVariable ["DRO_month", nil];
	publicVariable "month";
	day = 0;
	profileNamespace setVariable ["DRO_day", nil];
	publicVariable "day";
	preferredObjectives = [];
	publicVariable "preferredObjectives";	
	customPos = [];
	publicVariable "customPos";	
	
	profileNamespace setVariable ["DRO_playersFaction", nil];
	profileNamespace setVariable ["DRO_enemyFaction", nil];
	profileNamespace setVariable ['DRO_objectivePrefs', nil];
	
	deleteMarker 'aoSelectMkr';
	aoName = nil;	
	ctrlSetText [2300, 'AO location: RANDOM'];
	selectedLocMarker setMarkerColor 'ColorPink';
	
	{
		((findDisplay 52525) displayCtrl _x) ctrlSetTextColor [1, 1, 1, 1];
	} forEach [2200, 2201, 2202, 2203, 2204, 2207, 2210, 2211, 2212, 2213];
	
};

sun_missionPreset = {
	params ["_preset"];
	/*
		lbSetCurSel [2107, aoOptionSelect];		
		sliderSetPosition [2111, 1*10];	//AI COUNT	
		lbSetCurSel [2113, minesEnabled];			
		lbSetCurSel [2115, civiliansEnabled];			
		lbSetCurSel [2119, stealthEnabled];				
		lbSetCurSel [2103, timeOfDay];		
		lbSetCurSel [2106, numObjectives];
	*/
	switch (_preset) do {
		case 1: {					
			["MAIN", 2020, 0] call sun_switchButtonSet;
			sliderSetPosition [2041, 1*10];
			((findDisplay 52525) displayCtrl 2040) ctrlSetText "Enemy force size multiplier: x1.0";				
			["MAIN", 2050, 0] call sun_switchButtonSet;
			["MAIN", 2060, 0] call sun_switchButtonSet;
			["MAIN", 2070, 0] call sun_switchButtonSet;
			["MAIN", 4010, 0] call sun_switchButtonSet;				
			lbSetCurSel [2103, 0];							
			lbSetCurSel [2106, 0];
			preferredObjectives = [];
			profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];
			{
				((findDisplay 52525) displayCtrl _x) ctrlSetTextColor [1, 1, 1, 1]
			} forEach [2200, 2201, 2202, 2203, 2204, 2207, 2210, 2211, 2212, 2213];			
		};
		case 2: {					
			["MAIN", 2020, 0] call sun_switchButtonSet;
			sliderSetPosition [2041, 0.5*10];
			((findDisplay 52525) displayCtrl 2040) ctrlSetText "Enemy force size multiplier: x0.5";	
			["MAIN", 2050, 0] call sun_switchButtonSet;			
			["MAIN", 2060, 0] call sun_switchButtonSet;					
			["MAIN", 2070, 1] call sun_switchButtonSet;	
			lbSetCurSel [2103, (selectRandom [3, 4])];		
			["MAIN", 4010, 1] call sun_switchButtonSet;	
			preferredObjectives = ["HVT"];
			profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];
			((findDisplay 52525) displayCtrl 2200) ctrlSetTextColor [0.05, 1, 0.5, 1];
			{			
				((findDisplay 52525) displayCtrl _x) ctrlSetTextColor [1, 1, 1, 1]
			} forEach [2201, 2202, 2203, 2204, 2207, 2210, 2211, 2212, 2213];			
		};
		case 3: {					
			["MAIN", 2020, 0] call sun_switchButtonSet;
			sliderSetPosition [2041, 1*12.5];	
			((findDisplay 52525) displayCtrl 2040) ctrlSetText "Enemy force size multiplier: x1.25";	
			["MAIN", 2050, 0] call sun_switchButtonSet;
			["MAIN", 2060, 0] call sun_switchButtonSet;
			["MAIN", 2070, 0] call sun_switchButtonSet;
			["MAIN", 4010, 0] call sun_switchButtonSet;				
			lbSetCurSel [2103, 0];							
			lbSetCurSel [2106, 0];
			preferredObjectives = [];
			profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];
			{
				((findDisplay 52525) displayCtrl _x) ctrlSetTextColor [1, 1, 1, 1]
			} forEach [2200, 2201, 2202, 2203, 2204, 2207, 2210, 2211, 2212, 2213];		
		};
		default {};
	};
};

dro_inputDaysData = {
	params ["_idc"];
	//_currentDaySelection = lbCurSel _idc;
	_currentDaySelection = profileNamespace getVariable ["DRO_day", 0];
	_days = [(date select 0), (date select 1)] call BIS_fnc_monthDays;	
	lbClear _idc;
	_daySelectionFound = false;
	for '_i' from 0 to _days step 1 do {
		if (_i == 0) then {
			lbAdd [_idc, "Random"];
		} else {
			lbAdd [_idc, str _i];
		};
		if (_i == _currentDaySelection) then {			
			lbSetCurSel [_idc, _i];
			_daySelectionFound = true;
		};
	};
	if !(_daySelectionFound) then {lbSetCurSel [_idc, 0];};
};
