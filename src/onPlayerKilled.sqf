if (isMultiplayer) then {
	//player setVariable ["respawnLoadout", (getUnitLoadout player)];
	if ((paramsArray select 0) == 3) then {
		[player, -2000, true] call BIS_fnc_respawnTickets;
		diag_log ([player, 0, true] call BIS_fnc_respawnTickets);
		[missionNamespace, -2000] call BIS_fnc_respawnTickets;
		//setPlayerRespawnTime 0;
	};
};

