ESX = nil
local isInMarker = false
local currentShop = {}
local currentShopIndex = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local coords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.Locations) do
            local dist = #(coords - vector3(v.x, v.y, v.z))
            if dist < 1.9 then
                currentShop = v
                currentShopIndex = k
                ESX.ShowHelpNotification('Press ~INPUT_PICKUP~ to open the vehicle catalog.')
                if IsControlJustPressed(0, 38) then
                    ESX.TriggerServerCallback('atomic_vehicleshop:server:getVehicles', function(vehicles)
                        SendNUIMessage({
                            action = 'open',
                            vehicles = vehicles
                        })
                    end, v.type)
                    SetNuiFocus(true, true)
                end
            end
        end
        local dist = #(coords - Config.VehicleSell.coords)
        if dist < 3 then
            ESX.ShowHelpNotification('Press ~INPUT_PICKUP~ to sell your vehicle.')
            if IsControlJustPressed(0, 38) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId())
                if vehicle ~= 0 then
                    local plate = GetVehicleNumberPlateText(vehicle)
                    TriggerServerEvent('atomic_vehicleshop:server:checkOwnerForSell', plate)
                else
                    exports['quantum_notify']:sendNotification('xx', 'You must sit in a vehicle in order to be able to sell it.', 'xx')
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    for _, item in pairs(Config.Locations) do
        local model = item.ped
        RequestModel(GetHashKey(model))
        local hash = GetHashKey(model)
        
        while not HasModelLoaded(GetHashKey(model)) do
            Wait(1)
        end
        local npc = CreatePed(4, hash, item.x, item.y, item.z, item.h, false, true)
        
        SetEntityHeading(npc, item.h)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        
        blip = AddBlipForCoord(item.x, item.y, item.z)
        SetBlipSprite(blip, item.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, item.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(item.blip.name)
        EndTextCommandSetBlipName(blip)
    end
    
    blip = AddBlipForCoord(Config.VehicleSell.coords)
    SetBlipSprite(blip, 225)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 59)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Vehicle shop')
    EndTextCommandSetBlipName(blip)
end)

RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('searchVehicle', function(data)
    TriggerServerEvent('atomic_vehicleshop:server:searchVehicle', data.value, data.category)
end)

RegisterNetEvent('atomic_vehicleshop:client:setVehicleResults')
AddEventHandler('atomic_vehicleshop:client:setVehicleResults', function(vehicles)
    SendNUIMessage({
        action = 'setVehicleResults',
        vehicles = vehicles
    })
end)

RegisterNUICallback('buyVehicle', function(data)
    TriggerServerEvent('atomic_vehicleshop:server:buyVehicle', data.model)
end)

RegisterNetEvent('atomic_vehicleshop:client:spawnVehicle')
AddEventHandler('atomic_vehicleshop:client:spawnVehicle', function(model, identifier)
    ESX.Game.SpawnVehicle(model, vector3(currentShop.spawn.x, currentShop.spawn.y, currentShop.spawn.z), currentShop.spawn.h, function(vehicle)
        local plate = GetVehicleNumberPlateText(vehicle)
        local props = ESX.Game.GetVehicleProperties(vehicle)
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, false, false, false)
        SetEntityAsMissionEntity(vehicle, true, false)
        TriggerServerEvent('atomic_vehicleshop:server:assignVehicleToPlayer', plate, props, identifier)
    end)
end)

RegisterNetEvent('atomic_vehicleshop:client:deleteVehicle')
AddEventHandler('atomic_vehicleshop:client:deleteVehicle', function()
    local ply = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ply)
    
    if vehicle ~= 0 then
        ESX.Game.DeleteVehicle(vehicle)
    end
end)
