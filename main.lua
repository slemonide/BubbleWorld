-- Asteroids game. Player travels on the field & collects coins. OK?
require("player")

K_CONSTANT = 6.674 * 10^-11
MIN_DISTANCE = 3 * 10^3
GEN_DISTANCE = 5 * 10^4
RADIUS = 300 -- Controls the size of the bubbles
SPEED = MIN_DISTANCE * 3 -- Controls the initial speed of the bubbles
TRAITS = 3 -- Number of traits each bubble has
ITER_TIME = 10^-2 -- [seconds] Controls the precision of the simulation. The smaller the number, the more precise simulation is.
CHARGE_MIN = 10
CHARGE_MAX_MINUS_MIN = 10

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
	if love.keyboard.isDown("left", "a") then
		pos.x = pos.x - speed * dt / scale
	end
	if love.keyboard.isDown("right","d") then
		pos.x = pos.x + speed * dt / scale
	end
	if love.keyboard.isDown("up","w") then
		pos.y = pos.y + speed * dt / scale
	end
	if love.keyboard.isDown("down","s") then
		pos.y = pos.y - speed * dt / scale
	end

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
				-- bubble.color = {math.random(100) + 100, math.random(100) + 100, math.random(100) + 100}
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
				-- Make the color a function of trairs
				bubble.color = {bubble.traits[1] % 100 + 100, bubble.traits[2] % 100 + 100, bubble.traits[2] % 100 + 100}
				bubble.velocity = {
					x = math.random(SPEED) - SPEED / 2,
					y = math.random(SPEED) - SPEED / 2
				}
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
						if collision(distance + RADIUS / 5) then
							bubble.active = false
							anotherBubble.active = false
						else
							for k, trait_mass in ipairs(bubble.traits) do
								acceleration.x = acceleration.x + K_CONSTANT * anotherBubble.traits[k] * trait_mass * dx / distance^3
								acceleration.y = acceleration.y + K_CONSTANT * anotherBubble.traits[k] * trait_mass * dy / distance^3
							end
						end
					end
				end
				bubble.pos.x = bubble.pos.x + bubble.velocity.x * ITER_TIME + acceleration.x * ITER_TIME^2 / 2
				bubble.pos.y = bubble.pos.y + bubble.velocity.y * ITER_TIME + acceleration.y * ITER_TIME^2 / 2

				bubble.velocity.x = bubble.velocity.x + acceleration.x * ITER_TIME
				bubble.velocity.y = bubble.velocity.y + acceleration.y * ITER_TIME
			end
		end

		count = count + 1
	end
end

function love.draw()
	window_pos = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}

	for i, bubble in ipairs(objects) do
		local x, y = global_to_local(bubble.pos.x, bubble.pos.y, pos.x, pos.y)
		x = x * scale + window_pos.x
		y = y * scale + window_pos.y

		love.graphics.setColor(bubble.color)
		love.graphics.circle("fill", x, y, RADIUS * bubbleScale)
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

function love.keypressed(key)
	if key == "escape" or key == "q" then
		love.event.quit()
	elseif key == "p" or key == "space" then
		if not pause then
			pause = true
		else
			pause = false
		end
	elseif key == "f" then
		local fullscreen = love.window.getFullscreen()
		if not fullscreen then
			love.window.setFullscreen(true)
		else
			love.window.setFullscreen(false)
		end
	elseif key == "z" then
		scale = 1
		bubbleScale = scale
	elseif key == "x" then
		scale = 0.1
		bubbleScale = scale
	elseif key == "c" then
		scale = 0.01
		bubbleScale = scale
	elseif key == "v" then
		scale = 0.001
		bubbleScale = 0.01

	elseif key == "b" then
		timeScale = 2
	elseif key == "n" then
		timeScale = 10
	elseif key == "m" then
		timeScale = 20

	elseif key == "e" then
		if autoExplore then
			autoExplore = false
		else
			autoExplore = true
		end

	elseif key == "r" then
		pos = {x = 0, y = 0}
	end
end
