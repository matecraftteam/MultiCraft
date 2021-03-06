
sethome = {}

local homes_file = minetest.get_worldpath() .. "/homes"
local homepos = {}

local function loadhomes()
--	local input = io.open(homes_file, "r")
--	if input then
--		repeat
--			local x = input:read("*n")
--			if x == nil then
--				break
--			end
--			local y = input:read("*n")
--			local z = input:read("*n")
--			local name = input:read("*l")
--			homepos[name:sub(2)] = {x = x, y = y, z = z}
--		until input:read(0) == nil
--		io.close(input)
--	end
	local input, err = io.open(homes_file, "r")
	if not input then
		return minetest.log("info", "Could not load player homes file: " .. err)
	end

	-- Iterate over all stored positions in the format "x y z player" each line
	for pos, name in input:read("*a"):gmatch("(%S+ %S+ %S+)%s([%w_-]+)[\r\n]") do
		homepos[name] = minetest.string_to_pos(pos)
	end
	input:close()
end

loadhomes()

sethome.set = function(name, pos)
	local player = minetest.get_player_by_name(name)
	if not player or not pos then
		return false
	end

	local data = {}
	local output, err = io.open(homes_file, "w")
	if output then
		homepos[name] = pos
		for i, v in pairs(homepos) do
			table.insert(data, string.format("%.1f %.1f %.1f %s\n", v.x, v.y, v.z, i))
		end
		output:write(table.concat(data))
		io.close(output)
		return true
	end
	minetest.log("action", "Unable to write to player homes file: " .. err)
	return false
end

sethome.get = function(name)
	return homepos[name]
end

sethome.go = function(name)
	local player = minetest.get_player_by_name(name)
	if player and homepos[name] then
		player:setpos(homepos[name])
		return true
	end
	return false
end

minetest.register_privilege("home", "Can use /sethome and /home")

minetest.register_chatcommand("home", {
	description = "Teleport you to your home point",
	privs = {home = true},
	func = function(name)
		if sethome.go(name) then
			return true, "Teleported to home!"
		end
		return false, "Set a home using /sethome"
	end,
})

minetest.register_chatcommand("sethome", {
	description = "Set your home point",
	privs = {home = true},
	func = function(name)
		name = name or "" -- fallback to blank name if nil
		local player = minetest.get_player_by_name(name)
		if player and sethome.set(name, player:getpos()) then
			return true, "Home set!"
		end
		return false, "Player not found!"
	end,
})

minetest.register_chatcommand("home set", {
	description = "Set your home point",
	privs = {home = true},
	func = function(name)
		name = name or "" -- fallback to blank name if nil
		local player = minetest.get_player_by_name(name)
		if player and sethome.set(name, player:getpos()) then
			return true, "Home set!"
		end
		return false, "Player not found!"
	end,
})