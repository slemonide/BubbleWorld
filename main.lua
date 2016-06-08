-- Asteroids game. Player travels on the field & collects coins. OK?
require("player")

GRAVITATIONAL_CONSTANT = 6.674 * 10^-11
MIN_DISTANCE = 10
GEN_DISTANCE = 10^4
RADIUS = 3 -- Controls the size of the bubbles
SPEED = 100 -- Controls the initial speed of the bubbles

function love.load()
	math.randomseed(os.time())

	pause = false
	scale = 1
	timeScale = 1

	pos = {x = 0, y = 0} -- User's global position
	speed = 100 -- Speed with which user can move

	world = {} -- Contains the WHOLE WORLD

	window_pos = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}

	tmp_debug = true
end

function love.update(dt)
	if love.keyboard.isDown("left", "a") then
		pos.x = pos.x - speed * dt
	end
	if love.keyboard.isDown("right","d") then
		pos.x = pos.x + speed * dt
	end
	if love.keyboard.isDown("up","w") then
		pos.y = pos.y + speed * dt
	end
	if love.keyboard.isDown("down","s") then
		pos.y = pos.y - speed * dt
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
				x = pos.x + math.random(GEN_DISTANCE / 2) - GEN_DISTANCE / 2,
				y = pos.y + math.random(GEN_DISTANCE / 2) - GEN_DISTANCE / 2
			}
			for i, otherBubble in ipairs(world) do
				if hypot(pos.x - bubble.pos.x, pos.y - bubble.pos.y) < MIN_DISTANCE
				or hypot(otherBubble.pos.x - bubble.pos.x, pos.y - otherBubble.pos.y - bubble.pos.y) < MIN_DISTANCE then
					createBubble = false
				end
			end
			if createBubble then
				bubble.color = {math.random(100) + 100, math.random(100) + 100, math.random(100) + 100}
				bubble.mass = math.random(10^10) + 10^10
				bubble.velocity = {
					x = math.random(SPEED / 2) - SPEED / 2,
					y = math.random(SPEED / 2) - SPEED / 2
				}
				table.insert(world, bubble)
			end
--[[
		for i, bubble in ipairs(world) do
			local acceleration = {x = 0, y = 0}
			for j, anotherBubble in ipairs(world) do
				local dx = anotherBubble.pos.x - bubble.pos.x
				local dy = anotherBubble.pos.y - bubble.pos.y

				local distance = hypot(dx, dy)
				acceleration.x = acceleration.x + GRAVITATIONAL_CONSTANT * anotherBubble.mass * dx / distance^3
				acceleration.y = acceleration.y + GRAVITATIONAL_CONSTANT * anotherBubble.mass * dy / distance^3
			end
				bubble.pos.x = bubble.pos.x + bubble.velocity.x * dt + acceleration.x * dt^2 / 2
				bubble.pos.y = bubble.pos.y + bubble.velocity.y * dt + acceleration.y * dt^2 / 2

				bubble.velocity.x = bubble.velocity.x + acceleration.x * dt^2
				bubble.velocity.y = bubble.velocity.y + acceleration.y * dt^2
		end
--]]
		count = count + 1
	end
end

function love.draw()
	window_pos = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}

	for i, bubble in ipairs(world) do
		local x, y = global_to_local(bubble.pos.x, bubble.pos.y, pos.x, pos.y)
		x = x + window_pos.x
		y = y + window_pos.y

		if tmp_debug then
			print()
			tmp_debug = false
		end

--		love.graphics.setColor(bubble.color)
		love.graphics.setColor({255,255,255})
		love.graphics.circle("fill", x, y, RADIUS)
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.circle("fill", window_pos.x, window_pos.y, 10, 3)
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
	elseif key == "x" then
		scale = 0.5
	elseif key == "c" then
		scale = 0.25
	elseif key == "v" then
		scale = 0.1

	elseif key == "b" then
		timeScale = 1
	elseif key == "n" then
		timeScale = 10
	elseif key == "m" then
		timeScale = 20
	end
end
