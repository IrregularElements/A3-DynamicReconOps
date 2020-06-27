

while {true} do {
	sleep 5;
	
	_aiUnits = [];
	{
		if (!isPlayer _x) then {_aiUnits pushBack _x};
	} forEach reviveUnits;	
	
	{
		//diag_log reviveUnits;
		//diag_log format ["%5 - rev_downed: %1, rev_beingAssisted: %2, rev_dragged: %3, rev_beingRevived: %4", (_x getVariable ["rev_downed", false]), (_x getVariable ["rev_beingAssisted", false]), (_x getVariable ["rev_dragged", false]), (_x getVariable ["rev_beingRevived", false]), _x];
		if ((_x getVariable ["rev_downed", false]) && !(_x getVariable ["rev_beingAssisted", false]) && !(_x getVariable ["rev_dragged", false]) && !(_x getVariable ["rev_beingRevived", false]) && (side _x != sideEnemy)) then {			
			_downedUnit = _x;
			_medikitMedics = [];
			_fakMedics = [];
			{
				_unit = _x;
				if (alive _unit && !(_unit getVariable ["rev_downed", false]) && !(_unit getVariable ["rev_revivingUnit", false])) then {
					if ("Medikit" in (items _unit)) then {
						_medikitMedics pushBackUnique _unit;
					};
					if ("FirstAidKit" in (items _unit)) then {
						_fakMedics pushBackUnique _unit;
					};				
				};				
			} forEach _aiUnits;			
			if (count _medikitMedics > 0) then {
				if (count _medikitMedics > 1) then {
					_closestMedics = [_medikitMedics, [_downedUnit], {_x distance _input0}, "ASCEND"] call BIS_fnc_sortBy;					
					[(_closestMedics select 0), _downedUnit] remoteExec ["rev_AIHeal", (_closestMedics select 0)];
				} else {					
					[(_medikitMedics select 0), _downedUnit] remoteExec ["rev_AIHeal", (_medikitMedics select 0)];
				};				
			} else {
				if (count _fakMedics > 0) then {
					if (count _fakMedics > 1) then {
						_closestMedics = [_fakMedics, [_downedUnit], {_x distance _input0}, "ASCEND"] call BIS_fnc_sortBy;						
						[(_closestMedics select 0), _downedUnit] remoteExec ["rev_AIHeal", (_closestMedics select 0)];
					} else {						
						[(_fakMedics select 0), _downedUnit] remoteExec ["rev_AIHeal", (_fakMedics select 0)];
					};					
				};				
			};
			
		};
	} forEach reviveUnits;
	
};
