
{
	if ((side _x == civilian) && (!captive _x)) then {
		_thisCiv = _x;
		[
			_thisCiv,
			[
				'"Move!"',  
				{  
					_dir = [(_this select 1), (_this select 0)] call BIS_fnc_dirTo;  
					_movePos = [(getPos (_this select 0)), 200, _dir] call dro_extendPos;  
					while {(count (waypoints (group (_this select 0)))) > 0} do
					{
						deleteWaypoint ((waypoints (group (_this select 0))) select 0);
					};
					_wp0 = (group (_this select 0)) addWaypoint [(getPos (_this select 0)), 0];
					_wp0 setWaypointSpeed "FULL";
					_wp1 = (group (_this select 0)) addWaypoint [_movePos, 50];
				},  
				nil,  
				6,  
				true,  
				true,  
				"",  
				"(_this distance _target < 10) && (vehicle _this == _this) && (alive _this) && (alive _target)"
			]
		] remoteExec ["addAction", 0, true];
	};
} forEach allUnits;

