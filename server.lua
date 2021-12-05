local ESX = nil
local vehicleList = {}
local truckList = {}
local airList = {}
local currentType = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

MySQL.ready(function()
    MySQL.Async.fetchAll('SELECT * FROM vehicles ORDER BY category', {}, function(results)
        for i = 1, #results do
            vehicleList[#vehicleList + 1] = {
                name = results[i].name,
                model = results[i].model,
                price = results[i].price,
                category = results[i].category
            }
        end
    end)
    
    MySQL.Async.fetchAll('SELECT * FROM trucks ORDER BY category', {}, function(results)
        for i = 1, #results do
            truckList[#truckList + 1] = {
                name = results[i].name,
                model = results[i].model,
                price = results[i].price,
                category = results[i].category
            }
        end
    end)
    MySQL.Async.fetchAll('SELECT * FROM aircrafts ORDER BY category', {}, function(results)
        for i = 1, #results do
            airList[#airList + 1] = {
                name = results[i].name,
                model = results[i].model,
                price = results[i].price,
                category = results[i].category
            }
        end
    end)
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
    if not isValid then
        for k, v in pairs(truckList) do
            if v.model == model then
                isValid = true
                return isValid
            end
        end
    end
    if not isValid then
        for k, v in pairs(airList) do
            if v.model == model then
                isValid = true
                return isValid
            end
        end
    end
    return isValid
end

ESX.RegisterServerCallback('atomic_vehicleshop:server:getVehicles', function(source, cb, type)
    currentType = type
    if type == 'car' then
        cb(vehicleList)
    elseif type == 'truck' then
        cb(truckList)
    elseif type == 'air' then
        cb(airList)
    end
end)

RegisterServerEvent('atomic_vehicleshop:server:searchVehicle')
AddEventHandler('atomic_vehicleshop:server:searchVehicle', function(name, category)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local name = tostring(name)
    
    if category == 'all' and name ~= '' then
        MySQL.Async.fetchAll('SELECT * FROM vehicles WHERE name LIKE "%' .. name .. '%"', {
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
    elseif name ~= '' and category ~= 'all' then
        MySQL.Async.fetchAll('SELECT * FROM vehicles WHERE name LIKE "%' .. name .. '%" AND category = @category', {
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
    elseif category ~= 'all' and name == '' then
        MySQL.Async.fetchAll('SELECT * FROM vehicles WHERE category = @category', {
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
    elseif category == 'all' and name == '' then
        TriggerClientEvent('atomic_vehicleshop:client:setVehicleResults', src, vehicleList)
    end
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
        if not found then
            for k, v in pairs(truckList) do
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
                    else
                        xPlayer.showNotification('You do not have enough money to buy that vehicle.')
                    end
                end
            end
        end
        if not found then
            for k, v in pairs(airList) do
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
                    else
                        xPlayer.showNotification('You do not have enough money to buy that vehicle.')
                    end
                end
            end
        end
    end
end)

RegisterServerEvent('atomic_vehicleshop:server:assignVehicleToPlayer')
AddEventHandler('atomic_vehicleshop:server:assignVehicleToPlayer', function(plate, prop, owner)
    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, garage_type, in_garage) VALUES (@owner, @plate, @vehicle, @garage_type, @in_garage)', {
        ['@owner'] = owner,
        ['@plate'] = plate,
        ['@vehicle'] = json.encode(prop),
        ['@garage_type'] = currentType,
        ['@in_garage'] = true
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
                TriggerClientEvent('quantum_notify:client:sendNotification', src, 'xx', 'Du kannst hier nur Fahrzeuge verkaufen, die du beim normalen Autohändler erwerben kannst.')
            else
                MySQL.Async.execute('DELETE FROM owned_vehicles WHERE plate = @plate', {
                    ['@plate'] = plate
                })
                local price = tonumber(price) * 0.40
                xPlayer.addMoney(price)
                
                TriggerClientEvent('quantum_notify:client:sendNotification', src, 'xx', 'Du hast $'..price..' für dein Fahrzeug erhalten.')
                TriggerClientEvent('atomic_vehicleshop:client:deleteVehicle', src)
            end
        else
            TriggerClientEvent('quantum_notify:client:sendNotification', src, 'xx', 'Du kannst kein Fahrzeug verkaufen, welches nicht dir gehört.')
        end
    end)
end)