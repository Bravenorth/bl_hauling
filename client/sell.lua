local Logger = require("utils.logger")
Logger.log("info", "Sell system client chargé avec succès.")

-- 📦 Affiche le menu de vente pour une station donnée
local function openSellMenu(stationId)
    local station = Config.Stations[stationId]
    if not station or not station.buys then
        Logger.log("error", "Station ou achats introuvables pour : %s", stationId)
        return
    end

    local options = {}

    for itemName, data in pairs(station.buys) do
        local label = Config.Commodities[itemName]?.label or itemName

        -- 📡 Récupère combien l’utilisateur a en stock
        local storedAmount = lib.callback.await("storage:getItemCount", false, stationId, itemName)

        -- ⚖️ Infos sur le poids (pour affichage uniquement)
        local itemInfo = exports.ox_inventory:Items(itemName)
        local itemWeight = itemInfo and itemInfo.weight or 0

        options[#options + 1] = {
            title = label,
            description = ("Prix de rachat : $%d\nEn stock : %d\nPoids/unité : %.2f")
                :format(data.price, storedAmount or 0, itemWeight),
            event = "bl_hauling:client:sellItem",
            args = {
                station = stationId,
                name = itemName,
                label = label,
                price = data.price,
                stored = storedAmount or 0,
                weight = itemWeight
            }
        }
    end

    if #options == 0 then
        Logger.log("warning", "Aucun objet achetable pour : %s", stationId)
        return
    end

    lib.registerContext({
        id = "sell_" .. stationId,
        title = "Vendre à " .. station.name,
        options = options
    })

    lib.showContext("sell_" .. stationId)
end

-- 📦 Quand le joueur clique sur un item à vendre
RegisterNetEvent("bl_hauling:client:sellItem", function(args)
    if not args or not args.name or not args.price then return end

    local input = lib.inputDialog(("Vendre : %s"):format(args.label), {
        {
            type = "number",
            label = ("Quantité (en stock : %d)"):format(args.stored or 0),
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

    Logger.log("info", "Vente demandée :")
    Logger.log("debug", "    Station : %s", args.station)
    Logger.log("debug", "    Item    : %s (%s)", args.label, args.name)
    Logger.log("debug", "    Prix/u  : %d", args.price)
    Logger.log("debug", "    Total   : %d", args.price * quantity)
    Logger.log("debug", "    Qté     : %d", quantity)

    TriggerServerEvent("bl_hauling:processSell:sellItem", args.name, quantity, args.station)
end)

-- 📦 Ouvre le menu via événement
RegisterNetEvent("bl_hauling:client:openSellMenu", function(stationId)
    openSellMenu(stationId)
end)

-- 🧪 Commande de test : /selltest station_alpha
RegisterCommand("selltest", function(_, args)
    local stationId = args[1]
    if Config.Stations[stationId] then
        openSellMenu(stationId)
    else
        Logger.log("error", "Utilisation : /selltest [station_id] (ex: station_alpha)")
    end
end, false)
