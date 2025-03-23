local Logger = require("utils/logger")
Blips = {}

local createdBlips = {}

Logger.log("info", "Blips system client chargé avec succès.")

function Blips.createBlip(station)
    if not station.blip or createdBlips[station.name] then return end

    local blip = AddBlipForCoord(station.blip.coords.x, station.blip.coords.y, station.blip.coords.z)
    SetBlipSprite(blip, station.blip.sprite or 477)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, station.blip.scale or 0.8)
    SetBlipColour(blip, station.blip.color or 3)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(station.name or "Station Inconnue")
    EndTextCommandSetBlipName(blip)

    createdBlips[station.name] = blip
    return blip
end

function Blips.clearBlips()
    for name, blip in pairs(createdBlips) do
        RemoveBlip(blip)
        Logger.log("debug", "Blip supprimé : %s", name)
    end
    createdBlips = {}
end

return Blips
