private ["_varName", "_str", "_unit", "_id", "_loadout", "_class", "_firstName", "_lastName", "_unitOld"];

diag_log format ["DRO: Initiating AI respawn for %1", (_this select 0)];

_unitOld = (_this select 0);
_loadout = ((_this select 0) getVariable "respawnLoadout");
_varName = vehicleVarName (_this select 0);
_id = parseNumber ((str (_this select 0)) select [1]);
_id = _id - 1;
_class = (typeOf (_this select 0));
_firstName = ((nameLookup select _id) select 0);
_lastName = ((nameLookup select _id) select 1);
_speaker = ((nameLookup select _id) select 2); 
_face = ((nameLookup select _id) select 3); 

diag_log format ["DRO: Data for respawning %1:", (_this select 0)];
diag_log format ["DRO: _varName = %1", _varName];
diag_log format ["DRO: _id = %1", _id];
diag_log format ["DRO: _loadout = %1", _loadout];
diag_log format ["DRO: _class = %1", _class];
diag_log format ["DRO: _firstName = %1", _firstName];
diag_log format ["DRO: _lastName = %1", _lastName];

sleep respawnTime;

_respawnPos = if ((paramsArray select 1) == 0 OR (paramsArray select 1) == 2) then {
	getMarkerPos "respawn"
} else {
	if ((paramsArray select 1) < 2) then {
		getMarkerPos "campMkr"
	} else {
		[]
	};
};

if (count _respawnPos > 0) then {
	_grp = createGroup playersSide;
	_unit = _grp createUnit [_class, _respawnPos, [], 0, "NONE"];

	diag_log format ["DRO: respawn - created unit %1 in group %2", _unit, _grp];

	if (reviveDisabled < 3) then {
		[_unit, _unitOld] call rev_addReviveToUnit;
	};

	deleteVehicle (_this select 0);

	_unit setVehicleVarName _varName;

	diag_log format ["DRO: respawn - unit %1 given var name %2", _unit, _varName];

	[_unit, _firstName, _lastName, _speaker, _face] remoteExec ['sun_setNameMP', 0, true];

	diag_log "DRO: respawn - names set";

	_playerGroup = grpNetId call BIS_fnc_groupFromNetId;
	_unit joinAsSilent [_playerGroup, _id];
	diag_log format ["DRO: respawn - unit %1 joined to group %2 in position %3", _unit, _playerGroup, _id];

	_unit setUnitLoadout _loadout;
	_unit setVariable ["respawnLoadout", (getUnitLoadout _unit), true];

	_unit setUnitTrait ["Medic", true];
	_unit setUnitTrait ["engineer", true];
	_unit setUnitTrait ["explosiveSpecialist", true];
	_unit setUnitTrait ["UAVHacker", true];

	if ((paramsArray select 0) == 3) then {
		[_unit, ["respawn", {
			_unit = (_this select 0);				
			deleteVehicle _unit
		}]] remoteExec ["addEventHandler", _unit, true];
	} else {
		[_unit, ["killed", {[(_this select 0)] execVM "sunday_system\player_setup\fakeRespawn.sqf"}]] remoteExec ["addEventHandler", _unit, true];
		[_unit, ["respawn", {
			_unit = (_this select 0);				
			deleteVehicle _unit
		}]] remoteExec ["addEventHandler", _unit, true];				
	};
	 
	deleteGroup _grp;
};