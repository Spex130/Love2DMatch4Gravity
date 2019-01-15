debug = true

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
	canDrop = true
	canDropTimerMax = 0.5 
	canDropTimer = canDropTimerMax

	--Gamestate tracking
	gameState = 1

	--Grid of Inert Blocks
	inert = {} 

	--Player location attributes
	player1 = 
	{
		location = {x = 3, y = 0}
	}
	
	loadBlocks()
	reset()
end

function love.update(dt)

end

function love.draw(dt)

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
	
	love.graphics.draw(blocksPGBY[colorBlue],player1.location.x * blockDrawSize,3 * blockDrawSize,0, blockDrawRatio, blockDrawRatio)
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
