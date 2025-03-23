local Logger = require("utils.logger")

Logger.log("info", "Buy system serveur chargé avec succès.")

RegisterNetEvent("bl_hauling:processBuy:buyItem")
AddEventHandler("bl_hauling:processBuy:buyItem", function(itemName, amount, stationId)
    Logger.log("info", "0. Achat de marchandise")

    local src = source
    local xPlayer = Ox.GetPlayer(src)
    if not xPlayer then
        Logger.log("error", "Joueur introuvable pour l'achat (src: %s)", src)
        return
    end

    local charId = tostring(xPlayer.charId)
    local stashID = ("storage_%s_%s"):format(charId, stationId)

    Logger.log("debug", "1. Vérification de la station")
    local station = Config.Stations[stationId]
    if not station then
        Logger.log("error", "Station invalide : %s", tostring(stationId))
        return
    end

    Logger.log("debug", "2. Vérification de l'article")
    local itemData = station.sells[itemName]
    if not itemData then
        Logger.log("error", "Article %s non vendu à la station %s", tostring(itemName), stationId)
        return
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        Logger.log("error", "Quantité invalide : %s", tostring(amount))
        return
    end

    local totalPrice = itemData.price * amount

    Logger.log("debug", "3. Vérification de l'argent")
    local money = exports.ox_inventory:GetItem(src, "money")
    if not money or money.count < totalPrice then
        Logger.log("error", "%s n’a pas assez d’argent ($%d requis)", charId, totalPrice)
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Achat échoué",
            description = "Pas assez d’argent !",
            type = "error"
        })
        return
    end

    Logger.log("debug", "4. Vérification de la capacité du stockage %s", stashID)
    local canCarry = exports.ox_inventory:CanCarryItem(stashID, itemName, amount)
    if not canCarry then
        Logger.log("error", "Le stockage %s est plein", stashID)
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Achat échoué",
            description = "Le stockage de la station est plein !",
            type = "error"
        })
        return
    end

    Logger.log("debug", "5. Retrait de l'argent")
    local removed, reason = exports.ox_inventory:RemoveItem(src, "money", totalPrice)
    if not removed then
        Logger.log("error", "Échec du retrait d'argent : %s", reason or "inconnu")
        return
    end

    Logger.log("debug", "6. Ajout de l'article dans %s", stashID)
    local added, addReason = exports.ox_inventory:AddItem(stashID, itemName, amount)
    if not added then
        Logger.log("error", "Échec de l'ajout d'objet dans le stockage : %s", addReason or "inconnu")
        -- Remboursement
        exports.ox_inventory:AddItem(src, "money", totalPrice)
        return
    end

    local label = Config.Commodities[itemName]?.label or itemName
    Logger.log("success", "[ACHAT] %s a acheté %dx %s pour $%d à %s (stockage : %s)", charId, amount, itemName, totalPrice, stationId, stashID)

    TriggerClientEvent("ox_lib:notify", src, {
        title = "Achat réussi",
        description = ("Vous avez acheté %d %s pour $%d. Les objets sont stockés."):format(amount, label, totalPrice),
        type = "success"
    })
end)
