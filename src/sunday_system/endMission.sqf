if (['taskStealth'] call BIS_fnc_taskExists) then {
	if !((["taskStealth"] call BIS_fnc_taskState) isEqualTo "FAILED") then {
		['taskStealth', 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
		sleep 3;
	};	
};
['taskExtract', 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;

sleep 5;
[["", "BLACK OUT", 5]] remoteExec ["cutText", 0];
[5, 0] remoteExec ["fadeSound", 0];
[5, 0] remoteExec ["fadeSpeech", 0];
sleep 5;

diag_log 'DRO: Ending MP mission';
_successCount = 0;
_failCount = 0;
{
	_state = [_x] call BIS_fnc_taskState;
	diag_log format ["DRO: At end of mission task %1 is %2", _x, _state];
	switch (_state) do {
		case "SUCCEEDED": {_successCount = _successCount + 1};
		case "CANCELED": {_failCount = _failCount + 1};
		case "FAILED": {_failCount = _failCount + 1};
	};
} forEach taskIDs;

diag_log format ["DRO: At end of mission _successCount is %1", _successCount];
diag_log format ["DRO: At end of mission _failCount is %1", _failCount];
diag_log format ["DRO: At end of mission civDeathCounter is %1", civDeathCounter];

if (civDeathCounter > 1) then {
	if (civDeathCounter == 2) then {
		if (isMultiplayer) then {
			'DROEnd_FailCiv1' call BIS_fnc_endMissionServer;
		} else {
			'DROEnd_FailCiv1' call BIS_fnc_endMission;
		};
	} else {
		if (isMultiplayer) then {
			'DROEnd_FailCiv2' call BIS_fnc_endMissionServer;
		} else {
			'DROEnd_FailCiv2' call BIS_fnc_endMission;
		};
	};
} else {
	if (_successCount == (count taskIDs)) then {
		if (isMultiplayer) then {
			'DROEnd_Full' call BIS_fnc_endMissionServer;
		} else {
			'DROEnd_Full' call BIS_fnc_endMission;
		};
	} else {
		if (_failCount == (count taskIDs)) then {
			if (isMultiplayer) then {
			'DROEnd_Fail' call BIS_fnc_endMissionServer;
			} else {
				'DROEnd_Fail' call BIS_fnc_endMission;
			};			
		} else {	
			if (isMultiplayer) then {
				'DROEnd_Partial' call BIS_fnc_endMissionServer;
			} else {
				'DROEnd_Partial' call BIS_fnc_endMission;
			};			
		};
	};	
};