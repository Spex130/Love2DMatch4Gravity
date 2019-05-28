local animator = require 'animator'
  --tileQuads[1] = love.graphics.newQuad(1 * tileSize, 0 * tileSize, tileSize, tileSize, tilesetImage:getWidth(), tilesetImage:getHeight())

  birdQuads = {}
  
birdAnimSet = 
{
	flyLeft = {},
}


function loadBirdQuads(blockSize)

	floor = math.floor
	
	tilesetImage = love.graphics.newImage( "assets/birds/birds2.png" )
	tilesetImage:setFilter("nearest", "linear") -- this "linear filter" removes some artifacts if we were to scale the tiles
	
	widthCalc = (floor(love.graphics.getWidth()/16)+1)
	heightCalc = (floor(love.graphics.getHeight()/16)+1)
	
	
	for x=1,12 do
		for y = 1,8 do
			birdQuads[x*y] = love.graphics.newQuad(x * blockSize, y * blockSize, blockSize, blockSize, tilesetImage:getWidth(), tilesetImage:getHeight())
		end
	end
	
	birdAnimSet.flyLeft = animator.newAnimation( { birdQuads[4*6], birdQuads[5*6], birdQuads[6*6], birdQuads[5*6] }, { .1, .1, .1, .1 }, tilesetImage )
	anim:setLooping()
	rotation = 0

end