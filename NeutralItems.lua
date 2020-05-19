-- Dependencies
 -- global debug flag
require 'Debug'
 -- Other Flags
require 'Flags'
 -- DataTables has helper functions for generating data structures we consume, and querying/acting on that data
require 'DataTables'
-- Award methods
require 'AwardBonus'
-- Settings (for neutral table)
require 'Settings'

-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;

-- Instantiate ourself
if NeutralItems == nil then
  NeutralItems = {}
end

-- Returns valid items for a given tier and role
function NeutralItems:GetTableForTierAndRole(tier,role)
	local items = {}
	local count = 0
	for _,item in ipairs(allNeutrals) do
	  if item.tier == tier and item.roles[role] ~= 0 then
	  	table.insert(items,item)
	  	count = count + 1
	  end
	end
	return items, count
end

-- selects a random item from the list (by tier and role) and returns the internal item name
function NeutralItems:SelectRandom(tier, role)
	-- Get items that qualify
	local items,count = NeutralItems:GetTableForTierAndRole(tier,role)
	-- pick one at random
	local item = items[math.random(count)]
	-- print selection for debug
	if isDebug and item ~= nil then
		print('Random item selected: ' .. item.name)
	end
	-- if there was a valid item, remove it from the table (if settings tell us to)
	if item ~= nil and Settings.neutralItems.isRemoveUsedItems then
		-- note that this loop only works because we only want to remove one item
		for i,_ in ipairs(allNeutrals) do
			if item == allNeutrals[i] then
		  	table.remove(allNeutrals,i)
			end
		end
  end
  -- return the selected item
  if item ~= nil then
	  return item.name
	else
		return nil
	end
end

-- Gives a random neutral item to a unit
function NeutralItems:GiveRandom(unit, tier, role)
	-- check if the bot already has an item from this tier (or higher)
	if unit.stats.neutralTier >= tier then 
		if isDebug then
			print('Bot has an item from tier '..unit.stats.neutralTier..'. This is equal to or better than '..tier)
			return
		end
	end
	-- check if the unit is at or above the award limit
	if unit.stats.awards.neutral >= Settings.cap.neutral then
		if isDebug then
			print('Bot is at the award limit of '..unit.stats.awards.neutral)
		  return 
	  end
	end
	-- select a new item from the list
	local item = NeutralItems:SelectRandom(tier, role)	
	-- award the new item if one was available
	if item ~= nil then
  -- determine if the unit already has one (neutrals always in slot 16)
	local currentItem = unit:GetItemInSlot(16)
	-- remove if so
	if currentItem ~= nil then
		unit:RemoveItem(currentItem)
	end
	AwardBonus:NeutralItem(unit, item, tier)
	end
end

function NeutralItems:GiveTierToBots(tier)
	local awards = 0
	-- sanity check
  if Bots == nil then return end
	for _, bot in pairs(Bots) do
		if bot ~= nil then
			if awards < Settings.neutralItems.maxPerTier then 
				if isDebug then
					print('Giving tier '..tostring(tier)..', Role '..tostring(bot.stats.role) ..' item to '..bot:GetName())
				end
			  NeutralItems:GiveRandom(bot, tier, bot.stats.role)
			  awards = awards + 1
			end
		end
	end
end

