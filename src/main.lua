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
		checkDeath()
		spawnFood()
 end
end

function spawnFood()
	while true do
		food = {
			x = math.random(grid.width - 2),
			y = math.random(grid.height- 2) 
		}
		if food.x == player.head.x and food.y == player.head.y then
			-- the food spawned ontop of the player
			-- continue
		else
			break
		end
	end
end

function updateDirection() 
	if love.keyboard.isDown("up") then
		player.direction = DIRECTION_UP
	elseif love.keyboard.isDown("right") then
		player.direction = DIRECTION_RIGHT
	elseif love.keyboard.isDown("down") then
		player.direction = DIRECTION_DOWN
	elseif love.keyboard.isDown("left") then
		player.direction = DIRECTION_LEFT
	end
end

function checkDeath()
	-- Check edge collision
	if player.head.x == 0 or player.head.x == grid.width-1 or 
		player.head.y == 0 or player.head.y == grid.height-1 then
		endGame()
	end
	-- check body collision
end

function endGame()
	initPlayer()
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
	-- Draw the head first
	love.graphics.setColor(255,0,0,255)
	drawTile(player.head.x, player.head.y)
end

function drawFood()
	-- Draw the food
	love.graphics.setColor(0,255,0,255)
	drawTile(food.x, food.y)
end
