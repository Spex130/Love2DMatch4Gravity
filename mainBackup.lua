local menuengine = require "menuengine"
--menuengine.settings.sndMove = love.audio.newSource("pick.wav", "static")
--menuengine.settings.sndSuccess = love.audio.newSource("accept.wav", "static")

gameStates = {MainMenu = 1, SinglePlayer = 2, GameOver = 3}
gameState = gameStates.MainMenu
local mainmenu

--Main Menu functions

local function start_game()
    reset()
	gameState = gameStates.SinglePlayer
end

function reset()
        inert = {}
        for y = 0, gridYCount do
            inert[y] = {}
            for x = 0, gridXCount do
                inert[y][x] = colorBlank
            end
        end
			
		resetPlayerBlock(player1)
		timer = 0

    end
	
function love.load(arg)
	math.randomseed(os.time())
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
	timerLimit = 1.0

	--Grid of Inert Blocks
	inert = {} 

	--Player location attributes
	rotations = {right = {x = 1, y = 0}, down = {x = 0, y = 1}, left = {x = -1, y = 0}, up = {x = 0, y = -1}}
	playStates = {controlStep = 0, gravityStep = 1, checkStep = 2}
	
	player1 = 
	{
		originPoint = {x = 3, y = 1},
		location = {x = 3, y = 1},
		rotation = rotations.right,
		drawLocation = {x = 3, y = 1},
		drawLocation2 = {x = 3 + rotations.right.x, y = 1 + rotations.right.y},
		canDrop = false,
		blockColors = {color1 = math.random(1,4), color2 = math.random(1,4)},
		playState = playStates.controlStep,
		gravityLocation = {x = 0, y1 = 0, x2 = 1, y2 = 0},
		combo = 0,
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
	
	for y = 0, gridYCount do
        for x = 0, gridXCount do
            drawBlock(inert[y][x], x + offsetX, y + offsetY)
        end
    end
	
	updatePlayerLerps(player1)
	drawPlayerBlocks(player1, offsetX, offsetX)

end

function updatePlayer(player)
	
	if player.playState == playStates.controlStep then
		descendPlayerBlock(player)	
	elseif player.playState == playStates.gravityStep then
		gravityStepLoop(player)
	elseif player.playState == playStates.checkStep then
		player.playState = playStates.controlStep
	else
	end
end

function drawPlayerBlocks(player, offsetX, offsetY)
	love.graphics.draw(blocksPGBY[player.blockColors.color1],(player.drawLocation.x + offsetX) * blockDrawSize,(player.drawLocation.y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	
	love.graphics.draw(blocksPGBY[player.blockColors.color2],(player.drawLocation2.x + offsetX) * blockDrawSize,(player.drawLocation2.y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	
	
	--DRAW GHOST BLOCKS STEP
	love.graphics.setColor(255,255,255,0.5)
	openSpots = {}
	
	if(player.rotation == rotations.up) then
		openSpots = {block1 = findOpenSpotInColumn(player.location.x) - 1, block2 = findOpenSpotInColumn(player.location.x + player.rotation.x) - 2}
		
	elseif(player.rotation == rotations.down) then
		openSpots = {block1 = findOpenSpotInColumn(player.location.x) - 2, block2 = findOpenSpotInColumn(player.location.x + player.rotation.x) - 1}
	else
		openSpots = {block1 = findOpenSpotInColumn(player.location.x) -1, block2 = findOpenSpotInColumn(player.location.x + player.rotation.x) -1}
	end	
	

	love.graphics.draw(blocksPGBY[player.blockColors.color1],(player.location.x + offsetX) * blockDrawSize,(openSpots.block1 + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(blocksPGBY[player.blockColors.color2],(player.location.x + player.rotation.x + offsetX) * blockDrawSize,(openSpots.block2 + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	

	love.graphics.setColor(255,255,255,255)

end


--Get spot, give if it's empty. (Converts from BlockSpace to PlaySpace for you.)
function isSpotFilled(testX, y)

	testY = y + 1

	if(
		testX < 0
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

function isPlayerBlockGrounded(player)
	
	local isGrounded = (isSpotFilled(player.location.x, player.location.y + 1) == true or isSpotFilled(player.location.x + player.rotation.x, player.location.y + player.rotation.y + 1) == true)

	return isGrounded
end

--Takes player, moves their block down if possible.
function descendPlayerBlock(player)
	if(isPlayerBlockGrounded(player) == false) then
		player.location.y = 1 + player.location.y
	else
		
		if(player.rotation == rotations.up) then
			player.gravityLocation.x1 = player.location.x
			player.gravityLocation.y1 = findOpenSpotInColumn(player.location.x) - 1
			player.gravityLocation.x2 = player.location.x
			player.gravityLocation.y2 = findOpenSpotInColumn(player.location.x + player.rotation.x) - 2
		elseif(player.rotation == rotations.down) then
			player.gravityLocation.x1 = player.location.x
			player.gravityLocation.y1 = findOpenSpotInColumn(player.location.x) - 2
			player.gravityLocation.x2 = player.location.x + player.rotation.x
			player.gravityLocation.y2 = findOpenSpotInColumn(player.location.x + player.rotation.x) -1
		else
			player.gravityLocation.x1 = player.location.x
			player.gravityLocation.y1 = findOpenSpotInColumn(player.location.x) - 1
			player.gravityLocation.x2 = player.location.x + player.rotation.x
			player.gravityLocation.y2 = findOpenSpotInColumn(player.location.x + player.rotation.x) -1
		end	

		player.playState = playStates.gravityStep
		
		findBlocksToClear(inert)
		

	end
end

function findOpenSpotInColumn(column)
	for y = 0, gridYCount-1 do
		if(inert[y+1][column] ~= colorBlank) then
			return y
		end
	end
	
	return gridYCount
end

function gravityStepLoop(player)

	distanceValue1 = distance (player.drawLocation.x, player.drawLocation.y,player.gravityLocation.x1, player.gravityLocation.y1)
	distanceValue2 = distance (player.drawLocation2.x , player.drawLocation2.y,player.gravityLocation.x2, player.gravityLocation.y2)

	if( distanceValue1 < .5 and distanceValue2 < .5) then
		
		player.drawLocation.x = player.gravityLocation.x1
		player.drawLocation.y = player.gravityLocation.y1
		player.drawLocation2.x = player.gravityLocation.x2
		player.drawLocation2.y = player.gravityLocation.y2
		
		if(player.rotation ~= rotations.up or player.rotation ~= rotations.down) then

			inert[findOpenSpotInColumn(player.location.x)][player.location.x] = player.blockColors.color1
			inert[findOpenSpotInColumn(player.location.x + player.rotation.x)][player.location.x + player.rotation.x] = player.blockColors.color2
			
		else
			resetPlayerLerps(player)	
			inert[player.location.y + 1][player.location.x] = player.blockColors.color1
			inert[player.location.y + player.rotation.y + 1][player.location.x + player.rotation.x] = player.blockColors.color2
		end	
		resetPlayerBlock(player)
		player.playState = playStates.controlStep
	end

end

function canPlayerRotate(player)
	if(player.rotation == rotations.right) then
		return isSpotFilled(player.location.x, getPlayerDown(player)) == false
	elseif(player.rotation == rotations.down) then
		return isSpotFilled(getPlayerLeft(player), player.location.y) == false
	elseif(player.rotation == rotations.left) then
		return isSpotFilled(player.location.x, getPlayerUp(player)) == false
	else
		return isSpotFilled(getPlayerRight(player), player.location.x) == false
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
		blockColors = {color1 = math.random(1,4), color2 = math.random(1,4)},
		playState = playStates.controlStep,
		gravityLocation = {x1=0,x2=0,y1=0,y2=0}
	}

end

function updatePlayerLerps(player)

	if(player.playState == playStates.controlStep) then
		player.drawLocation.x = lerp(player.drawLocation.x, player.location.x, .2)
		player.drawLocation.y = lerp(player.drawLocation.y, player.location.y, .2)
		player.drawLocation2.x = lerp(player.drawLocation2.x, player.drawLocation.x  + player.rotation.x, .8)
		player.drawLocation2.y = lerp(player.drawLocation2.y, player.drawLocation.y  + player.rotation.y, .8)
	elseif(player.playState == playStates.gravityStep) then
		player.drawLocation.x = lerp(player.drawLocation.x, player.gravityLocation.x1, .2)
		player.drawLocation.y = lerp(player.drawLocation.y, player.gravityLocation.y1, .2)
		player.drawLocation2.x = lerp(player.drawLocation2.x, player.gravityLocation.x2, .8)
		player.drawLocation2.y = lerp(player.drawLocation2.y, player.gravityLocation.y2, .8)
	end

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
	[colorGray] = love.graphics.newImage('assets/blocksGra.png')
	}


end

function findBlocksToClear(inertArray)
	
	markedArray = {}
	
	chainNumber = 0

	upIsMatch = false
	rightIsMatch = false
	downIsMatch = false
	leftIsMatch = false
	
	for y = 0, gridYCount do
            markedArray[y] = {}
            for x = 0, gridXCount do
                markedArray[y][x] = -1 --(-1 signifies unchecked. 0 is Empty, 1 is matching.)
            end
        end
	
	
	for locY = 0, gridYCount do
		for locX = 0, gridXCount do

			if(inertArray[locY][locX] ~= 1) then --If we haven't already looked here, then proceed.
			
				--Check up
				if(locY - 1 >= 0 ) then --If the block above us is within the array
					if(inertArray[locY][locX] == inertArray[locY-1][locX] and inertArray[locY][locX] > 0 and markedArray[locY-1][locX] ~= 0) then
						upIsMatch = true
						chainNumber = chainNumber + 1
					end
				end

				--Check right
				if(locX + 1 < gridXCount) then
					if(inertArray[locY][locX] == inertArray[locY][locX+1] and inertArray[locY][locX] > 0 and markedArray[locY][locX + 1] ~= 0) then
						rightIsMatch = true
						chainNumber = chainNumber + 1
					end
				end

				--Check down
				if(locY + 1 < gridYCount ) then --If the block above us is within the array
					if(inertArray[locY][locX] == inertArray[locY+1][locX] and inertArray[locY][locX] > 0 and markedArray[locY + 1][locX] ~= 0) then
						downIsMatch = true
						chainNumber = chainNumber + 1
					end
				end

				--Check left
				if(locX - 1 >= 0) then
					if(inertArray[locY][locX] == inertArray[locY][locX-1] and inertArray[locY][locX] > 0 and markedArray[locY][locX - 1] ~= 0) then
						leftIsMatch = true
						chainNumber = chainNumber + 1
					end
				end
				

				
				if(chainNumber > 2) then --If we have a chain
					
					--Set Middle
					markedArray[locY][locX] = 1
					
					--Set Up
					if(upIsMatch) then
						markedArray[locY-1][locX] = 1
					end
					
					--Set Right
					if(rightIsMatch) then
						inertArray[locY][locX+1] = 1
					end
					
					--Set Down
					if(downIsMatch) then
						markedArray[locY+1][locX] = 1
					end
					
					--Set Left
					if(leftIsMatch) then
						inertArray[locY][locX-1] = 1
					end
					
				end
				
				chainNumber = 0
			end
		end
	end

end

function recursiveBlockClearStart(inertArray, locY, locX, chainNumber, markedArray)
--Take in the array we're working with, the X and Y location to check in that array, and how many matching numbers we've found before this point.

isMatch = false

--First, note that we've checked the spot we're at.
markedArray[y][x] = 0

--Check all directions

	--Check up
	if(locY - 1 >= 0 ) then --If the block above us is within the array
		if(inertArray[locY][locX] == inertArray[locY-1][locX] and inertArray[locY][locX] > 0 and markedArray[locY-1][locX] ~= 0) then
			isMatch = true
			recursiveBlockClearStep(inertArray, locY - 1, locX, chainNumber, markedArray)
		end
	end

	--Check right
	if(locX + 1 < gridXCount) then
		if(inertArray[locY][locX] == inertArray[locY][locX+1] and inertArray[locY][locX] > 0 and markedArray[locY][locX + 1] ~= 0) then
			isMatch = true
			recursiveBlockClearStep(inertArray, locY, locX + 1, chainNumber, markedArray)
		end
	end

	--Check down
	if(locY + 1 < gridYCount ) then --If the block above us is within the array
		if(inertArray[locY][locX] == inertArray[locY+1][locX] and inertArray[locY][locX] > 0 and markedArray[locY + 1][locX] ~= 0) then
			isMatch = true
			recursiveBlockClearStep(inertArray, locY + 1, locX, chainNumber, markedArray)
		end
	end

	--Check left
	if(locX - 1 >= 0) then
		if(inertArray[locY][locX] == inertArray[locY][locX-1] and inertArray[locY][locX] > 0 and markedArray[locY][locX - 1] ~= 0) then
			isMatch = true
			recursiveBlockClearStep(inertArray, locY, locX - 1, chainNumber, markedArray)
		end
	end
	
	if(isMatch == true) then
		chainNumber = chainNumber + 1
	end
	
	if(chainNumber > 2) then
		markedArray[locY][locX] = 1 --Set as marked for match
	end
	
	
	--Mark in the MarkedArray, return the number
	
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
end

--Math functions
function lerp(a,b,t) return (1-t)*a + t*b end
function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end