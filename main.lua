-- Asteroids game. Player travels on the field & collects coins. OK?
require("player")

GRAVITATIONAL_CONSTANT = 6.674 * 10^-11
MIN_DISTANCE = 10^4
GEN_DISTANCE = 10^6
RADIUS = 300 -- Controls the size of the bubbles
SPEED = MIN_DISTANCE * 3 -- Controls the initial speed of the bubbles
TRAITS = 3 -- Number of traits each bubble has

function love.load()
	math.randomseed(os.time())

	pause = false
	scale = 1
	bubbleScale = scale
	timeScale = 1

	pos = {x = 0, y = 0} -- User's global position
	speed = 100 -- Speed with which user can move

	world = {} -- Contains the WHOLE WORLD

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
			for i, otherBubble in ipairs(world) do
				if hypot(otherBubble.pos.x - bubble.pos.x, otherBubble.pos.y - bubble.pos.y) < MIN_DISTANCE then
					createBubble = false
				end
			end
			if createBubble then
				bubble.color = {math.random(100) + 100, math.random(100) + 100, math.random(100) + 100}
				bubble.traits = {}
				trait_iterator = 0
				while trait_iterator <= TRAITS do
					local mass_type
					local random_number = math.random(3)
					if random_number == 1 then
						mass_type = 1
					elseif random_number == 2 then
						mass_type = -1
					else
						mass_type = 0
					end
					local mass = (math.random(10^10) + 10^17) * mass_type
					table.insert(bubble.traits, mass)
					trait_iterator = trait_iterator + 1
				end
				bubble.velocity = {
					x = math.random(SPEED) - SPEED / 2,
					y = math.random(SPEED) - SPEED / 2
				}
				bubble.active = true
				table.insert(world, bubble)
			end

		for i, bubble in ipairs(world) do
			if bubble.active then
				local acceleration = {x = 0, y = 0}
				for j, anotherBubble in ipairs(world) do
					if i ~= j then
						local dx = anotherBubble.pos.x - bubble.pos.x
						local dy = anotherBubble.pos.y - bubble.pos.y

						local distance = hypot(dx, dy)
						if collision(distance - RADIUS / 2) then
							bubble.active = false
							anotherBubble.active = false
						else
							for k, trait_mass in ipairs(bubble.traits) do
								acceleration.x = acceleration.x + GRAVITATIONAL_CONSTANT * trait_mass * dx / distance^3
								acceleration.y = acceleration.y + GRAVITATIONAL_CONSTANT * trait_mass * dy / distance^3
							end
						end
					end
				end
				bubble.pos.x = bubble.pos.x + bubble.velocity.x * dt + acceleration.x * dt^2 / 2
				bubble.pos.y = bubble.pos.y + bubble.velocity.y * dt + acceleration.y * dt^2 / 2

				bubble.velocity.x = bubble.velocity.x + acceleration.x * dt^2
				bubble.velocity.y = bubble.velocity.y + acceleration.y * dt^2
			end
		end

		count = count + 1
	end
end

function love.draw()
	window_pos = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}

	for i, bubble in ipairs(world) do
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
		.. ".\t\t\tNumber of bubbles: " .. #world, 0, 0)

	love.graphics.setColor(0, 255, 255)
	if pause then
		love.graphics.print("PAUSED", love.graphics.getWidth() - 60, love.graphics.getHeight() - 20)
	end

	love.graphics.print("ZOOM: " .. 1/scale .. "x", love.graphics.getWidth()/2, love.graphics.getHeight() - 40)
	love.graphics.print("TIME SPEED: " .. timeScale .. "x", love.graphics.getWidth()/2, love.graphics.getHeight() - 20)
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
		timeScale = 1
	elseif key == "n" then
		timeScale = 10
	elseif key == "m" then
		timeScale = 20
	end
end
