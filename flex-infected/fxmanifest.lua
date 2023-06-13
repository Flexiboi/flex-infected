fx_version 'cerulean'
game 'gta5'

description 'Flex-infected'
version '0.0.1'

client_script {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
	'client/baseevents.lua',
    'client/main.lua',
}

shared_scripts {
    '@qb-core/shared/locale.lua',
	'config/config.lua',
	'client/baseevents.lua',
	'locales/nl.lua',
}

server_scripts {
    'server/main.lua'
}

exports {
	'isingame',
    'getlives'
}

lua54 'yes'
