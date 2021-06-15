fx_version 'adamant'

game 'gta5'

description 'Racing script to build'

version '0.0.2'

client_scripts {
	'config.lua',
	'client/main.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@async/async.lua',
	'config.lua',
	'server/main.lua'
}
