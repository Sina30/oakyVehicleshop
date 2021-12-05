local ESX = nil
local vehicleList = {}
local currentType = nil
local dbType = 'vehicles'

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

MySQL.ready(function()
    for k, v in pairs(Config.Tables) do
        MySQL.Async.fetchAll('SELECT * FROM '..k..' ORDER BY category', {}, function(results)
            for i = 1, #results do
                vehicleList[#vehicleList + 1] = {
                    type = v,
                    name = results[i].name,
                    model = results[i].model,
                    price = results[i].price,
                    category = results[i].category
                }
            end
        end)
    end
    
    -- MySQL.Async.fetchAll('SELECT * FROM trucks ORDER BY category', {}, function(results)
    --     for i = 1, #results do
    --         vehicleList[#vehicleList + 1] = {
    --             type = 'truck'
    --             name = results[i].name,
    --             model = results[i].model,
    --             price = results[i].price,
    --             category = results[i].category
    --         }
    --     end
    -- end)
    -- MySQL.Async.fetchAll('SELECT * FROM aircrafts ORDER BY category', {}, function(results)
    --     for i = 1, #results do
    --         vehicleList[#vehicleList + 1] = {
    --             type = 'aircraft',
    --             name = results[i].name,
    --             model = results[i].model,
    --             price = results[i].price,
    --             category = results[i].category
    --         }
    --     end
    -- end)
end)

-- Checking if the model is valid
function isValidModel(model)
    local isValid = false
    for k, v in pairs(vehicleList) do
        if v.model == model then
            isValid = true
            return isValid
        end
    end
    return isValid
end

ESX.RegisterServerCallback('atomic_vehicleshop:server:getVehicles', function(source, cb, type)
    currentType = type
    if type == 'car' then
        dbType = 'vehicles'
    elseif type == 'truck' then
        dbType = 'trucks'
    elseif type == 'air' then
        dbType = 'aircrafts'
    end
    local newList = {}
    for k, v in pairs(vehicleList) do
        if v.type == type then
            newList[#newList + 1] = v
        end
    end

    cb(newList)
end)

RegisterServerEvent('atomic_vehicleshop:server:searchVehicle')
AddEventHandler('atomic_vehicleshop:server:searchVehicle', function(name, category)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local name = tostring(name)

    MySQL.Async.fetchAll('SELECT * FROM '..dbType..' WHERE name LIKE "%' .. name .. '%"', {
        ['@category'] = category
    }, function(result)
        local vehicles = {}
        for i = 1, #result do
            vehicles[#vehicles + 1] = {
                name = result[i].name,
                model = result[i].model,
                price = result[i].price,
                category = result[i].category
            }
        end
        TriggerClientEvent('atomic_vehicleshop:client:setVehicleResults', src, vehicles)
    end)
end)

RegisterServerEvent('atomic_vehicleshop:server:buyVehicle')
AddEventHandler('atomic_vehicleshop:server:buyVehicle', function(model)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xMoney = xPlayer.getMoney()
    
    if isValidModel(model) then
        local found = false
        for k, v in pairs(vehicleList) do
            if v.model == tostring(model) then
                found = true
                if xPlayer.getMoney() >= tonumber(v.price) then
                    if xPlayer.get('characterType') == 'outlaw' then
                        local newPrice = tonumber(v.price) - (tonumber(v.price) * 0.05)
                        xPlayer.removeMoney(newPrice)
                    elseif xPlayer.get('characterType') == 'racket' then
                        local newPrice = tonumber(v.price) - (tonumber(v.price) * 0.02)
                        xPlayer.removeMoney(newPrice)
                    else
                        xPlayer.removeMoney(tonumber(v.price))
                    end
                    TriggerClientEvent('atomic_vehicleshop:client:spawnVehicle', src, model, xPlayer.getIdentifier())
                    xPlayer.showNotification('Youve bought that vehicle.')
                    -- TriggerClientEvent('quantum_notify:client:sendNotification', src, 'xx', 'Du hast das Fahrzeug erfolgreich gekauft.', 'xx')
                else
                    xPlayer.showNotification('You do not have enough money to buy that vehicle.')
                    -- TriggerClientEvent('quantum_notify:client:sendNotification', src, 'xx', 'Du hast nicht genügend Geld dabei, um das Fahrzeug zu kaufen.', 'xx')
                end
            end
        end
    else
        print('^3[oakyVehicleshop]: Player '..xPlayer.getName()..' | '..xPlayer.source..' tried to buy a vehicle which is not in the catalog.^7')
    end
end)

RegisterServerEvent('atomic_vehicleshop:server:assignVehicleToPlayer')
AddEventHandler('atomic_vehicleshop:server:assignVehicleToPlayer', function(plate, prop, owner)
    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (@owner, @plate, @vehicle, @stored)', {
        ['@owner'] = owner,
        ['@plate'] = plate,
        ['@vehicle'] = json.encode(prop),
        ['@stored'] = false
    })
end)

RegisterNetEvent('atomic_vehicleshop:server:checkOwnerForSell')
AddEventHandler('atomic_vehicleshop:server:checkOwnerForSell', function(plate)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate AND owner = @owner', {
        ['@plate'] = plate,
        ['@owner'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            local vehicle = json.decode(result[1].vehicle)
            local found = false
            local price = nil
            for k, v in pairs(vehicleList) do
                local hash = GetHashKey(v.model)
                if vehicle.model == hash then
                    found = true
                    price = v.price
                    break
                end
            end
            if not found then
                xPlayer.showNotification('You can only sell vehicles here which you can buy on the default vehicle shop.')
            else
                MySQL.Async.execute('DELETE FROM owned_vehicles WHERE plate = @plate', {
                    ['@plate'] = plate
                })
                local price = tonumber(price) * 0.40
                xPlayer.addMoney(price)
                
                xPlayer.showNotification('Youve got $'..price..' for your vehicle.')
                TriggerClientEvent('atomic_vehicleshop:client:deleteVehicle', src)
            end
        else
            xPlayer.showNotification('You cant sell a vehicle which you dont own.')
        end
    end)
end)