resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

server_script '@mysql-async/lib/MySQL.lua'

client_script 'client.lua'
server_script "server.lua"
client_script "config.lua"
server_script "config.lua"

ui_page "NUI/panel.html"

files {
	"NUI/panel.js",
	"NUI/panel.html",
	"NUI/panel.css",
	"NUI/iphone.png",
	"NUI/robinhood-logo.png",
}