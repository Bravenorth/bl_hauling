local Logger = require("utils.logger") -- Assure-toi que le chemin est correct

Logger.log("info", "Interactions system client chargé avec succès.")

Interactions = {}
local activePoints = {} -- ✅ Stocke les interactions créées

local function displayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function createInteractionPoint(coords, text, action, color)
    if not coords then return end

    local point = lib.points.new({
        coords = coords,
        distance = Config.MarkerDistance,
        nearby = function(self)
            if not self.coords then return end
            DrawMarker(1, self.coords.x, self.coords.y, self.coords.z - 1.2, 0, 0, 0, 0, 0, 0,
                1.5, 1.5, 1.0, color.r, color.g, color.b, 150, false, true, 2, nil, nil, false)

            if self.currentDistance < Config.InteractionDistance then
                displayHelpText(text)
                if IsControlJustReleased(0, 38) then action() end
            end
        end
    })

    table.insert(activePoints, point)
    Logger.log("info", "Interaction créée : %s", text)
end

function Interactions.createStationPoints(station_id, station)
    if not station or not station_id then
        Logger.log("error", "Station invalide !")
        return
    end

    local player = Ox.GetPlayer()
    if not player then
        Logger.log("error", "Impossible de récupérer les données du joueur !")
        return
    end

    local charId = tostring(player.charId)
    local stashID = ("storage_%s_%s"):format(charId, station_id)

    local interactions = {
        {
            station.player_storage,
            "[E] Consulter votre stockage",
            function()
                Logger.log("info", "Ouverture du stockage %s", stashID)
                exports.ox_inventory:openInventory("stash", stashID)
            end,
            Config.MarkerColors.storage
        },
        {
            station.buy_point,
            "[E] Acheter des marchandises",
            function()
                Logger.log("info", "Ouverture menu d'achat à %s", station.name)
                TriggerEvent("bl_hauling:client:openBuyMenu", station_id)
            end,
            Config.MarkerColors.buy,
            station.sells
        },
        {
            station.sell_point,
            "[E] Vendre vos marchandises",
            function()
                Logger.log("info", "Ouverture menu de vente à %s", station.name)
                TriggerEvent("bl_hauling:client:openSellMenu", station_id)
            end,
            Config.MarkerColors.sell,
            station.buys
        }
    }

    for _, data in ipairs(interactions) do
        local coords, text, action, color, condition = table.unpack(data)
        if coords and (not condition or next(condition)) then
            createInteractionPoint(coords, text, action, color)
        end
    end
end


function Interactions.clearInteractions()
    for _, point in ipairs(activePoints) do
        if point and point.remove then point:remove() end
    end
    activePoints = {}
    Logger.log("info", "Toutes les interactions ont été supprimées.")
end

return Interactions
