camLobby cameraEffect ["terminate","back"];
camUseNVG false;
camDestroy camLobby;

missionNameSpace setVariable ["lobbyComplete", 1];
publicVariable "lobbyComplete";

hintSilent  "";
closeDialog 1;

