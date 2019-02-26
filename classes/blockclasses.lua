Object = require "classic"
GlobalVarObject = Object:extend()

gameStates = {MainMenu = 1, SinglePlayer = 2, GameOver = 3}

function GlobalVarObject:new(screenX, screenY, gamestate, blockSize, players)
	self.screenX = screenX or 800
	self.screenY = screenY or 1000
	self.gamestate = gamestate or gameStates.MainMenu
	self.blockSize = blockSize or 30
	self.players = players or {}
end