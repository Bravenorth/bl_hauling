Config = {}

-- 📌 Distance d'affichage et d'interaction
Config.MarkerDistance = 10.0
Config.InteractionDistance = 1.0

-- 📌 Couleurs des markers
Config.MarkerColors = {
    storage = { r = 0, g = 255, b = 0 }, -- Vert (Stockage)
    buy = { r = 0, g = 0, b = 255 },   -- Bleu (Achat)
    sell = { r = 255, g = 255, b = 0 } -- Jaune (Vente)
}

-- 📌 Liste des stations
Config.Stations = {
    ["station_alpha"] = {
        name = "Station Alpha",
        blip = {
            coords = vector3(1207.3523, -3196.0220, 6.0280),
            sprite = 477,
            scale = 0.8,
            color = 3
        },
        player_storage = vector3(1240.5289, -3155.6313, 5.5282),
        buy_point = vector3(1240.5823, -3161.9729, 7.1048),
        sell_point = vector3(1243.0719, -3164.6001, 5.5283),
        sells = { scrapmetal = { price = 10, max_stock = 5000 } },
        buys = { sand = { price = 8 } }
    },

    ["station_beta"] = {
        name = "Carrière de Sable",
        blip = {
            coords = vector3(1216.6854, 1845.8750, 78.9098),
            sprite = 477,
            scale = 0.8,
            color = 5
        },
        player_storage = vector3(1216.6854, 1845.8750, 78.9098),
        buy_point = vector3(1219.0798, 1848.9786, 78.9667),
        sell_point = vector3(1211.6947, 1841.1691, 78.9015),
        sells = { sand = { price = 6, max_stock = 3000 } },
        buys = { scrapmetal = { price = 12 } }
    }
}

-- 📦 Liste des commodities
Config.Commodities = {
    scrapmetal = { label = "Scrap Metal" },
    sand = { label = "Sable" }
}
