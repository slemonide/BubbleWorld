function hypot(dx, dy)
	return math.sqrt(dx^2 + dy^2)
end

-- Removes an item from the table
function remove_item(table, item)
	for k, i in ipairs(table) do
		if i == item then
			table.remove(table, k)
		end
	end
end

function global_to_local(x, y, origin_x, origin_y)
	local local_x = x - origin_x
	local local_y = origin_y - y

	return local_x, local_y 
end

function nearest_planet(x, y, planets)
	local candidate, key
	for i, planet in ipairs(planets) do
		local next_candidate = math.sqrt((planet.pos.x - x)^2 + (planet.pos.y - y)^2) - planet.radius
		local next_key = i

		if not candidate then
			candidate = next_candidate
		end
		if not key then
			key = next_key
		end

		if next_candidate < candidate then
			candidate = next_candidate
			key = next_key
		end
	end

	return candidate, planets[key]
end

function collision(distance)
	if 2 * RADIUS >= distance then
		return true
	else
		return false
	end
end
