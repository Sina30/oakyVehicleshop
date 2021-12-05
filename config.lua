Config = {}

Config.Tables = {
    ['vehicles'] = 'car',
    ['trucks'] = 'truck',
    ['aircrafts'] = 'aircraft',
    ['boats'] = 'boat'
}

Config.Locations = {
    { 
        blip = {
            name = 'Vehicle shop', 
            sprite = 225, 
            color = 30
        },
        ped = 'cs_siemonyetarian',
        type = 'car', 
        x = -32.75, 
        y = -1102.36, 
        z = 25.42, 
        h = 77.24, 
        spawn = { 
            x = -31.35, 
            y = -1090.64, 
            z = 25.42, 
            h = 339.54 
        } 
    },
    { 
        blip = {
            name = 'Truck Shop', 
            sprite = 67, 
            color = 30
        }, 
        ped = 'cs_siemonyetarian',
        type = 'truck', 
        x = 900.45, 
        y = -1154.96, 
        z = 24.16, 
        h = 171.15, 
        spawn = { 
            x = 878.76, 
            y = -1168.48, 
            z = 24.98, 
            h = 269.1 
        } 
    },
    { 
        blip = {
            name = 'Aircraft Shop', 
            sprite = 64, 
            color = 30
        }, 
        ped = 'cs_siemonyetarian',
        type = 'aircraft', 
        x = -960.16, 
        y = -2962.0, 
        z = 12.94, 
        h = 142.64, 
        spawn = { 
            x = -972.14, 
            y = -2977.84, 
            z = 13.94, 
            h = 91.49 
        }
     }
}

Config.VehicleSell = {
    coords = vector3(451.84, -3061.78, 6.06)
}