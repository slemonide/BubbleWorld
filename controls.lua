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
		scale = 0.02
		bubbleScale = scale
	elseif key == "v" then
		scale = 0.01
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

function continuous_controls(dt)
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
end
