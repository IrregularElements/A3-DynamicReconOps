#include "reviveFunctions.sqf";

reviveUnits = units (_this select 0);
reviveTime = 10;
bleedTime = if (isNil "reviveDisabled") then {
	300
} else {
	switch (reviveDisabled) do {
		case 0: {300};
		case 1: {120};
		case 2: {60};
		default {300};
	};
};
reviveGroup = (_this select 0) call BIS_fnc_netId;
diag_log format ["Revive init begun for group %1", reviveGroup];

publicVariable "reviveUnits";
publicVariable "reviveTime";
publicVariable "bleedTime";
publicVariable "reviveGroup";

{
	diag_log format ["Revive init begun for unit %1", _x];
	_x setVariable ["rev_beingAssisted", false, true];		
	_x setVariable ["rev_beingRevived", false, true];
	_x setVariable ["rev_revivingUnit", false, true];
	_x setVariable ["rev_downed", false, true];
	_x setVariable ["rev_dragged", false, true];			
	_x setVariable ["rev_timeoutCounter", 0, true];		
	
	if (isMultiplayer) then {
		if (!isPlayer _x) then {
			_handlerLocal = [_x, ["Local", rev_changeLocal]] remoteExec ["addEventHandler", 0, true];
		};		
		_handlerDamage = [_x, ["HandleDamage", rev_handleDamage]] remoteExec ["addEventHandler", _x, true];	
		_handlerKilled = [_x, ["Killed", rev_handleKilled]] remoteExec ["addEventHandler", _x, true];
		_handlerRespawn = [_x, ["Respawn", {
			(_this select 0) removeAllEventHandlers "HandleDamage";
			(_this select 0) removeAllEventHandlers "Killed";			
			_handlerDamage = (_this select 0) addEventHandler ["HandleDamage", rev_handleDamage];
			_handlerKilled = (_this select 0) addEventHandler ["Killed", rev_handleKilled];
			(_this select 0) setCaptive false;
			reviveUnits = reviveUnits - [(_this select 1)];
			reviveUnits pushBack (_this select 0);
			publicVariable 'reviveUnits';
			private _allPlayers = allPlayers;
			_allPlayers = _allPlayers - [(_this select 0)];	
			[(_this select 0)] remoteExec ["rev_reviveActionAdd", _allPlayers, true];
			[(_this select 0)] remoteExec ["rev_dragActionAdd", _allPlayers, true];
			[(_this select 0), ["HandleRating", {if ((_this select 1) < 0) then {0}}]] remoteExec ["addEventHandler", (_this select 0), true];
			[(format ["Revive actions added for unit %1 called for %2", (_this select 0), _allPlayers])] remoteExec ["diag_log", 2];	
		}]] remoteExec ["addEventHandler", _x, true];
		diag_log format ["Revive initialised for unit %1", _x];
		
	} else {
		_handlerDamage = _x addEventHandler ["HandleDamage", rev_handleDamage];
		_handlerKilled = _x addEventHandler ["Killed", rev_handleKilled];
		diag_log format ["Revive initialised for unit %1", _x];	
	};	
		
	private _allPlayers = allPlayers;
	_allPlayers = _allPlayers - [_x];	
	[_x] remoteExec ["rev_reviveActionAdd", _allPlayers, true];
	[_x] remoteExec ["rev_dragActionAdd", _allPlayers, true];
	[(format ["Revive actions add for unit %1 called for %2", _x, _allPlayers])] remoteExec ["diag_log", 2];	
	// Handle ratings to stop units getting stuck in heal/kill loops
	[_x, ["HandleRating", {if ((_this select 1) < 0) then {0}}]] remoteExec ["addEventHandler", _x, true];
} forEach reviveUnits;

_aiUnits = [];
{
	if (!isPlayer _x) then {_aiUnits pushBack _x};
} forEach reviveUnits;
if (count _aiUnits > 0) then {
	[] spawn {
		while {true} do {
			sleep 5;
			
			_aiUnits = [];
			{
				if (!isPlayer _x) then {
					_aiUnits pushBack _x;					
				};
			} forEach reviveUnits;	
			if (count _aiUnits > 0) then {
				_leader = (leader (_aiUnits select 0));			
				[_aiUnits] remoteExec ["rev_AIListen", _leader];
			};
		};
	};
	[] spawn {
		sleep 200;
		_aiUnits = [];
		{
			if (!isPlayer _x) then {
				_aiUnits pushBack _x;					
			};
		} forEach reviveUnits;
		{
			_x setVariable ["rev_timeoutCounter", 0, true];
		} forEach _aiUnits;
	};
};


//[] execVM "sunday_revive\AIReviveListen.sqf";