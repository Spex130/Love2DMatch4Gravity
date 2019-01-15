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

function canPieceMove(testX, testY, testRotation)
	return false
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
		timerLimit = 0.5
		if timer >= timerLimit then
			timer = timer - timerLimit
			player1.location.y = 1 + player1.location.y
		--[[
			local testY = pieceY + 1
			if canPieceMove(pieceX, testY, pieceRotation) then
				pieceY = testY
			else
				--If it's over, add the piece to the inert array
				for y = 1, pieceYCount do
					for x = 1, pieceXCount do
						local block = pieceStructures[pieceType][pieceRotation][y][x]
						if block ~= ' ' then
							inert[pieceY + y][pieceX + x] = block
						end
					end
				end
			
				-- Find complete rows
				for y = 1, gridYCount do
					local complete = true
					for x = 1, gridXCount do
						if inert[y][x] == ' ' then
							complete = false
						end
					end

					--remove complete rows
					if complete then
						for removeY = y, 2, -1 do
							for removeX = 1, gridXCount do
								inert[removeY][removeX] = inert[removeY - 1][removeX]
							end
						end
					
						for removeX = 1, gridXCount do
							inert[1][removeX] = ' '
						end
					end
				end
			
				newPiece()
				
				if not canPieceMove(pieceX, pieceY, pieceRotation) then
					--Normally, you would swap to GAME OVER state here.
					love.load()
				end
			end
		]]--
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



function updateGameState()

	if(gameState == 0) then--Busy

	--Do Nothing

	elseif(gameState == 1) then--Spawning
		--SpawnNewPair()
		gameState = 2 --Switch to Falling        

	elseif(gameState == 2) then--Falling (In Control of Player)
		handleFall()

	elseif(gameState == 3) then--CheckAndDestroy	(Look for and clear out combos)	
		--DestroyAllChains()
		--gameState = 0 --Set to Busy. DestroyAllChains will set gameState when complete;

	elseif(gameState == 4) then--Repositioning (Reposition Blocks affected by gravity after placement)
		
		--repositionBlocks()
		--gameState = 0 --Set to Busy. RepositionBlocks will set gameState when complete;

	elseif(gameState == 5) then--GameOver	

		
	else

	end
end

function dropTimerUpdate(dt)
	-- Should be based on GameSpeed.
	canDropTimer = canDropTimer - (1 * dt)
	if canDropTimer < 0 then
	  canDrop = true
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
	timerLimit = 0.5

	--Gamestate tracking
	gameState = 1

	--Grid of Inert Blocks
	inert = {} 

	--Player location attributes
	rotations = {right = {x = 1, y = 0}, down = {x = 0, y = 1}, left = {x = -1, y = 0}, up = {x = 0, y = -1}}
	player1 = 
	{
		location = {x = 3, y = 1},
		rotation = rotations.right
	}
	
	loadBlocks()
	reset()
end

function drawSinglePlayer()
	local function drawBlock(block, x, y)
		love.graphics.draw(blocksPGBY[block],x * blockDrawSize,y * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
    end
	
	local offsetX = 2
    local offsetY = 3
	
	for y = 1, gridYCount do
        for x = 1, gridXCount do
            drawBlock(inert[y][x], x + offsetX, y + offsetY)
        end
    end
	
	love.graphics.draw(blocksPGBY[colorBlue],(player1.location.x + offsetX) * blockDrawSize,(player1.location.y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
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

--input Functions

function love.mousemoved(x, y, dx, dy, istouch)
    menuengine.mousemoved(x, y)
end