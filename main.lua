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
		player1.drawLocation.x = lerp(player1.drawLocation.x, player1.location.x, .2)
		player1.drawLocation.y = lerp(player1.drawLocation.y, player1.location.y, .2)
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
	timerLimit = 1.5

	--Grid of Inert Blocks
	inert = {} 

	--Player location attributes
	rotations = {right = {x = 1, y = 0}, down = {x = 0, y = 1}, left = {x = -1, y = 0}, up = {x = 0, y = -1}}
	player1 = 
	{
		location = {x = 3, y = 1},
		rotation = rotations.right,
		drawLocation = {x = 3, y = 1},
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
	
	if(player1.canDrop == false) then
		drawPlayerBlocks(player1, offsetX, offsetX)
		
	else
		
	end
end

function drawPlayerBlocks(player, offsetX, offsetY)
	love.graphics.draw(blocksPGBY[player.blockColors.color1],(player.drawLocation.x + offsetX) * blockDrawSize,(player.drawLocation.y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
	love.graphics.draw(blocksPGBY[player.blockColors.color2],(player.drawLocation.x + player.rotation.x + offsetX) * blockDrawSize,(player.drawLocation.y + player.rotation.y + offsetY) * blockDrawSize,0, blockDrawRatio, blockDrawRatio)

end

function dropCheck(player)
	
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
	--[[
	if key == 'x' then
        local testRotation = pieceRotation + 1
        if testRotation > #pieceStructures[pieceType] then
            testRotation = 1
        end

        if canPieceMove(pieceX, pieceY, testRotation) then
            pieceRotation = testRotation
        end

    elseif key == 'z' then
        local testRotation = pieceRotation - 1
        if testRotation < 1 then
            testRotation = #pieceStructures[pieceType]
        end

        if canPieceMove(pieceX, pieceY, testRotation) then
            pieceRotation = testRotation
        end
        
    elseif key == 'left' then
        local testX = pieceX - 1

        if canPieceMove(testX, pieceY, pieceRotation) then
            pieceX = testX
        end

    elseif key == 'right' then
        local testX = pieceX + 1

        if canPieceMove(testX, pieceY, pieceRotation) then
            pieceX = testX
        end

    elseif key == 'c' then
        while canPieceMove(pieceX, pieceY + 1, pieceRotation) do
            pieceY = pieceY + 1
            timer = timerLimit
        end
    end]]--
end

--Math functions
function lerp(a,b,t) return (1-t)*a + t*b end