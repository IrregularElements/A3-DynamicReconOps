// Apply player unit loadouts and identities
disableSerialization;
_thisUnit = _this select 0;
_return = _this select 1;

if ((player == _thisUnit) OR (!isPlayer _thisUnit)) then {
	
	_infCopy = nil;
	
	if (typeName (_return select 0) == "CONTROL") then {
		_infCopy = (_return select 0) lbData (_return select 1);
	} else {
		_infCopy = (_return select 0);
	};
	
	if ((_thisUnit getVariable ["unitChoice", ""]) == _infCopy) then {
		//diag_log format ["DRO: %1 kept current loadout without change", _thisUnit];
	} else {
		_thisUnit setVariable ['unitChoice', _infCopy, true];
		if (_infCopy == "CUSTOM") then {

		} else {			
			if (typeName (_return select 0) == "CONTROL") then {
				_lbSize = (lbSize (_return select 0));
				for "_i" from 1 to _lbSize do {
					if (((_return select 0) lbData _i) == "CUSTOM") then {
						(_return select 0) lbDelete _i;
						(_return select 0) lbSetCurSel (_return select 1);
					};
				};	
			};			
			_thisUnit setVariable ['unitClass', _infCopy, true];			
			_thisUnit setUnitLoadout (getUnitLoadout _infCopy);		
			
		};
	};
};

{
	_class = if (typeName (_return select 0) == "CONTROL") then {
		(_return select 0) lbText (_return select 1)
	} else {
		(_return select 1)
	};	
	[626262, (_thisUnit getVariable "unitLoadoutIDC"), _class] remoteExec ["sun_lobbyChangeLabel", _x];	
	
} forEach allPlayers;
