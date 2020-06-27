params ["_delay", ["_target", (getPos (leader (grpNetId call BIS_fnc_groupFromNetId)))]];

_useRandomPos = false;
_targetPos = switch (typeName _target) do {
	case "STRING": {_useRandomPos = true};
	case "OBJECT": {getPos _target};
	case "ARRAY": {_target};
};

_groupArray = [];
if (!isNil "enemySemiAlertableGroups") then {
	_groupArray = _groupArray + enemySemiAlertableGroups;
};
if (!isNil "enemySemiAlertableGroups") then {
	_groupArray = _groupArray + enemyAlertableGroups;
};
if (count _groupArray > 0) then {
	{
		while {(count (waypoints _x)) > 0} do {
			deleteWaypoint ((waypoints _x) select 0);
		};
		if (_useRandomPos) then {
			_targetPos = [[_target]] call BIS_fnc_randomPos;
		};
		[_x, _targetPos] call BIS_fnc_taskAttack;	
		sleep _delay;	
	} forEach _groupArray;
};