-- code for computercraft computer checks whether a coal block has been removed from certain locations and
-- after a certain time has passed, if the location is empty respawns the coal block

coal_locations = {
	[0] = {-20,4,-30},
	[1] = {-20,5,-30}
}

timers = {
	[0] = 0,
	[1] = 0
}

air  = "minecraft:air"
coal = "minecraft:coal_ore"

coalRespawnTime = 5 -- in seconds

-- checks if block_name is in pos
function check( pos, block_name )
	return commands.getBlockInfo( pos[1], pos[2], pos[3] ).name == block_name
end

function put_block(pos, block_name)
	txt = string.format("setblock %d %d %d %s", pos[1], pos[2], pos[3], block_name)
	--print(txt)
	commands.exec(txt)
end

while true do
	for i=0,1 do
		-- if no coal and timer not started, start timer
		if not check(coal_locations[i], coal) and timers[i] == 0 then
			timers[i] = os.clock() + coalRespawnTime
		end
		-- if timer ended and location empty, put coal and reset timer
		if timers[i] ~= 0 and os.clock() > timers[i] and check(coal_locations[i], air) then
			put_block(coal_locations[i], coal)
			timers[i] = 0
		end
	end
end
