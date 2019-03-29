local menuengine = require "menuengine"
--menuengine.settings.sndMove = love.audio.newSource("pick.wav", "static")
--menuengine.settings.sndSuccess = love.audio.newSource("accept.wav", "static")

gameStates = {MainMenu = 1, SinglePlayer = 2, GameOver = 3}
gameState = gameStates.SinglePlayer
local mainmenu

blockSize = 64
blockDrawSize = 30
blockDrawRatio = blockSize/30

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

	--Tile Attributes
	tilesBG = {} -- Ocean and Geometry
	tilesUI = {} -- Score and info windows
	
	--Misc Sprites
	shadowSprite = love.graphics.newImage('assets/shadow.png')
	
	--Timers
	timerLimit = 1.0

	--Grid of Inert Blocks
	inert = {} 

	--Player location attributes
	rotations = {right = {x = 1, y = 0}, down = {x = 0, y = 1}, left = {x = -1, y = 0}, up = {x = 0, y = -1}}
	playStates = {controlStep = 0, gravityStep = 1, gridFixStep = 2, gravityCheckStep = 3}
	
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
		gravityGrid = {}, --Holds a list of blocks that need to be dropped after a clear.
		inertClone = {},
	}
	
	loadBlocks()
	loadBGTiles()
	loadUITiles()
	reset()
end

function drawBlock(block, x, y)
		love.graphics.draw(blocksPGBY[block],x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
end

function drawBlockShadow(x, y)
		love.graphics.draw(shadowSprite,x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
end

function drawPlayfieldTile(x, offsetX, y, offsetY)



	--[[ Pseudocode for tile calculation
		--If X is 0 (If we are on the left edge of the field)
			--if Y == 0 (if we are at the top left of the ledge)
				-- Set tile to tile 1 (grass top left)
			--else if Y == height (if we are the bottom left)
				-- Set tile to tile 65 (grass bottom left)
			--else
				--find mod = (Y mod 3)
				
				--case mod == 0
					--set tile to tile 17 (Random Left Grass 1)
				--case mod == 1	
					--set tile to tile 33 (Random Left Grass 2)
				--case mod == 2	
					--set tile to tile 49  (Random Left Grass 3)
					
		--Else If X is Length (If we are on the right edge of the field)
			--if Y == 0 (if we are at the top right of the ledge)
				-- Set tile to tile 5 (grass top right)
			--else if Y == height (if we are the bottom right)
				-- Set tile to tile 69 (grass bottom right)
			--else
				--find mod = (Y mod 3)
				
				--case mod == 0
					--set tile to tile 21 (Random Right Grass 1)
				--case mod == 1	
					--set tile to tile 37 (Random Right Grass 2)
				--case mod == 2	
					--set tile to tile 53  (Random Right Grass 3)
		
		--Else If X is Greater than 0 and Less than Length (If we're horizontally in the middle)
			--find mod = (X mod 3)
			--if Y == 0 (if we are at the top)
				--case mod == 0
					--set tile to tile 02 (Random Top Middle Grass 1)
				--case mod == 1	
					--set tile to tile 03 (Random Top Middle Grass 2)
				--case mod == 2	
					--set tile to tile 04  (Random Top Middle Grass 3)
			--else if Y == height (if we are at the bottom)
				--case mod == 0
					--set tile to tile 66 (Random Bottom Middle Grass 1)
				--case mod == 1	
					--set tile to tile 67 (Random Bottom Middle Grass 2)
				--case mod == 2	
					--set tile to tile 68  (Random Bottom Middle Grass 3)
			--else	--We're really out in the middle of nowhere.
				--find mod = ((X + Y) mod 6)
				--case mod == 0
					--set tile to tile 50 (Generic Center Grass)
				--case mod == 4
					--set tile to tile 52 (Generic Center Grass)				
				--default
					--set tile to tile 51 (Generic Center Grass)
			
		--]]
		
		if(x == 0) then
			if(y == 0) then
				love.graphics.draw(tilesBG[1],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Top left)
			elseif(y == gridYCount) then
				love.graphics.draw(tilesBG[65],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Bottom left)
		
			else	--(Middle left section)
				mod = y % 3		--Used for randomization
				
				if(mod == 0) then
					love.graphics.draw(tilesBG[17],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				elseif(mod == 1) then
					love.graphics.draw(tilesBG[33],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				else
					love.graphics.draw(tilesBG[49],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				end	

			end
		elseif(x == gridXCount) then
			if(y == 0) then
				love.graphics.draw(tilesBG[5],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Top right)
			elseif(y == gridYCount) then
				love.graphics.draw(tilesBG[69],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Bottom right)

			else	--(Middle right section)
				mod = y % 3		--Used for randomization
				
				if(mod == 0) then
					love.graphics.draw(tilesBG[21],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				elseif(mod == 1) then
					love.graphics.draw(tilesBG[37],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				else
					love.graphics.draw(tilesBG[53],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				end	

			end
		else
			
			mod = y % 3	
			if(y == 0) then
				if(mod == 0) then
					love.graphics.draw(tilesBG[2],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				elseif(mod == 1) then
					love.graphics.draw(tilesBG[3],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				else
					love.graphics.draw(tilesBG[4],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				end	
			elseif(y == gridYCount) then
				if(mod == 0) then
					love.graphics.draw(tilesBG[66],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				elseif(mod == 1) then
					love.graphics.draw(tilesBG[67],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				else
					love.graphics.draw(tilesBG[68],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				end	
			else	--(Middlesection)
				mod =((x + y) % 6)
				
				if(mod == 0) then
					love.graphics.draw(tilesBG[50],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				elseif(mod == 4) then
					love.graphics.draw(tilesBG[52],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				else
					love.graphics.draw(tilesBG[51],(x + offsetX) * blockDrawSize, (y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				end	
			end
		end
end

function drawPlayfieldBorder(offsetX, offsetY)
	
	--Above the Top and Below the Bottom: Left, Right, Middle
	for i = -1, gridXCount + 1 do
		if(i == -1) then
			love.graphics.draw(tilesBG[127],(i + offsetX) * blockDrawSize, (-1 + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
			love.graphics.draw(tilesBG[143],(i + offsetX) * blockDrawSize, (gridYCount+1 + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)				
		elseif (i == gridXCount + 1) then
			love.graphics.draw(tilesBG[128],(i + offsetX) * blockDrawSize, (-1 + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
			love.graphics.draw(tilesBG[144],(i + offsetX) * blockDrawSize, (gridYCount+1 + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
		else
			love.graphics.draw(tilesBG[173],(i + offsetX) * blockDrawSize, (-1 + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
			love.graphics.draw(tilesBG[124],(i + offsetX) * blockDrawSize, (gridYCount+1 + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
		end
	end
	
	--Line the sides
	for i = 0, gridYCount do
			love.graphics.draw(tilesBG[142],(-1 + offsetX) * blockDrawSize, (i + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
			love.graphics.draw(tilesBG[139],(gridXCount + 1 + offsetX) * blockDrawSize, (i + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	end
	
end

function drawCharacterPlatform(x, offsetX, y, offsetY)

	xLoc = x + offsetX
	yLoc = y + offsetY

	--Top Row
	love.graphics.draw(tilesBG[56],(xLoc) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(tilesBG[57],(xLoc + 1) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(tilesBG[58],(xLoc + 2) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	
	--Bottom Row
	love.graphics.draw(tilesBG[72],(xLoc) * blockDrawSize, (yLoc + 1) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(tilesBG[73],(xLoc + 1) * blockDrawSize, (yLoc + 1) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(tilesBG[74],(xLoc + 2) * blockDrawSize, (yLoc+ 1) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
end

function drawScoreUI(x, offsetX, y, offsetY)
	xLoc = x + offsetX
	yLoc = y + offsetY

	--Top Row
	love.graphics.draw(tilesUI[1],(xLoc) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(tilesUI[2],(xLoc + 1) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(tilesUI[3],(xLoc + 2) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	
	--Middle Row
	love.graphics.draw(tilesUI[5],(xLoc) * blockDrawSize, (yLoc + 1) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(tilesUI[6],(xLoc + 1) * blockDrawSize, (yLoc + 1) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(tilesUI[7],(xLoc + 2) * blockDrawSize, (yLoc+ 1) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)

	--Second Middle Row
	love.graphics.draw(tilesUI[5],(xLoc) * blockDrawSize, (yLoc + 2) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(tilesUI[6],(xLoc + 1) * blockDrawSize, (yLoc + 2) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(tilesUI[7],(xLoc + 2) * blockDrawSize, (yLoc+ 2) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	
	--Bottom Row
	love.graphics.draw(tilesUI[9],(xLoc) * blockDrawSize, (yLoc + 3) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(tilesUI[10],(xLoc + 1) * blockDrawSize, (yLoc + 3) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(tilesUI[11],(xLoc + 2) * blockDrawSize, (yLoc+ 3) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
end

function drawNextBlockUI(x, offsetX, y, offsetY)

end

function drawOceanBG()
	local rotator = 0
	for x = 0, 20 do
		for y = 0, 20 do
		rotator = rotator + 1
			if(rotator == 9 + (x % 5)) then
				love.graphics.draw(tilesBG[140],x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
			elseif(rotator == 23) then
				love.graphics.draw(tilesBG[156],x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				rotator = 0
			else
				love.graphics.draw(tilesBG[141],x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
			end
		end
	end
end

function drawSinglePlayer()
	
	updateDrawBlockSize()
	
	local offsetX = (love.graphics.getWidth()/blockDrawSize)/4 - gridXCount/3  	--Put X as middle left
    local offsetY = (love.graphics.getHeight()/blockDrawSize)/2 - gridYCount/2	--Put Y as dead center
	
	drawOceanBG()											--Draw Ocean	
	drawPlayfieldBorder(offsetX, offsetY)					--Draw Field Border
	drawCharacterPlatform(9, offsetX, 11, offsetY)			--Draw Character Platform
	drawScoreUI(9, offsetX, 3, offsetY)						--Draw Score Box
	
	for y = 0, gridYCount do
        for x = 0, gridXCount do
			
			drawPlayfieldTile(x, offsetX, y, offsetY)				--Draw Field
			if(inert[y][x] ~=0) then
				drawBlockShadow(x + offsetX, y + offsetY)
				drawBlock(inert[y][x], x + offsetX, y + offsetY)	--Then draw overlay
			end
        end
    end
	
	
	
	if(player1.playState == playStates.gridFixStep) then
		drawGravityGrid(player1)
	else
		updatePlayerLerps(player1)
		drawPlayerBlocks(player1, offsetX, offsetY + 1)
	end


end

function updateDrawBlockSize()
	blockDrawSize = math.min(love.graphics.getWidth(), love.graphics.getHeight())/16
	blockDrawRatio = blockDrawSize/blockSize
end

function updatePlayer(player)
	
	if player.playState == playStates.controlStep then
		descendPlayerBlock(player)	
	elseif player.playState == playStates.gravityStep then
		gravityStepLoop(player)
	elseif player.playState == playStates.gridFixStep then
		gridFixLoop(player)
	elseif player.playState == playStates.gravityCheckStep then
		gridFixLoop(player)
	else
	end
end

function drawPlayerBlocks(player, offsetX, offsetY)
	
	
	--DRAW TRANSPARENT STUFF FIRST
	drawBlockShadow(player.drawLocation.x + offsetX, player.drawLocation.y + offsetY)
	drawBlockShadow(player.drawLocation2.x + offsetX, player.drawLocation2.y + offsetY)
	
	love.graphics.setColor(255,255,255,0.5)
	openSpots = {}
	
	if(player.rotation == rotations.up) then
		openSpots = {block1 = findOpenSpotInColumn(player.location.x) - 1, block2 = findOpenSpotInColumn(player.location.x + player.rotation.x) - 2}
		
	elseif(player.rotation == rotations.down) then
		openSpots = {block1 = findOpenSpotInColumn(player.location.x) - 2, block2 = findOpenSpotInColumn(player.location.x + player.rotation.x) - 1}
	else
		openSpots = {block1 = findOpenSpotInColumn(player.location.x) -1, block2 = findOpenSpotInColumn(player.location.x + player.rotation.x) -1}
	end	
	
	drawBlockShadow(player.drawLocation.x + offsetX, openSpots.block1 + offsetY)
	drawBlockShadow(player.drawLocation.x + offsetX + player.rotation.x, openSpots.block2 + offsetY)
	
	drawBlock(player.blockColors.color1, player.drawLocation.x + offsetX, openSpots.block1 + offsetY)
	drawBlock(player.blockColors.color2, player.drawLocation.x + offsetX + player.rotation.x, openSpots.block2 + offsetY)
	

	love.graphics.setColor(255,255,255,255)
	
	--DRAW ACTUAL BLOCKS
	drawBlock(player.blockColors.color1, player.drawLocation.x + offsetX, player.drawLocation.y + offsetY)
	drawBlock(player.blockColors.color2, player.drawLocation2.x + offsetX, player.drawLocation2.y + offsetY)

end

function drawGravityGrid(player)
	-- Iterate through the Gravity Grid and draw everything
	if(player.gravityGrid  ~= null) then
		for i,v in ipairs(player.gravityGrid) do
			if(v.color ~= 0) then
				drawBlock(v.color, v.x, v.drawY)
			end
		end
	end
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

function findLowestOpenSpotInColumn(column, inertArray)
	for y = gridYCount, 0, -1  do
		if(inertArray[y][column] == colorBlank) then
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
		
		if(player.rotation ~= rotations.up and player.rotation ~= rotations.down) then
			inert[findOpenSpotInColumn(player.location.x)][player.location.x] = player.blockColors.color1
			inert[findOpenSpotInColumn(player.location.x + player.rotation.x)][player.location.x + player.rotation.x] = player.blockColors.color2
			
		elseif(player.rotation == rotations.up) then
			resetPlayerLerps(player)	
			inert[player.location.y + 1][player.location.x] = player.blockColors.color1
			inert[player.location.y + player.rotation.y + 1][player.location.x + player.rotation.x] = player.blockColors.color2
		elseif(player.rotation == rotations.down) then
			resetPlayerLerps(player)	
			inert[player.location.y + 1][player.location.x] = player.blockColors.color1
			inert[player.location.y + player.rotation.y + 1][player.location.x] = player.blockColors.color2
		end	
		shouldLoop = findBlocksToClear(inert, player)
		if(shouldLoop == true) then
			player.playState = playStates.gridFixStep
		else
			resetPlayerBlock(player)
			player.playState = playStates.controlStep
		end
		--]]
	end

end

function gridFixLoop(player)

	--allClear = gridFixStep(player)
	
	--[[]
	if(allClear == true) then
		for y = 0, gridYCount do
			for x = 0, gridXCount do
			   inert[y][x] = player.inertClone[y][x]
			end
		end
		resetPlayerBlock(player)
		player.playState = playStates.controlStep
	end
	--]]

	shouldLoop = findBlocksToClear(inert, player)
	if(shouldLoop == true) then
		player.playState = playStates.gridFixStep
	else
		resetPlayerBlock(player)
		player.playState = playStates.gravityStep
	end
end

function gridFixStep(player)
	allClear = true -- Tells us whether or not we have to loop any more
	-- Iterate through the Gravity Grid and draw everything
	for i,v in ipairs(player.gravityGrid) do
		distanceValue = distance (v.x, v.y,v.x, v.drawY) -- figure out how far we are from where we should be.
		print("Distance Value: "..distanceValue)
		if(distanceValue >.5) then
			v.drawY = v.drawY - .5
			allClear = false
		else
			v.drawY = v.y
		end
	end
	
	return allClear
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

function loadBGTiles()
for i=1,256 do
      if(i < 10) then
		tilesBG[i] = love.graphics.newImage( "assets/grassland/Grassland_0"..i..".png" )
	  else
		tilesBG[i] = love.graphics.newImage( "assets/grassland/Grassland_"..i..".png" )
	  end
   end
end

function loadUITiles()
	for i=1,16 do
      if(i < 10) then
		tilesUI[i] = love.graphics.newImage( "assets/menusprites/WindowUI_0"..i..".png" )
	  else
		tilesUI[i] = love.graphics.newImage( "assets/menusprites/WindowUI_"..i..".png" )
	  end
   end
end

function findBlocksToClear(inertArray, player)
	
	
	local matchesFound = false -- This only ever gets set to true once, if any part of the loop finds a match.
	local shouldLoop = true -- This is reset pre loop. If the loop makes it to the end as false, then we're all good.
	
	--while(shouldLoop == true) do --TODO: Move this While Loop to the GridFixStep
	
	markedArray = {}
	player.inertClone = {}	-- Clear out the Inert Clone Array so we can use it.
	chainNumber = 0
		
		shouldLoop = false -- Break the loop per loop. But only if nothing is found.
		--Mark all the places we need to check
		
		for y = 0, gridYCount do
				markedArray[y] = {}
				player.inertClone[y] = {}
				for x = 0, gridXCount do
					if(inertArray[y][x] == 0) then
						markedArray[y][x] = 0
					else
						markedArray[y][x] = -1 --(-1 signifies unchecked. 0 is Empty, 1 is matching.)
					end
					player.inertClone[y][x] = inertArray[y][x]
				end
			end
		
		--Check all the places, recursively.
		
		
		
		for locY = 0, gridYCount do
			for locX = 0, gridXCount do
				found = recursiveBlockClearStart(inertArray, locY, locX, markedArray)
				if(found == true) then
					matchesFound = true
					shouldLoop = true
				end
			end
		end
		
		player.gravityGrid = {} -- Clear out the Gravity Grid so we can use it.
		--Set up the gravity lerps. Backwards, from bottom to top.
		for locY = gridYCount -1, 0, -1  do
			for locX = 0, gridXCount do
				currentColor = inertArray[locY][locX] 				--Get the color of the spot we're currently at.
				if(currentColor ~= colorBlank) then
					local emptyY = findLowestOpenSpotInColumn(locX, inertArray)	--Find the lowest empty spot in this column
					if(emptyY > locY) then							--If this spot is lower than where we're currently at, then we record the new spot.
						inertArray[locY][locX] = colorBlank			--Clear out the current spot in the clone and real array
						inertArray[emptyY][locX] = currentColor		--Move it to the lowest open spot in the clone array.
					end
				end

			end
		end
		
	--end
	
	--resetPlayerBlock(player)
	--player.playState = playStates.controlStep
	return matchesFound
	
end

function recursiveBlockClearStart(inertArray, locY, locX, markedArray)
--Take in the array we're working with, the X and Y location to check in that array, and how many matching numbers we've found before this point.

	--If we've already been here, SKIP.
if(markedArray[locY][locX] == -1) then
	--First, note that we've checked the spot we're at.
	markedArray[locY][locX] = 0

	--Make it so we can mark down ALL of the spots found that count.
	foundPairLocations = {}
	
	--Note if we've found ANY matches at all.
	matchesFound = false
	
	--Since this is the beginning, start the chain at 1
	chainNumber = 1


				--Check up
				if(locY - 1 >= 0 ) then --If the block above us is within the array
					if(inertArray[locY][locX] == inertArray[locY-1][locX] and inertArray[locY][locX] > 0 and markedArray[locY-1][locX] == -1) then
						--print("Match Up")
						chainNumber = chainNumber + 1
						table.insert(foundPairLocations, {y = locY-1, x = locX})
						chainNumber = recursiveBlockClear(inertArray, locY -1, locX, markedArray, chainNumber)
					end
				end

				--Check right
				if(locX + 1 <= gridXCount) then
					if(inertArray[locY][locX] == inertArray[locY][locX+1] and inertArray[locY][locX] > 0 and markedArray[locY][locX + 1] ~= 0) then
						--print("Match Right")
						chainNumber = chainNumber + 1
						table.insert(foundPairLocations, {y = locY, x = locX+1})
						chainNumber = recursiveBlockClear(inertArray, locY, locX + 1, markedArray, chainNumber)
					end
				end

				--Check down
				if(locY + 1 <= gridYCount ) then --If the block above us is within the array
					if(inertArray[locY][locX] == inertArray[locY+1][locX] and inertArray[locY][locX] > 0 and markedArray[locY + 1][locX] == -1) then
						--print("Match Down")
						chainNumber = chainNumber + 1
						table.insert(foundPairLocations, {y = locY+1, x = locX})
						chainNumber = recursiveBlockClear(inertArray, locY + 1, locX, markedArray, chainNumber)
					end
				end

				--Check left
				if(locX - 1 >= 0) then
					if(inertArray[locY][locX] == inertArray[locY][locX-1] and inertArray[locY][locX] > 0 and markedArray[locY][locX - 1] ~= 0) then
						--print("Match Left")
						chainNumber = chainNumber + 1
						table.insert(foundPairLocations, {y = locY, x = locX-1})
						chainNumber = recursiveBlockClear(inertArray, locY, locX - 1, markedArray, chainNumber)
					end
				end
				

				if(chainNumber > 3) then
					markedArray[locY][locX] = 1
					table.insert(foundPairLocations, {y = locY, x = locX})
					matchesFound = true

					--Now that we've marked everything and have a list of spots to clear, go through the list and clear them.
					for i,v in ipairs(foundPairLocations) do
						--print(""..(v.x)..", "..(v.y).."\n")
						inertArray[v.y][v.x] = 0
						--print("Clear: "..v.x..", "..v.y)
					end
				end

	
		--Return if we found and cleared anything
		return matchesFound
	end
end

function recursiveBlockClear(inertArray, locY, locX, markedArray, chainNumber)
	
	if(markedArray[locY][locX] == -1) then
		--First, note that we've checked the spot we're at.
		markedArray[locY][locX] = 0
		
		--Check up
		if(locY - 1 >= 0 ) then --If the block above us is within the array
			if(inertArray[locY][locX] == inertArray[locY-1][locX] and inertArray[locY][locX] > 0 and markedArray[locY-1][locX] == -1) then
				--print("Match Up")
				chainNumber = chainNumber + 1
				table.insert(foundPairLocations, {y = locY-1, x = locX})
				chainNumber = recursiveBlockClear(inertArray, locY -1, locX, markedArray, chainNumber)
			end
		end

		--Check right
		if(locX + 1 <= gridXCount) then
			if(inertArray[locY][locX] == inertArray[locY][locX+1] and inertArray[locY][locX] > 0 and markedArray[locY][locX + 1] ~= 0) then
				--print("Match Right")
				chainNumber = chainNumber + 1
				table.insert(foundPairLocations, {y = locY, x = locX+1})
				chainNumber = recursiveBlockClear(inertArray, locY, locX + 1, markedArray, chainNumber)
			end
		end

		--Check down
		if(locY + 1 <= gridYCount ) then --If the block above us is within the array
			if(inertArray[locY][locX] == inertArray[locY+1][locX] and inertArray[locY][locX] > 0 and markedArray[locY + 1][locX] == -1) then
				--print("Match Down")
				chainNumber = chainNumber + 1
				table.insert(foundPairLocations, {y = locY+1, x = locX})
				chainNumber = recursiveBlockClear(inertArray, locY + 1, locX, markedArray, chainNumber)
			end
		end

		--Check left
		if(locX - 1 >= 0) then
			if(inertArray[locY][locX] == inertArray[locY][locX-1] and inertArray[locY][locX] > 0 and markedArray[locY][locX - 1] ~= 0) then
				--print("Match Left")
				chainNumber = chainNumber + 1
				table.insert(foundPairLocations, {y = locY, x = locX-1})
				chainNumber = recursiveBlockClear(inertArray, locY, locX - 1, markedArray, chainNumber)
			end
		end
		
		--print("recursive Chain Number: "..chainNumber)
		if(chainNumber > 3) then
			markedArray[locY][locX] = 1
			--table.insert(foundPairLocations, {y = locY, x = locX})
		end

	end
	return chainNumber
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