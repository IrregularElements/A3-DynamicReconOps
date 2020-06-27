params ["_unit", "_caller"];

private ["_varName", "_str", "_unitNew", "_id", "_loadout", "_class", "_firstName", "_lastName", "_pos"];

_playerGroup = group _caller;//grpNetId call BIS_fnc_groupFromNetId;

diag_log format ["DRO: Initiating AI reset for %1", _unit];

_loadout = (getUnitLoadout _unit);
_varName = vehicleVarName _unit;
_id = parseNumber ((str _unit) select [1]);
_id = _id - 1;
_class = (typeOf _unit);
_firstName = ((nameLookup select _id) select 0);
_lastName = ((nameLookup select _id) select 1);
_face = ((nameLookup select _id) select 3);
_speaker = speaker _unit;

_pos = [(getPos _unit), 0, 50, 1, 0, -1, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
if (_pos isEqualTo [0,0,0]) then {
	_pos = [(getPos player), 0, 50, 1, 0, -1, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
};
if (_pos isEqualTo [0,0,0]) exitWith {
	hint "No valid location found for unit reset!";
};

_grp = createGroup playersSide;
_unitNew = _grp createUnit [_class, _pos, [], 0, "NONE"];

diag_log format ["DRO: reset - created unit %1 in group %2, side %3", _unitNew, _grp, playersSide];

if (reviveDisabled < 3) then {	
	[_unitNew, _unit] call rev_addReviveToUnit;
};

deleteVehicle _unit;

[_unitNew, _varName] remoteExec ["setVehicleVarName", 0, true];
//_unitNew setVehicleVarName _varName;

diag_log format ["DRO: reset - unit %1 given var name %2", _unitNew, _varName];
diag_log format ["DRO: reset - unit %1 new var name is %2", _unitNew, vehicleVarName _unitNew];

//[_unitNew, ([format ["%1 %2", _firstName, _lastName], _firstName, _lastName])] remoteExec ["setName", 0, true];
[_unitNew, _lastName] remoteExec ["setNameSound", 0, true];

[_unitNew, _firstName, _lastName, _speaker, _face] remoteExec ['sun_setNameMP', 0, true];

diag_log "DRO: reset - names set";


_unitNew joinAsSilent [_playerGroup, _id];
diag_log format ["DRO: reset - unit %1 joined to group %2 in position %3", _unitNew, _playerGroup, _id];

_unitNew setUnitLoadout _loadout;
_unitNew setVariable ["respawnLoadout", (getUnitLoadout _unitNew), true];

[_unitNew] call sun_addResetAction;

/*
_unitNew setUnitTrait ["Medic", true];
_unitNew setUnitTrait ["engineer", true];
_unitNew setUnitTrait ["explosiveSpecialist", true];
_unitNew setUnitTrait ["UAVHacker", true];
*/
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


