fx_version 'cerulean'
game 'gta5'

author 'Marco'

ui_page 'html/ui.html'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server.lua',

}

client_scripts {
    'config.lua',
    'client.lua'
}

files {
    'html/ui.html',
    'html/style.css',
    'html/script.js',
    'html/fonts/*.otf',
    'html/assets/*.jpg',
    'html/assets/*.png',
}
