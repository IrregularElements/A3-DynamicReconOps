params ["_supportCoords"];

// POPULATE LIST OF ARTILLERY
// POPULATE LIST OF AMMO TYPES
// POPULATE LIST OF ROUNDS
// FIRE!

BIS_SUPP_calculateAmmo = compile preprocessFileLineNumbers "A3\modules_f\supports\procedures\calculateAmmo.sqf";
BIS_SUPP_distributeRounds = compile preprocessFileLineNumbers "A3\modules_f\supports\procedures\distributeRounds.sqf";

player setVariable ["DRO_SUPP_supportCoords", _supportCoords];
_provider = (player getVariable ["DRO_SUPP_artyVeh", objNull]);
player setVariable ["DRO_SUPP_ammoType", -1];
player setVariable ["DRO_SUPP_burst", 0];
_providerName = ((configfile >> "CfgVehicles" >> typeOf (vehicle _provider) >> "displayName") call BIS_fnc_GetCfgData);

// Provider
DRO_SUPP_MENU =
[
	// First array: "User menu" This will be displayed under the menu, bool value: has Input Focus or not.
	// Note that as to version Arma2 1.05, if the bool value set to false, Custom Icons will not be displayed.
	["Artillery", true],
	// Syntax and semantics for following array elements:
	// ["Title_in_menu", [assigned_key], "Submenu_name", CMD, [["expression",script-string]], "isVisible", "isActive" <, optional icon path> ]
	// Title_in_menu: string that will be displayed for the player
	// Assigned_key: 0 - no key, 1 - escape key, 2 - key-1, 3 - key-2, ... , 10 - key-9, 11 - key-0, 12 and up... the whole keyboard
	// Submenu_name: User menu name string (eg "#USER:MY_SUBMENU_NAME" ), "" for script to execute.
	// CMD: (for main menu:) CMD_SEPARATOR -1; CMD_NOTHING -2; CMD_HIDE_MENU -3; CMD_BACK -4; (for custom menu:) CMD_EXECUTE -5
	// script-string: command to be executed on activation.  (_target=CursorTarget,_pos=CursorPos) 
	// isVisible - Boolean 1 or 0 for yes or no, - or optional argument string, eg: "CursorOnGround"
	// isActive - Boolean 1 or 0 for yes or no - if item is not active, it appears gray.
	// optional icon path: The path to the texture of the cursor, that should be used on this menuitem.
	
	[_providerName, [2], "", -5, [["expression", "[] spawn DRO_menuOpenArtyAmmo"]], "1", "1", ""]	
	
];


DRO_menuOpenArtyAmmo = {
	_provider = (player getVariable ["DRO_SUPP_artyVeh", objNull]);
	// Ammo type
	DRO_SUPP_MENU =
	[
		["Ammo Type", true]		
	];
	
	{
		DRO_SUPP_MENU = DRO_SUPP_MENU + [
			[
				getText (configFile >> "CfgMagazines" >> _x >> "displayName"),
				[_forEachIndex + 2],
				"",
				-5,
				[["expression", format ["player setVariable ['DRO_SUPP_ammoType', %1]; [] spawn DRO_menuOpenArtyRounds", _forEachIndex]]],
				"1",
				"1",
				""
			]
		]
	} forEach getArtilleryAmmo [vehicle _provider];
	
	sleep 0.1;
	showCommandingMenu '#USER:DRO_SUPP_MENU'
};


DRO_menuOpenArtyRounds = {
	_provider = (player getVariable ["DRO_SUPP_artyVeh", objNull]);
	_supportCoords = (player getVariable ["DRO_SUPP_supportCoords", [0,0,0]]);
	_selectedAmmo = (getArtilleryAmmo [vehicle _provider] select (player getVariable "DRO_SUPP_ammoType"));
	
	// Rounds
	DRO_SUPP_MENU =
	[
		[localize "STR_A3_mdl_supp_comm_burst" + format [", ETA %1s", round (vehicle _provider getArtilleryETA [_supportCoords, _selectedAmmo])], TRUE]	
	];
	
	_weaponUsed = "";
	{if (_selectedAmmo in getArray (configFile >> "CfgWeapons" >> _x >> "magazines")) then {_weaponUsed = _x}} forEach weapons vehicle _provider;
	_roundsLeft = [_provider, (getArtilleryAmmo [vehicle _provider] select (player getVariable "DRO_SUPP_ammoType")), _supportCoords] call BIS_SUPP_calculateAmmo;
	_isInRange = _supportCoords inRangeOfArtillery [[_provider], _selectedAmmo];
	if (_roundsLeft > 0 && _isInRange) then {
		for [{_x = 1}, {_x <= _roundsLeft && _x <= 9}, {_x = _x + 1}] do {
			DRO_SUPP_MENU = DRO_SUPP_MENU + [
				[
					"",
					[_x + 1],
					"",
					-5,
					[[
						"expression",
						format ["player setVariable ['DRO_SUPP_burst', %1]; [] spawn DRO_artyCommit", _x]
					]],
					"1",
					"1",
					""
				]
			];
		};
	} else {
		DRO_SUPP_MENU = DRO_SUPP_MENU + [
			[
				"No ammunition or no range",
				[0],
				"",
				-5,
				[[
					"expression",
					""
				]],
				"1",
				"0",
				""
			]
		];
	};
	sleep 0.1;
	showCommandingMenu '#USER:DRO_SUPP_MENU'
};

DRO_artyCommit = {
	_provider = (player getVariable ["DRO_SUPP_artyVeh", objNull]);	
	_selectedAmmo = (getArtilleryAmmo [vehicle _provider] select (player getVariable "DRO_SUPP_ammoType"));
	
	_provider setVariable ["DRO_SUPP_supporting", true, true];	
	
	_supportCoords = (player getVariable ["DRO_SUPP_supportCoords", [0,0,0]]);	
	_provider setVariable ["DRO_SUPP_supportRunCoords", _supportCoords, true];
	_ammo = (getArtilleryAmmo [vehicle _provider] select (player getVariable "DRO_SUPP_ammoType"));
	_burst = player getVariable "DRO_SUPP_burst";
	_gunners = [_provider, _ammo, _burst, _supportCoords] call BIS_SUPP_distributeRounds;
	
	_isInRange = _supportCoords inRangeOfArtillery [[_provider], _selectedAmmo];
	if (!_isInRange) exitWith {
		dro_messageStack pushBack [
			[
				[str group ((crew _provider) select 0), "No range on that target.", 0]
			],
			true
		];
	};
	
	DRO_SUPP_tempEH = vehicle _provider addEventHandler ["Fired", {
		_this select 0 removeEventHandler ["Fired", DRO_SUPP_tempEH];		
		[_this select 0, _this select 6] spawn {
			waitUntil {!(alive (_this select 1)) || (((_this select 1) distance ((_this select 0) getVariable "DRO_SUPP_supportRunCoords") < 1000) && ((velocity (_this select 1)) select 2) < 0)};
			(_this select 0) setVariable ["DRO_SUPP_supporting", false, true];
		}
	}];
	
	{_x commandArtilleryFire [_supportCoords, _ammo, _x getVariable "BIS_SUPP_rounds"]} forEach _gunners;
	diag_log (driver _provider);
	dro_messageStack pushBack [
		[
			[str group ((crew _provider) select 0), "Rounds complete.", 0]
		],
		true
	];	
		
	_i = 1;
	_mrkrName = format ["BIS_SUPP_mrkr_%1", _i];
	while {markerPos format ["BIS_SUPP_mrkr_%1", _i] distance [0,0,0] > 0} do {_i = _i + 1};
	_mrkrName = format ["BIS_SUPP_mrkr_%1", _i];
	_mrkr = createMarker [_mrkrName, _supportCoords];
	_mrkrName setMarkerText localize "STR_A3_mdl_supp_disp_artillery";
	_mrkrName setMarkerType "selector_selectedMission";
	_mrkrName setMarkerColor "ColorBlack";
	_mrkrName setMarkerSize [0.75, 0.75];
		
	[_provider, _mrkrName, _supportCoords, _ammo] spawn {
		_provider = _this select 0;
		_mrkrName = _this select 1;
		_supportCoords = _this select 2;
		_ammo = _this select 3;
		_eta = round (vehicle _provider getArtilleryETA [_supportCoords, _ammo]);
		while {(_provider getVariable "DRO_SUPP_supporting") && alive _provider} do {			
			_mrkrName setMarkerText format ["%1 ETA %2s", localize "STR_A3_mdl_supp_disp_artillery", _eta];
			sleep 1;
			_eta = _eta - 1;
		};
		waitUntil {!(_provider getVariable "DRO_SUPP_supporting") || !alive _provider};
		deleteMarker _mrkrName;
		dro_messageStack pushBack [
			[
				[str group ((crew _provider) select 0), "Splash.", 0]
			],
			true
		];
	};
	
	//(_this select 0) kbTell [_this select 2, ""BIS_SUPP_protocol"", ""Artillery_Accomplished"", BIS_SUPP_channels select ([WEST, EAST, RESISTANCE] find side group (_this select 0))];
};

[] spawn {
	sleep 0.1;
	showCommandingMenu "#USER:DRO_SUPP_MENU";
};




