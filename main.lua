-- Asteroids game. Player travels on the field & collects coins. OK?
require("player")
require("controls")

K_CONSTANT = 6.674 * 10^-11 * 10^11
MIN_DISTANCE = 3 * 10^3
GEN_DISTANCE = 10^5
RADIUS = 300 -- Controls the size of the bubbles
DENSITY = 5
SPEED = MIN_DISTANCE * 10^2 -- Controls the initial speed of the bubbles
TRAITS = 3 -- Number of traits each bubble has
ITER_TIME = 10^-2 -- [seconds] Controls the precision of the simulation. The smaller the number, the more precise simulation is.
CHARGE_MIN = 10^10
CHARGE_MAX_MINUS_MIN = 10^10
MIN_COLLISIONS = 200 -- Number of collisions before bubbles are connected by a poligon

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

	objects = {bubbles = {}, polygons = {}} -- Contains all of the objects

	world = love.physics.newWorld(0, 0, true) -- Create a world

	window_pos = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}
end

function love.update(dt)
	world:update(dt)

	continuous_controls(dt)

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
			for i, otherBubble in ipairs(objects.bubbles) do
				if hypot(otherBubble.pos.x - bubble.pos.x, otherBubble.pos.y - bubble.pos.y) < MIN_DISTANCE then
					createBubble = false
				end
			end
			if createBubble then
				bubble.color = {math.random(100) + 100, math.random(100) + 100, math.random(100) + 100}
				bubble.traits = {}
				trait_iterator = 0
				while trait_iterator <= TRAITS do
					local charge_type
					local random_number = math.random(3)
					if random_number == 1 then
						charge_type = 1
					elseif random_number == 2 then
						charge_type = -1
					else
						charge_type = 0
					end
					local charge = (math.random(CHARGE_MAX_MINUS_MIN) + CHARGE_MIN) * charge_type
					table.insert(bubble.traits, charge)
					trait_iterator = trait_iterator + 1
				end
				bubble.velocity = {
					x = math.random(SPEED) - SPEED / 2,
					y = math.random(SPEED) - SPEED / 2
				}
				bubble.collisions = 0

				bubble.body = love.physics.newBody(world, bubble.pos.x, bubble.pos.y, "dynamic")
				bubble.shape = love.physics.newCircleShape(RADIUS)
				bubble.fixture = love.physics.newFixture(bubble.body, bubble.shape, DENSITY)
				bubble.body:setLinearVelocity(bubble.velocity.x, bubble.velocity.y)

				bubble.active = true
				table.insert(objects.bubbles, bubble)
			end

		for i, bubble in ipairs(objects.bubbles) do
			if bubble.active then
				local acceleration = {x = 0, y = 0}
				for j, anotherBubble in ipairs(objects.bubbles) do
					if i ~= j then
						local dx = anotherBubble.pos.x - bubble.pos.x
						local dy = anotherBubble.pos.y - bubble.pos.y

						local distance = hypot(dx, dy)
						if collision(distance)
						and bubble.collisions > MIN_COLLISIONS
						and anotherBubble.collisions > MIN_COLLISIONS then
							local polygon_num --= #objects.polygons
							if anotherBubble.polygon then
								polygon_num = anotherBubble.polygon
								table.insert(objects.polygons[polygon_num], bubble)
								if bubble.polygon then
									--remove_item(objects.polygons[bubble.polygon], bubble)
								end
								bubble.polygon = polygon_num
							else -- If not, create new polygon
								polygon_num = #objects.polygons + 1
								objects.polygons[polygon_num] = {}
								table.insert(objects.polygons[polygon_num], bubble)
								table.insert(objects.polygons[polygon_num], anotherBubble)
								bubble.polygon = polygon_num
								anotherBubble.polygon = polygon_num
							end
						else
							for k, trait_mass in ipairs(bubble.traits) do
								acceleration.x = acceleration.x + K_CONSTANT * anotherBubble.traits[k] * trait_mass * dx / distance^3
								acceleration.y = acceleration.y + K_CONSTANT * anotherBubble.traits[k] * trait_mass * dy / distance^3
							end
							if collision(distance) then
								bubble.collisions = bubble.collisions + 1
								anotherBubble.collisions = anotherBubble.collisions + 1
							end
						end
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

	for i, bubble in ipairs(objects.bubbles) do
		local x = (bubble.body:getX() - pos.x) * scale + window_pos.x
		local y = (bubble.body:getY() + pos.y) * scale + window_pos.y

		love.graphics.setColor(bubble.color)
		love.graphics.circle("fill", x, y, bubble.shape:getRadius() * scale)
	end

	for i, polygon in ipairs(objects.polygons) do
		local vertices = {}
		for j, body in ipairs(polygon) do
			table.insert(vertices, (body.pos.x - pos.x) * scale + window_pos.x)
			table.insert(vertices, (body.pos.y + pos.y) * scale + window_pos.y)
		end

		if #vertices > 6 then
			love.graphics.setColor(255, 0, 0)
			love.graphics.polygon("fill", vertices)
		end
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.circle("fill", window_pos.x, window_pos.y, 3, 4)
	love.graphics.print("Position: x = " .. math.floor(pos.x)
		.. ", y = " .. math.floor(pos.y)
		.. ".\t\t\tNumber of bubbles: " .. #objects.bubbles
		.. ".\t\t\tNumber of polygons: " .. #objects.polygons, 0, 0)

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
