_allHCs = entities "HeadlessClient_F";
_allHPs = (units (group player)) - _allHCs;

_dialogPlayer = {
	if (isPlayer _x) exitWith {
		_x
	};
} forEach _allHPs;
diag_log format ["DRO: _allHPs = ", _allHPs];
diag_log format ["DRO: %2 considers dialog top control player to be: %2", player, _dialogPlayer];

disableSerialization;

_lobbyCamHandle = [] execVM "sunday_system\dialogs\initLobbyCam.sqf";
diag_log format ["DRO: Lobby cam script executed: %1", _lobbyCamHandle];

_lineSpacing = 2.5 * pixelGridNoUIScale * pixelH;
_lineHeight = 2.25 * pixelGridNoUIScale * pixelH;
{	
	_x setDir (_x getVariable ["startDir", 0]);	

	// Create delete checkbox
	_deleteControl = (findDisplay 626262) ctrlCreate ["DROCheckBoxRemove", (_x getVariable "unitDeleteIDC"), ((findDisplay 626262) displayCtrl 6060)];		
	_deleteControl ctrlSetPosition [2.5 * pixelGridNoUIScale * pixelW, ((_forEachIndex) * _lineSpacing), 2.25 * pixelGridNoUIScale * pixelW, _lineHeight];	
	_deleteControl ctrlSetEventHandler ["CheckBoxesSelChanged", (format ["_nil=[%1, _this]ExecVM 'sunday_system\dialogs\removeAI.sqf'", _x])];	
	_deleteControl ctrlCommit 0;		
	
	// Create nametag
	_nameControl = (findDisplay 626262) ctrlCreate ["DRONameButton", (_x getVariable "unitNameTagIDC"), ((findDisplay 626262) displayCtrl 6060)];	
	_nameControl ctrlSetPosition [4.75 * pixelGridNoUIScale * pixelW, ((_forEachIndex) * _lineSpacing), 15.25 * pixelGridNoUIScale * pixelW, _lineHeight];		
	if (isPlayer _x) then {		
		_nameControl ctrlSetText (format ["%1:", (name _x)]);
	} else {
		_nameControl ctrlSetText (format ["%1 (AI):", (name _x)]);
	};	
	_nameControl ctrlSetEventHandler ["ButtonClick", (format ["[%1] call sun_lobbyCamTarget", _x])];	
	_nameControl ctrlCommit 0;	
	
	// Create loadout switcher
	if ((player == _x) OR ((player == _dialogPlayer) && (!isPlayer _x))) then {
		_loadoutControl = (findDisplay 626262) ctrlCreate ["DROLoadoutSwitch", (_x getVariable "unitLoadoutIDC"), ((findDisplay 626262) displayCtrl 6060)];		
		_loadoutControl ctrlSetPosition [20 * pixelGridNoUIScale * pixelW, ((_forEachIndex) * _lineSpacing), 15.25 * pixelGridNoUIScale * pixelW, _lineHeight];	
		_loadoutControl ctrlSetEventHandler ["LBSelChanged", (format ["_nil=[%1, _this]ExecVM 'sunday_system\player_setup\switchUnitLoadout.sqf'", _x])];	
		_loadoutControl ctrlCommit 0;		
	} else {		
		_loadoutControl = (findDisplay 626262) ctrlCreate ["sundayText", (_x getVariable "unitLoadoutIDC"), ((findDisplay 626262) displayCtrl 6060)];	
		_loadoutControl ctrlSetPosition [20 * pixelGridNoUIScale * pixelW, ((_forEachIndex) * _lineSpacing), 15.25 * pixelGridNoUIScale * pixelW, _lineHeight];		
		_loadoutControl ctrlSetBackgroundColor [0.1,0.1,0.1,1];		
		_loadoutControl ctrlSetTextColor [1,1,1,0.5];		
		_factionClass = ((configfile >> "CfgVehicles" >> (_x getVariable "unitClass") >> "faction") call BIS_fnc_getCfgData);
		_class = format ["%1 - %2", ((configfile >> "CfgVehicles" >> (_x getVariable "unitClass") >> "displayName") call BIS_fnc_getCfgData), ((configfile >> "CfgFactionClasses" >> _factionClass >> "displayName") call BIS_fnc_getCfgData)];		
		_loadoutControl ctrlSetText _class;	
		_loadoutControl ctrlCommit 0;		
	};
	
	// Create VA button
	_VAControl = (findDisplay 626262) ctrlCreate ["DROVAButton", (_x getVariable "unitArsenalIDC"), ((findDisplay 626262) displayCtrl 6060)];		
	_VAControl ctrlSetPosition [35.25 * pixelGridNoUIScale * pixelW, ((_forEachIndex) * _lineSpacing), 2.25 * pixelGridNoUIScale * pixelW, _lineHeight];	
	_VAControl ctrlSetEventHandler ["ButtonClick", (format ["if (!isNil '%1') then {_nil=[%1]ExecVM 'sunday_system\dialogs\openArsenal.sqf'}", _x])];	
	_VAControl ctrlCommit 0;		
} forEach _allHPs;

menuSliderArray = [	
	["SQUAD LOADOUT", 6060],
	["INSERTION", 6070],
	["SUPPORTS", 6080]	
];
menuSliderCurrent = 0;

{
	((findDisplay 626262) displayCtrl (ctrlIDC _x)) ctrlSetFade 0;
	((findDisplay 626262) displayCtrl (ctrlIDC _x)) ctrlCommit 0.3;
} forEach (allControls findDisplay 626262);

if (player getVariable ['startReady', false]) then {
	((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseEnter", "(_this select 0) ctrlsettextcolor [0.04, 0.7, 0.4, 1]"];
	((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseExit", "(_this select 0) ctrlsettextcolor [0.05, 1, 0.5, 1]"];
	((findDisplay 626262) displayCtrl 1601) ctrlSetTextColor [0.05, 1, 0.5, 1];
};

{
	_thisUnit = _x;
	if ((player == _thisUnit) OR ((player == _dialogPlayer) && (!isPlayer _thisUnit))) then {
		// Populate unit classes
		
		// Get listbox for this unit, make sure it's clear and add all class options to it
		_thisLB = (_thisUnit getVariable "unitLoadoutIDC");		
		lbClear _thisLB;
		{		
			_index = lbAdd [_thisLB, format ["%1 - %2", (_x select 1), (_x select 2)]];			
			lbSetData [_thisLB, _index, (_x select 0)];
		} forEach unitList;	
			
		if ((_thisUnit getVariable "unitChoice") isEqualType "") then {		
			if ((_thisUnit getVariable "unitChoice") == "CUSTOM") then {
				_index = lbAdd [_thisLB, "Custom Loadout"];
				lbSetData [_thisLB, _index, "CUSTOM"];
				lbSetCurSel [_thisLB, _index];
			} else {		
				for "_i" from 1 to (lbSize _thisLB) do {
					_className = lbData [_thisLB, (_i - 1)];
					if ((_thisUnit getVariable "unitChoice") == _className) then {
						lbSetCurSel [_thisLB, (_i - 1)];						
					};
				};
			};		
		};
	};
	
	// Disable delete button for players
	if (isPlayer _thisUnit) then {
		ctrlEnable [(_thisUnit getVariable "unitDeleteIDC"), false];
	};
	
} forEach playerGroup;

lbAdd [6009, "Random"];
lbAdd [6009, "Ground"];
lbAdd [6009, "Air - HALO"];
lbAdd [6009, "Air - Helicopter"];
if (player == _dialogPlayer) then {
	lbSetCurSel [6009, insertType];
};

// Insert vehicle options
if (player == _dialogPlayer) then {
	
	_validVehicles = if (missionPreset == 3) then {
		pCarClasses + pAPCClasses + pTankClasses + pArtyClasses + pHeliClasses;
	} else {
		pCarClasses + pHeliClasses;
	};
	{
		_thisIDC = _x;
		_thisIDCIndex = _forEachIndex;
		_index0 = lbAdd [_thisIDC, "Random"];
		lbSetData [_thisIDC, _index0, ""];		
		{
			_index = lbAdd [_thisIDC, ((configfile >> "CfgVehicles" >> _x >> "displayName") call BIS_fnc_getCfgData)];
			lbSetPicture [_thisIDC, _index, ((configfile >> "CfgVehicles" >> _x >> "icon") call BIS_fnc_getCfgData)];	
			lbSetPictureColor [_thisIDC, _index, [1, 1, 1, 1]];
			lbSetData [_thisIDC, _index, _x];			
			if ((startVehicles select _thisIDCIndex) == _x) then {
				lbSetCurSel [_thisIDC, _index];
			};						
		} forEach _validVehicles;
		if (lbCurSel _thisIDC == -1) then {
			lbSetCurSel [_thisIDC, _index0];
		};
	} forEach [6021, 6022];
};

// Support options
lbAdd [6010, "Random"];
lbAdd [6010, "Custom"];

if (player == _dialogPlayer) then {
	lbSetCurSel [6010, randomSupports];
	if ('SUPPLY' in customSupports) then {		
		((findDisplay 626262) displayCtrl 6011) ctrlSetTextColor [0.05, 1, 0.5, 1];
	};
	if ('ARTY' in customSupports) then {		
		((findDisplay 626262) displayCtrl 6012) ctrlSetTextColor [0.05, 1, 0.5, 1];
	};
	if ('CAS' in customSupports) then {		
		((findDisplay 626262) displayCtrl 6013) ctrlSetTextColor [0.05, 1, 0.5, 1];
	};
	if ('UAV' in customSupports) then {			
		((findDisplay 626262) displayCtrl 6014) ctrlSetTextColor [0.05, 1, 0.5, 1];
	};	
	if ((count pHeliClasses) == 0) then {
		ctrlEnable [6011, false];
		if ('SUPPLY' in customSupports) then {customSupports = customSupports - ['SUPPLY']};
	};
	if ((count (pMortarClasses + pArtyClasses)) == 0) then {
		ctrlEnable [6012, false];
		if ('ARTY' in customSupports) then {customSupports = customSupports - ['ARTY']};
	};
	if ((count availableCASClasses) == 0) then {
		ctrlEnable [6013, false];
		if ('CAS' in customSupports) then {customSupports = customSupports - ['CAS']};
	};
	if (({_x isKindOf "Plane"} count pUAVClasses) == 0) then {
		ctrlEnable [6014, false];
		if ('UAV' in customSupports) then {customSupports = customSupports - ['UAV']};
	};	
};



// If player is not _dialogPlayer then disable all other controls
if (player != _dialogPlayer) then {
	{
		if (_x != player) then {			
			ctrlEnable [(_x getVariable "unitArsenalIDC"), false];			
			ctrlEnable [(_x getVariable "unitDeleteIDC"), false];
		}
	} forEach playerGroup;
	ctrlEnable [6004, false];
	ctrlEnable [6005, false];
	ctrlEnable [6009, false];
	ctrlEnable [6010, false];
	ctrlEnable [6011, false];
	ctrlEnable [6012, false];
	ctrlEnable [6013, false];
	ctrlEnable [6014, false];
	ctrlEnable [6050, false];
	ctrlEnable [6021, false];
	ctrlEnable [6022, false];
};

// Remove controls for AI no longer in group
{
	if (isObjectHidden _x) then {		
		ctrlEnable [(_x getVariable "unitLoadoutIDC"), false];
		ctrlEnable [(_x getVariable "unitArsenalIDC"), false];		
		ctrlEnable [(_x getVariable "unitDeleteIDC"), true];
		((findDisplay 626262) displayCtrl (_x getVariable "unitDeleteIDC")) ctrlSetChecked true;		
	};	
} forEach playerGroup;

if (!isNil "firstLobbyOpen") then {
	if (firstLobbyOpen && (player == _dialogPlayer)) then {
		{
			_maxIndex = if (missionPreset == 2) then {1} else {3};
			if (_forEachIndex > _maxIndex) then {
				if (!isPlayer _x) then {
					[_x, true] remoteExec ["hideObject", 0, true];				
					//[_x] joinSilent grpNull;				
					ctrlEnable [(_x getVariable "unitLoadoutIDC"), false];
					ctrlEnable [(_x getVariable "unitArsenalIDC"), false];
					ctrlEnable [(_x getVariable "unitReadyIDC"), false];					
					diag_log format ["DRO: Removed unit %1", _x];
					((findDisplay 626262) displayCtrl (_x getVariable "unitDeleteIDC")) ctrlSetChecked true;
				};			
			};
		} forEach _allHPs;
	};
	firstLobbyOpen = false;
};

// Destroy camera and allow player control if lobby isn't complete and dialog is exited
waitUntil {!dialog};
if (((missionNameSpace getVariable "lobbyComplete") != 1)) then {	
	if (isNull (uiNamespace getVariable ["BIS_fnc_arsenal_cam", objNull ])) then {
		if (!visibleMap) then {
			camLobby cameraEffect ["terminate","back"];
			camUseNVG false;
			camDestroy camLobby;
			player switchCamera playerCameraView;
		};
	};	
};
