params ["_player", "_didJIP"];

// Synchronize server weather for JIP clients.
// https://community.bistudio.com/wiki/setRain
if(_didJIP) then {
	skipTime 1;
	skipTime -1;
};
