-- Configuration
function love.conf(t)
	t.title = "Match 4 Gravity Drop Game" -- The title of the window the game is in (string)
	t.version = "11.2"         -- The LÖVE version this game was made for (string)
	t.window.width = 480        -- we want our game to be long and thin.
	t.window.height = 600
	t.window.resizable = true

	-- For Windows debugging
	t.console = true
end