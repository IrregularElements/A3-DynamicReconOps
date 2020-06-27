
_leaders = [];
{
	if ((count units _x)>=2) then {
		if (side _x == enemySide) then {
			_leaders pushBack (leader _x);
		};
	};
} forEach allGroups;

{		
	[
		_x,
		"Search for Intel",
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
		"(!alive _target) && ((_this distance _target) < 3)",
		"((_this distance _target) < 3)",
		{
		
		},
		{
			if ((_this select 4) % 5 == 0) then {
				_object = [
					(selectRandom ["Land_Document_01_F", "Land_File1_F", "Land_FilePhotos_F", "Land_File2_F", "Land_File_research_F", "Land_Notepad_F", "Item_ItemGPS", "Land_MobilePhone_old_F", "Land_PortableLongRangeRadio_F"]),
					([(getPos (_this select 0)), 0.7, (random 360)] call dro_extendPos),
					(random 360)
				] call dro_createSimpleObject;
				(_this select 0) setVariable ["intelObjects", (((_this select 0) getVariable ["intelObjects", []]) + [_object])];
			};
		},
		{
			[1, false, (_this select 1)] execVM "sunday_system\intel\revealIntel.sqf";			
			{
				deleteVehicle _x;			
			} forEach ((_this select 0) getVariable ["intelObjects", []]);
			[(_this select 0), (_this select 2)] remoteExec ["bis_fnc_holdActionRemove", 0, true];			
		},
		{
			{
				deleteVehicle _x;
			} forEach ((_this select 0) getVariable ["intelObjects", []]);
		},
		[],
		10,
		10,
		true,
		false
	] remoteExec ["bis_fnc_holdActionAdd", 0, true];	
} forEach _leaders;
removeFromRemainsCollector _leaders;