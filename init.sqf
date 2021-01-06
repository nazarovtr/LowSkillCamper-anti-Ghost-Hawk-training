desiredSpeed = 0;
desiredAltitude = 0;
desiredDirection = 0;
shotsFired = 0;

logGhostHawkData = {
    _speed = 3.6 * vectorMagnitude velocity gh;
    _altitude = (getPosASL gh) select 2;
    _direction = getDir gh;
    _text = format ["SPD: %1 (%2), ALT %3 (%4), DIR: %5 (%6)",
     round _speed, round desiredSpeed, round _altitude, round desiredAltitude, round _direction, round desiredDirection];
     systemChat _text;
};

respawnGhostHawk = {
    { deleteVehicle _x; } forEach units ghCrew;
    deleteVehicle gh;
    deleteGroup ghCrew;
    shotsFired = 0;
    sleep 0.2;
    gh = createVehicle ["B_Heli_Transport_01_F", player1 getPos [500, 90], [], 0, "FLY"];
    ghCrew = createVehicleCrew gh;
    desiredAltitude = 150 + random 250;
    gh setPosASL [getPosASL gh select 0, getPosASL gh select 1, desiredAltitude];
    desiredDirection = (240 + random 60);
    gh setDir desiredDirection;
    _waypointPos = gh getPos [3000, desiredDirection];
    _wp = ghCrew addWaypoint [_waypointPos, 0];
    gh flyInHeightASL [desiredAltitude, desiredAltitude, desiredAltitude];
    desiredSpeed = 70 + random 100;
    _speedMS = desiredSpeed / 3.6;
    gh setVelocity [_speedMS * (sin desiredDirection), _speedMS * (cos desiredDirection), 0];
    gh limitSpeed desiredSpeed;
    gh addEventHandler ["Dammaged", {
    	params ["_unit", "_selection", "_damage", "_hitIndex", "_hitPoint", "_shooter", "_projectile"];
        1 cutText [format ["<t size='2' align='left'>%1</t>", _hitPoint], "PLAIN NOFADE", -1, true, true];
        1 cutFadeOut 1;
    }];
    gh addEventHandler ["Killed", {
    	params ["_unit", "_killer", "_instigator", "_useEffects"];
    	_speed = 3.6 * vectorMagnitude velocity gh;
        _altitude = (getPosASL gh) select 2;
        _distance = gh distance player1;
        _text = format ["Kill: SPD: %1, ALT %2, DST: %3, Shots: %4",
         round _speed, round _altitude, round _distance, shotsFired];
         systemChat _text;
    }];
};

giveInfiniteAmmo = {
    _player = _this select 0;
    _player addWeaponItem ["srifle_GM6_F", "5Rnd_127x108_APDS_Mag", true];
    _player addWeaponItem ["launch_MRAWS_green_F", "MRAWS_HEAT_F", true];
    _player addeventhandler ["fired",
    {
        shotsFired = shotsFired + 1;
        params ["_unit", "_wep"];
        if (currentWeapon _unit == secondaryWeapon _unit) then {
            _unit addWeaponItem ["launch_MRAWS_green_F", "MRAWS_HEAT_F", true];
        };
        if (currentWeapon _unit == primaryWeapon _unit) then {
            _unit addWeaponItem ["srifle_GM6_F", "5Rnd_127x108_APDS_Mag", true];
        };
    }];
};


[player1] call giveInfiniteAmmo;
[] call respawnGhostHawk;
player1 addAction ["Respawn Ghost Hawk", respawnGhostHawk, nil, 1.5, true, false];

getColor = {
    params ["_damage"];
    if (isNil "_damage") then {
        "#FF0000";
    } else {
        if (_damage == 0) then {
            "#FFFFFF";
        } else {
            if (_damage > 0 && _damage < 0.5) then {
                "#FFE600"
            } else {
                if (_damage >= 0.5 && _damage < 1) then {
                    "#FF9A00"
                } else {
                    "#FF0000"
                };
            };
        };
    };
};

logGhostHawkDamage = {
    try {
        _crew = crew gh;
        _pilot = [1] call getColor;
        _copilot = [1] call getColor;
        _leftGunner = [1] call getColor;
        _rightGunner = [1] call getColor;
        if (count _crew == 4) then {
            _pilot = [damage ((crew gh) select 0)] call getColor;
            _copilot = [damage ((crew gh) select 1)] call getColor;
            _leftGunner = [damage ((crew gh) select 2)] call getColor;
            _rightGunner = [damage ((crew gh) select 3)] call getColor;
        };
        _engine1 = [gh getHitPointDamage "hitengine"] call getColor;
        _engine2 = [gh getHitPointDamage "hitengine2"] call getColor;
        _mainRotor = [gh getHitPointDamage "hithrotor"] call getColor;
        _tailRotor = [gh getHitPointDamage "hitvrotor"] call getColor;
        _transmission = [gh getHitPointDamage "hittransmission"] call getColor;
        _hydraulics = [gh getHitPointDamage "hithydraulics"] call getColor;
        _fuel = [gh getHitPointDamage "hitfuel"] call getColor;
        _fuelLevel = fuel gh;
        2 cutText [format ["<t align='right' valign='bottom'>" +
        "<t size='1.5' color='%1'>Engine 1</t> <t size='1.5' color='%2'> Engine 2</t><br/>" +
        "<t size='1.5' color='%3'>Main rotor</t> <t size='1.5' color='%4'> Tail rotor</t><br/>" +
        "<t size='1.5' color='%5'>Hydraulics</t> <t size='1.5' color='%6'> Transmission</t><br/>" +
        "<t size='1.5' color='%7'>Fuel</t> <t size='1.5'> %8</t><br/>" +
        "<t size='1.5' color='%9'>Pilot</t> <t size='1.5' color='%10'> Copilot</t><br/>" +
        "<t size='1.5' color='%11'>Left gunner</t> <t size='1.5' color='%12'> Right gunner</t><br/>" +
        "<t size='1.5'>Shots fired: %13</t></t>",
         _engine1,
         _engine2,
         _mainRotor,
         _tailRotor,
         _hydraulics,
         _transmission,
         _fuel,
         _fuelLevel,
         _pilot,
         _copilot,
         _leftGunner,
         _rightGunner,
         shotsFired], "PLAIN NOFADE", -1, true, true];
     } catch {};
};

3 cutText ["<t size='2' valign='top'>Use action menu to respawn the Ghost Hawk.</t>", "PLAIN NOFADE", -1, true, true];
sleep 5;
3 cutFadeOut 1;
while {true} do {
    [] call logGhostHawkDamage;
    sleep 0.1;
};

