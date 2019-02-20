local menuengine = require "menuengine"
local baton = require "baton"
--menuengine.settings.sndMove = love.audio.newSource("pick.wav", "static")
--menuengine.settings.sndSuccess = love.audio.newSource("accept.wav", "static")

gameStates = {MainMenu = 1, SinglePlayer = 2, GameOver = 3}
gameState = gameStates.MainMenu
local mainmenu
	
--Set Baton input controls!
local inputMenu = baton.new {
  controls = {
    left = {'axis:leftx-', 'button:dpleft'},
    right = {'axis:leftx+', 'button:dpright'},
    up = {'axis:lefty-', 'button:dpup'},
    down = {'axis:lefty+', 'button:dpdown'},
    action = {'button:a'},
	start = {'button:start'},
  },
  pairs = {
    move = {'left', 'right', 'up', 'down'}
  },
  joystick = love.joystick.getJoysticks()[1],
}
	

local input1 = baton.new {
  controls = {
    left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
    right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
    up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
    down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
    action = {'key:x', 'button:a'},
	start = {'key:return', 'button:start'},
  },
  pairs = {
    move = {'left', 'right', 'up', 'down'}
  },
  joystick = love.joystick.getJoysticks()[1],
}
	
function love.load(arg)
	math.randomseed(os.time())
	loadMainMenu()

end

function love.update(dt)

	updateInputs()

	if gameState == gameStates.MainMenu then
		mainmenu:update()
		menuInputUpdates()		
		
	elseif gameState == gameStates.SinglePlayer then

	end
end

menuTimer = 0

function love.draw(dt)
	if gameState == gameStates.MainMenu then
		drawMenu(menuTimer)
		menuTimer = menuTimer+1
	elseif gameState == gameStates.SinglePlayer then
		
	end
end

--Menu Functions

function loadMainMenu()
	font = love.graphics.newImageFont("assets/imagefont51.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")

	love.graphics.setFont(font, 40, "normal")
	bg_image = love.graphics.newImage('assets/menubackground.png')
    bg_image:setWrap("repeat", "repeat")

    -- note how the Quad's width and height are larger than the image width and height.
    bg_quad = love.graphics.newQuad(0, 0, 600, 600, bg_image:getWidth(), bg_image:getHeight())

	logo = love.graphics.newImage('assets/Logo.png')

    mainmenu = menuengine.new(50,400)
    mainmenu:addEntry("Start Game", start_game)
    mainmenu:addEntry("Options", options)
    mainmenu:addEntry("Quit Game", quit_game)

end

function drawMenu(dt)
	love.graphics.draw(bg_image, bg_quad, 0, 0)
	love.graphics.draw(logo, 50, 60 + math.cos(dt*.05) * 15)
	mainmenu:draw()
end


local function start_game()
	gameState = gameStates.SinglePlayer
end
--Input Functions

function love.mousemoved(x, y, dx, dy, istouch)
    menuengine.mousemoved(x, y)
end

function updateInputs()
	input1:update()
end

function menuInputUpdates()
	if (inputMenu:pressed 'up') then
		mainmenu:moveCursor(-1)
		
	elseif (inputMenu:pressed 'down') then
		mainmenu:moveCursor(1)
	
	elseif (inputMenu:pressed 'start') then
		self:_finish()
	else
	
	end
	
end

function love.keypressed(key, scancode, isrepeat)
    menuengine.keypressed(scancode)

    if scancode == "escape" then
        love.event.quit()
    end

	--[[]
	if key == 'x' then
		if(canPlayerRotate(player1)) then
			playerRotate(player1)
		end
        
    elseif key == 'left' then
        if (
		isSpotFilled(getPlayerLeft(player1), player1.location.y, pieceRotation) == false
		and
		isSpotFilled(player1.location.x + player1.rotation.x -1, player1.location.y + player1.rotation.y, pieceRotation) == false
		) then
            player1.location.x = player1.location.x-1
        end

    elseif key == 'right' then
        if (
		isSpotFilled(getPlayerRight(player1), player1.location.y, pieceRotation) == false
		and
		isSpotFilled(player1.location.x + player1.rotation.x +1, player1.location.y + player1.rotation.y, pieceRotation) == false
		) then
            player1.location.x = player1.location.x+1
        end
	
	elseif key == 'down' then
		descendPlayerBlock(player1)
	
    elseif key == 'c' then

		local y = player1.location.y
		local x2 = player1.location.x + player1.rotation.x
		local y2 = player1.location.y + player1.rotation.y
		
		while (isSpotFilled(player1.location.x, y + 1, pieceRotation) == false and isSpotFilled(x2, y2 + 1, pieceRotation) == false) do
            y = y + 1
			y2 = y2 + 1
			timer = 0
        end
			player1.location.y = y
	else
	
    end
	]]--
end

--Math functions
function lerp(a,b,t) return (1-t)*a + t*b end
function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end