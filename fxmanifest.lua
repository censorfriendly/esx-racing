fx_version 'adamant'

game 'gta5'

description 'Racing script to build'

version '0.0.3'

client_scripts {
	'config.lua',
	'client/main.lua',
    'tracks/**/**.lua',
}

files {
    'html/dist/index.html',
    'html/dist/css/app.css',
    'html/dist/js/app.js'
}

ui_page 'html/dist/index.html'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@async/async.lua',
	'config.lua',
	'server/main.lua',
    'tracks/**/**.lua'
}
