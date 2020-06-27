_taskDesc = "Maintain stealth by avoiding enemies or taking them out before they can alert other squads.";
_taskTitle = "Optional: Maintain Stealth";
_taskID = ["taskStealth", true, [_taskDesc, _taskTitle, ""], nil, "CREATED", 0, true, true, "listen"] call BIS_fnc_setTask;
stealthActive = true;

// Test for stealth
/*
while {stealthActive} do {
	sleep 5;
	hint str (enemySide knowsAbout (leader (grpNetId call BIS_fnc_groupFromNetId)));
	{		
		if ((enemySide knowsAbout _x) > 3.5) exitWith {
			_sentence = selectRandom [
				"I've been spotted, we need to take these guys out fast!",
				"They've seen me! We need to take them out now!",
				"I'm compromised, we've got to eliminate these guys before they raise the alarm!"
			];
			[_x, _sentence] remoteExec ["groupChat", 0];
			sleep 30;
			if ((enemySide knowsAbout _x) > 3.5) then {				
				stealthActive = false;
			};
		};
	} forEach (units (grpNetId call BIS_fnc_groupFromNetId));	
};
*/

// TEST STEALTH!!
alertedGroups = [];
alertableLeaders = allGroups select {side _x == enemySide};
alertableLeaders = alertableLeaders apply {leader _x};
while {stealthActive} do {	
	//hint str (enemySide knowsAbout (leader (grpNetId call BIS_fnc_groupFromNetId)));
	sleep 1;
	{
		_thisLeader = _x;
		if (alive _thisLeader) then {
			{
				_target = _x;
				_knowsAbout = ((group _thisLeader) knowsAbout _target);
				if (_knowsAbout >= 1.5) exitWith {
					alertableLeaders = alertableLeaders - [_thisLeader];
					[_thisLeader, _target, _knowsAbout] spawn {
						params ["_thisLeader", "_target", "_knowsAbout"];
						_sleepTime = (30*(5-_knowsAbout));
						diag_log format ["DRO: %1 detected by leader %2 with value %3 - waiting for %4", _target, _thisLeader, _knowsAbout, _sleepTime];
						
						_sentence = selectRandom [
							"I've been spotted, we need to take these guys out fast!",
							"They've seen me! We need to take them out now!",
							"I'm compromised, we've got to eliminate these guys before they raise the alarm!"
						];
						[_target, _sentence] remoteExec ["groupChat", 0];
						
						sleep _sleepTime;													
						if (alive _thisLeader) then {
							if ((_thisLeader knowsAbout _target) >= _knowsAbout) then {				
								stealthActive = false;
								diag_log format ["DRO: Alarm raised by %1", _thisLeader];
							} else {
								alertableLeaders pushBackUnique _thisLeader;
								diag_log "DRO: Alert avoided";
							};							
						} else {							
							diag_log "DRO: Alert avoided";
						};
					};
				};
			} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
		};
	} forEach alertableLeaders;
};

/*
while {stealthActive} do {
	sleep 5;
	//hint str (enemySide knowsAbout (leader (grpNetId call BIS_fnc_groupFromNetId)));
	{
		_knowsAbout = (enemySide knowsAbout _x);
		if (_knowsAbout >= 1.5) exitWith {			
			sleep (30*(5-_knowsAbout));			
			if ((enemySide knowsAbout _x) >= _knowsAbout) then {				
				stealthActive = false;
			};
		};
	} forEach (units (grpNetId call BIS_fnc_groupFromNetId));	
};
*/
if (!stealthActive) then {
	// Fail the stealth task
	[_taskID, "FAILED", true] spawn BIS_fnc_taskSetState;	
	
	if (enemyCommsActive) then {
		// Alarm sound effects
		{					
			_thisPos = (_x select 0);
			[_thisPos] spawn {
				_alarm = createSoundSource ["Sound_Alarm", (_this select 0), [], 0];
				sleep 120;
				deleteVehicle _alarm;
			};
		} forEach AOLocations;
		
		// Alert nearby enemies to attack
		_groupArray = enemyAlertableGroups;
		{
			if ((leader _x) distance (leader (grpNetId call BIS_fnc_groupFromNetId)) < 600) then {
				 while {(count (waypoints _x)) > 0} do {
					deleteWaypoint ((waypoints _x) select 0);
				 };
				[_x, getPos (leader (grpNetId call BIS_fnc_groupFromNetId))] call BIS_fnc_taskAttack;	
				sleep 30;	
			};
		} forEach _groupArray;
	};
};