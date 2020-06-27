_possibleIndexes = [];
_indexWeights = [];
{		
	if (count ((_x select 2) select 7) > 0) then {
		_possibleIndexes pushBack _forEachIndex;
		_indexWeights pushBack 1;
	};
} forEach AOLocations;

_maps = switch (worldName) do {
	case "Altis": {["Land_Map_altis_F", "Land_Map_unfolded_Altis_F"]};
	case "Stratis": {["Land_Map_stratis_F", "Land_Map_unfolded_F"]};
	case "Tanoa": {["Land_Map_Tanoa_F", "Land_Map_unfolded_Tanoa_F"]};
	case "Malden": {["Land_Map_Malden_F", "Land_Map_unfolded_Malden_F"]};
	case "Enoch": {["Land_Map_Enoch_F", "Land_Map_unfolded_Enoch_F"]};
	default {["Land_Map_blank_F"]};
};	
_intelClasses = if (random 1 > 0.6) then {
	["Land_File1_F", "Land_FilePhotos_F", "Land_File2_F", "Land_File_research_F", "Land_MobilePhone_old_F", "Land_PortableLongRangeRadio_F", "Land_Laptop_02_unfolded_F"];
} else {
	_maps
};

_surfaces = [["Land_WoodenTable_small_F", 0.813], ["Land_CampingTable_small_white_F", 0.813], ["Land_WoodenCrate_01_F", 0.677]];

for "_i" from 0 to ([0,2] call BIS_fnc_randomInt) step 1 do {	
	if (count _possibleIndexes > 0) then {
		_thisIndex = [_possibleIndexes, _indexWeights] call BIS_fnc_selectRandomWeighted;
		_indexWeights set [(_possibleIndexes find _thisIndex), 0.1];
		if (count (((AOLocations select _thisIndex) select 2) select 7) > 0) then {
			_thisBuilding = [(((AOLocations select _thisIndex) select 2) select 7)] call sun_selectRemove;
			
			_validSurfaces = [];
			_allSurfaces = [];
			_intelClass = selectRandom _intelClasses;
			_surfaceClass = selectRandom _surfaces;
			
			_buildingPositions = [_thisBuilding] call BIS_fnc_buildingPositions;
			{
				if (_thisBuilding isKindOf 'House') then {
					_thisSurface = (_surfaceClass select 0) createVehicle _x;
					_checkPos = getPosWorld _thisSurface;
					_checkPos set [2, ((_checkPos select 2) + 0.3)];
					_intersect = lineIntersectsSurfaces [ 
						_checkPos,  
						_checkPos vectorAdd [0, 0, -5],  
						_thisSurface, objNull, true, 1, 'GEOM', 'NONE' 
					];// select 0 params ['','','','_thisBuilding'];
					if (count _intersect > 0) then {
						_thisSurface setPosASL ((_intersect select 0) select 0);
						_thisSurface setDir (getDir _thisBuilding);
						_allSurfaces pushBack _thisSurface;								
						_validSurfaces pushBack [_thisSurface, _x];
					};
				};
			} forEach _buildingPositions;
			
			if (count _validSurfaces > 0) then {
				_selectedSurface = (selectRandom _validSurfaces);
				_thisSurface = (_selectedSurface select 0);
				
				{
					if (_x != _thisSurface) then {
						deleteVehicle _x;
					};
				} forEach _allSurfaces;
				_surfacePos = getPos _thisSurface;
				_thisIntel = _intelClass createVehicle _surfacePos;				
				[_thisSurface, _thisIntel, [0,0,((_surfaceClass select 1) + 0.03)], (random 360)] call BIS_fnc_relPosObject;				
				diag_log format ["DRO: Intel object created: %1", _thisIntel];
				
				_markerName = format["intelMkr%1", floor(random 10000)];
				_markerBuilding = createMarker [_markerName, getPos _thisBuilding];			
				_markerBuilding setMarkerShape "ICON";
				_markerBuilding setMarkerText "Possible Intel";
				_markerBuilding setMarkerType "mil_box_noShadow";
				_markerBuilding setMarkerColor "ColorBlack";		
				_markerBuilding setMarkerSize [0.65, 0.65];		
				_markerBuilding setMarkerAlpha 1;
				_thisIntel setVariable ["markerName", _markerName, true];				
				[
					_thisIntel,
					"Search for Intel",
					"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
					"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
					"((_this distance _target) < 3)",
					"((_this distance _target) < 3)",
					{},
					{
						/*
						if ((_this select 4) % 4 == 0) then {
							(selectRandom ["FD_CP_Clear_F", "FD_CP_Not_Clear_F", "FD_Timer_F"]) remoteExec ["playSound", (_this select 1)];
						};
						*/
					},
					{
						deleteMarker ((_this select 0) getVariable "markerName");
						[5, true, (_this select 1)] execVM "sunday_system\intel\revealIntel.sqf";
						[(_this select 0), (_this select 2)] remoteExec ["bis_fnc_holdActionRemove", 0, true];
						deleteVehicle (_this select 0);
					},
					{},
					[],
					10,
					10,
					true,
					false
				] remoteExec ["bis_fnc_holdActionAdd", 0, true];
				
				// Add interaction to the surface as well in case occlusion prevents intel object action				
				[
					_thisSurface,
					"Search for Intel",
					"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
					"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
					"((_this distance _target) < 3)",
					"((_this distance _target) < 3) && !isNull (_arguments select 0)",
					{},
					{
						/*
						if ((_this select 4) % 4 == 0) then {
							(selectRandom ["FD_CP_Clear_F", "FD_CP_Not_Clear_F", "FD_Timer_F"]) remoteExec ["playSound", (_this select 1)];
						};
						*/
					},
					{
						deleteMarker ((_this select 0) getVariable "markerName");
						[5, true, (_this select 1)] execVM "sunday_system\intel\revealIntel.sqf";
						[(_this select 0), (_this select 2)] remoteExec ["bis_fnc_holdActionRemove", 0, true];
						deleteVehicle ((_this select 3) select 0);
					},
					{},
					[_thisIntel],
					10,
					10,
					true,
					false
				] remoteExec ["bis_fnc_holdActionAdd", 0, true];
			};
		};
	};	
};