local menuengine = require "menuengine"
local animator = require 'animator'
--menuengine.settings.sndMove = love.audio.newSource("pick.wav", "static")
--menuengine.settings.sndSuccess = love.audio.newSource("accept.wav", "static")

gameStates = {MainMenu = 1, SinglePlayer = 2, GameOver = 3, Instructions = 4}
gameState = gameStates.MainMenu
local mainmenu
local pausemenu

--Flip this to true if being used with an Ultimark iPac2 or iPac4 with default config layout.
isArcadeBuild = true


font = love.graphics.newImageFont("assets/imagefont51.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
pauseFont = love.graphics.newFont((30) * 64/30)

blockSize = 64
blockDrawSize = 30
blockDrawRatio = blockSize/30
widthChecker = love.graphics.getWidth()
heightChecker = love.graphics.getHeight()

maxSpeedScore = 3000
minTimerSpeed = .2

windowChanged = true
isPaused = false
gameOver = false
hiSpeedMode = true

--Sound variables

	--Menu
    sound_menuSuccess = love.audio.newSource("/assets/Sound/BlipActivate.wav", "static")
    sound_menuMove = love.audio.newSource("/assets/Sound/BlipSound1.wav", "static")
	
	--Block and Dropping noises
	sound_gameTimerDrop = love.audio.newSource("/assets/Sound/TimerDrop.wav", "static")
	sound_gameHardDrop = love.audio.newSource("/assets/Sound/BurstSound.wav", "static")
	sound_gameBlockLock = love.audio.newSource("/assets/Sound/ThudTinySound.wav", "static")
	sound_gameInitialClear = love.audio.newSource("/assets/Sound/ThudSound.wav", "static")
	sound_gameBlockSpin = love.audio.newSource("/assets/Sound/BlipSound2.wav", "static")
	sound_gameBlockReset = love.audio.newSource("/assets/Sound/MysticAppearance.wav", "static")
	sound_gameAddJunkBlock = love.audio.newSource("/assets/Sound/BlipSound2.wav", "static")
	
	--Clearing noises
	
	sound_clearBlue = love.audio.newSource("/assets/Sound/ClearBlue.wav", "static")
	sound_clearGreen = love.audio.newSource("/assets/Sound/ClearGreen.wav", "static")
	sound_clearPurple = love.audio.newSource("/assets/Sound/ClearPurple.wav", "static")
	sound_clearYellow = love.audio.newSource("/assets/Sound/ClearYellow.wav", "static")
	sound_clearJunk = love.audio.newSource("/assets/Sound/JunkBlockLoad.wav", "static")
	
	--State noises
	
	sound_gameOver = love.audio.newSource("/assets/Sound/GameOverBurst.wav", "static")

--Music
	sound_VGM = {}
--Main Menu functions

local function start_game()
	reset()
	gameState = gameStates.SinglePlayer
	loadSinglePlayer()
	resetMusic()
end

local function view_instructions()
	gameState = gameStates.Instructions
end

--Pause Menu Functions

local function quit_to_menu()
	love.audio.stop()
	gameState = gameStates.MainMenu
	isPaused = false
end

local function quit()
	love.event.quit(0)
end

local function unpause_game()
	isPaused = false
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
		player1.score = 0
		isPaused = false
		gameOver = false

    end
	
function love.load(arg)
	--profilerLoad()
	loadMusic()
	math.randomseed(os.time())
	loadSinglePlayer()
	loadMainMenu()
	loadBirdQuads(blockDrawRatio)

end

love.frame = 0
function love.update(dt)
	--profilerUpdate()	
	
	timerCalcu = calculateTimerLimit(player1.score)

	if gameState == gameStates.MainMenu then
		mainmenu:update()	
		
	elseif gameState == gameStates.SinglePlayer then
		if(isPaused == false and gameOver == false ) then
			timer = timer + dt

			if timer >= timerCalcu then
				timer = timer - timerCalcu
				sound_gameTimerDrop:play()
				updatePlayer(player1)
			end
		elseif(isPaused == true) then
			pausemenu:update()
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
	elseif gameState == gameStates.Instructions then
		drawInstructions(menuTimer)
		menuTimer = menuTimer+1
	end
	
	--profilerDraw()
end

--Profiler Functions

function profilerLoad()
	love.profiler = require('profile') 
	love.profiler.hookall("Lua")
	love.profiler.start()
end

function profilerUpdate()
	love.frame = love.frame + 1
	if love.frame%100 == 0 then
		love.report = love.profiler.report('time', 20)
		love.profiler.reset()
	end
end

function profilerDraw()
	love.graphics.print(love.report or "Please wait...")
end

--Music
function loadMusic()
	vg0 = love.audio.newSource("/assets/Music/BlockDrop_VGM0.ogg", "stream")
	vg0:setLooping(true)
	vg1 = love.audio.newSource("/assets/Music/BlockDrop_VGM1.ogg", "stream")
	vg1:setLooping(true)
	sound_VGM = {
		vg0,
		vg1,
	}
end

function resetMusic()
	love.audio.stop()
	number = love.math.random( #sound_VGM )
	sound_VGM[number]:play()
end

--Single Player Specific Functions

function loadSinglePlayer()
	loadPauseMenu()
	
	--Playfield attributes
	gridXCount = 6
	gridYCount = 12

	gridOrigin = {0, 0}
	gridAspect = {gridXCount, gridYCount}
	gridHeight = 600
	gridWidth = 480
	gridBlockWidth = 32

	playfieldExtrasXOffset = gridXCount + 3
	ScoreUILocY = 2
	CharPlatLocY = ScoreUILocY + 9
	
	oldWidth = love.graphics.getWidth()
	oldHeight = love.graphics.getWidth()
	
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
	tilesBG = {} 		-- Ocean and Geometry	
	tilesUI = {}		-- Score and info windows
	
	tileBGQuads = {}	-- Ocean and Geometry (Quads)
	tileUIQuads = {}	-- Score and info windows (Quads)	
	
	tilesBigBag = {}	-- Score Bag tiles
	tilesTinyBag = {}	-- Compressed Score Bag tiles
	
	--Quad related variables
	bgOceanMap = {}
	tilesetOceanBatch = {}
	
	playfieldMap = {}
	tilesetPlayfieldBatch = {}
	
	basicBG = love.graphics.newImage('assets/gamebackground.png')
	
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
		nextBlockColors = {color1 = math.random(1,4), color2 = math.random(1,4)},
		playState = playStates.controlStep,
		gravityLocation = {x = 0, y1 = 0, x2 = 1, y2 = 0},
		gravityGrid = {}, --Holds a list of blocks that need to be dropped after a clear.
		inertClone = {},
		score = 0,
		tinyBagCount = 
		{
			BagL0 = 0,
			BagL1 = 0,
			BagL2 = 0,
			BagL3 = 0,
			BagL4 = 0,
		},
		gemDeliveryArray={},	--Holds a list of gems to be delivered to the Gem Bag
		junkDeliveryArray={},	--Holds a list of junk gems to be delivered
		junkCountdownStep = 0,	--The count for how many turns it's been since a Junk Block dropped
		junkCountdownMax = 1,
		
	}
	
	isPaused = false
	gameOver = false
	
	loadBlocks()
	loadBGTiles()
	loadBGQuads()
	setOceanBGMap()
	setPlayfieldMap((widthChecker/blockDrawSize)/4 - gridXCount/3 ,(heightChecker/blockDrawSize)/2 - gridYCount/2)
	loadUITiles()
	loadMiscTiles()
	loadUIFont()
	reset()
	
end

function drawBlock(block, x, y)
		love.graphics.draw(blocksPGBY[block],x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
end

function drawBlockResize(block, x, y, size)
		love.graphics.draw(blocksPGBY[block],x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio * size, blockDrawRatio * size)
end

function drawBlockShadow(x, y)
		love.graphics.draw(shadowSprite,x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
end

function drawPlayfieldTile(x, offsetX, y, offsetY)

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

function setPlayfieldMap(offsetX, offsetY)
	floor = math.floor
	local widthCalc = gridXCount
	local heightCalc = gridYCount
	local localWidthCheck = (floor(widthChecker/16/4))

	
	local rotator = 0
	
	 tilesetPlayfieldBatch:clear()
	for x = 0, widthCalc + 2 do
		playfieldMap[x] = {}
		for y = 0, heightCalc + 2 do
			
			if(x == 0) then--we are on the far left column
				if(y == 0) then--we are in the top left corner
					playfieldMap[x][y] = 127
				elseif(y > 0 and y < heightCalc + 2) then--we are in the middle left column
					playfieldMap[x][y] = 142
				else--We are in the bottom left corner
					playfieldMap[x][y] = 143
				end
			elseif(x > 0 and x < widthCalc + 2) then--we are in the middle columns
				if(y == 0) then--we are in the top row
					playfieldMap[x][y] = 173
				elseif(y == heightCalc + 2) then--We are in the bottom row
					playfieldMap[x][y] = 124
				else--We're in the middle and are a SPECIAL CASE!!!!
					drawPlayfieldTileQuad(x, offsetX, y, offsetY)
				end
			elseif(x == widthCalc + 2) then--we are on the far left column
				if(y == 0) then--we are in the top right corner
					playfieldMap[x][y] = 128
				elseif(y > 0 and y < heightCalc + 2) then--we are in the middle right column
					playfieldMap[x][y] = 139
				else--We are in the bottom right corner
					playfieldMap[x][y] = 144
				end
			else--Catch all condition
				playfieldMap[x][y] = 127
			end

			tilesetPlayfieldBatch:add(tileBGQuads[playfieldMap[x][y]], (x + offsetX - 1) *blockDrawSize, (y + offsetY -1) *blockDrawSize, 0, blockDrawRatio, blockDrawRatio)
		end
	end
	tilesetPlayfieldBatch:flush()
end

function drawPlayfieldTileQuad(x, offsetX, y, offsetY)

		if(x == 1) then
			if(y == 1) then
				playfieldMap[x][y] = 1		--(Top left)
			elseif(y == gridYCount + 1) then
				playfieldMap[x][y] = 65		--(Bottom left)
		
			else	--(Middle left section)
				mod = y % 3		--Used for randomization
				
				if(mod == 0) then
					playfieldMap[x][y] = 17
				elseif(mod == 1) then
					playfieldMap[x][y] = 33
				else
					playfieldMap[x][y] = 49
				end	

			end
		elseif(x == gridXCount + 1) then
			if(y == 1) then
				playfieldMap[x][y] = 5		--(Top right)
			elseif(y == gridYCount + 1) then
				playfieldMap[x][y] = 69		--(Bottom right)

			else	--(Middle right section)
				mod = y % 3		--Used for randomization
				
				if(mod == 0) then
					playfieldMap[x][y] = 21
				elseif(mod == 1) then
					playfieldMap[x][y] = 37
				else
					playfieldMap[x][y] = 53
				end	

			end
		else
			
			mod = y % 3	
			if(y == 1) then
				if(mod == 0) then
					playfieldMap[x][y] = 2
				elseif(mod == 1) then
					playfieldMap[x][y] = 3
				else
					playfieldMap[x][y] = 4
				end	
			elseif(y == gridYCount + 1) then
				if(mod == 0) then
					playfieldMap[x][y] = 66
				elseif(mod == 1) then
					playfieldMap[x][y] = 67
				else
					playfieldMap[x][y] = 68
				end	
			else	--(Middlesection)
				mod =((x + y) % 6)
				
				if(mod == 0) then
					playfieldMap[x][y] = 50
				elseif(mod == 4) then
					playfieldMap[x][y] = 52
				else
					playfieldMap[x][y] = 51
				end	
			end
		end
		tilesetPlayfieldBatch:add(tileBGQuads[playfieldMap[x][y]], (x + offsetX - 1) *blockDrawSize, (y + offsetY -1) *blockDrawSize, 0, blockDrawRatio, blockDrawRatio)
end

function drawPlayfieldQuad(offsetX, offsetY)
	if(windowChanged) then
		setPlayfieldMap(offsetX, offsetY)
	end
	
	love.graphics.draw(tilesetPlayfieldBatch, 1, 1, 0, 1, 1)
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

function drawBagSprites(x, offsetX, y, offsetY, player)

	xLoc = x + offsetX
	yLoc = y + offsetY

	fill = calculateBagFill(player)

	--Draw Gem Bag
	love.graphics.draw(shadowSprite,(xLoc + .5) * blockDrawSize, (yLoc - .3) * blockDrawSize,0, blockDrawRatio * 2, blockDrawRatio * 2)
	love.graphics.draw(tilesBigBag[fill],(xLoc + .5) * blockDrawSize, (yLoc -.5) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	
end

function drawTinyBagSprites(x, offsetX, y, offsetY, player)

	row = 0
	
	if(player.tinyBagCount.BagL4 > 0) then
		love.graphics.draw(tilesTinyBag[4],(x + 1 + offsetX) * blockDrawSize, (y + offsetY + row) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
		drawTextCentered(x + 2, offsetX, y + row, offsetY, "x")
		drawTextCentered(x + 3, offsetX, y + row, offsetY, tostring(player.tinyBagCount.BagL4))
		row = row + 1
	end
	if(player.tinyBagCount.BagL3 > 0) then
		love.graphics.draw(tilesTinyBag[3],(x + 1 + offsetX) * blockDrawSize, (y + offsetY + row) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
		drawTextCentered(x + 2, offsetX, y + row, offsetY, "x")
		drawTextCentered(x + 3, offsetX, y + row, offsetY, tostring(player.tinyBagCount.BagL3))
		row = row + 1
	end
	if(player.tinyBagCount.BagL2 > 0) then
		love.graphics.draw(tilesTinyBag[2],(x + 1 + offsetX) * blockDrawSize, (y + offsetY + row) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
		drawTextCentered(x + 2, offsetX, y + row, offsetY, "x")
		drawTextCentered(x + 3, offsetX, y + row, offsetY, tostring(player.tinyBagCount.BagL2))
		row = row + 1
	end
	if(player.tinyBagCount.BagL1 > 0) then
		love.graphics.draw(tilesTinyBag[1],(x + 1 + offsetX) * blockDrawSize, (y + offsetY + row) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
		drawTextCentered(x + 2, offsetX, y + row, offsetY, "x")
		drawTextCentered(x + 3, offsetX, y + row, offsetY, tostring(player.tinyBagCount.BagL1))
		row = row + 1
	end
	if(player.tinyBagCount.BagL0 > 0) then
		love.graphics.draw(tilesTinyBag[0],(x + 1 + offsetX) * blockDrawSize, (y + offsetY + row) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
		drawTextCentered(x + 2, offsetX, y + row, offsetY, "x")
		drawTextCentered(x + 3, offsetX, y + row, offsetY, tostring(player.tinyBagCount.BagL0))
		row = row + 1
	end



end

function calculateBagFill(player)
	
	floor = math.floor
	
	fillLevel = 0	-- The number we should give the draw call to put into the array.
	bagCount = 0	-- How many tiny bags our score has earned us.
	
	tempScore = player.score + 0	--	The remainder of the score after extracting out the tiny bags
	
	if(tempScore > 500) then	--First figure out how many times we need to reduce the score
		bagCount = floor(player.score/500)
		tempScore = player.score - (500 * bagCount)
	end
	if(tempScore >= 400) then
		fillLevel = 4
	elseif(tempScore >= 300) then
		fillLevel = 3
	elseif(tempScore >= 200) then
		fillLevel = 2
	elseif(tempScore >= 100) then
		fillLevel = 1
	end
		
	if(bagCount >= 625) then
		player.tinyBagCount.BagL4 = floor(bagCount/625)
		bagCount = bagCount - player.tinyBagCount.BagL4
	end
	if(bagCount >= 125) then
		player.tinyBagCount.BagL3 = floor(bagCount/125)
		bagCount = bagCount - player.tinyBagCount.BagL3
	end
	if(bagCount >=25) then
		player.tinyBagCount.BagL2 = floor(bagCount/25)
		bagCount = bagCount - player.tinyBagCount.BagL2
	end
	if(bagCount >=5) then
		player.tinyBagCount.BagL1 = floor(bagCount/5)
		bagCount = bagCount - player.tinyBagCount.BagL1
	end
	if(bagCount > 0 and bagCount < 5) then
		player.tinyBagCount.BagL0 = bagCount
	end
		
	return fillLevel
end

function calculateTimerLimit(playerScore)
	min = math.min
	timerCalc = lerp(1.0, minTimerSpeed, min(1, playerScore/maxSpeedScore))
	return timerCalc
	
end

function addToGemDeliveryArray(player, gemColor, gemXLoc, gemYLoc)
	gem = 
	{
		color = gemColor,
		x = gemXLoc,
		y = gemYLoc,
		location = 0,
	}
	--table.insert(player.gemDeliveryArray, gem)
	if(gemColor == colorBlue) then
		sound_clearBlue:play()
	elseif(gemColor == colorGreen) then 
		sound_clearGreen:play()
	elseif(gemColor == colorPurple) then
		sound_clearPurple:play()
	elseif(gemColor == colorYellow) then
		sound_clearYellow:play()
	end
	
	player.gemDeliveryArray[#player.gemDeliveryArray+1] = gem
end

function drawGemDelivery(player, offsetX, offsetY)

	if(#player.gemDeliveryArray > 0) then
		for i,v in ipairs(player.gemDeliveryArray) do
			if(v.location <= 1) then
				
				bagX = playfieldExtrasXOffset + offsetX + (.5 * v.location) + 1--(v.location * 1.5)
				bagY = CharPlatLocY + offsetY + (.5 * v.location) - .5--(v.location * 1.5)
			
				xLoc = lerp(v.x + offsetX, bagX, v.location)
					--Find the horizontal difference between the two numbers
					--Then take the percentage traveled by multiplying it by a number from 0 to 1
					-- Then add it to the original number to get the horizontal location
				yLoc = lerp(v.y + offsetY,bagY, v.location)
					--Do the same for Y
				drawBlockResize(v.color, xLoc, yLoc, 1 -v.location)
				v.location = v.location + .05
			else
				if(v.color == colorBlue) then
					sound_clearBlue:play()
				elseif(v.color == colorGreen) then 
					sound_clearGreen:play()
				elseif(v.color == colorPurple) then
					sound_clearPurple:play()
				elseif(v.color == colorYellow) then
					sound_clearYellow:play()
				end
				table.remove(player.gemDeliveryArray, i)
			end
		end
	end

end

function drawGemDeliveryPause(player, offsetX, offsetY)
	if(#player.gemDeliveryArray > 0) then
		for i,v in ipairs(player.gemDeliveryArray) do
			if(v.location <= 1) then
				local bagX = playfieldExtrasXOffset + offsetX + (.5 * v.location) + 1--(v.location * 1.5)
				local bagY = CharPlatLocY + offsetY + (.5 * v.location) - .5--(v.location * 1.5)
			
				local xLoc = lerp(v.x + offsetX, bagX, v.location)
					--Find the horizontal difference between the two numbers
					--Then take the percentage traveled by multiplying it by a number from 0 to 1
					-- Then add it to the original number to get the horizontal location
				local yLoc = lerp(v.y + offsetY,bagY, v.location)
					--Do the same for Y
				drawBlockResize(v.color, xLoc, yLoc, 1 -v.location)
			end
		end
	end
end

function addToJunkDeliveryArray(player, gemColor, gemXLoc, gemYLoc)
	junk = 
	{
		color = gemColor,
		x = gemXLoc,
		y = gemYLoc,
		location = 0,
	}
	sound_clearJunk:play()
	--table.insert(player.junkDeliveryArray, junk)
	player.junkDeliveryArray[#player.junkDeliveryArray+1] = junk
end

function drawJunkDelivery(player, offsetX, offsetY)
	if(#player.junkDeliveryArray > 0) then
		for i,v in ipairs(player.junkDeliveryArray) do
			if(v.location <= 1) then
							
				sizeLerp = lerp(1.5, 1, v.location)
				
				drawBlockResize(5, v.x + offsetX - (.5 * (1-v.location)), v.y + offsetY - (.5 * (1-v.location)), sizeLerp)
				v.location = v.location + .05
			else
				table.remove(player.junkDeliveryArray, i)
			end
		end
	end
end

function drawJunkDeliveryPause(player, offsetX, offsetY)
	if(#player.junkDeliveryArray > 0) then
		for i,v in ipairs(player.junkDeliveryArray) do
			if(v.location <= 1) then
			
				sizeLerp = lerp(1.5, 1, v.location)
				
				drawBlockResize(5, v.x + offsetX, v.y + offsetY, sizeLerp)
			end
		end
	end
end

function addJunkToInertArray(inertArray, column, player)
	
	colOpenSpot = findOpenSpotInColumn(column)
	
	inertArray[colOpenSpot][column] = 5
	
	addToJunkDeliveryArray(player, 5, column, colOpenSpot)
	sound_clearJunk:play()
end

function junkSpotStep(player)

random = math.random


	if(player.junkCountdownStep < player.junkCountdownMax) then
		player.junkCountdownStep = player.junkCountdownStep + 1
	else
	addJunkToInertArray(inert, random(0, gridXCount), player)
	player.junkCountdownStep = 0;
	end
end

function drawUIBox(gridXLoc, offsetX, xCount, gridYLoc, offsetY, yCount)
	
	max = math.max
	
	xLoc = gridXLoc + offsetX
	yLoc = gridYLoc + offsetY
	
	xCount = max(0, xCount-1)
	yCount = max(0, yCount-1)

	if(xCount == 0 and yCount == 0) then			--Size 0,0
		love.graphics.draw(tilesUI[16],(xLoc) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	elseif(xCount == 0 and yCount > 0) then			--Single width column
		for y = 0, yCount do
			if(y == 0) then
					love.graphics.draw(tilesUI[4],(xLoc) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Top)
				elseif(y == yCount) then
					love.graphics.draw(tilesUI[12],(xLoc) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Bottom )
			
				else	--(Middle sections)
					love.graphics.draw(tilesUI[8],(xLoc) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
			end
		end
	elseif(xCount > 0 and yCount == 0) then			--Single height row
		for x = 0, xCount do
			if(x == 0) then
					love.graphics.draw(tilesUI[13],(xLoc + x) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Left)
				elseif(x == xCount) then
					love.graphics.draw(tilesUI[15],(xLoc+ x) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Right)
			
				else	--(Middle sections)
					love.graphics.draw(tilesUI[14],(xLoc + x) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
			end
		end
	else
	for x = 0, xCount do
		for y = 0, yCount do
			if(x == 0) then
				if(y == 0) then
					love.graphics.draw(tilesUI[1],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Top left)
				elseif(y == yCount) then
					love.graphics.draw(tilesUI[9],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Bottom left)
			
				else	--(Middle left section)
					love.graphics.draw(tilesUI[5],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				end
			elseif(x == xCount) then
				if(y == 0) then
					love.graphics.draw(tilesUI[3],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Top right)
				elseif(y == yCount) then
					love.graphics.draw(tilesUI[11],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Bottom right)
				else	--(Middle right section)
					love.graphics.draw(tilesUI[7],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				end
			else
				if(y == 0) then
					love.graphics.draw(tilesUI[2],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Top Middle)
				elseif(y == yCount) then
					love.graphics.draw(tilesUI[10],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Bottom Middle)
				else
					love.graphics.draw(tilesUI[6],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)	--(MIDDLE MIDDLE)
				end
			end
		end
	end

	end
	

end

function drawUINongridBox(xLoc, xCount, yLoc, yCount)

	max = math.max
	
	xLoc = xLoc - .25
	yLoc = yLoc - .25
	
	xCount = max(0, xCount-1)
	yCount = max(0, yCount-1)

	if(xCount == 0 and yCount == 0) then			--Size 0,0
		love.graphics.draw(tilesUI[16],(xLoc) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	elseif(xCount == 0 and yCount > 0) then			--Single width column
		for y = 0, yCount do
			if(y == 0) then
					love.graphics.draw(tilesUI[4],(xLoc) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Top)
				elseif(y == yCount) then
					love.graphics.draw(tilesUI[12],(xLoc) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Bottom )
			
				else	--(Middle sections)
					love.graphics.draw(tilesUI[8],(xLoc) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
			end
		end
	elseif(xCount > 0 and yCount == 0) then			--Single height row
		for x = 0, xCount do
			if(x == 0) then
					love.graphics.draw(tilesUI[13],(xLoc + x) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Left)
				elseif(x == xCount) then
					love.graphics.draw(tilesUI[15],(xLoc+ x) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Right)
			
				else	--(Middle sections)
					love.graphics.draw(tilesUI[14],(xLoc + x) * blockDrawSize, (yLoc) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
			end
		end
	else
	for x = 0, xCount do
		for y = 0, yCount do
			if(x == 0) then
				if(y == 0) then
					love.graphics.draw(tilesUI[1],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Top left)
				elseif(y == yCount) then
					love.graphics.draw(tilesUI[9],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Bottom left)
			
				else	--(Middle left section)
					love.graphics.draw(tilesUI[5],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				end
			elseif(x == xCount) then
				if(y == 0) then
					love.graphics.draw(tilesUI[3],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Top right)
				elseif(y == yCount) then
					love.graphics.draw(tilesUI[11],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Bottom right)
				else	--(Middle right section)
					love.graphics.draw(tilesUI[7],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				end
			else
				if(y == 0) then
					love.graphics.draw(tilesUI[2],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Top Middle)
				elseif(y == yCount) then
					love.graphics.draw(tilesUI[10],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)		--(Bottom Middle)
				else
					love.graphics.draw(tilesUI[6],(xLoc + x) * blockDrawSize, (yLoc + y) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)	--(MIDDLE MIDDLE)
				end
			end
		end
	end

	end

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

function drawNextBlockUI(x, offsetX, y, offsetY, player)
	
	local xLoc = x + offsetX
	local yLoc = y + offsetY
	
	local xLoc2 = x + offsetX + 1
	local yLoc2 = y + offsetY + 1
	
	love.graphics.print("Next:", (xLoc + (blockDrawRatio/2)) * blockDrawSize, (yLoc + (blockDrawRatio/2)) * blockDrawSize, 0, blockDrawRatio, blockDrawRatio)
	drawBlock(player.nextBlockColors.color1, xLoc, yLoc2)
	drawBlock(player.nextBlockColors.color2, xLoc2, yLoc2)
end

function drawScoreTextCentered(x, offsetX, y, offsetY, player)
	
	local xLoc = x + offsetX +(blockDrawRatio/2)
	local yLoc = y + offsetY +(blockDrawRatio/2)
	
	
	local yLoc2 = y + offsetY +(blockDrawRatio/2) + 1
	
	love.graphics.print("Score:", xLoc * blockDrawSize,yLoc * blockDrawSize, 0, blockDrawRatio, blockDrawRatio)
	love.graphics.print(player.score, xLoc * blockDrawSize,yLoc2 * blockDrawSize, 0, blockDrawRatio/2, blockDrawRatio/2)

end

function drawTextCentered(x, offsetX, y, offsetY, text)
	
	local xLoc = x + offsetX +(blockDrawRatio/2)
	local yLoc = y + offsetY +(blockDrawRatio/2)
	
	love.graphics.print(text, xLoc * blockDrawSize,yLoc * blockDrawSize, 0, blockDrawRatio, blockDrawRatio)
end

function drawText(x, y, text, rotation)
	love.graphics.print(text, x, y, rotation, blockDrawRatio, blockDrawRatio)
end

function drawText(x, y, text, rotation, rotationOffsetX)
	love.graphics.print(text, x, y, rotation, blockDrawRatio, blockDrawRatio, rotationOffsetX)
end

function drawBagUI(x, offsetX, y, offsetY)
	drawUIBox(x, offsetX, 5, y, offsetY, 5)
	
	drawBagSprites(playfieldExtrasXOffset, offsetX, CharPlatLocY, offsetY, player1)
	drawTinyBagSprites(x, offsetX, y, offsetY, player1)
end

function setOceanBGMap()
	floor = math.floor
	local widthCalc = (floor(widthChecker/16)+1)
	local heightCalc = (floor(heightChecker/16)+1)
	local localWidthCheck = (floor(widthChecker/16/4))

	
	local rotator = 0
	
	 tilesetOceanBatch:clear()
	for x = 0, widthCalc do
		bgOceanMap[x] = {}
		for y = 0, heightCalc do
			rotator = rotator + 1
			if(rotator == (9 + (x % 5)) and x > localWidthCheck) then
				bgOceanMap[x][y] = 141
			elseif(rotator == 23) then
				if(x > localWidthCheck) then
					bgOceanMap[x][y] = 157
				else
					bgOceanMap[x][y] = 140
				end
				rotator = 0
			else
				bgOceanMap[x][y] = 141
			end
			
			tilesetOceanBatch:add(tileBGQuads[bgOceanMap[x][y]], x*blockDrawSize, y*blockDrawSize, 0, blockDrawRatio, blockDrawRatio)
		end
	end
	tilesetOceanBatch:flush()
end

function drawOceanBG()
	floor = math.floor
	widthCalc = (floor(widthChecker/16)+1)
	heightCalc = (floor(heightChecker/16)+1)
	localWidthCheck = (floor(widthChecker/16/4))
	
	local rotator = 0
	for x = 0, widthCalc do
		for y = 0, heightCalc do
		rotator = rotator + 1
			if(rotator == 9 + (x % 5) and x > localWidthCheck) then
				love.graphics.draw(tilesBG[140],x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
			elseif(rotator == 23) then
				if(x > localWidthCheck) then
					love.graphics.draw(tilesBG[156],x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				else
					love.graphics.draw(tilesBG[141],x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
				end
				rotator = 0
			else
				love.graphics.draw(tilesBG[141],x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
			end
		end
	end
end

function drawOceanBGQuad()
	if(windowChanged) then
		setOceanBGMap()
	end
	
	love.graphics.draw(tilesetOceanBatch, 1, 1, 0, 1, 1)
end


function convertIDtoBatch(ID)
	floor = math.floor
	
	coords = {x=0,y=0}
	
	subt = ID/16.0
	coords.y = floor(subt)
	coords.x = 16 * (subt - coords.y)
	
	return coords
end

basicBGScrollX = 0
basicBGScrollY = 0
timerCalcu = 0
 
function drawBasicBG()

	basicBGScrollX = basicBGScrollX + timerCalcu
	basicBGScrollY = basicBGScrollY + (timerCalcu + timerCalcu)
	myWidth = basicBG:getWidth()
	myHeight = basicBG:getHeight()
	max = math.max

	local checker = max(widthChecker, heightChecker)

	local bgRatio = (myWidth / checker)
	if(basicBGScrollX > myWidth/bgRatio) then
		basicBGScrollX = myWidth/bgRatio
	end
	if(basicBGScrollY > myHeight/bgRatio) then
		basicBGScrollY = myHeight/bgRatio
	end
	
	love.graphics.draw(basicBG, 0 - basicBGScrollX, 0 - basicBGScrollY, 0, 1/bgRatio, 1/bgRatio) --Original/Top Left
	love.graphics.draw(basicBG, 0 - basicBGScrollX + myWidth/bgRatio, 0 - basicBGScrollY, 0, 1/bgRatio, 1/bgRatio) -- Top Right
	love.graphics.draw(basicBG, 0 - basicBGScrollX + myWidth/bgRatio, 0 - basicBGScrollY +  myHeight/bgRatio, 0, 1/bgRatio, 1/bgRatio) -- Bottom Right
	love.graphics.draw(basicBG, 0 - basicBGScrollX, 0 - basicBGScrollY +  myHeight/bgRatio, 0, 1/bgRatio, 1/bgRatio) -- Bottom Left
	
	if(basicBGScrollX == myWidth/bgRatio) then
		basicBGScrollX = 0
	end
	if(basicBGScrollY == myHeight/bgRatio) then
		basicBGScrollY = 0
	end
end

function loadPauseMenu()
		pauseFont = love.graphics.newFont((30) * blockDrawRatio)
		love.graphics.setFont(pauseFont, 40, "normal")
		
		pausemenu = menuengine.new(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
		pausemenu:addEntry("Resume", unpause_game)
		pausemenu:addEntry("Quit", quit_to_menu)
		pausemenu:mouseDisable()
end

function loadUIFont()
	love.graphics.setFont(font, 40, "normal")
end

function drawGameOver()
	drawText(widthChecker/4, heightChecker/2, "GAME OVER!", math.cos(love.timer.getTime()) * (20 * 0.0174533), widthChecker/16/8)
end

function drawPauseMenu()
	if(windowChanged) then
		loadPauseMenu()
	end
	pausemenu:draw()

end

function drawSinglePlayer()
	
	updateDrawBlockSize()
	
	updateWindowSizeCheck()
	updateBatches()
	
	local offsetX = (widthChecker/blockDrawSize)/4 - gridXCount/3  	--Put X as middle left
    local offsetY = (heightChecker/blockDrawSize)/2 - gridYCount/2	--Put Y as dead center
	
	--drawOceanBG()											--Draw Ocean	
	if(not hiSpeedMode) then
		drawOceanBGQuad()
	else
		drawBasicBG()
	end
	--drawPlayfieldBorder(offsetX, offsetY)					--Draw Field Border
	if(not hiSpeedMode) then
		drawPlayfieldQuad(offsetX, offsetY)
		drawCharacterPlatform(playfieldExtrasXOffset, offsetX, CharPlatLocY, offsetY)			--Draw Character Platform
	else
		drawUIBox(0, offsetX, gridXCount + 1, 1, offsetY, gridYCount) --Playerfield Box
		drawUIBox(playfieldExtrasXOffset, offsetX, 3, CharPlatLocY, offsetY, 2)
	end
	
	
	loadUIFont()
	drawScoreUI(playfieldExtrasXOffset, offsetX, ScoreUILocY, offsetY)						--Draw Score Box
	drawBagUI(8, offsetX, ScoreUILocY + 4, offsetY)
	drawScoreTextCentered(9, offsetX, ScoreUILocY, offsetY, player1)	--Draw Score Text
	drawNextBlockUI(playfieldExtrasXOffset, offsetX, ScoreUILocY+2, offsetY, player1)
	
	for y = 0, gridYCount do
        for x = 0, gridXCount do
			
			--drawPlayfieldTile(x, offsetX, y, offsetY)				--Draw Field
			if(inert[y][x] ~=0) then
				drawBlockShadow(x + offsetX, y + offsetY)
				drawBlock(inert[y][x], x + offsetX, y + offsetY)	--Then draw overlay
			end
        end
    end
	
	if( gameOver == true) then
		drawGemDeliveryPause(player1, offsetX, offsetY)
		drawJunkDeliveryPause(player1, offsetX, offsetY)
		drawPlayerBlocks(player1, offsetX, offsetY + 1)
		--drawUINongridBox(love.graphics.getWidth()/blockDrawSize/2, 3, love.graphics.getHeight()/blockDrawSize/2, 2)
		
		drawGameOver()
	elseif(isPaused == false) then
		if(player1.playState == playStates.gridFixStep) then
			drawGravityGrid(player1)
		else
			updatePlayerLerps(player1)
			drawPlayerBlocks(player1, offsetX, offsetY + 1)
		end
		
		drawJunkDelivery(player1, offsetX, offsetY)
		drawGemDelivery(player1, offsetX, offsetY)
	elseif(isPaused == true) then
		drawGemDeliveryPause(player1, offsetX, offsetY)
		drawJunkDeliveryPause(player1, offsetX, offsetY)
		drawPlayerBlocks(player1, offsetX, offsetY + 1)
		drawUINongridBox(widthChecker/blockDrawSize/2, 3, heightChecker/blockDrawSize/2, 2)
		
		drawPauseMenu()

	end


end

function updateDrawBlockSize()
	if(widthChecker ~= love.graphics.getWidth() or heightChecker ~= love.graphics.getHeight()) then
		blockDrawSize = math.floor(math.min(love.graphics.getWidth(), love.graphics.getHeight())/16)
		blockDrawRatio = blockDrawSize/blockSize
		widthChecker = love.graphics.getWidth() 
		heightChecker = love.graphics.getHeight()
	end
end

function updateWindowSizeCheck()
	if(oldWidth ~= widthChecker or oldHeight ~= heightChecker) then
		oldWidth = widthChecker 
		oldHeight = heightChecker
		windowChanged = true
	else
		windowChanged = false
	end
end

function updateBatches()
	if(windowChanged == true) then
		loadBGQuads()
	end
end

function updatePlayer(player)
	
	if player.playState == playStates.controlStep then
		descendPlayerBlock(player)	
	elseif player.playState == playStates.gravityStep then
		gravityStepLoop(player)
	elseif player.playState == playStates.gridFixStep then
		gridFixLoop(player)
	elseif player.playState == playStates.gravityCheckStep then
		gravityCheckLoop(player)
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
	if(player.gravityGrid  ~= nil) then
		for i = 0,#player.gravityGrid do
			if(player.gravityGrid[i]  ~= nil) then
				if(player.gravityGrid[i].color ~= 0) then
					drawBlock(player.gravityGrid[i].color, player.gravityGrid[i].x, player.gravityGrid[i].drawY)
				end
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

function hardDropPlayerBlocks(player)
				local y = player.location.y
				local x2 = player.location.x + player.rotation.x
				local y2 = player.location.y + player.rotation.y
				
				while (isSpotFilled(player.location.x, y + 1, pieceRotation) == false and isSpotFilled(x2, y2 + 1, pieceRotation) == false) do
					y = y + 1
					y2 = y2 + 1
					timer = 0
				end
					sound_gameHardDrop:play()
					player.location.y = y
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
			sound_gameInitialClear:play()
			player.playState = playStates.gridFixStep
		else
			resetPlayerBlock(player)
			player.playState = playStates.controlStep
			junkSpotStep(player)
		end
		--]]
	end

end

function gridFixLoop(player)



	shouldLoop = findBlocksToClear(inert, player)
	if(shouldLoop == true) then
		player.playState = playStates.gridFixStep
	else
		resetPlayerBlock(player)
		player.playState = playStates.controlStep
	end
end

function gridFixStep(player)
	allClear = true -- Tells us whether or not we have to loop any more
	-- Iterate through the Gravity Grid and draw everything
	for i,v in ipairs(player.gravityGrid) do
		distanceValue = distance (v.x, v.y,v.x, v.drawY) -- figure out how far we are from where we should be.
		--print("Distance Value: "..distanceValue)
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
	sound_gameBlockSpin:play()
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
	
	player.originPoint = {x = 3, y = 1}
	player.location = {x = 3, y = 1}
	player.rotation = rotations.right
	player.drawLocation = {x = 3, y = 1}
	player.drawLocation2 = {x = 3 + rotations.right.x, y = 1 + rotations.right.y}
	player.canDrop = false
	player.blockColors = {color1 = player.nextBlockColors.color1, color2 = player.nextBlockColors.color2}
	player.nextBlockColors = {color1 = math.random(1,4), color2 = math.random(1,4)}
	player.playState = playStates.controlStep
	player.gravityLocation = {x1=0,x2=0,y1=0,y2=0}
	player.gravityGrid = {}
	player.inertClone = {}
	
	
	if(inert[player.originPoint.y + 1][player.originPoint.x] ~= 0)then
		gameOver = true;
		sound_gameOver:play()
	else
		sound_gameBlockReset:play()
	end
	--[[
	player1 = {
		originPoint = {x = 3, y = 1},
		location = {x = 3, y = 1},
		rotation = rotations.right,
		drawLocation = {x = 3, y = 1},
		drawLocation2 = {x = 3 + rotations.right.x, y = 1 + rotations.right.y},
		canDrop = false,
		blockColors = {color1 = math.random(1,4), color2 = math.random(1,4)},
		nextBlockColors = {color1 = math.random(1,4), color2 = math.random(1,4)},
		playState = playStates.controlStep,
		gravityLocation = {x = 0, y1 = 0, x2 = 1, y2 = 0},
		gravityGrid = {}, --Holds a list of blocks that need to be dropped after a clear.
		inertClone = {},
		score = 0,
	} --]]

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

function loadBGQuads()
	floor = math.floor
	
	tilesetImage = love.graphics.newImage( "assets/grassland/grassland.png" )
	tilesetImage:setFilter("nearest", "linear") -- this "linear filter" removes some artifacts if we were to scale the tiles
	
	uiSetImage = love.graphics.newImage( "assets/menusprites/orig/MenuUISprites.png" )
	uiSetImage:setFilter("nearest", "linear") -- this "linear filter" removes some artifacts if we were to scale the tiles

	widthCalc = (floor(widthChecker/16)+1)
	heightCalc = (floor(heightChecker/16)+1)
	
	
	for i=1,256 do
		
		coords = convertIDtoBatch(i -1)
		--[[
		if(i < 17) then
			tileUIQuads[i] = love.graphics.newQuad(coords.x * blockSize, coords.y * blockSize, blockSize, blockSize, uiSetImage:getWidth(), uiSetImage:getHeight())
		end
		--]]--
		tileBGQuads[i] = love.graphics.newQuad(coords.x * blockSize, coords.y * blockSize, blockSize, blockSize, tilesetImage:getWidth(), tilesetImage:getHeight())
	end
	
	tilesetOceanBatch = love.graphics.newSpriteBatch(tilesetImage, gridXCount * gridYCount)
	tilesetPlayfieldBatch = love.graphics.newSpriteBatch(tilesetImage, gridXCount * gridYCount)
	tilesetPlatformBatch = love.graphics.newSpriteBatch(tilesetImage, gridXCount * gridYCount)
	--tilesetUIBatch = love.graphics.newSpritebatch(tilesetImage, --[[TODO FILL THIS THING]]--)
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

function loadMiscTiles()
	--Load Big Bags
	for i=0,4 do
		tilesBigBag[i] = love.graphics.newImage( "assets/bigbags/bagL"..i..".png" )
	end
	
	--load Tiny Bags
	for i=0,4 do
		tilesTinyBag[i] = love.graphics.newImage( "assets/tinybags/tinyBagL"..i..".png" )
	end
	
end

function findBlocksToClear(inertArray, player)
	
	
	local matchesFound = false -- This only ever gets set to true once, if any part of the loop finds a match.
	local shouldLoop = true -- This is reset pre loop. If the loop makes it to the end as false, then we're all good.
	
	--while(shouldLoop == true) do --TODO: Move this While Loop to the GridFixStep
	
	markedArray = {}
	player.inertClone = {}	-- Clear out the Inert Clone Array so we can use it.
		
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
				found = recursiveBlockClearStart(inertArray, locY, locX, markedArray, player)
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
				if(currentColor ~= colorBlank or currentColor ~= colorGray) then
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

function recursiveBlockClearStart(inertArray, locY, locX, markedArray, player)
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

if(inertArray[locY][locX] ~= 5) then
				--Check up
				if(locY - 1 >= 0 ) then --If the block above us is within the array
					if(inertArray[locY][locX] == inertArray[locY-1][locX] and inertArray[locY][locX] > 0 and markedArray[locY-1][locX] == -1) then
						--print("Match Up")
						chainNumber = chainNumber + 1
						--table.insert(foundPairLocations, {y = locY-1, x = locX})
						foundPairLocations[#foundPairLocations+1] = {y = locY-1, x = locX}
						chainNumber = recursiveBlockClear(inertArray, locY -1, locX, markedArray, chainNumber)
					end
				end

				--Check right
				if(locX + 1 <= gridXCount) then
					if(inertArray[locY][locX] == inertArray[locY][locX+1] and inertArray[locY][locX] > 0 and markedArray[locY][locX + 1] ~= 0) then
						--print("Match Right")
						chainNumber = chainNumber + 1
						--table.insert(foundPairLocations, {y = locY, x = locX+1})
						foundPairLocations[#foundPairLocations+1] = {y = locY, x = locX+1}
						chainNumber = recursiveBlockClear(inertArray, locY, locX + 1, markedArray, chainNumber)
					end
				end

				--Check down
				if(locY + 1 <= gridYCount ) then --If the block above us is within the array
					if(inertArray[locY][locX] == inertArray[locY+1][locX] and inertArray[locY][locX] > 0 and markedArray[locY + 1][locX] == -1) then
						--print("Match Down")
						chainNumber = chainNumber + 1
						--table.insert(foundPairLocations, {y = locY+1, x = locX})
						foundPairLocations[#foundPairLocations+1] = {y = locY+1, x = locX}
						chainNumber = recursiveBlockClear(inertArray, locY + 1, locX, markedArray, chainNumber)
					end
				end

				--Check left
				if(locX - 1 >= 0) then
					if(inertArray[locY][locX] == inertArray[locY][locX-1] and inertArray[locY][locX] > 0 and markedArray[locY][locX - 1] ~= 0) then
						--print("Match Left")
						chainNumber = chainNumber + 1
						--table.insert(foundPairLocations, {y = locY, x = locX-1})
						foundPairLocations[#foundPairLocations+1] = {y = locY, x = locX-1}
						chainNumber = recursiveBlockClear(inertArray, locY, locX - 1, markedArray, chainNumber)
					end
				end
				

				if(chainNumber > 3) then
					markedArray[locY][locX] = 1
					--table.insert(foundPairLocations, {y = locY, x = locX})
					foundPairLocations[#foundPairLocations+1] = {y = locY, x = locX}
					matchesFound = true
					player.score = player.score + (chainNumber * 10)
					
					junkBlockGridCheck(inertArray, locX, locY, chainNumber, foundPairLocations)
					
					--Now that we've marked everything and have a list of spots to clear, go through the list and clear them.
					for i = 0, #foundPairLocations do
						if(foundPairLocations[i] ~= nil) then
							addToGemDeliveryArray(player, inertArray[foundPairLocations[i].y][foundPairLocations[i].x], foundPairLocations[i].x, foundPairLocations[i].y)
							inertArray[foundPairLocations[i].y][foundPairLocations[i].x] = 0
						end
					end
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
		
	if(inertArray[locY][locX] ~= 5) then
			--Check up
			if(locY - 1 >= 0 ) then --If the block above us is within the array
				if(inertArray[locY][locX] == inertArray[locY-1][locX] and inertArray[locY][locX] > 0 and markedArray[locY-1][locX] == -1) then
					--print("Match Up")
					chainNumber = chainNumber + 1
					--table.insert(foundPairLocations, {y = locY-1, x = locX})
					foundPairLocations[#foundPairLocations+1] = {y = locY-1, x = locX}
					chainNumber = recursiveBlockClear(inertArray, locY -1, locX, markedArray, chainNumber)
				end
			end

			--Check right
			if(locX + 1 <= gridXCount) then
				if(inertArray[locY][locX] == inertArray[locY][locX+1] and inertArray[locY][locX] > 0 and markedArray[locY][locX + 1] ~= 0) then
					--print("Match Right")
					chainNumber = chainNumber + 1
					--table.insert(foundPairLocations, {y = locY, x = locX+1})
					foundPairLocations[#foundPairLocations+1] = {y = locY, x = locX+1}
					chainNumber = recursiveBlockClear(inertArray, locY, locX + 1, markedArray, chainNumber)
				end
			end

			--Check down
			if(locY + 1 <= gridYCount ) then --If the block above us is within the array
				if(inertArray[locY][locX] == inertArray[locY+1][locX] and inertArray[locY][locX] > 0 and markedArray[locY + 1][locX] == -1) then
					--print("Match Down")
					chainNumber = chainNumber + 1
					--table.insert(foundPairLocations, {y = locY+1, x = locX})
					foundPairLocations[#foundPairLocations+1] = {y = locY+1, x = locX}
					chainNumber = recursiveBlockClear(inertArray, locY + 1, locX, markedArray, chainNumber)
				end
			end

			--Check left
			if(locX - 1 >= 0) then
				if(inertArray[locY][locX] == inertArray[locY][locX-1] and inertArray[locY][locX] > 0 and markedArray[locY][locX - 1] ~= 0) then
					--print("Match Left")
					chainNumber = chainNumber + 1
					--table.insert(foundPairLocations, {y = locY, x = locX-1})
					foundPairLocations[#foundPairLocations+1] = {y = locY, x = locX-1}
					chainNumber = recursiveBlockClear(inertArray, locY, locX - 1, markedArray, chainNumber)
				end
			end
			
			--print("recursive Chain Number: "..chainNumber)
			if(chainNumber > 3) then
				markedArray[locY][locX] = 1
				--table.insert(foundPairLocations, {y = locY, x = locX})
				junkBlockGridCheck(inertArray, locX, locY, chainNumber, foundPairLocations)
			end

		end
	end
	return chainNumber
end
	
function junkBlockGridCheck(inertArray, locX, locY, chainNumber, foundPairLocations)

	max = math.max
	min = math.min

	junkBlockClearCheck(inertArray, locX, min(locY+1, gridYCount), chainNumber, foundPairLocations)
	junkBlockClearCheck(inertArray, locX, max(locY-1, 0), chainNumber, foundPairLocations)
	junkBlockClearCheck(inertArray, min(locX+1, gridXCount), locY, chainNumber, foundPairLocations)
	junkBlockClearCheck(inertArray, max(locX-1, 0), locY, chainNumber, foundPairLocations)
end
	
function junkBlockClearCheck(inertArray, locX, locY, chainNumber, foundPairLocations)
	if(inertArray[locY][locX] ~= nil) then
		if(inertArray[locY][locX] == 5 and chainNumber >= 4) then
			markedArray[locY][locX] = 1
			--table.insert(foundPairLocations, {y = locY, x = locX})
			foundPairLocations[#foundPairLocations+1] = {y = locY, x = locX}
		end
	end
end	

--Menu Functions

function loadMainMenu()
	font = love.graphics.newImageFont("assets/imagefont51.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
	smallfont = love.graphics.newImageFont("assets/imagefont17.png",
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
    mainmenu:addEntry("Instructions", view_instructions)
    mainmenu:addEntry("Quit Game", quit)
	mainmenu:setSndSuccess(sound_menuSuccess)
	mainmenu:setSndMove(sound_menuMove)
	mainmenu:mouseDisable()

end

function drawMenu(dt)

	local checker = math.max(love.graphics.getWidth(), love.graphics.getHeight())
	local bgRatio = (bg_image:getWidth() / checker)

	love.graphics.draw(bg_image, 0, 0, 0, 1/bgRatio, 1/bgRatio)
	love.graphics.draw(logo, 50, 60 + math.cos(dt*.05) * 15)
	mainmenu:draw()
end

function drawInstructions(dt)
	
	drawUINongridBox(1, math.max(3, math.floor(love.graphics.getWidth()/blockDrawSize) - 1), 1, math.max(5, math.floor(love.graphics.getHeight()/blockDrawSize) - 1))
	
	love.graphics.setColor(255,255,255,255)

	love.graphics.setFont(smallfont, 40, "normal")
	love.graphics.printf("Clear Blocks by matching colors. Match 4 and they'll clear!", 0 + love.graphics.getWidth()/4, (love.graphics.getHeight()/12) *2, love.graphics.getWidth()/2,"center")
	love.graphics.printf("Blocks with nothing under them fall! Use this and make combos!", 0 + love.graphics.getWidth()/4, (love.graphics.getHeight()/12) *3, love.graphics.getWidth()/2,"center")
	love.graphics.draw(blocksPGBY[1], love.graphics.getWidth()/2 - blockDrawSize/2,(love.graphics.getHeight()/12) *4 + blockDrawSize/4,0, .5, .5)
	
	love.graphics.printf("Junk blocks will show up over time.", 0 + love.graphics.getWidth()/4, (love.graphics.getHeight()/12) *6, love.graphics.getWidth()/2,"center")
	love.graphics.printf("Clear blocks next to them to clear them out!", 0 + love.graphics.getWidth()/4, (love.graphics.getHeight()/12) *7, love.graphics.getWidth()/2,"center")
	love.graphics.draw(blocksPGBY[5], love.graphics.getWidth()/2 - blockDrawSize/2,(love.graphics.getHeight()/12) *8,0, .5, .5)

	love.graphics.printf("Move: Arrows / Spin: L-CTRL / Drop: L-ALT", 0 + love.graphics.getWidth()/4, (love.graphics.getHeight()/12) * 10, love.graphics.getWidth()/2,"center")
	love.graphics.draw(blocksPGBY[3], love.graphics.getWidth()/2 - blockDrawSize/2,(love.graphics.getHeight()/12) *11,0, .5, .5)

	
	love.graphics.setFont(font, 40, "normal")
	love.graphics.printf("INSTRUCTIONS.", 0, (love.graphics.getHeight()/12) * 1, love.graphics.getWidth(),"center")
	love.graphics.printf("JUNK BLOCKS!?", 0, (love.graphics.getHeight()/12) *5, love.graphics.getWidth(),"center")
	love.graphics.printf("Controls!", 0, (love.graphics.getHeight()/12) *9, love.graphics.getWidth(),"center")
end
--Input Functions

function love.mousemoved(x, y, dx, dy, istouch)
    menuengine.mousemoved(x, y)
end

function love.keypressed(key)
	
	if( gameState == gameStates.SinglePlayer) then
		if(isArcadeBuild == false) then	
			if(isPaused == false) then
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
			elseif(key == 'return') then
				loadPauseMenu()
				isPaused = not isPaused
				
			end
				
			elseif(gameOver == true) then
				if(key == 'return' or key == 'c' or key == 'x') then
					quit_to_menu()
				end

			
			elseif(isPaused == true) then
				if key == 'down' then
					pausemenu:moveCursor(-1)
				elseif key == 'up' then
					pausemenu:moveCursor(1)		
				elseif key == 'return' then
					pausemenu:accept()
					--isPaused = not isPaused
				end
			end
			
			if(key == 'escape') then
				quit()
			end

		elseif (isArcadeBuild == true) then
			if(isPaused == false) then
				if key == 'lctrl' then
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
					
				elseif key == 'lalt' then
						hardDropPlayerBlocks(player1)
						
				elseif(key == '1') then
					loadPauseMenu()
					isPaused = not isPaused
					
				end
					
				elseif(gameOver == true) then
					if(key == '1' or key == 'lctrl' or key == 'lalt') then
						quit_to_menu()
					end

				
				elseif(isPaused == true) then
					if key == 'down' then
						pausemenu:moveCursor(-1)
					elseif key == 'up' then
						pausemenu:moveCursor(1)		
					elseif key == '1' then
						pausemenu:accept()
						--isPaused = not isPaused
					end
				end
				
				if(key == 'escape') then
					quit()
				end
			end
	elseif(gameState == gameStates.MainMenu) then
		if key == 'down' then
			mainmenu:moveCursor(1)
		elseif key == 'up' then
			mainmenu:moveCursor(-1)		
		elseif key == 'return' or key =='1' or key =='lctrl' or key == 'lalt' then
			mainmenu:accept()
			--isPaused = not isPaused
		end
	elseif(gameState == gameStates.Instructions) then
		if key == 'return' or key =='1' or key =='lctrl' or key =='lalt' or  key == 'x' or key == 'c' then
			quit_to_menu()
		end
	end
end

--Math functions
function lerp(a,b,t) return (1-t)*a + t*b end
function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

--Animation section

  birdQuads = {}
  
birdAnimSet = 
{
	flyLeft = {},
}


function loadBirdQuads(blockSize)

	floor = math.floor
	
	tilesetImage = love.graphics.newImage( "assets/birds/birds2.png" )
	tilesetImage:setFilter("nearest", "linear") -- this "linear filter" removes some artifacts if we were to scale the tiles
	
	widthCalc = (floor(widthChecker/16)+1)
	heightCalc = (floor(heightChecker/16)+1)
	
	
	for x=1,12 do
		for y = 1,8 do
			birdQuads[x*y] = love.graphics.newQuad(x * blockSize, y * blockSize, blockSize, blockSize, tilesetImage:getWidth(), tilesetImage:getHeight())
		end
	end
	
	birdAnimSet.flyLeft = animator.newAnimation( { birdQuads[4*6], birdQuads[5*6], birdQuads[6*6], birdQuads[5*6] }, { .1, .1, .1, .1 }, tilesetImage )
	birdAnimSet.flyLeft:setLooping()
	rotation = 0

end