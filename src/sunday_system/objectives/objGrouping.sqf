
// Objective grouping
_powTaskIndexes = [];
_hvtTaskIndexes = [];
_vehTaskIndexes = [];
_cacheTaskIndexes = [];
_artyTaskIndexes = [];
_wreckTaskIndexes = [];
_heliTaskIndexes = [];
_intelTaskIndexes = [];
{
	_taskTitle = (_x select 2);
	if (["Captive", _taskTitle] call BIS_fnc_inString) then {
		_powTaskIndexes pushBack _forEachIndex;
	};
	if (["HVT", _taskTitle] call BIS_fnc_inString) then {
		if (count (_x select 7) > 0) then {
			_continue = true;
			{
				if (["Capture", (_x select 2)] call BIS_fnc_inString) then {
					_continue = false;
				};
			} forEach (_x select 7);
			if (_continue) then {_hvtTaskIndexes pushBack _forEachIndex};
		} else {
			_hvtTaskIndexes pushBack _forEachIndex;
		};		
	};
	if (["Vehicle", _taskTitle] call BIS_fnc_inString) then {
		_vehTaskIndexes pushBack _forEachIndex;
	};
	if (["Cache", _taskTitle] call BIS_fnc_inString) then {
		_cacheTaskIndexes pushBack _forEachIndex;
	};
	if (["Destroy A", _taskTitle] call BIS_fnc_inString) then {
		_artyTaskIndexes pushBack _forEachIndex;
	};
	if (["Wreck", _taskTitle] call BIS_fnc_inString) then {
		_wreckTaskIndexes pushBack _forEachIndex;
	};
	if (["Helicopter", _taskTitle] call BIS_fnc_inString) then {
		_heliTaskIndexes pushBack _forEachIndex;
	};
	if (["Intel", _taskTitle] call BIS_fnc_inString) then {
		_intelTaskIndexes pushBack _forEachIndex;
	};
} forEach objData;

// POW
if (count powJoinTasks > 0) then {
	if (count pHeliClasses > 0) then {
		// Allow helicopter extraction
		[] spawn {
			waitUntil {playersReady == 1};			
			// Check for join subtask completion
			waitUntil { 
				sleep 10;				
				({[_x] call BIS_fnc_taskCompleted} count powJoinTasks == count powJoinTasks)								
			};			
			// Give extraction support
			[(leader (grpNetId call BIS_fnc_groupFromNetId)), "heliExtract"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];
			extractHeliUsed = true;
		};	
	} else {	
		// Spawn ground based extraction group
		_extractPos = {
			if (count ((_x select 2) select 5) > 0) exitWith {
				[((_x select 2) select 5)] call sun_selectRemove;
			}; 
		} forEach AOLocations;
		_extractPos = [
			[trgAOC],
			["water","out"],
			{
				_return = true;
				{				
					if ((_this distance (_x select 0)) < 800) exitWith {
						_return = false
					};
				} forEach AOLocations;
				_return
			}
		] call BIS_fnc_randomPos;
		
		if (!isNil "_extractPos") then {		
			_markerExtract = createMarker [(format ["mkrExtract%1", round(random 100000)]), _extractPos];						
			_markerExtract setMarkerShape "ICON";		
			_markerExtract setMarkerColor markerColorPlayers;
			_markerExtract setMarkerType "mil_pickup";
			_markerExtract setMarkerText "Extraction Team";
			_extractGroup = [_extractPos, playersSide, pInfClassesForWeights, pInfClassWeights, [4, 6]] call dro_spawnGroupWeighted;
			waitUntil {!isNil "_extractGroup"};
			_dir = [_extractPos, trgAOC] call BIS_fnc_dirTo;
			{
				_x allowDamage false;
				_x setCaptive true;
				_x setUnitPos "MIDDLE";				
				_x setFormDir _dir;
				_x setDir _dir;
			} forEach units _extractGroup;
			
			_powUnits = [];
			{
				_powUnits pushBack ((objData select _x) select 8);		
			} forEach _powTaskIndexes;
						
			{
				[_x, _extractGroup] spawn {
					waitUntil {
						sleep 5;
						((_this select 0) distance (leader (_this select 1)) < 20)
					};
					[(_this select 0)] join (_this select 1);						
				};
			} forEach _powUnits;
			
			[_powUnits, _extractGroup, _extractPos] spawn {
				waitUntil {
					sleep 5;					
					({group _x == (_this select 1)} count (_this select 0)) == (count (_this select 0))					
				};
				{
					_x setUnitPos "UP";
				} forEach units (_this select 1);
				_leaveDir = [((AOLocations select 0) select 0), (_this select 2)] call BIS_fnc_dirTo;
				_leavePos = [(_this select 2), 3000, _leaveDir] call BIS_fnc_relPos;						
				_wp = (_this select 1) addWaypoint [_leavePos, 0];
			};		
		};
	};	
};



if (count _powTaskIndexes > 1) then {
	// Collect all POW names
	_allPOWNames = [];
	{
		_allPOWNames pushBack (name ((objData select _x) select 8));		
	} forEach _powTaskIndexes;
	_namesCommaList = [_allPOWNames] call sun_stringCommaList;
	
	_downedHeliClass = if (powType == "HELICREW") then {
		(selectRandom pHeliClasses)
	};
	
	_powTypeDesc = switch (powType) do {
		case "JOURNALISTS": {
			(selectRandom ["a group of journalists", "a team of journalists", (format ["%1 war reporters", count _powTaskIndexes]), (format ["%1 embedded reporters", count _powTaskIndexes])])			
		};
		case "SCIENTISTS": {
			(selectRandom ["a group of scientists", "a research team", (format ["%1 science team members", count _powTaskIndexes]), (format ["%1 nuclear inspectors", count _powTaskIndexes])])			
		};
		case "INFANTRY": {
			(selectRandom ["all that remains of an ambushed squad", (format ["captured survivors of a %1 assault", enemyFactionName]), (format ["captive %1 soldiers", playersFactionName])])			
		};
		case "HELICREW": {
			selectRandom [(format ["%1 survivors of a downed %2", count _powTaskIndexes, ((configFile >> "CfgVehicles" >> _downedHeliClass >> "displayName") call BIS_fnc_GetCfgData)]), (format ["the captured crew of a downed", ((configFile >> "CfgVehicles" >> _downedHeliClass >> "displayName") call BIS_fnc_GetCfgData)])];
		};
		case "ENGINEERS": {
			(selectRandom ["an engineering team", (format ["%1 engineers", count _powTaskIndexes])])			
		};
	};
	
	_powTypeDesc2 = "";
	if (count _wreckTaskIndexes > 0) then {
		if (powType == "HELICREW") then {
			_powTypeDesc2 = selectRandom [(format ["%1 survivors of a downed %2", count _powTaskIndexes, ((configFile >> "CfgVehicles" >> _downedHeliClass >> "displayName") call BIS_fnc_GetCfgData)]), (format ["the captured crew of a downed", ((configFile >> "CfgVehicles" >> _downedHeliClass >> "displayName") call BIS_fnc_GetCfgData)])];
		} else {
			_allWrecks = [];
			{
				_allWrecks pushBack ((configFile >> "CfgVehicles" >> (typeOf ((objData select _x) select 8)) >> "displayName") call BIS_fnc_GetCfgData);	
			} forEach _wreckTaskIndexes;
			_powTypeDesc2 = format ["that were being transported through the %2 region in a %1", selectRandom _allWrecks, aoLocationName]
		};
	} else {
		switch (powType) do {
			case "JOURNALISTS": {				
				_powTypeDesc2 = (selectRandom [(format ["that were covering the %1 region", aoLocationName]), (format ["who were reporting on civil disturbances in the %1 area", aoLocationName]), (format ["who were operating with %2 blessing in the %1 area", aoLocationName, enemyFactionName])])
			};
			case "SCIENTISTS": {				
				_powTypeDesc2 = (selectRandom [(format ["that were conducting research in the %1 region", aoLocationName]), (format ["who were fleeing the %1 regime", enemyFactionName]), (format ["who were inspecting %2 facilities in the %1 area", aoLocationName, enemyFactionName])])
			};
			case "INFANTRY": {				
				_powTypeDesc2 = (selectRandom [(format ["who were conducting routine patrols around the %1 region", aoLocationName]), (format ["who came under heavy %1 fire after entering the %2 area", enemyFactionName, aoLocationName]), (format ["who were on reconnaissance tasking in the %2 area", aoLocationName, enemyFactionName])])
			};
			case "HELICREW": {
				_powTypeDesc2 = selectRandom [(format ["%1 survivors of a downed %2", count _powTaskIndexes, ((configFile >> "CfgVehicles" >> _downedHeliClass >> "displayName") call BIS_fnc_GetCfgData)]), (format ["the captured crew of a downed", ((configFile >> "CfgVehicles" >> _downedHeliClass >> "displayName") call BIS_fnc_GetCfgData)])];
			};
			case "ENGINEERS": {				
				_powTypeDesc2 = (selectRandom [(format ["who were overseeing civil projects in the %1 region", aoLocationName]), (format ["who were clearing mines in the %1 area", aoLocationName]), "who were ambushed on the way to a repair tasking"])
			};
		};
	};
	
	_descNew = (format [
		"%1 are %2 %3. They were taken captive %4 and %5",
		_namesCommaList,
		_powTypeDesc,
		_powTypeDesc2,
		selectRandom ["last night", "15 hours ago", "12 hours ago", "8 hours ago"],
		selectRandom ["command has tasked your team with their retrieval.", "we have a small window of opportunity to get them home.", "we have reason to believe they will be moved out of reach soon. Get them out of the area ASAP."]
	]);
	
	{
		if (_forEachIndex in _powTaskIndexes) then {
			_x set [1, _descNew];
		};
	} forEach objData;	
};

if (count _wreckTaskIndexes > 0 && count _powTaskIndexes == 1) then {
	_thisWreckIndex = selectRandom _wreckTaskIndexes;	
	_wreckType = ((configFile >> "CfgVehicles" >> (typeOf ((objData select _thisWreckIndex) select 8)) >> "displayName") call BIS_fnc_GetCfgData);		
	_powName = (name ((objData select (_powTaskIndexes select 0)) select 8));
	_powType = ((configFile >> "CfgVehicles" >> (typeOf ((objData select (_powTaskIndexes select 0)) select 8)) >> "displayName") call BIS_fnc_GetCfgData);
	
	_powDesc1 = selectRandom [
		(format ["%1 is a %2 who survived an attack on the %3 transporting him through the %4 region", _powName, toLower _powType, _wreckType, aoLocationName]),
		(format ["A %3 was transporting %2 %1 in the %4 region when it came under attack", _powName, toLower _powType, _wreckType, aoLocationName])
	];
	_timing = selectRandom ["last night", "15 hours ago", "12 hours ago", "8 hours ago"];
	_powDescNew = (format [
		"%1 %2. %3",
		_powDesc1,		
		_timing,
		selectRandom ["Command has tasked your team with his retrieval.", "We have a small window of opportunity to get him home.", "We have reason to believe he will be moved out of reach soon. Get him out of the area ASAP."]
	]);
		
	_wreckDescNew = (format [
		"A %1 came under attack in the %2 region %5 while transporting a %4 named %3. It is important that %6 are denied use of the %1 and command has tasked you with its destruction as well as %3's retrieval.",
		_wreckType,
		aoLocationName,
		_powName,
		toLower _powType,
		_timing,
		enemyFactionName
	]);
	
	{
		if (_forEachIndex in _powTaskIndexes) then {
			_x set [1, _powDescNew];
		};
		if (_forEachIndex == _thisWreckIndex) then {
			_x set [1, _wreckDescNew];
		};
	} forEach objData;
};

if (count _vehTaskIndexes > 1) then {
	_intro = selectRandom [
		(format ["A number of %1 vehicles in the %2 area have come to our attention, providing us with the perfect opportunity to disrupt %1 operations in the region.", enemyFactionName, aoLocationName]),
		(format ["Scouts have reported motorized %1 activity in the %2 region. A concentration of these vulnerable forces provides us with the perfect opportunity to disrupt %1 operations in the region.", enemyFactionName, aoLocationName]),
		(format ["A flyover last night showed motorized %1 units moving into the %2 area. We expect the rest of the %1 force to follow shortly so we want you to hit their motorized assets hard before they become too entrenched.", enemyFactionName, aoLocationName])
	];
		
	{
		if (_forEachIndex in _vehTaskIndexes) then {
			_vehicleName = ((configFile >> "CfgVehicles" >> (typeOf (_x select 8)) >> "displayName") call BIS_fnc_GetCfgData);
			_vehType = "";
			if (["Destroy", (_x select 2)] call BIS_fnc_inString) then {
				_vehType = selectRandom [
					(format ["We have reports that a %2 %1 can be found somewhere in the area and command would like to see it taken out of action.", _vehicleName, enemyFactionName, aoLocationName]),
					(format ["The target is a %1 which will need to be located and destroyed.", _vehicleName, enemyFactionName, aoLocationName]),
					(format ["Destroying the %1 along with its cargo will hamper %2 resupply efforts and assist the general %4 offensive.", _vehicleName, enemyFactionName, aoLocationName, playersFactionName])
				];
			};
			if (["Steal", (_x select 2)] call BIS_fnc_inString) then {
				_vehType = selectRandom [
					(format ["Locate the %2 %1 and steal it. Once it is out of the AO we can recover it safely.", _vehicleName, enemyFactionName, aoLocationName]),
					(format ["%4 intelligence believe the %1 contains important information regarding %2 positions and wants you to locate and steal it. Once the %1 is out of the AO we can recover it safely.", _vehicleName, enemyFactionName, aoLocationName, playersFactionName]),
					(format ["Reports suggest there is a %2 %1 that we would like you to steal. Once it is out of the AO we can recover it safely.", _vehicleName, enemyFactionName])
				];
			};
			
			_descNew = (format [
				"%1 %2",
				_intro,
				_vehType
			]);
		
			_x set [1, _descNew];
		};
	} forEach objData;
};

if (count _cacheTaskIndexes > 1) then {
	_string = selectRandom [
		(format ["In preparation for a major %3 offensive we believe that %1 forces have moved their ammunition caches to hidden locations. Find and eliminate each cache.", enemyFactionName, aoLocationName]),
		(format ["Reports are coming in about a major %1 offensive soon to be launched from the %2 region. In preparation a number of weapons caches have been moved into the area and we need a small team to find and destroy them before they can be used.", enemyFactionName, aoLocationName]),
		(format ["Insurgent groups operating out of the %2 region have displayed a more advanced arsenal than we would usually expect to see. Intelligence reports that these arms have come from %1 forces and are being hidden in the area. Find and destroy them.", enemyFactionName, aoLocationName])
	];
		
	{
		if (_forEachIndex in _cacheTaskIndexes) then {		
			_x set [1, _string];
		};
	} forEach objData;
};

if (count _artyTaskIndexes > 1) then {
	_string = selectRandom [
		(format ["Recent intelligence has placed %3 weapons platforms in the %2 region and command is anxious to see these destroyed before they can be employed against %4 forces in the region. Infiltrate the area and destroy the %3 targets.", enemyFactionName, aoLocationName, (count _artyTaskIndexes), playersFactionName]),
		(format ["With only hours until a major %4 offensive it is vital that the %3 targets located near %2 are destroyed. Command has requested a small unit to infiltrate and destroy them before the main force arrives.", enemyFactionName, aoLocationName, (count _artyTaskIndexes), playersFactionName]),
		(format ["%3 %1 heavy weapons targets have been spotted operating around the %2 area. Needless to say this makes %4 operations in the region complicated and command have ordered a covert attack to neutralize them.", enemyFactionName, aoLocationName, (count _artyTaskIndexes), playersFactionName])
	];
		
	{
		if (_forEachIndex in _artyTaskIndexes) then {		
			_x set [1, _string];
		};
	} forEach objData;
};

if (count _hvtTaskIndexes > 0) then {
	
	_allHVTNames = [];
	{
		_allHVTNames pushBack (((objData select _x) select 8) getVariable "codename");		
	} forEach _hvtTaskIndexes;
	_namesCommaList = [_allHVTNames] call sun_stringCommaList;

	_hvtString1 = selectRandom [
		(format ["Recent intelligence has placed %3 important targets in the %2 region.", enemyFactionName, aoLocationName, (count _hvtTaskIndexes), playersFactionName, _namesCommaList]),			
		(format ["Advancing %4 forces have trapped %3 %1 high value targets in the %2 region.", enemyFactionName, aoLocationName, (count _hvtTaskIndexes), playersFactionName, _namesCommaList]),			
		(format ["Routine surveillance of the %2 region by local militia groups has revealed %3 %1 targets in the area.", enemyFactionName, aoLocationName, (count _hvtTaskIndexes), playersFactionName, _namesCommaList])		
	];		
	_hvtString3 = selectRandom [
		"Locate and eliminate each of the targets.",			
		(format ["Move in to %1 and eliminate the targets.", aoLocationName]),			
		(format ["Neutralize the %1 targets as quickly and cleanly as possible.", enemyFactionName])			
	];
	
	if (count _hvtTaskIndexes > 1) then {
		// Multiple HVTs			
		_hvtString2 = selectRandom [
			(format ["%5 are members of the %1 command that have overseen the perpetration of war crimes during the current conflict. We have reason to believe that they fully intend to commit further acts against the civilian and militia populations.", enemyFactionName, aoLocationName, (count _hvtTaskIndexes), playersFactionName, _namesCommaList]),			
			(format ["%5 are responsible for a recent attack on %4 troops and are believed to be planning further operations against the civilian population.", enemyFactionName, aoLocationName, (count _hvtTaskIndexes), playersFactionName, _namesCommaList]),			
			(format ["%5 were recently lost from a %4 intelligence programme and are believed to have knowledge of clandestine operations and sources that could be used to cause the loss of important %4 assets.", enemyFactionName, aoLocationName, (count _hvtTaskIndexes), playersFactionName, _namesCommaList])		
		];				
		_hvtString = format ["%1 %2 %3", _hvtString1, _hvtString2, _hvtString3];
		{
			if (_forEachIndex in _hvtTaskIndexes) then {		
				_x set [1, _hvtString];
			};
		} forEach objData;
	} else {
		// Single HVT and...
		if (count _artyTaskIndexes > 0) then {
			// ...artillery
			_hvtString2 = selectRandom [
				(format ["%5 is a member of %1 command who has overseen recent artillery bombardments on civilian and %4 occupied areas.", enemyFactionName, aoLocationName, (count _hvtTaskIndexes), playersFactionName, _namesCommaList]),			
				(format ["%5 is responsible for a recent artillery attack on %4 troops. Command believes the accuracy of this attack indicates he has intelligence that may compromise further %4 operations.", enemyFactionName, aoLocationName, (count _hvtTaskIndexes), playersFactionName, _namesCommaList]),			
				(format ["%5 was recently lost from a %4 intelligence programme and is believed to have been using his knowledge of %4 positions to target them with artillery strikes.", enemyFactionName, aoLocationName, (count _hvtTaskIndexes), playersFactionName, _namesCommaList])		
			];					
			_artyString = selectRandom [
				(format ["A %2 artillery emplacement under command of HVT %1 is stopping effective %3 operations in the %4 region. It is vital these targets are taken out before the main %3 force can safely engage the enemy and commit to a sustained attack. Destroy the artillery.", _namesCommaList, enemyFactionName, playersFactionName, aoLocationName]),
				(format ["%2 have moved an artillery unit into the %4 area under the command of HVT %1. %3 command has placed a halt on major operations in the area until it is taken out. We believe a small unit should be able to infiltrate and destroy the artillery.", _namesCommaList, enemyFactionName, playersFactionName, aoLocationName]),
				(format ["With only hours until a major %3 offensive it is vital that the %2 artillery unit located near %4 is destroyed. Command has requested that a small unit infiltrate and destroy the artillery before the main force arrives. The artillery is under the command of an HVT codenamed %1 who is another target of ours.", _namesCommaList, enemyFactionName, playersFactionName, aoLocationName])
			];				
			_hvtString = format ["%1 %2 %3", _hvtString1, _hvtString2, _hvtString3];				
			{
				if (_forEachIndex in _hvtTaskIndexes) then {		
					_x set [1, _hvtString];
				};
				if (_forEachIndex in _artyTaskIndexes) then {		
					_x set [1, _artyString];
				};
			} forEach objData;
		};
		if (count _heliTaskIndexes > 0) then {
			// ...helicopters
			_hvtString2 = selectRandom [
				(format ["%5 is a member of %1 command that has overseen the perpetration of war crimes during the current conflict. We have reason to believe that he fully intends to commit further acts against the civilian and militia populations.", enemyFactionName, aoLocationName, (count _hvtTaskIndexes), playersFactionName, _namesCommaList]),			
				(format ["%5 is responsible for a recent attack on %4 troops and is believed to be planning further operations against the civilian population.", enemyFactionName, aoLocationName, (count _hvtTaskIndexes), playersFactionName, _namesCommaList]),			
				(format ["%5 was recently lost from a %4 intelligence programme and is believed to have knowledge of clandestine operations and sources that could be used to cause the loss of important %4 assets.", enemyFactionName, aoLocationName, (count _hvtTaskIndexes), playersFactionName, _namesCommaList])		
			];			
			_hvtString4 = "";
			_heliString = "";
			if (count _heliTaskIndexes > 1) then {
				// Multiple helicopters
				_hvtString4 = selectRandom [
					"It's believed that the target has access to air assets that may be used to extract him if he's in danger. It may be possible to get further value from this operation with their destruction.",			
					"Command is concerned that air assets may be used to take the target to safety and has requested that you destroy any located as an additional task.",			
					(format ["The target is believed to have prepared escape routes via air assets. Destroying any of these will be beneficial both to your mission and %1 operations in general.", playersFactionName])		
				];				
				_heliString = selectRandom [
					(format ["%2 air assets are stationed in the %3 region. We have intelligence that they are potentially being used as an extraction method for %1 making it important they are destroyed.", _namesCommaList, enemyFactionName, aoLocationName]),		
					(format ["Until recently %2 have been attacking %4 forces from hidden airbases at a number of locations. More recent intelligence has reveals that these air assets are being used to support the HVT %1 making it the perfect time to locate and destroy them.", _namesCommaList, enemyFactionName, aoLocationName, playersFactionName])				
				];	
			} else {
				// One helicopter
				_heliName = "";
				{
					_heliName = ((configFile >> "CfgVehicles" >> (typeOf ((objData select _x) select 8)) >> "displayName") call BIS_fnc_GetCfgData);						
				} forEach _heliTaskIndexes;				
				_hvtString4 = selectRandom [
					(format ["It's believed that the target has access to a %1 that may be used to extract him if he's in danger. It may be possible to get further value from this operation with its destruction.", _heliName]),			
					(format ["Command is concerned that a %1 may be used to take the target to safety and has requested that you locate and destroy it as an additional task.", _heliName]),									
					(format ["The target is believed to have prepared escape routes via a %2. Destroying this air asset will be beneficial both to your mission and %1 operations in general.", playersFactionName, _heliName])		
				];
				_heliString = selectRandom [
					(format ["An %2 %4 is stationed in the %3 region. We have intelligence that they are potentially being used as an extraction method for %1 making it important they are destroyed.", _namesCommaList, enemyFactionName, aoLocationName, _heliName]),		
					(format ["Until recently %2 have been attacking %4 forces from hidden airbases at a number of locations. More recent intelligence has reveals that a %5 is being used to support the HVT %1 making it the perfect time to locate and destroy it.", _namesCommaList, enemyFactionName, aoLocationName, playersFactionName, _heliName])				
				];	
			};			
			_hvtString = format ["%1 %2 %4 %3", _hvtString1, _hvtString2, _hvtString3, _hvtString4];				
			{
				if (_forEachIndex in _hvtTaskIndexes) then {		
					_x set [1, _hvtString];
				};
				if (_forEachIndex in _heliTaskIndexes) then {		
					_x set [1, _heliString];
				};
			} forEach objData;
		};		
	};	
};

if (count _intelTaskIndexes > 0) then {
	_stringIntros = [
		"It is likely that",
		"Command believes",
		"Intelligence leads us to believe",
		"Recent reports show the possibility that"
	];
	_intelStrings = [];
	if (count _hvtTaskIndexes > 0) then {
		_allHVTNames = [];
		{
			_allHVTNames pushBack (((objData select _x) select 8) getVariable "codename");		
		} forEach _hvtTaskIndexes;
		_namesCommaList = [_allHVTNames] call sun_stringCommaList;
		_stringIntro = [_stringIntros] call sun_selectRemove;
		_intelStrings pushBack (format ["%1 this intel package will contain information about the location of %2 as well as possible identifying information.", _stringIntro, _namesCommaList]);
	};
	if (count _powTaskIndexes > 0) then {
		_allPOWNames = [];
		{
			_allPOWNames pushBack (name ((objData select _x) select 8));		
		} forEach _powTaskIndexes;
		_namesCommaList = [_allPOWNames] call sun_stringCommaList;
		_stringIntro = [_stringIntros] call sun_selectRemove;
		_intelStrings pushBack (format ["%1 this intel package will contain information about the location of %2 as well as possible identifying information.", _stringIntro, _namesCommaList]);
	};
	if (count _cacheTaskIndexes > 0) then {
		_stringIntro = [_stringIntros] call sun_selectRemove;
		if (count _cacheTaskIndexes > 1) then {
			_intelStrings pushBack (format ["%1 this intel package will contain information about the location of the %2 caches.", _stringIntro, count _cacheTaskIndexes]);
		} else {
			_intelStrings pushBack (format ["%1 this intel package will contain information about the location of the cache.", _stringIntro]);
		};
	};
	if (count _intelStrings > 0) then {	
		_intelString = [_intelStrings] call sun_stringCommaList;
		{
			if (_forEachIndex in _intelTaskIndexes) then {		
				_x set [1, (format ["%1 %2", (_x select 1), _intelString])];
			};			
		} forEach objData;		
	};
};

