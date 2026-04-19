Config = {}

Config.Coords = {
    outside = { coords = vec3(1024.3672, -2398.3105, 30.1214), heading = 282.9619 },
    inside  = { coords = vec3(1022.3672, -2398.4248, 30.1387), heading = 4.6493   },
    bench   = { coords = vec3(1021.1190, -2404.8428, 30.1387), heading = 0.0      }, -- if you have your own warehouse mlo you want to use change these coords to fit that.
    -- Add or change as many zones as you desire
}

Config.CraftItems = {
    { name = 'switch', label = 'Glock Switch', price = 10000, image = 'wh_craft/images/switch.png'},
    { name = 'WEAPON_BAT', label = 'Baseball Bat', price = 12500, image = 'wh_craft/images/WEAPON_BAT.png'},
    { name = 'WEAPON_DRACO', label = 'Micro Draco', price = 100000, image = 'wh_craft/images/weapon_draco.png'},
    -- Placeholder weapons replace and add any weapons you want here just follow the format.
}

Config.Permissions = {
    enabled = true,
    Type = 'license',
    Identifiers = {
        'license:' -- add any licenses here that have access to the warehouse, if you want everyone to have access then just set enabled to false:)
    }
}

Config.Strings = {
    ['NotAllowed'] = 'You do not have permission to enter'
}