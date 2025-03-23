local Logger = require("utils/logger")
local debug = true

Logger.log("info", "Buy system client chargé avec succès.")

local function openBuyMenu(stationId)
    local station = Config.Stations[stationId]
    if not station or not station.sells then
        Logger.log("error", "Station ou ventes introuvables pour : %s", stationId)
        return
    end

    local options = {}

    for itemName, data in pairs(station.sells) do
        local label = Config.Commodities[itemName]?.label or itemName

        -- 📦 Infos sur le stockage
        local storedAmount = lib.callback.await("storage:getItemCount", false, stationId, itemName)
        local remainingSpace = lib.callback.await("storage:getAvailableSpace", false, stationId)

        -- ⚖️ Infos sur le poids de l'objet
        local itemInfo = exports.ox_inventory:Items(itemName)
        local itemWeight = itemInfo and itemInfo.weight or 0

        -- 🧮 Calcul du max achetable en fonction du poids restant
        local maxQuantity = itemWeight > 0 and math.floor(remainingSpace / itemWeight) or "?"

        options[#options + 1] = {
            title = label,
            description = ("Prix : $%d\nPoids/unité : %.2f\nDans le stockage : %d\nEspace dispo : %.2f\nMax possible : %s")
                :format(data.price, itemWeight, storedAmount or 0, remainingSpace or 0, maxQuantity),
            event = "bl_hauling:client:buyItem",
            args = {
                station = stationId,
                name = itemName,
                label = label,
                price = data.price,
                stored = storedAmount or 0,
                remaining = remainingSpace or 0,
                weight = itemWeight,
                max = maxQuantity
            }
        }
    end

    if #options == 0 then
        Logger.log("error", "Aucun objet à vendre pour : %s", stationId)
        return
    end

    lib.registerContext({
        id = "buy_" .. stationId,
        title = "Acheter à " .. station.name,
        options = options
    })

    lib.showContext("buy_" .. stationId)
end

RegisterNetEvent("bl_hauling:client:buyItem", function(args)
    if not args or not args.name or not args.price then return end

    local input = lib.inputDialog(("Acheter : %s"):format(args.label), {
        {
            type = "number",
            label = ("Quantité (Stock : %d / Espace : %.2f / Max : %s)")
                :format(args.stored or 0, args.remaining or 0, args.max or "?"),
            min = 1,
            default = 1,
            required = true
        }
    })

    if not input or not input[1] then return end

    local quantity = tonumber(input[1])
    if not quantity or quantity <= 0 then
        Logger.log("error", "Quantité invalide.")
        return
    end

    Logger.log("info", "Achat demandé :")
    Logger.log("debug", "    Station : %s", args.station)
    Logger.log("debug", "    Item    : %s (%s)", args.label, args.name)
    Logger.log("debug", "    Prix/u  : %d", args.price)
    Logger.log("debug", "    Total   : %d", args.price * quantity)
    Logger.log("debug", "    Qté     : %d", quantity)

    Logger.log("info", "Envoi vers le serveur...")
    TriggerServerEvent("bl_hauling:processBuy:buyItem", args.name, quantity, args.station)
end)

RegisterNetEvent("bl_hauling:client:openBuyMenu", function(stationId)
    openBuyMenu(stationId)
end)

-- 🧪 Commande de test : /buytest station_alpha
RegisterCommand("buytest", function(_, args)
    local stationId = args[1]
    if Config.Stations[stationId] then
        openBuyMenu(stationId)
    else
        Logger.log("error", "Utilisation : /buytest [station_id] (ex: station_alpha)")
    end
end, false)
