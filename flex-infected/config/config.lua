Config = {}

--DEBUG
Config.debug = false

-- SETTINGS
Config.minplayers = 2
Config.zoneSizeChangeTime = 10 --seconds
Config.turnzombietime = 15 --seconds
Config.lobby = vector4(177.02, -964.5, 30.66, 281.85)
Config.extraStartLives = 0
Config.zombieSpeedMulti = 0.7

-- VEHICLE SETTINGS
Config.explode = false -- True = explode -- False = leave vehicle
Config.timeBeforeExplode = 5 --seconds
Config.timeBeforeLeave = 3

--RANDOM ZOMBIE SKIN
Config.zombieped = {
    'Rodney',
    'FreddyKrueger',
    'ghostface',
    'u_m_y_zombie_01',
}

Config.arenaCenter = vector4(178.16, -963.67, 30.66, 172.78)
Config.arenaSize = 175

-- PMA VOICE RADIO JOIN
Config.joinRadio = false
function radio(state)
    if state == 1 then -- ALIVE
        exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
        exports['pma-voice']:setRadioChannel(9999)
    elseif state == 2 then -- ZOMBIE
        exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
        exports['pma-voice']:setRadioChannel(6666)
    elseif state == 3 then -- LEAVE
        exports['pma-voice']:removePlayerFromRadio()
        exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
    else -- ERROR
        print('error')
    end
end

function reloadskin()
    TriggerEvent('fivem-appearance:client:reloadSkin')
end