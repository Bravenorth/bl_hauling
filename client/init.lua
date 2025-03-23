local Logger = require("utils/logger")

Logger.log("info", "Init system client chargé avec succès.")

local function initializeStations()
    if not Blips or not Interactions then
        Logger.log("error", "Blips.lua ou Interactions.lua ne sont pas chargés !")
        return
    end

    if not Config or not Config.Stations or next(Config.Stations) == nil then
        Logger.log("error", "Config.Stations est vide ou non défini !")
        return
    end

    if Blips.clearBlips then
        Blips.clearBlips()
        Logger.log("info", "Suppression des anciens Blips.")
    end

    if Interactions.clearInteractions then
        Interactions.clearInteractions()
        Logger.log("info", "Suppression des anciennes Interactions.")
    end

    for station_id, station in pairs(Config.Stations) do
        Blips.createBlip(station)
        Interactions.createStationPoints(station_id, station)
        Logger.log("info", "Station %s chargée (ID: %s).", station.name, station_id)
    end

    Logger.log("success", "Toutes les stations ont été chargées avec succès !")
end

RegisterNetEvent("playerSpawned")
AddEventHandler("playerSpawned", function()
    Wait(500)
    Logger.log("info", "Player Spawn détecté, rechargement des stations...")
    initializeStations()
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(500)
        Logger.log("info", "Resource redémarrée, rechargement des stations...")
        initializeStations()
    end
end)
