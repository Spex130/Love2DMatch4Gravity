local menuengine = require "menuengine"
--menuengine.settings.sndMove = love.audio.newSource("pick.wav", "static")
--menuengine.settings.sndSuccess = love.audio.newSource("accept.wav", "static")

gameStates = {MainMenu = 1, SinglePlayer = 2, GameOver = 3}
gameState = gameStates.SinglePlayer
local mainmenu

--Main Menu functions

local function start_game()
    reset()
	gameState = gameStates.SinglePlayer
end

function reset()
        inert = {}
        for y = 1, gridYCount do
            inert[y] = {}
            for x = 1, gridXCount do
                inert[y][x] = colorBlank
            end
        end

        --newSequence()
        --newPiece()

		timer = 0

    end
	
function love.load(arg)
	loadSinglePlayer()
	loadMainMenu()

end

function love.update(dt)

	if gameState == gameStates.MainMenu then
		mainmenu:update()	
		
	elseif gameState == gameStates.SinglePlayer then
		timer = timer + dt

		if timer >= timerLimit then
			timer = timer - timerLimit
			updatePlayer(player1)
		end
	end
end

menuTimer = 0

function love.draw(dt)
	if gameState == gameStates.MainMenu then
		drawMenu(menuTimer)
		menuTimer = menuTimer+1
	elseif gameState == gameStates.SinglePlayer then
		drawSinglePlayer()
	end
end




--Single Player Specific Functions

function loadSinglePlayer()
	
	--Playfield attributes
	gridXCount = 6
	gridYCount = 12

	gridOrigin = {0, 0}
	gridAspect = {gridXCount, gridYCount}
	gridHeight = 600
	gridWidth = 480
	gridBlockWidth = 32

	--Block Attributes

	blockSize = 64
	blockDrawSize = 30 
	blockDrawRatio = blockDrawSize/blockSize
	blocksPGBY = {}
	colorBlank = 0
	colorPurple = 1
	colorGreen = 2
	colorBlue = 3
	colorYellow = 4
	colorGray = 5

	--Timers
	timerLimit = 0.1

	--Grid of Inert Blocks
	inert = {} 

	--Player location attributes
	rotations = {right = {x = 1, y = 0}, down = {x = 0, y = 1}, left = {x = -1, y = 0}, up = {x = 0, y = -1}}
	player1 = 
	{
		originPoint = {x = 3, y = 1},
		location = {x = 3, y = 1},
		rotation = rotations.right,
		drawLocation = {x = 3, y = 1},
		drawLocation2 = {x = 3 + rotations.right.x, y = 1 + rotations.right.y},
		canDrop = false,
		blockColors = {color1 = colorBlue, color2 = colorBlue}
		
	}
	
	loadBlocks()
	reset()
end

function drawSinglePlayer()


	local function drawBlock(block, x, y)
		love.graphics.draw(blocksPGBY[block],x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
    end
	
	local offsetX = (love.graphics.getWidth()/blockDrawSize)/2 - gridXCount/2  --Put X as DEAD CENTER
    local offsetY = (love.graphics.getHeight()/blockDrawSize)/2 - gridYCount/2
	
	for y = 1, gridYCount do
        for x = 1, gridXCount do
            drawBlock(inert[y][x], x + offsetX, y + offsetY)
        end
    end
	
	updatePlayerLerps(player1)
	if(player1.canDrop == false) then
		drawPlayerBlocks(player1, offsetX, offsetX)
	else
		
	end
end

function updatePlayer(player)
			if(isSpotFilled(player.location.x, player.location.y + 1) == false and isSpotFilled(player.location.x + player.rotation.x, player.location.y + player.rotation.y + 1) == false) then
				player.location.y = 1 + player.location.y
			else
				resetPlayerLerps(player)
				inert[player.location.y][player.location.x] = player.blockColors.color1
				inert[player.location.y + player.rotation.y][player.location.x + player.rotation.x] = player.blockColors.color2
				resetPlayerBlock(player)
			end
		
end

function drawPlayerBlocks(player, offsetX, offsetY)
	love.graphics.draw(blocksPGBY[player.blockColors.color1],(player.drawLocation.x + offsetX) * blockDrawSize,(player.drawLocation.y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	
	love.graphics.draw(blocksPGBY[player.blockColors.color2],(player.drawLocation2.x + offsetX) * blockDrawSize,(player.drawLocation2.y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)

end

function isSpotFilled(testX, testY)

	if(
		testX < 1
		or testX > gridXCount
		or testY > gridYCount
	) then
		return true
	elseif(inert[testY][testX] ~= colorBlank) then
		return true
	
	else
		return false
	end
        
	
end

function canPlayerRotate(player)
	if(player.rotation == rotations.right) then
		return getPlayerDown(player)
	elseif(player.rotation == rotations.down) then
		return getPlayerLeft(player)
	elseif(player.rotation == rotations.left) then
		return getPlayerUp(player)
	else
		return getPlayerRight(player)
	end
end

function playerRotate(player)
	if(player.rotation == rotations.right) then
		player.rotation = rotations.down
		
	elseif(player.rotation == rotations.down) then
		player.rotation = rotations.left
		
	elseif(player.rotation == rotations.left) then
		player.rotation = rotations.up
		
	else
		player.rotation = rotations.right
		
	end
end

function getPlayerLeft(player)
	if(player.rotation == rotations.left) then
		return player.location.x-2
	else
		return player.location.x-1
	end
end

function getPlayerRight(player)
	if(player.rotation == rotations.right) then
		return player.location.x+2
	else
		return player.location.x+1
	end
end

function getPlayerDown(player)
	if(player.rotation == rotations.down) then
		return player.location.y+2
	else
		return player.location.y+1
	end
end

function getPlayerUp(player)
	if(player.rotation == rotations.up) then
		return player.location.y-2
	else
		return player.location.y-1
	end
end

function resetPlayerBlock(player)
	player1 = {
		originPoint = {x = 3, y = 1},
		location = {x = 3, y = 1},
		rotation = rotations.right,
		drawLocation = {x = 3, y = 1},
		drawLocation2 = {x = 3 + rotations.right.x, y = 1 + rotations.right.y},
		canDrop = false,
		blockColors = {color1 = colorBlue, color2 = colorBlue}
		
	}

end

function updatePlayerLerps(player)
	player.drawLocation.x = lerp(player.drawLocation.x, player.location.x, .2)
	player.drawLocation.y = lerp(player.drawLocation.y, player.location.y, .2)
	player.drawLocation2.x = lerp(player.drawLocation2.x, player.drawLocation.x  + player.rotation.x, .8)
	player.drawLocation2.y = lerp(player.drawLocation2.y, player.drawLocation.y  + player.rotation.y, .8)
end

function resetPlayerLerps(player)
	player.drawLocation = player.location
	player.drawLocation2.x = player.location.x
	player.drawLocation2.y = player.location.y
end

function loadBlocks()

	blocksPGBY = {
	[colorBlank] = love.graphics.newImage('assets/blocksEmp.png'), 
	[colorPurple] = love.graphics.newImage('assets/blocksPur.png'),
	[colorGreen] = love.graphics.newImage('assets/blocksGre.png'), 
	[colorBlue] = love.graphics.newImage('assets/blocksBlu.png'), 
	[colorYellow] = love.graphics.newImage('assets/blocksYel.png'),
	[colorGray] = love.graphics.newImage('assets/blocksEmp.png')
	}


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

--Input Functions

function love.mousemoved(x, y, dx, dy, istouch)
    menuengine.mousemoved(x, y)
end

function love.keypressed(key)
	
	if key == 'x' then
		if(canPlayerRotate(player1)) then
			playerRotate(player1)
		end
        
    elseif key == 'left' then
        if (isSpotFilled(getPlayerLeft(player1), player1.location.y, pieceRotation) == false) then
            player1.location.x = player1.location.x-1
        end

    elseif key == 'right' then
        if (isSpotFilled(getPlayerRight(player1), player1.location.y, pieceRotation) == false) then
            player1.location.x = player1.location.x+1
        end

    elseif key == 'c' then
        --[[
		while isSpotFilled(pieceX, pieceY + 1, pieceRotation) do
            pieceY = pieceY + 1
            timer = timerLimit
        end]]--
	else
	
    end
end

--Math functions
function lerp(a,b,t) return (1-t)*a + t*b end