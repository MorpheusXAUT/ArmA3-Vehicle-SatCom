/*
    Name: mor_fnc_vehicleSatCom

    Author(s):
        MorpheusXAUT

    Description:
        Enables a SatCom sytem for all vehicles with the provided classes (including inheritance), making use of a TFAR vehicleID override and the InterCom system.
        Players can activate, switch and deactivate their SatCom links via vehicle ACE interaction menu while in a vehicle.
        All SatCom Links provided are defined and can be used by players as defined via their playerVariables (see below).
        SatCom Links will be displayed for soldiers depending on their "VehicleSatCom_satComLinks" variable, thus allowing to restrict certain players to their own SatCom Links.
        Optionally, SatCom Links can be displayed in an alternative color (defaults to #FFFFFF, white if not provided).
        SatCom Links will persist for all players within a vehicle (that have access to the InterCom as defined by TFAR), the crew and cargo InterCom channels can also be used to
        further devide SatCom Links into two more groups. Players that do not have access to any SatCom Links can still deactivate the Link if it has been previously activated.
        Deactivating a SatCom Link returns the vehicle's TFAR InterCom to regular operations, allowing only communications between players within the same vehicle.

    Parameters:
        0: ARRAY - Vehicle classes [
            STRING - Vehicle class name (e.g. "All", "Air", "Plane", "B_Plane_Fighter_01_F")
        ]
        1: ARRAY - Available SatCom Links [
            STRING - SatCom Link name (e.g. "Reaper", "Gambit")
            or
            ARRAY - SatCom Link details [
                0: STRING - SatCom Link name (e.g. "Reaper", "Gambit")
                1: STRING - SatCom Link color hex code (e.g. "#FF0000", "#0000FF")
            ]
        ]

    Returns:
        0: SCRIPT HANDLE - Handle of script spawned to add ACE interaction menus

    Examples:
        // Add SatCom Links Reaper and Gambit to all F/A-181 Black Wasp II and Hunter vehicles spawned
        _handle = [["B_Plane_Fighter_01_F", "B_MRAP_01_F"], [["Reaper", "#0000FF"], "Gambit"]] call mor_fnc_vehicleSatCom;

        // Set appropriate Links for soldiers
        // Pilot1 and Pilot2 can only talk/listen on Reaper Link, platoon lead can talk/listen on Reaper and Gambit Links, platoon sergeant can only talk/listen on Gambit Link
        _pilot1 setVariable ["VehicleSatCom_satComLinks", ["Reaper"]];
        _pilot2 setVariable ["VehicleSatCom_satComLinks", ["Reaper"]];
        _platoonLead setVariable ["VehicleSatCom_satComLinks", ["Reaper", "Gambit"]];
        _platoonSergeant setVariable ["VehicleSatCom_satComLinks", ["Gambit"]];
 */

if !(isClass(configFile >> "CfgPatches" >> "task_force_radio")) exitWith {};
if !(isClass(configFile >> "CfgPatches" >> "ace_interact_menu")) exitWith {};

_handle = _this spawn {
    params [
        ["_vehicleClasses", [""], [[""]]],
        ["_satComLinks", [""], [[""], [["", ""]]]]
    ];

    mor_vehicleSatCom_scriptfnc_activate = {
        params ["_vehicle", "_satComLink"];

        _vehicle setVariable ["TFAR_vehicleIDOverride", format["VehicleSatComLink_%1", _satComLink], true];
    };

    mor_vehicleSatCom_scriptfnc_deactivate = {
        params ["_vehicle"];

        _vehicle setVariable ["TFAR_vehicleIDOverride", nil, true];
    };

    mor_vehicleSatCom_scriptfnc_conditionMenu = {
        params ["_vehicle", "_player"];

        private _vehicleSatComLink = _vehicle getVariable "TFAR_vehicleIDOverride";
        private _playerSatComLinks = _player getVariable ["VehicleSatCom_satComLinks", []];
        if ((isNil "_vehicleSatComLink") && (count _playerSatComLinks == 0)) exitWith { false };

        true;
    };

    mor_vehicleSatCom_scriptfnc_conditionActivate = {
        params ["_vehicle", "_player", "_satComLink"];

        private _vehicleSatComLink = _vehicle getVariable "TFAR_vehicleIDOverride";
        if (!(isNil "_vehicleSatComLink")) exitWith { false };

        private _playerSatComLinks = _player getVariable ["VehicleSatCom_satComLinks", []];
        if (count _playerSatComLinks == 0) exitWith { false };
        if (!(_satComLink in _playerSatComLinks)) exitWith { false };
        
        true;
    };

    mor_vehicleSatCom_scriptfnc_conditionSwitch = {
        params ["_vehicle", "_player", "_satComLink"];

        private _vehicleSatComLink = _vehicle getVariable "TFAR_vehicleIDOverride";
        if (isNil "_vehicleSatComLink") exitWith { false };
        if (_vehicleSatComLink == format["VehicleSatComLink_%1", _satComLink]) exitWith { false };

        private _playerSatComLinks = _player getVariable ["VehicleSatCom_satComLinks", []];
        if (count _playerSatComLinks == 0) exitWith { false };
        if (!(_satComLink in _playerSatComLinks)) exitWith { false };
        
        true;
    };

    mor_vehicleSatCom_scriptfnc_conditionDeactivate = {
        params ["_vehicle", "_player"];

        private _vehicleSatComLink = _vehicle getVariable "TFAR_vehicleIDOverride";
        if (isNil "_vehicleSatComLink") exitWith { false };

        true;
    };

    mor_vehicleSatCom_scriptfnc_getPlayerSatComLinks = {
        params ["_player"];
    };

    {
        private _vehicleClass = _x;

        private _ace_selfActions_VehicleSatComMenu = [
            "VehicleSatComMenu",
            "SatCom",
            "",
            {},
            { [_this select 0, _this select 1] call mor_vehicleSatCom_scriptfnc_conditionMenu },
            {},
            []
        ] call ace_interact_menu_fnc_createAction;

        [_vehicleClass, 1, ["ACE_SelfActions"], _ace_selfActions_VehicleSatComMenu, true] call ace_interact_menu_fnc_addActionToClass;

        {
            private _satComLink = _x;
            private _satComLinkColor = "#FFFFFF";
            if (count _satComLink == 2) then {
                _satComLink = _x select 0;
                _satComLinkColor = _x select 1;
            };

            _ace_selfActions_VehicleSatComActivate = [
                format ["VehicleSatComActivate_%1", _satComLink],
                format ["<t color=""%1"">Activate SatCom Link %2</t>", _satComLinkColor, _satComLink],
                "",
                {
                    [_this select 0, (_this select 2) select 0] call mor_vehicleSatCom_scriptfnc_activate;
                },
                {
                    [_this select 0, _this select 1, (_this select 2) select 0] call mor_vehicleSatCom_scriptfnc_conditionActivate;
                },
                {},
                [ _satComLink ]
            ] call ace_interact_menu_fnc_createAction;

            [_vehicleClass, 1, ["ACE_SelfActions", "VehicleSatComMenu"], _ace_selfActions_VehicleSatComActivate, true] call ace_interact_menu_fnc_addActionToClass;
        } forEach _satComLinks;

        {
            private _satComLink = _x;
            private _satComLinkColor = "#FFFFFF";
            if (count _satComLink == 2) then {
                _satComLink = _x select 0;
                _satComLinkColor = _x select 1;
            };

            _ace_selfActions_VehicleSatComSwitch = [
                format ["VehicleSatComSwitch_%1", _satComLink],
                format ["<t color=""%1"">Switch to SatCom Link %2</t>", _satComLinkColor, _satComLink],
                "",
                {
                    [_this select 0, (_this select 2) select 0] call mor_vehicleSatCom_scriptfnc_activate;
                },
                {
                    [_this select 0, _this select 1, (_this select 2) select 0] call mor_vehicleSatCom_scriptfnc_conditionSwitch;
                },
                {},
                [ _satComLink ]
            ] call ace_interact_menu_fnc_createAction;

            [_vehicleClass, 1, ["ACE_SelfActions", "VehicleSatComMenu"], _ace_selfActions_VehicleSatComSwitch, true] call ace_interact_menu_fnc_addActionToClass;
        } forEach _satComLinks;

        _ace_selfActions_VehicleSatComDeactivate = [
            "VehicleSatComDeactivate",
            "<t color=""#FF0000"">Deactivate SatCom Link</t>",
            "",
            {
                [_this select 0] call mor_vehicleSatCom_scriptfnc_deactivate;
            },
            {
                [_this select 0, _this select 1] call mor_vehicleSatCom_scriptfnc_conditionDeactivate;
            },
            {},
            []
        ] call ace_interact_menu_fnc_createAction;

        [_vehicleClass, 1, ["ACE_SelfActions", "VehicleSatComMenu"], _ace_selfActions_VehicleSatComDeactivate, true] call ace_interact_menu_fnc_addActionToClass;
    } forEach _vehicleClasses;
};

_handle;