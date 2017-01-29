-- Asteroids game. Player travels on the field & collects coins. OK?
require("player")
require("controls")

G_CONSTANT = 10^3
MIN_DISTANCE = 5 * 10^3
GEN_DISTANCE = 10^4
RADIUS = 300 -- Controls the size of the bubbles
DENSITY = 5
SPEED = MIN_DISTANCE * 10^20 -- Controls the initial speed of the bubbles
ITER_TIME = 10^-2 -- [seconds] Controls the precision of the simulation. The smaller the number, the more precise simulation is.
DENSITY_MIN = 10^10
DENSITY_MAX_MINUS_MIN = 10^10

function love.load()
	math.randomseed(os.time())

	pause = false
	scale = 1
	bubbleScale = scale
	timeScale = 1

	timeInterval = 10^(-3) -- Time interval used to update the positions of the bubbles

	autoExplore = false
	exploreTurn = true -- This is used by autoExplore
	exploreTimeMin = 6000 -- This is in seconds
	exploreTime = 0

	pos = {x = 0, y = 0} -- User's global position
	speed = 100 -- Speed with which user can move

	objects = {} -- Contains all of the objects

	world = love.physics.newWorld(0, 0, true) -- Create a world

	window_pos = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}
end

function love.update(dt)
	world:update(ITER_TIME)

	continuous_controls(ITER_TIME)

	if autoExplore then
		if exploreTime >= exploreTimeMin then
			if exploreTurn then
				pos.x = pos.x + GEN_DISTANCE
				exploreTurn = false
			else
				pos.y = pos.y + GEN_DISTANCE
				exploreTurn = true
			end
			exploreTime = 0
		else
			exploreTime = exploreTime + dt
		end
	end

	if pause then
		return
	end

	count = 0
	while count < timeScale do
		-- Create bubbles
		local bubble = {}
			local createBubble = true
			bubble.pos = {
				x = pos.x + math.random(GEN_DISTANCE) - GEN_DISTANCE / 2,
				y = pos.y + math.random(GEN_DISTANCE) - GEN_DISTANCE / 2
			}
			for i, otherBubble in ipairs(objects) do
				if hypot(otherBubble.pos.x - bubble.pos.x, otherBubble.pos.y - bubble.pos.y) < MIN_DISTANCE then
					createBubble = false
				end
			end
			if createBubble then
				bubble.color = {math.random(100) + 100, math.random(100) + 100, math.random(100) + 100}
				bubble.mass = math.random(DENSITY_MAX_MINUS_MIN) + DENSITY_MIN
				bubble.velocity = {
					x = math.random(SPEED) - SPEED / 2,
					y = math.random(SPEED) - SPEED / 2
				}

				bubble.body = love.physics.newBody(world, bubble.pos.x, bubble.pos.y, "dynamic")
				bubble.shape = love.physics.newCircleShape(RADIUS)
				bubble.fixture = love.physics.newFixture(bubble.body, bubble.shape, DENSITY)
				bubble.body:setLinearVelocity(bubble.velocity.x, bubble.velocity.y)

				bubble.active = true
				table.insert(objects, bubble)
			end

		for i, bubble in ipairs(objects) do
			if bubble.active then
				local acceleration = {x = 0, y = 0}
				for j, anotherBubble in ipairs(objects) do
					if i ~= j then
						local dx = anotherBubble.pos.x - bubble.pos.x
						local dy = anotherBubble.pos.y - bubble.pos.y

						local distance = hypot(dx, dy)
						if collision(distance) then
							--table.remove(objects, j)
						end
						acceleration.x = acceleration.x + G_CONSTANT * anotherBubble.mass * dx / distance^3
						acceleration.y = acceleration.y + G_CONSTANT * anotherBubble.mass * dy / distance^3
					end
				end
				bubble.body:applyForce(acceleration.x, acceleration.y)
				bubble.pos.x, bubble.pos.y = bubble.body:getPosition()
			end
		end

		count = count + 1
	end
end

function love.draw()
	window_pos = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}

	for i, bubble in ipairs(objects) do
		local x = (bubble.body:getX() - pos.x) * scale + window_pos.x
		local y = (bubble.body:getY() + pos.y) * scale + window_pos.y

		love.graphics.setColor(bubble.color)
		love.graphics.circle("fill", x, y, bubble.shape:getRadius() * scale)
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.circle("fill", window_pos.x, window_pos.y, 3, 4)
	love.graphics.print("Position: x = " .. math.floor(pos.x)
		.. ", y = " .. math.floor(pos.y)
		.. ".\t\t\tNumber of bubbles: " .. #objects, 0, 0)

	love.graphics.setColor(0, 255, 255)
	if pause then
		love.graphics.print("PAUSED", love.graphics.getWidth() - 60, love.graphics.getHeight() - 20)
	end
	if autoExplore then
		love.graphics.print("EXPLORING", love.graphics.getWidth() - 80, 20)
	end

	love.graphics.print("ZOOM: " .. 1/scale .. "x", 5, love.graphics.getHeight() - 40)
	love.graphics.print("TIME SPEED: " .. timeScale .. "x", 5, love.graphics.getHeight() - 20)
end
