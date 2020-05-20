-- Dependencies
 -- global debug flag
require "Debug"
 -- Other Flags
require "Flags"

-- local debug flag
local thisDebug = false; 
local isDebug = Debug.IsDebug() and thisDebug;

-- Instantiate ourself
if ItemSettings == nil then
  ItemSettings = {}
end

-- Helper function for setting neutral item settings
function ItemSettings:Apply(n, tier, position, name)
	local index = 0
	for i,_ in pairs(n.tiers[tier][position]) do
	  index = index + 1
	end
	print('Num Items: '..tostring(index))
	n.tiers[tier][position][index] = name
end

-- Helper function for setting neutral item settings
function ItemSettings:ApplyTable(n, tier, position, itemTable)
	local index = 0
	for i,_ in pairs(n.tiers[tier][position]) do
	  index = index + 1
	end
	for _,name in pairs(itemTable) do		
	  n.tiers[tier][position][index] = name
	end
end

-- Helper function to instantiate neutral item settings
function ItemSettings:GetNeutralItemSettings(timetier1, timetier2, timetier3, timetier4, timetier5)
	-- Neutral Items
	local neutrals = 
	{
		-- Constants for timing - time in seconds
		awardTier1 = timetier1,
		awardTier2 = timetier2,
		awardTier3 = timetier3,
		awardTier4 = timetier4,
		awardTier5 = timetier5,
		tiers = {}
	}
	-- tiers array
  local tiers = {}
  -- create position arrays
  for i = 1,5 do
  	tiers[i] = {}
  	-- create item arrays
  	for j = 1,5 do
  		tiers[i][j] = {}
  	end 	
  end	              
  neutrals.tiers = tiers
  
  if isDebug then 
  	print("Neutrals Table:")
  	DeepPrintTable(neutrals)
  end
	return neutrals
end
