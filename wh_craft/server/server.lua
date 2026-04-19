local teleportCooldowns = {}  -- only for enter/exit
local craftCooldowns    = {}  -- only for crafting

local function getIdentifier(src)
    return GetPlayerIdentifierByType(src, 'license')
end

RegisterNetEvent('wh_craft:enter', function()
    local src = source
    local identifiers = GetPlayerIdentifiers(src)

    local playerLicense = nil
    for _, v in ipairs(identifiers) do
        if string.find(v, 'license:') then
            playerLicense = v
            break
        end
    end

    local HasAccess = false

    for _, id in ipairs(Config.Permissions.Identifiers) do if id == playerLicense
        then HasAccess = true
        break
    end
end

if HasAccess or Config.Permissions.enabled == false then
    local ped = GetPlayerPed(src)

    if teleportCooldowns[src] and GetGameTimer() - teleportCooldowns[src] < 5000 then return end teleportCooldowns[src] = GetGameTimer()

    TriggerClientEvent('wh_craft:FadeOut', src)

    Wait(600)

    SetEntityCoords(ped, Config.Coords.inside.coords.x, Config.Coords.inside.coords.y, Config.Coords.inside.coords.z )
    SetEntityHeading(ped, Config.Coords.inside.heading)

    TriggerClientEvent('wh_craft:FadeIn', src)
end

if not HasAccess and Config.Permissions.enabled == true then 
    TriggerClientEvent('wh_craft:notify', src, 'error', Config.Strings.NotAllowed)
    return
end
end)

RegisterNetEvent('wh_craft:exit', function()
    local src = source

    if teleportCooldowns[src] and GetGameTimer() - teleportCooldowns[src] < 5000 then return end teleportCooldowns[src] = GetGameTimer()

    TriggerClientEvent('wh_craft:FadeOut', src)

    Wait(600)

    -- server does the teleport, not the client 
    local ped = GetPlayerPed(src)
    SetEntityCoords(ped, Config.Coords.outside.coords.x, Config.Coords.outside.coords.y, Config.Coords.outside.coords.z)
    SetEntityHeading(ped, Config.Coords.outside.heading)

    -- only tell client to do the visual fade, nothing gameplay critical
    TriggerClientEvent('wh_craft:FadeIn', src)
end)

RegisterNetEvent('wh_craft:craftMenu', function()

    local src = source 


    local craftItems = {}
    for _, item in pairs(Config.CraftItems) do
        table.insert(craftItems, {
            name = item.name,
            label = item.label,
            price = item.price,
            image = item.image
        })
    end


    TriggerClientEvent('wh_craft:craftMenuClient', src, craftItems)
end)

RegisterNetEvent('wh_craft:craftItem', function(itemName, quantity)
    local src = source 

    if type(itemName) ~= 'string' or type(quantity) ~= 'number' then return end

    if quantity < 1 or quantity > 5 then return end

    if craftCooldowns[src] and craftCooldowns[src] > GetGameTimer() then 
        TriggerClientEvent('wh_craft:notify', src, 'error', 'Please wait before crafting again')
        return
    end



    local validItem = nil
    for _, item in pairs(Config.CraftItems) do 
        if item.name == itemName then 
            validItem = item
            break
        end
    end

    if not validItem then
        print('[wh_craft] Player '.. src .. ' tried to craft an invalid item: ' .. itemName)
        return
    end
    
    local totalPrice = validItem.price * quantity

    local playerMoney = exports.ox_inventory:GetItem(src, 'money', nil, true)

    if playerMoney and playerMoney >= totalPrice then

        exports.ox_inventory:RemoveItem(src, 'money', totalPrice)

        exports.ox_inventory:AddItem(src, itemName, quantity)

        TriggerClientEvent('wh_craft:notify', src, 'success', 'You crafted ' .. quantity .. 'x ' .. validItem.label)

        -- server.lua, after successful craft
        local identifier = getIdentifier(src)
        MySQL.insert('INSERT INTO `crafting_logs` (`player_src`, `item_name`, `quantity`, `total_price`, `timestamp`) VALUES (?, ?, ?, ?, NOW())', {
        identifier,
        itemName,
        quantity,
        totalPrice
        })


        craftCooldowns[src] = GetGameTimer() + 3000
    else
        TriggerClientEvent('wh_craft:notify', src, 'error', 'You cannot afford ' .. validItem.label)
    end
end)

lib.callback.register('wh_craft:canAffordCraft', function(source, itemName, quantity)
    if type(itemName) ~= 'string' or type(quantity) ~= 'number' then
        return false, 'Invalid craft request.'
    end

    if quantity < 1 or quantity > 5 then
        return false, 'Invalid quantity.'
    end

    if craftCooldowns[source] and craftCooldowns[source] > GetGameTimer() then
        return false, 'Please wait before crafting again'
    end

    local validItem = nil
    for _, item in pairs(Config.CraftItems) do
        if item.name == itemName then
            validItem = item
            break
        end
    end

    if not validItem then
        return false, 'Invalid item.'
    end

    local totalPrice = validItem.price * quantity
    local playerMoney = exports.ox_inventory:GetItem(source, 'money', nil, true) or 0

    if playerMoney < totalPrice then
        return false, 'You cannot afford ' .. validItem.label
    end

    return true
end)

lib.callback.register('wh_craft:getHistory', function(source)
    local src        = source
    local identifier = getIdentifier(src)

    if not identifier then return {} end

    local results = MySQL.query.await(
        'SELECT `item_name`, `quantity`, `total_price`, `timestamp` FROM `crafting_logs` WHERE `player_src` = ? ORDER BY `timestamp` DESC LIMIT 10',
        { identifier }
    )

    return results or {}
end)

AddEventHandler('playerDropped', function()
    local src = source
    teleportCooldowns[src] = nil
    craftCooldowns[src] = nil
end)
