-- Edit this flag to enable / disable debug
local isDebug = false;
local FretId = "76561197969449114";

-- Instantiate the class
if Debug == nil then
	Debug = {};
end

-- Edit this return to enable / disable debug
function Debug:IsDebug()
	return isDebug;
end

-- Is this player Fret?
function Debug:IsFret(id)
	if (tostring(id) == FretId) then
		return true;
	else
		return false;
	end
end

function Debug:IsPlayerIDFret(playerID)
	return Debug:IsFret(PlayerResource:GetSteamID(playerID))
end

-- shorthand for debug printing
function Debug:Print(msg, header)
	if header ~= nil then
		if isDebug then print(header) end
	end
	if type(msg) == 'table' then
		if isDebug then DeepPrintTable(msg) end
	else
		if isDebug then print(msg) end
	end
end

-- shorthand for debug table printing
function Debug:DeepPrint(o, title)
	if isDebug then DeepPrintTable(o) end
end

-- Kills a random bot
function Debug:KillBot(index)
	-- Kill a specific bot (by position)
	if index ~= nil then
		-- check by index
		if Bots[index] ~= nil then 
			if Bots[index]:IsAlive() then 
				Bots[index]:ForceKill(true)
			end
		-- Check by name
		else	 
			for _, bot in pairs(Bots) do
				if bot:IsAlive() and string.lower(bot.stats.name) == string.lower(index) then 
					bot:ForceKill(true)
					break
				end			
			end
		end
  -- otherwise kill one at random
	else
		local numBots = 0
		local aliveBots = {}
		for _, bot in pairs(Bots) do
			if bot:IsAlive() then 
				numBots = numBots + 1
				table.insert(aliveBots,bot)
			end
		end
		if numBots > 0 then
			aliveBots[math.random(numBots)]:ForceKill(true)
		end		
	end
end