# ArmA 3 Vehicle SatCom
ArmA 3 satellite communications for vehicles, utilizing TFAR's InterCom system.

This script uses a vehicleID override in the ArmA 3 mod [Task Force Arrowhead Radio](https://github.com/michail-nikolaev/task-force-arma-3-radio) to enable cross-vehicle communications using TFAR's InterCom system. This allows for SatCom-like communication without range or terrain limitations and can especially be useful for jet flights or other vehicle crew potentially operating at long ranges or high-stress situations.

SatCom Links allow for multiple, separated communication channels to be provided (e.g. a separate one for each group plus a shared one for logistics).

## Requirements

**Addons**:
- TFAR 1.0 or newer
- ACE 3.9 or newer

Since this script uses TFAR's InterCom, [Task Force Arrowhead Radio](https://github.com/michail-nikolaev/task-force-arma-3-radio) must be used by all players to allow for communication. The InterCom system is only available in TFAR version >= 1.0, which is still in [development and beta state](https://github.com/michail-nikolaev/task-force-arma-3-radio/tree/1.0) as of the time of writing this README (2017-06-15).

Additionally, the ACE3 interaction menu is used to provide controls for the SatCom system, thus requiring the [ACE3](https://github.com/acemod/ACE3) mod to be present. There is no strict version requirement, the latest ACE3 release available should suffice.

## Installation

Simply add the script (and it's LICENSE.md file) to your ArmA 3 mission (e.g. to a `functions\vehicleSatCom` folder) and make sure to reference it in your `CfgFunctions.hpp` properly or compile it using `CBA_fnc_compileFunction`. All examples provided use the `mor` tag for simplicity.

You might want to also include this README since it provides a bit more in-depth documentation and examples than the script header.

## Usage

**Functions**:
- `mor_fnc_vehicleSatCom`

**Player variables**:
- `VehicleSatCom_satComLinks`

The script adds ACE3 Interaction Menus to all vehicles with the provided classes (or a class that inherits from the provided classes). A new `SatCom` entry will be added alongside the already existing `InterCom` one provided by TFAR, players can access it via the ACE3 Interaction key while being within a vehicle.

To enable SatCom, simply call the script in your `init.sqf` (`initPlayerLocal.sqf` should probably also suffice) and provide a list of vehicle classes as well as available SatCom Links. The example below enables SatCom for all planes and defines two SatCom Links, *Reaper* and *Gambit*:

```SQF
[["Plane"], ["Reaper", "Gambit"]] call mor_fnc_vehicleSatCom;
```

After calling the script, all vehicles with the `Plane` class (or a class that inherits from `Plane`, like `B_Plane_Fighter_01_F`, the *F/A-181 Black Wasp II*) will have the SatCom Links *Reaper* and *Gambit* defined.

Note that players will still not see any SatCom Links available, unless they have the variable `VehicleSatCom_satComLinks` set. The example below allows *Pilot1* and *Pilot2* to use the SatCom Link *Reaper* and their *Leader* to use SatCom Links *Reaper* and *Gambit*:

```SQF
_pilot1 setVariable ["VehicleSatCom_satComLinks", ["Reaper"]];
_pilot2 setVariable ["VehicleSatCom_satComLinks", ["Reaper"]];
_leader setVariable ["VehicleSatCom_satComLinks", ["Reaper", "Gambit"]];
```

This "filtering" allows for multiple, separated SatCom Links to exist and for access to said communication channels to be restricted to certain roles or players. A player can have access to as many SatCom Links as ArmA or the ACE Interaction Menu allow (no upper limit has been tested yet, but it's probably going to get quite annoying to navigate).

**Note**: all SatCom Links to be used within the mission have to be provided to the script call, even if not every vehicle should use/have access to every Link. Adding a Link to a player's `VehicleSatCom_satComLinks` that has not been defined via `mor_fnc_vehicleSatCom` will have no effect.

## Credits

Spezial thanks to [Spezialeinheit Luchs](http://spezialeinheit-luchs.de), especially to [SeL] Schneeflocke, [SeL] Shawalla and [SeL] Sinus for the idea as well as help during testing.

## License

Copyright (c) 2017 MorpheusXAUT

[![APL-SA](https://www.bistudio.com/assets/img/licenses/APL-SA.png)](https://www.bistudio.com/community/licenses/arma-public-license-share-alike)

[This work is licensed under the Arma Public License Share Alike](https://www.bistudio.com/community/licenses/arma-public-license-share-alike)