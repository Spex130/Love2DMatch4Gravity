debug = true


--Playfield attributes
gridXCount = 6
gridYCount = 12

gridOrigin = {0, 0}
gridAspect = {6, 12}
gridHeight = 600
gridWidth = 480
gridBlockWidth = 32

--Block Attributes
blocksPGBY = {}
colorBlank = 5
colorPurple = 1
colorGreen = 2
colorBlue = 3
colorYellow = 4

--Timers
canDrop = true
canDropTimerMax = 0.5 
canDropTimer = canDropTimerMax

--Gamestate tracking
gameState = 1

--Controllable falling attributes
fallingPair = {}


	function love.load(arg)
		importClasses()
		
		
	--Code start
		love.graphics.setBackgroundColor(255, 255, 255)
		
		loadBlocks()
		
		
		

		inert = {}
		for y = 1, gridYCount do
			inert[y] = {}
			for x = 1, gridXCount do
				inert[y][x] = colorBlank
			end
		end
	end

	function love.update(dt)
		updateGameState()
		dropTimerUpdate(dt)
	end

	function love.draw(dt)
		drawInertBlocks()
	end

	function loadBlocks()

		blocksPGBY = {love.graphics.newImage('assets/blocksPur.png'), love.graphics.newImage('assets/blocksGre.png'), love.graphics.newImage('assets/blocksBlu.png'), love.graphics.newImage('assets/blocksYel.png')}

	end

	function drawGrid()
		for y = 1, gridYCount do
			for x = 1, gridXCount do
				love.graphics.setColor(.87, .87, .87)
				local blockSize = 20
				local blockDrawSize = blockSize - 1
				love.graphics.rectangle(
					'fill',
					(x - 1) * blockSize,
					(y - 1) * blockSize,
					blockDrawSize,
					blockDrawSize
				)
			end
		end
	end

	function drawGridBlock(color, col, row)
		if(color ~= colorBlank) then
			love.graphics.draw(blocksPGBY[1], gridOrigin[1] + gridBlockWidth* (col-1) , gridOrigin[2] + gridBlockWidth * (row-1))
		end
	end

	function drawInertBlocks()
		for x = 1, gridXCount do

			for y = 1, gridYCount do
				--drawGridBlock(inert[y][x], x, y)
				color = inert[y][x]
				if(color ~= colorBlank) then
					love.graphics.draw(blocksPGBY[color], gridOrigin[1] + gridBlockWidth* (x-1) , gridOrigin[2] + gridBlockWidth*(y-1), 0, .5)
				end
			end
		end
	end
	
	function handleFall()
		--Do some stuff
		canDrop = false
		canDropTimer = canDropTimerMax
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

	function importClasses()
		Object = require "classic"
		require "block"
	end
