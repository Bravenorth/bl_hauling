local Logger = require("utils.logger")
Logger.log("info", "Storage system serveur chargé avec succès.")

RegisterNetEvent("storage:createPersonalStash")
AddEventHandler("storage:createPersonalStash", function(playerData)
    if type(playerData) ~= "table" or not playerData.charId then
        Logger.log("error", "`charId` invalide reçu ! Valeur actuelle: %s", json.encode(playerData))
        return
    end

    local charId = tostring(playerData.charId)

    for station_id, station in pairs(Config.Stations) do
        local stashID = "storage_" .. charId .. "_" .. station_id
        local stashLabel = "Stockage " .. station.name
        local slots = 50
        local weight = 100000
        local owner = charId

        local stashExists = exports.ox_inventory:GetInventory(stashID, owner)

        if not stashExists then
            Logger.log("info", "Création du stockage : %s pour charId %s", stashID, owner)
            Logger.log("debug", "Paramètres :\n   - ID: %s\n   - Label: %s\n   - Slots: %d\n   - Weight: %d\n   - Owner: %s",
                stashID, stashLabel, slots, weight, owner)

            local success, err = pcall(function()
                return exports.ox_inventory:RegisterStash(stashID, stashLabel, slots, weight, owner)
            end)

            if success then
                Logger.log("success", "Stockage %s créé avec succès pour charId %s", stashID, owner)
            else
                Logger.log("error", "Échec de la création du stockage (%s)", tostring(err))
            end
        else
            Logger.log("info", "Stockage %s existe déjà pour charId %s", stashID, owner)
        end
    end
end)

-- 🔁 Helper pour générer l'ID du stockage
local function getStashID(charId, stationId)
    return ("storage_%s_%s"):format(charId, stationId)
end

-- 📦 Callback pour obtenir la quantité d’un item dans un stockage
lib.callback.register("storage:getItemCount", function(source, stationId, itemName)
    local xPlayer = Ox.GetPlayer(source)
    if not xPlayer then return 0 end

    local stashID = getStashID(xPlayer.charId, stationId)
    local item = exports.ox_inventory:GetItem(stashID, itemName)
    return item and item.count or 0
end)

-- 📦 Callback pour obtenir l’espace libre dans un stockage
lib.callback.register("storage:getAvailableSpace", function(source, stationId)
    local xPlayer = Ox.GetPlayer(source)
    if not xPlayer then return 0 end

    local stashID = getStashID(xPlayer.charId, stationId)
    local inventory = exports.ox_inventory:GetInventory(stashID)

    if not inventory then return 0 end

    local used = inventory.weight or 0
    local max = inventory.maxWeight or 100000

    return max - used
end)

-- 📦 (Optionnel) Callback pour obtenir tout le contenu d’un stockage
lib.callback.register("storage:getStashContents", function(source, stationId)
    local xPlayer = Ox.GetPlayer(source)
    if not xPlayer then return {} end

    local stashID = getStashID(xPlayer.charId, stationId)
    local inventory = exports.ox_inventory:GetInventory(stashID)
    return inventory and inventory.items or {}
end)