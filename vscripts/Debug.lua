-- Edit this flag to enable / disable debug
local isDebug = true;
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
function Debug:KillBot()
	for _, bot in pairs(Bots) do
		if bot:IsAlive() then 
			bot:ForceKill(true)
			break
		end
	end
end