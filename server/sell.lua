local log = require("utils.logger")
log.log("info", "Sell system serveur chargé avec succès.")

-- 📦 Traitement de la vente de marchandise
RegisterNetEvent("bl_hauling:processSell:sellItem")
AddEventHandler("bl_hauling:processSell:sellItem", function(itemName, amount, stationId)
    local src = source
    local xPlayer = Ox.GetPlayer(src)
    if not xPlayer then
        log.log("error", "Joueur introuvable pour la vente.")
        return
    end

    local charId = tostring(xPlayer.charId)
    local station = Config.Stations[stationId]
    if not station then
        log.log("error", "Station invalide : %s", stationId)
        return
    end

    local itemData = station.buys[itemName]
    if not itemData then
        log.log("error", "Article non achetable ici : %s", itemName)
        return
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        log.log("error", "Quantité invalide : %s", tostring(amount))
        return
    end

    -- 📦 Utiliser le stockage personnel du joueur
    local stashID = ("storage_%s_%s"):format(charId, stationId)
    local item = exports.ox_inventory:GetItem(stashID, itemName)

    if not item or item.count < amount then
        log.log("warning", "Pas assez de %s pour vendre (stockage : %s, possédé : %s, requis : %s)", itemName, stashID, item and item.count or 0, amount)
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Vente échouée",
            description = "Vous n’avez pas assez d’objets dans le stockage pour vendre.",
            type = "error"
        })
        return
    end

    local total = itemData.price * amount

    local removed = exports.ox_inventory:RemoveItem(stashID, itemName, amount)
    if not removed then
        log.log("error", "Erreur lors du retrait de l'objet %s depuis le stockage %s", itemName, stashID)
        return
    end

    exports.ox_inventory:AddItem(src, "money", total)

    local label = Config.Commodities[itemName]?.label or itemName
    log.log("success", "[%s] a vendu %dx %s pour $%d à %s (depuis %s)", charId, amount, itemName, total, station.name, stashID)

    TriggerClientEvent("ox_lib:notify", src, {
        title = "Vente réussie",
        description = ("Vous avez vendu %d %s pour $%d."):format(amount, label, total),
        type = "success"
    })
end)
