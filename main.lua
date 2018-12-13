debug = true


blocksPGBY = {}
colorPurple = 1
colorGreen = 2
colorBlue = 3
colorYellow = 4

gridXCount = 6
gridYCount = 12

gameState = 1

function love.load(arg)
	love.graphics.setBackgroundColor(255, 255, 255)
	
	loadBlocks()
	
	
	

    inert = {}
    for y = 1, gridYCount do
        inert[y] = {}
        for x = 1, gridXCount do
            inert[y][x] = ' '
        end
    end
end

function love.update(dt)


end

function love.draw(dt)
	
	
	love.graphics.draw(blocksPGBY[1], 100, 100)
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

function drawInertBlocks()

end

function updateGameState()

	if(gameState == 0) then--Busy

	--Do Nothing

	elseif(gameState == 1) then--Spawning
		SpawnNewPair()
		gameState = 2 --Switch to Falling        

	elseif(gameState == 2) then--Falling (In Control of Player)
		HandleFall()

	elseif(gameState == 3) then--CheckAndDestroy	(Look for and clear out combos)	
		DestroyAllChains()
		--gameState = 0 --Set to Busy. DestroyAllChains will set gameState when complete;

	elseif(gameState == 4) then--Repositioning (Reposition Blocks affected by gravity after placement)
		
		repositionBlocks()
		--gameState = 0 --Set to Busy. RepositionBlocks will set gameState when complete;

	elseif(gameState == 5) then--GameOver	

		
	else

	end
end