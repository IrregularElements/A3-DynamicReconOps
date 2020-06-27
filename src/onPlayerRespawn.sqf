
waitUntil {!isNull player};
["DRO: Player %1 respawned: %2", player, _this] call bis_fnc_logFormatServer;
if (!isNil "loadoutSavingStarted") then {
	if (loadoutSavingStarted) then {
		playerRespawning = true;
		_loadout = player getVariable "respawnLoadout";	
		if (!isNil "_loadout") then {
			diag_log format ["DRO: Respawning with loadout = %1", _loadout];
			player setUnitLoadout _loadout;
		};
		if (!isNil "respawnTime") then {
			setPlayerRespawnTime respawnTime;	
		};
		deleteVehicle (_this select 1);
		playerRespawning = false;
	};
};
if (!isNil "droGroupIconsVisible") then {
	if (droGroupIconsVisible) then {
		setGroupIconsVisible [true, false];
	};
};