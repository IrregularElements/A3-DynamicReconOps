sleep 0.05;

_unit = _this select 0;

[(format ["Revive: Bleedout started for %1", _unit])] remoteExec ["diag_log", 2];

private _time = bleedTime;
private ["_timeBefore", "_total", "_blood"];
_timeBefore = time;
_total = _time;
_blood = 1;

private _bloodLevel = 0;
private _bloodLevelPrev = 0;

private _suicideAction = nil;


BIS_BleedCC = ppEffectCreate ["ColorCorrections", 1634];

// Post process effects for players
if (!isDedicated && _unit == player) then {
	[] spawn {		
		while {(player getVariable "rev_downed")} do {
			sleep 1;
			if (player getVariable "rev_downed") then {				
				//grab blood level
				private _blood = player getVariable ["rev_blood", 1];
			
				//calculate desaturation
				private _bright = 0.2 + (0.1 * _blood);
				bis_revive_ppColor ppEffectAdjust [1,1, 0.15 * _blood,[0.3,0.3,0.3,0],[_bright,_bright,_bright,_bright],[1,1,1,1]];

				//calculate intensity of vignette
				private _intense = 0.6 + (0.4 * _blood);
				bis_revive_ppVig ppEffectAdjust [1,1,0,[0.15,0,0,1],[1.0,0.5,0.5,1],[0.587,0.199,0.114,0],[_intense,_intense,0,0,0,0.2,1]];

				//calculate intensity of blur
				private _blur = 0.7 * (1 - _blood);
				bis_revive_ppBlur ppEffectAdjust [_blur];

				//smoothly transition
				{_x ppEffectCommit 1} forEach [bis_revive_ppColor, bis_revive_ppVig, bis_revive_ppBlur];
				
				/*
				BIS_BleedCC ppEffectAdjust [1,1,0,[0.17, 0.0008, 0.0008, 0],[0.17, 0.0008, 0.0008, 0.1],[1, 1, 1, 0], [0.95, 0.95, 0, 0, 0, 0.2, 2]];
				BIS_BleedCC ppEffectEnable TRUE;
				BIS_BleedCC ppEffectCommit 0.0;
				
				[20] call BIS_fnc_bloodEffect;
				
				playSound (selectRandom ["WoundedGuyA_01", "WoundedGuyA_02", "WoundedGuyA_03", "WoundedGuyA_04", "WoundedGuyA_05", "WoundedGuyA_06", "WoundedGuyA_07", "WoundedGuyA_08"]);
				//playSound3D ["A3\Missions_F_EPA\data\sounds\WoundedGuyA_01.wss", player, false, [0,0,0], 1, 1, 10];
				
				sleep 0.2;
				
				// switch Hit PP off
				BIS_BleedCC ppEffectAdjust [1,1,0,[0, 0, 0, 0],[1, 1, 1, 1],[0, 0, 0, 0], [1, 1, 0, 0, 0, 0.1, 0.5]];
				BIS_BleedCC ppEffectCommit 2;				
				sleep 3;
				*/				
			};
		};

		bis_revive_ppColor ppEffectAdjust [1, 1, 0, [1, 1, 1, 0], [0, 0, 0, 1],[0,0,0,0]];
		bis_revive_ppVig ppEffectAdjust [1, 1, 0, [1, 1, 1, 0], [0, 0, 0, 1],[0,0,0,0]];
		bis_revive_ppBlur ppEffectAdjust [0];

		{_x ppEffectCommit 1} forEach [bis_revive_ppColor, bis_revive_ppVig, bis_revive_ppBlur];
		sleep 1;
		{_x ppEffectEnable false} forEach [bis_revive_ppColor, bis_revive_ppVig, bis_revive_ppBlur];
		
	};
	/*
	[] spawn {
		sleep 5;
		_suicide = 0;
		_suicideKey = actionKeysNames ["action", 1, "Keyboard"];
		_suicideText = format ["<t color='#ffffff' size = '.6'>Hold %1 to commit suicide<br />or await revive</t>", _suicideKey];
		[_suicideText,-1,1,10,2,0,789] spawn BIS_fnc_dynamicText;
		//titleText ["Hold space to commit suicide", "PLAIN"];
		while {(player getVariable "rev_downed")} do {
			if (inputAction "action" > 0) then {
				while {(inputAction "action" > 0)} do {					
					_suicide = _suicide + 1;					
					if (_suicide >= 5) then {
						player setDamage 1;
					};					
					sleep 1;				
				};
				_suicide = 0;
			}; 
		};
	};
	*/
	
	//_suicideAction = player addAction ["Suicide", {(_this select 0) setDamage 1; (_this select 0) removeAction (_this select 2)}, nil, 1000, true, true, "", "alive _target", -1, true];
	_suicideAction = [player] call rev_suicideActionAdd;
	
};


waitUntil {
	sleep 0.1;

	if !(_unit getVariable "rev_beingRevived") then {
		_time = _time - (time - _timeBefore);
	};

	_timeBefore = time;		

	//calculate blood
	_blood = (_time / _total);

	//get & set bleedout state
	_bloodLevel = floor(_blood * 5); if (_bloodLevel > 3) then {_bloodLevel = 3;};

	if (_unit getVariable "rev_downed") then {
		_unit setVariable ["rev_blood", _blood];
	};	
	
	//wait for unit to bleeding out be revived
	_blood <=0 || {!alive _unit || {!(_unit getVariable "rev_downed")}}
};

[(format ["Revive: %1 blood = %2", _unit, _blood])] remoteExec ["diag_log", 2];


if (!isNil "_suicideAction") then {
	_unit removeAction _suicideAction;
};

//kill unit if it bled out
if (alive _unit && {_blood <=0}) then {
	_unit setDamage 1;
};
