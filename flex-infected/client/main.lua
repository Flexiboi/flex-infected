local QBCore = exports['qb-core']:GetCoreObject()

local igname, lives, iszombie, hasgamestarted, isinradio = false, 0, false, false, false
local arenasize = Config.arenaSize

local function GetClosestPlayer()
    local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
	end
	return closestPlayer, closestDistance
end

local function draw()
    CreateThread(function()
        Citizen.Wait(1)
        while true do
            if igname and hasgamestarted then
                Citizen.Wait(1)
                zoneborder:draw()
            else
                break
            end
        end
    end)
end

local function teleport(ped, coordX, coordY, coordZ, coordW)
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(10)
    end
    local z = zcoordZ
    for z = 1, 1000 do
        SetPedCoordsKeepVehicle(ped, coordX, coordY, z + 0.0)
        local foundGround, zPos = GetGroundZFor_3dCoord(coordX, coordY, z + 0.0)
        if foundGround then
            SetPedCoordsKeepVehicle(ped, coordX, coordY, z + 0.0)
            SetEntityHeading(ped, coordW)
            break
        end
        Citizen.Wait(5)
    end
    DoScreenFadeIn(500)
end

local function rloc()
    local ped = GetPlayerPed(-1)
    local x,y = 0,0
    local r = math.random(0,3)
    local size = 0
    if arenasize >= 25 then
        size = arenasize-25
    else
        size = arenasize-5
    end
    if r == 0 then
        x, y = Config.arenaCenter.x + math.random(0, size), Config.arenaCenter.y + math.random(0, size)
    elseif r == 1 then
        x, y = Config.arenaCenter.x - math.random(0, size), Config.arenaCenter.y + math.random(0, size)
    elseif r == 2 then
        x, y = Config.arenaCenter.x + math.random(0, size), Config.arenaCenter.y - math.random(0, size)
    elseif r == 3 then
        x, y = Config.arenaCenter.x - math.random(0, size), Config.arenaCenter.y - math.random(0, size)
    end
    teleport(ped, x, y, Config.arenaCenter.z, Config.arenaCenter.w)
end

local function border()
    CreateThread(function()
        zoneborder = CircleZone:Create(Config.arenaCenter, arenasize, { name = 'zoneborder', debugPoly = Config.debug })
        draw()
        zoneborder:onPlayerInOut(function(isPointInside)
            if isPointInside then
            else
                if igname and hasgamestarted then
                    if not iszombie then
                        turnzombie()
                        TriggerServerEvent('flex-infected:server:turnzombie')
                    else
                        rloc()
                    end
                end
            end
        end)
        SetTimeout(1000*Config.zoneSizeChangeTime, function()
            if arenasize ~= 0 and arenasize > 10 then
                arenasize = arenasize - 5
                if zoneborder ~= nil then
                    zoneborder:destroy()
                end
            end
            if igname and hasgamestarted then
                border()
            end
        end)
    end)
end

RegisterNetEvent('flex-infected:client:dead', function()
    local ped = GetPlayerPed(-1)
    if igname and hasgamestarted then
        QBCore.Functions.TriggerCallback('flex-infected:callback:checklives', function(amount)
            if amount <= 0 then
                turnzombie()
                TriggerServerEvent('flex-infected:server:turnzombie')
                if Config.joinRadio then
                    if isinradio then
                        radio(3)
                        Citizen.Wait(500)
                        isinradio = false
                        radio(2)
                    end
                end
            else
                lives = amount
                rloc()
            end
        end)
    end
end)

RegisterNetEvent('flex-infected:client:join', function()
    if not igname then
        igname = true
        TriggerServerEvent('flex-infected:server:join')
        Notify(Lang:t('success.joined'), 'success', 5000)
    else
        Notify(Lang:t('error.alreadyjoined'), 'error', 5000)
    end
end)

RegisterNetEvent('flex-infected:client:leave', function()
    if igname then
        igname = false
        TriggerServerEvent('flex-infected:server:leave')
        TriggerServerEvent('flex-infected:server:giveBackItems')
        if Config.joinRadio then
            Citizen.Wait(2000)
            radio(3)
        end
        Notify(Lang:t('error.leavegame'), 'error', 5000)
    end
end)

RegisterNetEvent('flex-infected:client:start', function()
    TriggerServerEvent('flex-infected:server:start')
end)

RegisterNetEvent('flex-infected:client:startgame', function()
    TriggerServerEvent('flex-infected:server:storeItems')
    if Config.joinRadio then
        if not isinradio then
            radio(3)
            Citizen.Wait(500)
            isinradio = true
            radio(1)
        end
    end
    countdown()
    hasgamestarted = true
    rloc()
    startdamagecheck()
    vehiclecheck()
    border()
end)

RegisterNetEvent('flex-infected:client:turnzombie', function()
    iszombie = true
    nostamina()
    turnzombie()
    zombieskincheck()
    TriggerServerEvent('flex-infected:server:turnzombie')
    if Config.joinRadio then
        if isinradio then
            radio(3)
            Citizen.Wait(500)
            isinradio = false
            radio(2)
        end
    end
end)

RegisterNetEvent('flex-infected:client:reset', function()
    Citizen.Wait(2000)
    zoneborder:destroy()
    igname, lives, iszombie, hasgamestarted, isinradio = false, 0, false, false, false
    arenasize = Config.arenaSize
    Citizen.Wait(500)
    local ped = GetPlayerPed(-1)
    --teleport(ped, Config.lobby.x, Config.lobby.y, Config.lobby.z, Config.lobby.w)
    SetPedCoordsKeepVehicle(ped, Config.lobby.x, Config.lobby.y, Config.lobby.z)
    TriggerServerEvent('flex-infected:server:giveBackItems')
    reloadskin()
    if Config.joinRadio then
        radio(3)
    end
end)

function startdamagecheck()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1)
            if igname then
                local ped = GetPlayerPed(-1)
                if HasEntityBeenDamagedByAnyPed(ped) then
                    local player, distance = GetClosestPlayer()
                    TriggerServerEvent("flex-infected:server:infectplayer", GetPlayerServerId(player))
                    ClearEntityLastDamageEntity(ped)
                    ClearPedLastWeaponDamage(ped)
                end
            else
                break
            end
        end
    end)
end

function zombieskincheck()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if igname then
                if iszombie then
                    local hash = GetEntityModel(PlayerPedId())
                    if hash == `mp_m_freemode_01` or hash == `mp_f_freemode_01` then
                        turnzombie()
                    end
                else
                    break
                end
            else
                break
            end
        end
    end)
end

function nostamina()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)
            if igname then
                if iszombie then
                    RestorePlayerStamina(PlayerId(), 1.0)
                    SetRunSprintMultiplierForPlayer(PlayerId(), Config.zombieSpeedMulti)
                end
            else
                break
            end
        end
    end)
end

function vehiclecheck()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)
            if igname then
                local ped = PlayerPedId()
                Wait(1)
                if IsPedInAnyVehicle(ped) then
                    if Config.explode then
                        Notify(Lang:t('error.leavevehicle'), 'error', 5000)
                        Citizen.Wait(1000 * Config.timeBeforeExplode)
                        local veh = GetVehiclePedIsIn(ped)
                        local coords = GetEntityCoords(veh)
                        AddExplosion(coords.x,coords.y,coords.z,'EXPLOSION_CAR',1.0,true,false,1.0)
                        NetworkExplodeVehicle(veh, true, false, 0)
                    else
                        Notify(Lang:t('error.cantdrive'), 'error', 5000)
                        Citizen.Wait(1000 * Config.timeBeforeLeave)
                        TaskLeaveVehicle(ped, veh, 0)
                    end
                end
            else
                break
            end
        end
    end)
end

RegisterNetEvent('flex-infected:client:infectplayer', function()
    TriggerServerEvent('flex-infected:server:checklives')
    SetEntityHealth(PlayerPedId(), 0)
end)

RegisterNetEvent('flex-infected:client:randomloc', function()
    rloc()
end)

RegisterNetEvent('flex-infected:client:resetall', function()
    TriggerServerEvent('flex-infected:server:resetall')
end)

-- JOIN AND UNLOAD
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if igname then
        TriggerServerEvent('flex-infected:server:leave')
        TriggerServerEvent('flex-infected:server:leaveplayer')
    end
end)

-- EXPORTS
RegisterNetEvent('flex-infected:client:checkingame', function(yesno)
    igname = yesno
end)

RegisterNetEvent('flex-infected:client:checklives', function(livecount)
    lives = livecount
end)

function isingame()
    TriggerServerEvent('flex-infected:server:checkingame')
    return igname
end
exports("isingame", isingame)

function getlives()
    TriggerServerEvent('flex-infected:server:checklives')
    return lives
end
exports("getlives", getlives)