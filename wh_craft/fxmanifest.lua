fx_version 'cerulean'
games { 'gta5' }
author 'Sx'
client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

shared_scripts {
    'shared/config.lua',
    '@ox_lib/init.lua'
}