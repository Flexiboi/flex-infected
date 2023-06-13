local QBCore = exports['qb-core']:GetCoreObject()
local isbussy = false
local joinedplayers = {
}
local aliveplayers = {
}
local zombies = {
}

RegisterServerEvent("flex-infected:server:join", function()
    local src = source
    table.insert(joinedplayers, {id = src, ingame = true, lives = Config.extraStartLives})
end)

RegisterServerEvent("flex-infected:server:leave", function()
    local src = source
    for k, v in pairs(joinedplayers) do
        if joinedplayers[k].id == src then
            table.remove(joinedplayers,k)
            break
        end
    end
    for k, v in pairs(aliveplayers) do
        if aliveplayers[k].id == src then
            table.remove(aliveplayers,k)
            break
        end
    end
    for k, v in pairs(zombies) do
        if zombies[k].id == src then
            table.remove(zombies,k)
            break
        end
    end
end)

RegisterServerEvent("flex-infected:server:turnzombie", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    for k, v in pairs(aliveplayers) do
        if aliveplayers[k].id == src then
            table.remove(aliveplayers,k)
            table.insert(zombies, {id = src})
            if not rawequal(next(aliveplayers), nil) then
                for z, w in pairs(joinedplayers) do
                    TriggerClientEvent('QBCore:Notify', joinedplayers[z].id, Player.PlayerData.charinfo.firstname..Lang:t('info.turnedzombie'), 'success')
                    TriggerClientEvent('flex-infected:client:randomloc', src)
                end
            else
                TriggerClientEvent('flex-infected:client:reset', src)
                isbussy = false
                for b, a in pairs(joinedplayers) do
                    TriggerClientEvent('QBCore:Notify', joinedplayers[b].id, Lang:t('info.killedallplayers'), 'success', 10000)
                    TriggerClientEvent('flex-infected:client:reset', joinedplayers[b].id)
                    --table.remove(joinedplayers,b)
                    --if next(joinedplayers) == nil or #joinedplayers <= 1 then
                    if b >= #joinedplayers then
                        joinedplayers = {}
                        aliveplayers = {}
                        zombies = {}
                    end
                end
            end
        end
    end
end)

RegisterServerEvent("flex-infected:server:checkingame", function()
    local src = source
    for k, v in pairs(joinedplayers) do
        if joinedplayers[k].id == src then
            TriggerClientEvent('flex-infected:client:checkingame', src, joinedplayers[k].ingame)
        --else
            --TriggerClientEvent('flex-infected:client:checkingame', src, false)
        end
    end
end)

RegisterServerEvent("flex-infected:server:checklives", function()
    local src = source
    for k, v in pairs(joinedplayers) do
        if joinedplayers[k].id == src then
            TriggerClientEvent('flex-infected:client:checklives', src, joinedplayers[k].lives)
            break
        end
    end
end)

RegisterServerEvent("flex-infected:server:infectplayer", function(targetid)
    local src = source
    for k, v in pairs(zombies) do
        if zombies[k].id == targetid then
            TriggerClientEvent("flex-infected:client:infectplayer", src)
            break
        end
    end
end)

RegisterServerEvent("flex-infected:server:addlives", function(amount)
    local src = source
    for k, v in pairs(joinedplayers) do
        if joinedplayers[k].id == src then
            liveamount = joinedplayers[k].lives
            table.remove(joinedplayers,k)
            table.insert(joinedplayers, {id = src, ingame = true, lives = liveamount + 1})
            break
        end
    end
end)

RegisterServerEvent("flex-infected:server:start", function()
    local src = source
    if not isbussy then
        if not rawequal(next(joinedplayers), nil) then
            if #joinedplayers >= Config.minplayers then
                isbussy = true
                SetTimeout(1000*Config.turnzombietime, function()
                    TriggerClientEvent('flex-infected:client:turnzombie', joinedplayers[math.random(1,#joinedplayers)].id)
                    for k, v in pairs(joinedplayers) do
                        TriggerClientEvent('QBCore:Notify', joinedplayers[k].id, Lang:t('info.zombiespawned'), 'success')
                    end
                end)
                for k, v in pairs(joinedplayers) do
                    TriggerClientEvent('flex-infected:client:startgame', joinedplayers[k].id)
                    table.insert(aliveplayers, {id = joinedplayers[k].id})
                end
            else
                TriggerClientEvent('QBCore:Notify', src, Lang:t('info.notenough'), 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t('info.notenough'), 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.alreadystarted'), 'error')
    end
end)

RegisterServerEvent("flex-infected:server:leaveplayer", function()
    if isbussy then
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        for k, v in pairs(aliveplayers) do
            if aliveplayers[k].id == src then
                table.remove(aliveplayers,k)
                table.insert(zombies, {id = src})
                if not rawequal(next(aliveplayers), nil) then
                    for k, v in pairs(joinedplayers) do
                        TriggerClientEvent('QBCore:Notify', joinedplayers[k].id, Player.PlayerData.charinfo.firstname..Lang:t('info.turnedzombie'), 'success')
                    end
                else
                    for k, v in pairs(joinedplayers) do
                        TriggerClientEvent('QBCore:Notify', joinedplayers[k].id, Lang:t('info.killedallplayers'), 'success')
                        TriggerClientEvent('flex-infected:client:reset', joinedplayers[k].id)
                        --table.remove(joinedplayers,k)
                        if k >= #joinedplayers then
                            joinedplayers = {}
                            aliveplayers = {}
                            zombies = {}
                            isbussy = false
                        end
                    end
                end
            end
        end
    end
end)

RegisterServerEvent("flex-infected:server:resetall", function()
    for k, v in pairs(joinedplayers) do
        TriggerClientEvent('flex-infected:client:reset', joinedplayers[k].id)
        --table.remove(joinedplayers,k)
        --if next(joinedplayers) == nil or #joinedplayers <= 1 then
        if k >= #joinedplayers then
            joinedplayers = {}
            aliveplayers = {}
            zombies = {}
            isbussy = false
        end
    end
end)
-- CALLLBACKS
QBCore.Functions.CreateCallback('flex-infected:callback:checklives', function(source, cb)
    local src = source
    local liveamount = 0
    for k, v in pairs(joinedplayers) do
        if joinedplayers[k].id == src then
            liveamount = joinedplayers[k].lives
            if liveamount <= 0 then
                cb(liveamount)
            else
                table.remove(joinedplayers,k)
                table.insert(joinedplayers, {id = src, ingame = true, lives = liveamount - 1})
                cb(liveamount - 1)
            end
            break
        end
    end
end)

QBCore.Commands.Add('infected', 'Speel mee', {}, false, function(source)
    permission = QBCore.Functions.HasPermission(source, 'god')
    if not isbussy or permission then
        local src = source
        TriggerClientEvent('flex-infected:client:gameMenu', src, permission)
    end
end)

-- SAVE ITEMS
RegisterNetEvent('flex-infected:server:storeItems', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not Player.PlayerData.metadata["jailitems"] or table.type(Player.PlayerData.metadata["jailitems"]) == "empty" then
        Player.Functions.SetMetaData("jailitems", Player.PlayerData.items)
        Wait(2000)
        Player.Functions.ClearInventory()
    end
end)

RegisterNetEvent('flex-infected:server:giveBackItems', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    for _, v in pairs(Player.PlayerData.metadata["jailitems"]) do
        Player.Functions.AddItem(v.name, v.amount, false, v.info)
    end
    Player.Functions.SetMetaData("jailitems", {})
end)