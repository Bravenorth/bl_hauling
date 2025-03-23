local Logger = require("utils.logger")
Logger.log("info", "Storage system client chargé avec succès.")

RegisterNetEvent("storage:requestPersonalStash")
AddEventHandler("storage:requestPersonalStash", function()
    local player = Ox.GetPlayer()

    if player then
        Logger.log("info", "Demande de création du stockage pour charId %s", tostring(player.charId))
        TriggerServerEvent("storage:createPersonalStash", player)
    else
        Logger.log("error", "Impossible de récupérer les informations du joueur !")
    end
end)

AddEventHandler("playerSpawned", function()
    Logger.log("info", "playerSpawned détecté, attente de la disponibilité d'OxPlayer...")

    local timeout, player = 0, Ox.GetPlayer()

    while not player or not player.charId do
        Wait(100)
        player = Ox.GetPlayer()
        timeout += 1
        if timeout > 50 then
            Logger.log("error", "Échec de récupération de Ox.GetPlayer() après 5 secondes.")
            return
        end
    end

    Logger.log("info", "Stockage demandé pour charId : %s", tostring(player.charId))
    TriggerServerEvent("storage:createPersonalStash", player)
end)



AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Logger.log("info", "Demande de stockage après restart.")
        TriggerEvent("storage:requestPersonalStash")
    end
end)
