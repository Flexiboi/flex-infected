local QBCore = exports['qb-core']:GetCoreObject()

function turnzombie()
    local ped = Config.zombieped[math.random(1, #Config.zombieped)]
    local plr = PlayerId()
    local model = GetHashKey(ped)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
    SetPlayerModel(plr, model)
    SetPedComponentVariation(GetPlayerPed(-1), 0, 0, 0, 2)
end

function Notify(msg, type, time)
    QBCore.Functions.Notify(msg, type, time)
end

function countdown()
    PlaySoundFrontend(-1, '5S', 'MP_MISSION_COUNTDOWN_SOUNDSET', true)
    Citizen.Wait(1000)
    Notify('3', 'success', 1000)
    Citizen.Wait(1000)
    Notify('2', 'success', 1000)
    Citizen.Wait(1000)
    Notify('1', 'success', 1000)
    Citizen.Wait(1000)
    Notify(Lang:t('info.startgame'), 'success', 1250)
end

RegisterNetEvent('flex-infected:client:gameMenu', function(permission)
    local gm = {
    }

    gm[#gm+1] = {
        header = Lang:t('menu.join'),
        params = {
            type = "client", 
            event = 'flex-infected:client:join',
            args = {}
        }
    }
    gm[#gm+1] = {
        header = Lang:t('menu.leave'),
        txt = "",
        params = {
            type = "client", 
            event = "flex-infected:client:leave",
            args = {}
        }
    }

    if permission then
        gm[#gm+1] = {
            header = Lang:t('menu.start'),
            txt = "",
            params = {
                type = "client", 
                event = "flex-infected:client:start",
                args = {}
            }
        }
        gm[#gm+1] = {
            header = Lang:t('menu.reset'),
            txt = "",
            params = {
                type = "client", 
                event = "flex-infected:client:resetall",
                args = {}
            }
        }
    end

    gm[#gm+1] = {
        header = Lang:t('menu.close'),
        txt = "",
        params = {
            event = "qb-menu:closeMenu",
            args = {}
        }
    }

    exports['qb-menu']:openMenu(gm)
end)