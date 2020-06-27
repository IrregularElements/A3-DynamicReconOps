dro_checkAOIndexes = {
	params ["_indexes"];
	_availableIndexes = [];
	{
		if (count (((AOLocations select _AOIndex) select 2) select _x) > 0) then {_availableIndexes pushBack _x};
	} forEach _indexes;	
	_availableIndexes
};

dro_civDeathHandler = {
	params ["_unit"];
	_index = _unit addMPEventHandler ["mpkilled", {
		if (group (_this select 1) == (grpNetId call BIS_fnc_groupFromNetId)) then {
			if (isServer) then {
				if (isNil "civDeathCounter") then {
					civDeathCounter = 1;
					publicVariable "civDeathCounter";			
					_text = format["%1 has been responsible for a civilian casualty. Command will not accept collateral damage, adjust your approach to ensure civilians are kept out of the line of fire.", name ((_this select 0) select 1)];
					//["Command", _text] spawn BIS_fnc_showSubtitle;
					//[] spawn sun_playSubtitleRadio;				
					dro_messageStack pushBack [[["Command", _text, 0]], true];
				} else {
					civDeathCounter = civDeathCounter + 1;
					publicVariable "civDeathCounter";			
					switch (civDeathCounter) do {
						case 0: {};
						case 1: {
							[_this] spawn {
								sleep 2;							
								_text = format["%1 has caused a civilian casualty. Command will not accept collateral damage, adjust your approach to ensure civilians are kept out of the line of fire.", name ((_this select 0) select 1)];
								//["Command", _text] spawn BIS_fnc_showSubtitle;
								//[] spawn sun_playSubtitleRadio;
								dro_messageStack pushBack [[["Command", _text, 0]], true];
							};
						};
						case 2: {
							[_this] spawn {
								sleep 2;
								_text = format["%1 has caused a civilian casualty. This is your second warning! If you cannot complete your objectives without causing collateral damage you must withdraw.", name ((_this select 0) select 1)];
								//["Command", _text] spawn BIS_fnc_showSubtitle;
								//[] spawn sun_playSubtitleRadio;
								dro_messageStack pushBack [[["Command", _text, 0]], true];
							};
						};
						case 3: {
							[_this] spawn {
								sleep 2;
								_text = format["Your team are responsible for excessive civilian casualties! Pull out immediately, the mission is over!", name ((_this select 0) select 1)];
								//["Command", _text] spawn BIS_fnc_showSubtitle;
								//[] spawn sun_playSubtitleRadio;
								dro_messageStack pushBack [[["Command", _text, 0]], true];
								//if (player == leader group player) then {
									{
										[_x, 'FAILED', true] spawn BIS_fnc_taskSetState;
									} forEach taskIDs;
								//};
							};
						};
						case 4: {
							[_this] spawn {
								sleep 2;
								//[] execVM "sunday_system\endMission.sqf";
								
								[["", "BLACK OUT", 5]] remoteExec ["cutText", 0];
								[5, 0] remoteExec ["fadeSound", 0];
								[5, 0] remoteExec ["fadeSpeech", 0];
								sleep 5;
								if (isMultiplayer) then {
									'DROEnd_FailCiv2' call BIS_fnc_endMissionServer;
								} else {
									'DROEnd_FailCiv2' call BIS_fnc_endMission;
								};
								
							};
						};
						default {
							[_this] spawn {
								_text = format["%1 has caused a civilian casualty. Command will not accept collateral damage, adjust your approach to ensure civilians are kept out of the line of fire.", name ((_this select 0) select 1)];
								//["Command", _text] spawn BIS_fnc_showSubtitle;
								//[] spawn sun_playSubtitleRadio;
								dro_messageStack pushBack [[["Command", _text, 0]], true];
							};
						};
					};
				};
			};
		};
	}]; 
};

dro_addConstructPoint = {
	params ["_pos", "_objType", "_dir", ["_posDistShift", 0]];		
	
	_useLib = if (_posDistShift == 0) then {false} else {true};
	_pos = _pos getPos [_posDistShift, _dir];
	_box = createVehicle [(selectRandom ["Land_WoodenCrate_01_F", "Land_WoodenCrate_01_stack_x3_F"]), _pos, [], 0, "CAN_COLLIDE"];
	_box setDir (random 360);
	[
		_box,
		"Construct Barricade",
		"\A3\ui_f\data\igui\cfg\actions\repair_ca.paa",
		"\A3\ui_f\data\igui\cfg\actions\repair_ca.paa",
		"((_this distance _target) < 4)",
		"true",
		{},
		{
			// Progress
			/*
			if ((_this select 4) % 3 == 0) then {			
				_sound = selectRandom ["A3\Sounds_F\arsenal\weapons\Rifles\Katiba\reload_Katiba.wss", "A3\Sounds_F\arsenal\weapons\Rifles\Mk20\reload_Mk20.wss", "A3\Sounds_F\arsenal\weapons\Rifles\MX\Reload_MX.wss", "A3\Sounds_F\arsenal\weapons\Rifles\SDAR\reload_sdar.wss", "A3\Sounds_F\arsenal\weapons\SMG\Vermin\reload_vermin.wss", "A3\Sounds_F\arsenal\weapons\SMG\PDW2000\Reload_pdw2000.wss"];
				playSound3D [_sound, (_this select 1)];				
			};
			*/
		},
		{
			// Completed
			// Remove helper
			deleteVehicle (_this select 0);			
			// Create object
			if ((_this select 3) select 3) then {				
				_objList = (selectRandom compositionsBunkerCorners);				
				_removeElements = [];
				{
					if ((_x select 0) == "Sign_Arrow_Blue_F") then {
						_removeElements pushBack _x;
					};
				} forEach (_objList);
				_objList = _objList - _removeElements;
				_spawnedObjects = [((_this select 3) select 1), ((_this select 3) select 2), _objList] call BIS_fnc_ObjectsMapper;
			} else {
				_objList = ((_this select 3) select 0);
				_pos = ((_this select 3) select 1);
				_dir = ((_this select 3) select 2);
				if (_objList isEqualType []) then {
					
					_distShift = -2;
					{					
						_spawnPos = _pos getPos [_distShift, _dir - 90];
						_spawnPos set [2, 0];			
						_obj = createVehicle [_x, _spawnPos, [], 0, "CAN_COLLIDE"];					
						_obj setDir _dir;					
						_distShift = _distShift + 2;
					} forEach _objList;				
				} else {				
					_pos set [2, 0];			
					_obj = createVehicle [_objList, _pos, [], 0, "CAN_COLLIDE"];
					_obj setDir _dir;
				};
			};
		},
		{
			// Interrupted			
		},
		[_objType, _pos, _dir, _useLib],
		5,
		10,
		true,
		false
	] remoteExec ["bis_fnc_holdActionAdd", 0, true];
	_box
};

dro_addConstructAction = {
	params ["_obj", "_objsToDelete", "_createPos", "_createDir", "_taskName"];		
	[
		_obj,
		"Construct Barricade",
		"\A3\ui_f\data\igui\cfg\actions\repair_ca.paa",
		"\A3\ui_f\data\igui\cfg\actions\repair_ca.paa",
		"((_this distance _target) < 4)",
		"true",
		{},
		{
			// Progress
			if ((_this select 4) % 4 == 0) then {			
				_sound = selectRandom ["A3\Sounds_F\arsenal\weapons\Rifles\Katiba\reload_Katiba.wss", "A3\Sounds_F\arsenal\weapons\Rifles\Mk20\reload_Mk20.wss", "A3\Sounds_F\arsenal\weapons\Rifles\MX\Reload_MX.wss", "A3\Sounds_F\arsenal\weapons\Rifles\SDAR\reload_sdar.wss", "A3\Sounds_F\arsenal\weapons\SMG\Vermin\reload_vermin.wss", "A3\Sounds_F\arsenal\weapons\SMG\PDW2000\Reload_pdw2000.wss"];
				playSound3D [_sound, (_this select 1)];
				if (count (((_this select 3) select 0) select {!isObjectHidden _x}) > 0) then {
					(selectRandom (((_this select 3) select 0) select {!isObjectHidden _x})) hideObjectGlobal true;
				};
			};
		},
		{
			// Completed
			// Remove barricade components			
			{deleteVehicle _x} forEach (((_this select 3) select 0) + [_this select 0]);
			
			// Create barricade
			_objects = selectRandom compositionsConstructs;
			_spawnedObjects = [((_this select 3) select 1), ((_this select 3) select 2), _objects] call BIS_fnc_ObjectsMapper;
			
			// Complete the task
			if ([((_this select 3) select 3)] call BIS_fnc_taskExists) then {
				_taskState = [((_this select 3) select 3)] call BIS_fnc_taskState;				
				if !(_taskState isEqualTo "SUCCEEDED") then {
					[((_this select 3) select 3), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;					
				};
			};
			missionNamespace setVariable [format ['%1Completed', ((_this select 3) select 0)], 1, true];
		},
		{
			// Interrupted
			{
				_x hideObjectGlobal false;
			} forEach ((_this select 3) select 0);
		},
		[_objsToDelete, _createPos, _createDir, _taskName],
		20,
		10,
		true,
		false
	] remoteExec ["bis_fnc_holdActionAdd", 0, true];	
};


dro_sendProgressMessage = {
	params ["_message", ["_sender", "Command"], ["_data", []], ["_playAudio", true]];	
	//sleep (random [1, 2, 1.5]);
	/*
	if (!isNil "bis_fnc_showsubtitle_subtitle") then {
		waitUntil {sleep (random [2, 3, 2.5]); isNull bis_fnc_showsubtitle_subtitle};
	};
	*/
	if (typeName _sender == "OBJECT") then {
		_sender = name _sender;
	};
	switch (_message) do {
		case "HOSTILECIVS": {
			dro_messageStack pushBack [
				[
					[_sender, "This is a reminder to check your targets, we believe that some of the civilian population may react with hostility to your presence. Move carefully and assess any contact as a potential threat.", 0],
					[_sender, "Even though you're going into a situation with unknown combatants hold fire until you see clear signs of hostile intent. Civilian casualties are still considered unacceptable.", 10]
				],
				_playAudio
			];			
		};
		case "AMBUSH": {
			dro_messageStack pushBack [
				[
					[_sender, "Command here, looks like your activities have been noticed, we show enemies moving to investigate.", 0],
					[_sender, "Find cover, hold and defend your position.", 7]
				],
				_playAudio
			];				
		};
		case "AMBUSHOP": {
			dro_messageStack pushBack [
				[
					[_sender, "Heads up, we're showing incoming enemies headed to your position. Good thing you got that OP set up in time.", 0],
					[_sender, "Take cover and defend the OP.", 7]
				],
				_playAudio
			];			
		};
		case "AMBUSHCIV": {	
			dro_messageStack pushBack [
				[
					[_sender, (format ["Just as we expected, enemy forces are moving to your position now.", (_data select 0)]), 0],
					[_sender, (format ["Take cover and protect %1!", (_data select 0)]), 7]
				],
				_playAudio
			];			
		};
		case "PROTECT_CIV_MEET": {
			dro_messageStack pushBack [
				[
					[_sender, (format ["Are you %1? We know of a threat to your life and we're here to keep you safe.", (_data select 0)]), 0],
					[_sender, (format ["Keep your head down and we'll do the rest.", (_data select 0)]), 7],
					[(_data select 0), (format ["You got it, I'll try and stay out of your way.", (_data select 0)]), 12]
				],
				_playAudio
			];				
		};
		case "PROTECT_CIV_CLEAR": {	
			dro_messageStack pushBack [
				[
					[_sender, (format ["That should be the last of them, I suggest you leave the area as soon as possible.", (_data select 0)]), 0],
					[(_data select 0), (format ["Thank God you arrived when you did. Don't worry, I've got no intention of sticking around.", (_data select 0)]), 7]				
				],
				_playAudio
			];					
		};
		case "BRIEFING": {	
			_greeting = (format ["Good day %1, Command here.", playerCallsign]);
			_hour = (date select 3);
			if (_hour >= 0 && _hour < 8) then {
				_greeting = (format ["Good morning %1, Command here.", playerCallsign]);
			} else {
				if (_hour >= 8 && _hour < 18) then {
					_greeting = (format ["Good day %1, Command here.", playerCallsign]);
				} else {
					if (_hour >= 18) then {
						_greeting = (format ["Good evening %1, Command here.", playerCallsign]);
					};
				};
			};
			_sendOff = selectRandom [
				format ["Good luck out there, stay alert and let's ensure %1 is a success.", (missionNameSpace getVariable ["mName", "the operation"])],
				format ["%1 will be an important mission for us, we're looking to you for a clean execution. Good luck.", (missionNameSpace getVariable ["mName", "the operation"])],
				format ["Keep your head on a swivel and take your time. We don't want any mistakes today.", (missionNameSpace getVariable ["mName", "the operation"])]
			];
			dro_messageStack pushBack [
				[
					[_sender, _greeting, 0],
					[_sender, "We've prepared a full briefing which is available under your briefing notes.", 6],
					[_sender, _sendOff, 14]
				],
				_playAudio
			];
		};
		case "TASK_SUCCEED": {
			diag_log "DRO: TASK_SUCCEED called";
			if (({_x call BIS_fnc_taskCompleted} count taskIDs) < (count taskIDs)) then {				
				_phrases = if (isNil "oneTaskCompleted") then {
					oneTaskCompleted = true;
					[(format ["Good job %1, keep the momentum up.", playerCallsign]), "Good work. Let's keep it moving.", (format ["Good work %1, maintain your pace and let's finish the job.", playerCallsign])];				
				} else {
					if (oneTaskCompleted) then {
						[(format ["Another one down, %1. You're doing well.", playerCallsign]), (format ["Good job again %1. Keep it moving.", playerCallsign]), (format ["Alright %1, stay frosty.", playerCallsign]), (format ["Good work %1, maintain your pace and let's finish the job.", playerCallsign])];
					};
				};
				dro_messageStack pushBack [
					[
						[_sender, (selectRandom _phrases), 0]			
					],
					_playAudio
				];
			};		
		};
		case "REACTIVE_TASK": {	
			dro_messageStack pushBack [
				[
					[_sender, (_data select 0), 0]			
				],
				_playAudio
			];			
		};
		case "FRIENDLY_START": {
			_phrase = selectRandom [
				(format ["%1, this is %2. We're beginning our move now.", playerCallsign, _sender]),
				(format ["%1, %2 here. We're going to begin our assault.", playerCallsign, _sender]),
				(format ["%1, we're heading to our objective now. See you on the other side.", playerCallsign])
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0]			
				],
				_playAudio
			];
		};
		case "REVEAL_INTEL": {			
			if (count (_data select 1) > 0) then {
				dro_messageStack pushBack [
					[
						[_sender, (_data select 0), 0],
						[_sender, (_data select 1), 6]		
					],
					_playAudio
				];				
			} else {
				dro_messageStack pushBack [
					[
						[_sender, (_data select 0), 0]		
					],
					_playAudio
				];				
			};			
		};		
		case "END_LEAVE": {			
			_phrase = selectRandom [
				(format ["Alright %1, time to get yourselves out of there.", playerCallsign]),
				(format ["That's everything %1. Get clear of the AO.", playerCallsign])				
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0]		
				],
				_playAudio
			];				
		};
		case "END_RTB": {			
			_phrase = selectRandom [
				(format ["Alright %1, get yourselves back to %2.", playerCallsign, markerText "campMkr"]),
				(format ["That's everything %1, return to %2 ASAP.", playerCallsign, markerText "campMkr"])
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0]		
				],
				_playAudio
			];				
		};
		case "END_RENDEZVOUS": {			
			_phrase = selectRandom [
				(format ["Alright %1, rendezvous with %2 then make your way out of the AO.", playerCallsign, groupId friendlySquad]),
				(format ["That's everything %1, rendezvous with %2 before you leave the AO.", playerCallsign, groupId friendlySquad])
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0]		
				],
				_playAudio
			];				
		};
		case "END_RENDEZVOUS_FAIL": {			
			_phrase = selectRandom [
				(format ["We've lost contact with %1! Proceed to extraction and we'll send a recovery team to find them.", groupId friendlySquad])				
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0]		
				],
				_playAudio
			];			
		};
		case "END_HOLD": {			
			_phrase = selectRandom [
				(format ["Alright %1, we need you to assist taking and holding %2. All units are go and the command has been given to secure the area.", playerCallsign, (text (holdAO select 5))]),
				(format ["Tasking complete %1. Your orders are now to assist the push to take and hold %2. All units are moving to secure the area.", playerCallsign, (text (holdAO select 5))])
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0],		
					[_sender, "However, if you're too damaged to assist in the assault then pull out and extract from the AO.", 8]		
				],
				_playAudio
			];			
		};
		case "OBSERVE_SUCCEED": {			
			_phrase = selectRandom [
				(format ["Alright %1, %2", playerCallsign, (_data select 0)]),
				(format ["Good spotting %1, %2", playerCallsign, (_data select 0)]),
				(format ["Nice work %1, %2", playerCallsign, (_data select 0)])
			];
			dro_messageStack pushBack [
				[
					[_sender, _phrase, 0]		
				],
				_playAudio
			];			
		};
	};	
};

dro_addSabotageAction = {
	params ["_objects", ["_taskName", ""]];
	if (typeName _objects == "OBJECT") then {		
		_objects = [_objects];		
	};
	{
		_x setVariable ['sabotaged', false, true];
	} forEach _objects;
	if (count _taskName == 0) then {
		_taskName = (_objects select 0) getVariable "thisTask";
	};
	{
		[
			_x,
			"Sabotage",
			"\A3\ui_f\data\igui\cfg\actions\ico_OFF_ca.paa",
			"\A3\ui_f\data\igui\cfg\actions\ico_OFF_ca.paa",
			"(alive _target) && !(_target getVariable ['sabotaged', false]) && ((_this distance _target) < 4) && ('ToolKit' in (items _this + assignedItems _this))",
			"true",
			{},
			{
				if ((_this select 4) % 3 == 0) then {			
					_sound = selectRandom ["A3\Sounds_F\arsenal\weapons\Rifles\Katiba\reload_Katiba.wss", "A3\Sounds_F\arsenal\weapons\Rifles\Mk20\reload_Mk20.wss", "A3\Sounds_F\arsenal\weapons\Rifles\MX\Reload_MX.wss", "A3\Sounds_F\arsenal\weapons\Rifles\SDAR\reload_sdar.wss", "A3\Sounds_F\arsenal\weapons\SMG\Vermin\reload_vermin.wss", "A3\Sounds_F\arsenal\weapons\SMG\PDW2000\Reload_pdw2000.wss"];
					playSound3D [_sound, (_this select 1)];
					//(selectRandom ["FD_Skeet_Launch1_F", "FD_Skeet_Launch2_F"]) remoteExec ["playSound", (_this select 1)];
				};
			},
			{
				// Sabotage this object
				((_this select 0) setVariable ['sabotaged', true, true]);				
				(_this select 0) removeAllEventHandlers "Explosion";
				(_this select 0) removeAllEventHandlers "Killed";
				[(_this select 0), "ALL"] remoteExec ["disableAI", (_this select 0), true];
				[(_this select 0), "LOCKED"] remoteExec ["setVehicleLock", (_this select 0), true];
				[(_this select 0)] remoteExec ["removeAllItems", (_this select 0), true];
				[(_this select 0)] remoteExec ["removeAllWeapons", (_this select 0), true];
				{[(_this select 0), _x] remoteExec ["removeMagazine", (_this select 0), true]} forEach magazines (_this select 0);
				// Check for any other objects that might need sabotaging for task completion
				_complete = true;
				{	
					
					if !(_x getVariable ['sabotaged', false]) then {
						_complete = false;
					};
				} forEach ((_this select 3) select 0);
				// If all are sabotaged then complete the task				
				if (_complete) then {					
					if ([((_this select 3) select 1)] call BIS_fnc_taskExists) then {
						_taskState = [((_this select 3) select 1)] call BIS_fnc_taskState;				
						if !(_taskState isEqualTo "SUCCEEDED") then {
							[((_this select 3) select 1), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;							
						};
					};
					missionNamespace setVariable [format ['%1Completed', ((_this select 3) select 0)], 1, true];					
				};				
			},
			{},
			[_objects, _taskName],
			10,
			10,
			true,
			false
		] remoteExec ["bis_fnc_holdActionAdd", 0, true];
	} forEach _objects;
};


dro_missionName = {
	_missionNameType = selectRandom ["OneWord", "DoubleWord", "TwoWords"];
	_taskBasedList = [];
	{
		_title = (((_x call BIS_fnc_taskDescription) select 1) select 0);
		if ((["hvt", _title, false] call BIS_fnc_inString)) then {
			_taskBasedList = ["Priest", "Ghost", "King", "Duke", "Baron", "Viper", "Snake", "Lion", "Tiger", "Bishop", "Apollo", "Jupiter", "Poseidon", "Odin", "Valhalla", "Anubis", "Osiris", "Reaper", "Ahriman", "Malsumis"];
		} else {
			if ((["cache", _title, false] call BIS_fnc_inString)) then {
				_taskBasedList = ["Pillar", "Hoard", "Nest", "Trove", "Gold", "Fortune", "Emerald", "Opal", "Iron", "Steel", "Pearl", "Oyster", "Fountain", "Egg"];
			} else {
				if ((["intel", _title, false] call BIS_fnc_inString)) then {
					_taskBasedList = ["Scribe", "Papyrus", "Tome", "Mind", "Book", "Codex", "Atlas", "Scroll", "Source", "Abacus", "Mentor", "Oracle", "Sphinx"];
				} else {
					if ((["helicopter", _title, false] call BIS_fnc_inString)) then {
						_taskBasedList = ["Falcon", "Pheasant", "Goose", "Grouse", "Buzzard", "Albatross", "Condor", "Turkey", "Pelican", "Gnat", "Moth"];
					} else {
						if ((["artillery", _title, false] call BIS_fnc_inString) || (["destroy aa", _title, false] call BIS_fnc_inString)) then {
							_taskBasedList = ["Hammer", "Maul", "Lance", "Grip", "Drill"];
						} else {
							if ((["captive", _title, false] call BIS_fnc_inString)) then {
								_taskBasedList = ["Lamb", "Artemis", "Hermes", "Exodus", "Cage", "Bond", "Lock", "Leash", "Shackle", "Tether", "Snare", "Diplomat"];
							} else {
								if ((["observe", _title, false] call BIS_fnc_inString)) then {
									_taskBasedList = ["Vigil", "Lens", "Tower", "Hunter", "Night", "Archer", "Track", "Seer", "Eye", "Spy"];
								};
							};
						};
					};
				};
			};			
		};		
	} forEach taskIDs;
	
	_missionName = switch (_missionNameType) do {
		case "OneWord": {
			_nameArray = if (count _taskBasedList > 0) then {
				_taskBasedList				
			} else {
				["Garrotte", "Castle", "Tower", "Sword", "Moat", "Traveller", "Headwind", "Fountain", "Taskmaster", "Tulip", "Carnation", "Gaunt", "Goshawk", "Jasper", "Flashbulb", "Banker", "Piano", "Rook", "Knight", "Bishop", "Pyrite", "Granite", "Hearth", "Staircase"];
			};			
			format ["Operation %1", selectRandom _nameArray];
		};
		case "DoubleWord": {
			_name1Array = ["Dust", "Swamp", "Red", "Green", "Black", "Gold", "Silver", "Lion", "Bear", "Dog", "Tiger", "Eagle", "Fox", "North", "Moon", "Watch", "Under", "Key", "Court", "Palm", "Fire", "Fast", "Light", "Blind", "Spite", "Smoke", "Castle"];
			_name2Array = ["bowl", "catcher", "fisher", "claw", "house", "master", "man", "fly", "market", "cap", "wind", "break", "cut", "tree", "woods", "fall", "force", "storm", "blade", "knife", "cut", "cutter", "taker", "torch"];
			format ["Operation %1%2", selectRandom _name1Array, selectRandom _name2Array];
		};
		case "TwoWords": {		
			_name1Array = ["Awoken", "Warning", "Wakeful", "Bonded", "Sweeping", "Watching", "Bladed", "Crushing", "Arcane", "Midnight", "Fallen", "Turbulent", "Nesting", "Daunting", "Dogged", "Darkened", "Shallow", "Blank", "Absent", "Parallel", "Restless"];					
			_name2Array = if (count _taskBasedList > 0) then {
				_taskBasedList
			} else {
				["Sky", "Moon", "Sun", "Hand", "Monk", "Priest", "Viper", "Snake", "Boon", "Cannon", "Market", "Rook", "Knight", "Bishop", "Command", "Mirror", "Spider", "Charter", "Court", "Hearth"]
			};		
			format ["Operation %1 %2", selectRandom _name1Array, selectRandom _name2Array];
		};
	};
	_missionName
};

sun_addIntel = {
	_intelObject = _this select 0;
	_taskName = _this select 1;
	_intelObject setVariable ["task", _taskName];	
	_intelObject addAction [
		"Collect Intel",
		{
			[_this select 3, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
			missionNamespace setVariable [format ["%1Completed", (_this select 3)], 1, true];
			deleteVehicle (_this select 0);
			[5, false, (_this select 1)] execVM "sunday_system\intel\revealIntel.sqf";			
		},
		_taskName,
		6,
		true,
		true,
		"",
		"true",
		5
	];	
};

dro_initLobbyCam = {
	private ["_playerPos", "_camLobbyStartPos", "_camLobbyEndPos"];
	_playerPos = [((getPos player) select 0), ((getPos player) select 1), (((getPos player) select 2)+1.2)];
	_camLobbyStartPos = [(getPos player), 5, (getDir player)-35] call dro_extendPos;
	_camLobbyStartPos = [(_camLobbyStartPos select 0), (_camLobbyStartPos select 1), (_camLobbyStartPos select 2)+1];
	camLobby = "camera" camCreate _camLobbyStartPos;
	camLobby cameraEffect ["internal", "BACK"];
	camLobby camSetPos _camLobbyStartPos;
	camLobby camSetTarget _playerPos;
	camLobby camCommit 0;
	cameraEffectEnableHUD false;
	_camLobbyEndPos = [(getPos player), 5, (getDir player)+35] call dro_extendPos;
	_camLobbyEndPos = [(_camLobbyEndPos select 0), (_camLobbyEndPos select 1), (_camLobbyEndPos select 2)+1];
	camLobby camPreparePos _camLobbyEndPos;
	camLobby camPrepareTarget _playerPos;
	camLobby camCommitPrepared 120;
};

dro_hvtCapture = {
	params ["_hostage", "_player"];		
	[_hostage] joinSilent (group _player);
	[_hostage] call sun_addResetAction;
	[_hostage, false] remoteExec ["setCaptive", _hostage, true];	
	[_hostage, 'MOVE'] remoteExec ["enableAI", _hostage, true];			
	[(_hostage getVariable 'captureTask'), 'SUCCEEDED', true] remoteExec ["BIS_fnc_taskSetState", (leader(group _player)), true];
	'mkrAOC' setMarkerAlpha 1;
	for "_i" from ((count taskIntel)-1) to 0 step -1 do {
		if (((taskIntel select _i) select 0) == ([(_hostage getVariable 'captureTask')] call BIS_fnc_taskParent)) then {taskIntel deleteAt _i};
	};
	publicVariable "taskIntel";
};

dro_hostageRelease = {
	params ["_hostage", "_player"];	
	_hostage setVariable ["hostageBound", false, true];
	[_hostage, "Acts_AidlPsitMstpSsurWnonDnon_out"] remoteExec ["playMoveNow", 0]; 
	[_hostage] joinSilent (group _player);
	[_hostage] call sun_addResetAction;
	[_hostage, false] remoteExec ["setCaptive", _hostage, true];	
	[_hostage, 'MOVE'] remoteExec ["enableAI", _hostage, true];			
	[(_hostage getVariable 'joinTask'), 'SUCCEEDED', true] remoteExec ["BIS_fnc_taskSetState", (leader(group _player)), true];
	'mkrAOC' setMarkerAlpha 1;
	for "_i" from ((count taskIntel)-1) to 0 step -1 do {
		if (((taskIntel select _i) select 0) == ([(_hostage getVariable 'joinTask')] call BIS_fnc_taskParent)) then {taskIntel deleteAt _i};
	};
	publicVariable "taskIntel";
	//missionNamespace setVariable [format ['%1Completed', ((_this select 0) getVariable 'taskName')], 1, true];	
};

dro_detectPosMP = {
	private ["_taskName", "_taskPosFake"];
	_taskName = _this select 0;
	_taskPosFake = _this select 1;		
	if (alive player) then {
		if ((((vehicle player) distance _taskPosFake) < 1000) || (((getConnectedUAV player) distance _taskPosFake) < 1000)) then {			
			_aimedPos = screenToWorld [0.5, 0.5];
			if ((_aimedPos distance _taskPosFake) < 100) then {				
				_inspTime = (missionNamespace getVariable _taskName);
				_inspTime = _inspTime + 1;
				["DRO: Received an observe hit on %1(%3) by player %2, setting to %4", _taskName, player, (missionNamespace getVariable _taskName), _inspTime] call bis_fnc_logFormatServer;
				missionNamespace setVariable [_taskName, _inspTime, true];
			};
		};
	};
};