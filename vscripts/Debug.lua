-- Edit this flag to enable / disable debug
local isDebug = true;
local FretId = "76561197969449114";

-- Instantiate the class
if Debug == nil then
	Debug = class({});
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

-- shorthand for debug printing
function Debug:Print(msg)
	if isDebug then print(msg) end
end

-- shorthand for debug table printing
function Debug:DeepPrint(o, title)
	if isDebug then DeepPrintTable(o) end
end
