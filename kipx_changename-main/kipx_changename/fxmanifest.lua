fx_version "adamant"
game "gta5"

description 'Kipx Change Name System'
version '1.0.0'
lua54 'yes'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/*.lua',
}

client_scripts {
    'client/*.lua',
}

shared_scripts {'@es_extended/imports.lua', '@ox_lib/init.lua', 'config.lua'}
dependencies {'ox_lib', 'es_extended', '/onesync'}