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


function love.load(arg)
	
end
	function love.update(dt)

	end

	function love.draw(dt)

	end

	function loadBlocks()

		blocksPGBY = {love.graphics.newImage('assets/blocksPur.png'), love.graphics.newImage('assets/blocksGre.png'), love.graphics.newImage('assets/blocksBlu.png'), love.graphics.newImage('assets/blocksYel.png')}

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
