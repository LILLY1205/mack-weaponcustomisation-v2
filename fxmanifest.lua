fx_version 'cerulean'
game 'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'mack-weaponcustomisation-v2'
description 'Weapon Customisation v2 (integrations + UI)'
author 'Mark + Phil'
version '2.0.0'

lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
  'config_components.lua',
  'config_weaponsmithbench.lua',
  'config_customise_materials.lua'
}

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/index.css',
  'html/index.js',
  'html/crock.ttf',
  'html/images/*.png'
}

client_scripts {
  'client/main.lua'
}

exports {
  'OpenCustomisation'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/main.lua'
}

escrow_ignore {
  'config.lua',
  'config_components.lua',
  'config_customise_materials.lua',
  'config_weaponsmithbench.lua',
  'installation/*.sql',
  'installation/*.lua',
  'installation/imgaes/*.png'
}

dependencies {
  'rsg-core',
  'ox_lib',
  'rsg-target'
}
