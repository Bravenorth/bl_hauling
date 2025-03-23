fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

name 'bl_hauling'
author 'Bravenorth'
version '0.0.1'
repository 'https://github.com/bravenorth/bl_hauling'
description 'Hauling system for FiveM with ox_core'

shared_scripts {
    '@ox_core/lib/init.lua',
    'utils/logger.lua',
    'shared/sh_config.lua',
}

client_scripts {
    'client/blips.lua',
    'client/interactions.lua',
    'client/storage.lua',
    'client/buy.lua',
    'client/sell.lua',
    'client/init.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/buy.lua',
    'server/sell.lua',
}

dependencies {
    'ox_core',
    'oxmysql',
    'ox_inventory',
}
