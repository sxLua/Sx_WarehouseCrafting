RegisterNetEvent('wh_craft:FadeOut', function()
    DoScreenFadeOut(500)
end)

RegisterNetEvent('wh_craft:FadeIn', function()
    Wait(200)
    DoScreenFadeIn(500)
end)

local zones = {
    { coords = Config.Coords.outside.coords, name = 'enter_warehouse', icon = 'fa-solid fa-warehouse', label = 'Enter Warehouse', event = 'wh_craft:enter'     },
    { coords = Config.Coords.inside.coords,  name = 'exit_warehouse',  icon = 'fa-solid fa-warehouse', label = 'Exit Warehouse',  event = 'wh_craft:exit'      },
}

for _, zone in pairs(zones) do
    exports.ox_target:addBoxZone({
        coords = zone.coords,
        size = vec3(2, 2, 2),
        rotation = 0,
        debug = false,
        options = {{
            name  = zone.name,
            icon  = zone.icon,
            label = zone.label,
            onSelect = function()
                TriggerServerEvent(zone.event)
            end
        }}
    })
end

exports.ox_target:addBoxZone({
    coords   = Config.Coords.bench.coords,
    size     = vec3(2, 2, 2),
    rotation = 0,
    debug    = false,
    options  = {{
        name     = 'crafting_bench',
        icon     = 'fa-solid fa-toolbox',
        label    = 'Crafting Bench',
        onSelect = function()
            lib.registerContext({
                id      = 'wh_craft_bench',
                title   = 'Crafting Bench',
                options = {
                    {
                        title       = 'Craft Items',
                        description = 'Browse available items to craft',
                        icon        = 'fa-solid fa-hammer',
                        onSelect    = function()
                            TriggerServerEvent('wh_craft:craftMenu')
                        end
                    },
                    {
                        title       = 'Craft History',
                        description = 'View your last 10 crafts',
                        icon        = 'fa-solid fa-clock-rotate-left',
                        onSelect    = function()
                            lib.callback('wh_craft:getHistory', false, function(results)
                                if not results or #results == 0 then
                                    lib.notify({
                                        type        = 'info',
                                        title       = 'Craft History',
                                        description = 'You have no crafting history yet.',
                                    })
                                    return
                                end

                               local options = {}
                                for _, row in pairs(results) do

                                local displayName = row.item_name  -- fallback if item not found
                                for _, item in pairs(Config.CraftItems) do
                                        if item.name == row.item_name then
                                            displayName = item.label   -- e.g. "Baseball Bat" instead of "WEAPON_BAT"
                                            break
                                        end
                                    end

                                    table.insert(options, {
                                        title       = displayName,
                                        description = 'Qty: ' .. row.quantity .. '  |  $' .. row.total_price .. '  |  ' .. row.timestamp,
                                        disabled    = true,
                                    })
                                end

                                lib.registerContext({
                                    id      = 'wh_craft_history',
                                    title   = 'Craft History',
                                    options = options
                                })
                                lib.showContext('wh_craft_history')
                            end)
                        end
                    },
                }
            })
            lib.showContext('wh_craft_bench')
        end
    }}
})

RegisterNetEvent('wh_craft:craftMenuClient', function(craftItems)

    local options = {}

    for _, item in pairs(craftItems) do 
        table.insert(options, {
            title = item.label,
            description = 'Price: $' .. item.price,
            image = item.image,
            onSelect = function()

                local amount = lib.inputDialog('Craft ' .. item.label, {
                    {type = 'number', label = 'How many do you want to craft?', default = 1, min = 1, max = 5}
                })

                if not amount or not amount[1] then return end

                local quantity = math.floor(amount[1])
                local totalPrice = item.price * quantity

                local confirm = lib.alertDialog({
                    header = 'Start Crafting',
                    content = 'Craft ' .. quantity .. 'x ' .. item.label .. ' for $' .. totalPrice .. '?',
                    centered = true,
                    cancel = true
                })

                if confirm ~= 'confirm' then return end

                local canCraft, reason = lib.callback.await('wh_craft:canAffordCraft', false, item.name, quantity)

                if not canCraft then
                TriggerEvent('wh_craft:notify', 'error', reason)
                return
                end

                local playerPed = PlayerPedId()

                local finished = lib.progressBar({
                 duration = 4000,
                label = 'Crafting ' .. quantity .. 'x ' .. item.label,
                useWhileDead = false,
                canCancel = false,
                anim = {
                dict = 'mini@repair',
                clip = 'fixing_a_ped'
    },
})

ClearPedTasks(playerPed)

if not finished then return end

TriggerServerEvent('wh_craft:craftItem', item.name, quantity)
            end
        })
    end

    lib.registerContext({
        id = 'wh_craft',
        title = 'Crafting Bench',
        options = options
    })

    lib.showContext('wh_craft')
end)

RegisterNetEvent('wh_craft:notify', function(type, message)
    lib.notify({
        type = type,
        title = 'Crafting Bench',
        description = message,
    })
end)

        
