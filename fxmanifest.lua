resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

fx_version 'bodacious'

game 'gta5'

description 'LUAConsole'
ui_page     'html/public/index.html'

files {
  'html/public/**/*',
}

client_scripts {

	'common/env.lua',
  'common/lib.lua',
  'common/main.lua',
  'common/events.lua',

  'client/events.lua',
  'client/lib.lua',
  'client/main.lua',

}

server_scripts {
  
  'common/env.lua',
  'common/lib.lua',
  'common/main.lua',
  'common/events.lua',

  'server/lib.lua',
  'server/main.lua',
  'server/events.lua',
}
