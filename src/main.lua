-- Main.la
require "Queue"
-- Constants
TILE_WIDTH = 25
TILE_HEIGHT = 25

DIRECTION_UP = 0
DIRECTION_RIGHT = 1
DIRECTION_DOWN = 2
DIRECTION_LEFT = 3

STARTING_SPEED = 25

function love.load()
	loadAssets()
	initGrid()
	initPlayer()
	spawnFood()
end

-- Load Assets
function loadAssets()
	-- Not loading any assets yet
end

-- Init Grid
function initGrid()
	grid = {}
	grid.width = love.graphics.getWidth() / TILE_WIDTH
	grid.height = love.graphics.getHeight() / TILE_HEIGHT
end

-- Init Player
function initPlayer()
	player = {}
	player.body = Queue.new()
	player.head = {
		x = math.floor(grid.width / 2),
		y = math.floor(grid.height / 2)
	}
	player.direction = DIRECTION_UP
	player.lastDirection = -1
	player.move = {
		[DIRECTION_UP] = function() player.head.y = player.head.y - 1 end,
		[DIRECTION_DOWN] = function() player.head.y = player.head.y + 1 end,
		[DIRECTION_LEFT] = function() player.head.x = player.head.x - 1 end,
		[DIRECTION_RIGHT] = function() player.head.x = player.head.x + 1 end
	}
	player.speed = STARTING_SPEED
end
sinceLastMove = 0
function love.update(dt)
	-- get input to update teh player direction
	updateDirection() 
	
	-- check if we are ready to move
	sinceLastMove = sinceLastMove + dt
	if  sinceLastMove > ( player.speed / 60 ) then
		-- update our last move
		sinceLastMove = 0
		
		-- Add the player head to the body
		Queue.pushleft(player.body, {x=player.head.x, y=player.head.y})	
		
		-- move the player
		player.move[player.direction]()
		-- check if we hit anything
		if checkDeath() or checkBodyCollision(player.head.x, player.head.y) then 
			endGame()
		else
			if true == checkFood() then
				spawnFood()
				player.speed = player.speed
			else
				Queue.popright(player.body)
			end
			if Queue.length(player.body) > 0 then
				player.bodyDirection = player.direction - 2
				if player.bodyDirection < 0 then
					player.bodyDirection = player.bodyDirection + 4
				end
			end
		end
	end
end

function spawnFood()
	while true do
		food = {
			x = math.random(grid.width - 2),
			y = math.random(grid.height- 2) 
		}
		if food.x ~= player.head.x and food.y ~= player.head.y then
			-- Food did not spawn on the player head
			if false == checkBodyCollision(food.x, food.y) then
				-- food did not spawn on the player body
				break
			end
		end
	end
end

function checkBodyCollision(x, y)
	for i=player.body.first,player.body.last do
		if player.body[i].x == x and player.body[i].y == y then
			return true
		end
	end
	return false
end

function updateDirection() 
	if love.keyboard.isDown("up") then
		if player.bodyDirection ~= DIRECTION_UP then
			player.direction = DIRECTION_UP
		end
	elseif love.keyboard.isDown("right") then
		if player.bodyDirection ~= DIRECTION_RIGHT then
			player.direction = DIRECTION_RIGHT
		end
	elseif love.keyboard.isDown("down") then
		if player.bodyDirection ~= DIRECTION_DOWN then
			player.direction = DIRECTION_DOWN
		end
	elseif love.keyboard.isDown("left") then
		if player.bodyDirection ~= DIRECTION_LEFT then
			player.direction = DIRECTION_LEFT
		end
	end
end

function checkDeath()
	-- Check edge collision
	if player.head.x == 0 or player.head.x == grid.width-1 or 
		player.head.y == 0 or player.head.y == grid.height-1 then
		return true
	end
	-- check body collision
	return false
end
function checkFood()
	-- check if we hit any food
	if player.head.x == food.x and player.head.y == food.y then
		return true
	end
	return false
end

function endGame()
	initPlayer()
	spawnFood()
end

function love.draw()
	drawGrid()
	drawFood()
	drawPlayer()
end

function drawTile(x, y)
	love.graphics.rectangle("fill", 
		TILE_WIDTH * x, TILE_HEIGHT * y, 
		TILE_WIDTH, TILE_HEIGHT )
end

function drawGrid()
	love.graphics.setColor(200,200,200,255)
	-- Draw the border
	for x=1,grid.width do
		for y=1,grid.height do
			if x == 1 or x == grid.width or 
				y == 1 or y == grid.height then
				--local ran = math.random(255)
				--love.graphics.setColor(0,ran,255 - ran,255)
				drawTile(x-1, y-1)
			end
		end
	end
end

function drawPlayer()
	love.graphics.setColor(0,0,255,255)
	-- Draw teh body
	for i=player.body.first,player.body.last do
		drawTile(player.body[i].x, player.body[i].y)
	end

	-- Draw the head first
	love.graphics.setColor(255,0,0,255)
	drawTile(player.head.x, player.head.y)

end

function drawFood()
	-- Draw the food
	love.graphics.setColor(0,255,0,255)
	drawTile(food.x, food.y)
end
