-- Methods for the creation / removal of neutral items for the bots.

 -- global debug flag
require 'Debug'
-- Settings 
require 'Settings'
-- Utilities
require 'Utilities'
-- Flags for tracking status
require 'Flags'

-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;
local isDebugChat = isDebug and true

-- Instantiate ourself
if NeutralItems == nil then
  NeutralItems = {}
end

-- Gives a neutral item to a unit, returns name of previous item
-- if there was one.
function NeutralItems:GiveToUnit(unit, item)
	if item ~= nil then
		local replacedItem
	  -- determine if the unit already has one (neutrals always in slot 16)
		local currentItem = unit:GetItemInSlot(16)
		-- remove if so
		if currentItem ~= nil then
			isReplaced = true
			replacedItem = currentItem:GetName()
			Debug:Print(unit.stats.name..': Replacing: '..replacedItem)
			unit:RemoveItem(currentItem)
		end
		NeutralItems:CreateAndInsert(unit, item.name, item.tier)
		return replacedItem	
	end
	return nil
end

-- Creates a specific item, inserts it into the bot
function NeutralItems:CreateAndInsert(bot, itemName, tier)
  if bot:HasRoomForItem(itemName, true, true) then
  	local item = CreateItem(itemName, bot, bot)
    item:SetPurchaseTime(0)
    bot:AddItem(item)
    bot.stats.neutralTier = tier
    -- Special handling if it's royal jelly	
    if itemName == "item_royal_jelly" then		
    	Say(bot:GetPlayerOwner(), "Spending royal jelly charge on self.", false)		
    	bot:CastAbilityOnTarget(bot, item, bot:GetPlayerOwnerID())		
    	for _, unit in pairs(Bots) do			
    		if unit.stats.isBot and unit.stats.team == bot.stats.team and unit.stats.name ~= bot.stats.name then	
    			Say(bot:GetPlayerOwner(), "Spending royal jelly charge on "..unit.stats.name..'.', false)				
    			bot:CastAbilityOnTarget(unit, item, bot:GetPlayerOwnerID())				
    			break			
    		end		
    	end	
    -- Since jelly was consumed, set hero to not have an item
    NeutralItems:ClearBotItem(bot)
    end
    return true
  end
  return false
end

-- Updates a bot's stats so it knows it doesn't have an item
function NeutralItems:ClearBotItem(bot)
		bot.stats.neutralTier = 0
    bot.stats.assignedNeutral = nil
end

-- Returns valid items for a given tier and role
function NeutralItems:GetTableForTierAndRole(tier,unit)
	local items = {}
	local count = 0
	for _,item in ipairs(AllNeutrals) do
		-- Melee / Ranged
		if item.ranged > 0 and not unit.stats.isMelee then
		  if item.tier == tier and item.roles[unit.stats.role] ~= 0 then
		  	table.insert(items,item)
		  	count = count + 1
		  end
		elseif item.melee > 0 and unit.stats.isMelee then
		  if item.tier == tier and item.roles[unit.stats.role] ~= 0 then
		  	table.insert(items,item)
		  	count = count + 1
		  end
		end
	end		
  return items, count
end

-- Returns valid items for a given tier
function NeutralItems:GetTableForTier(tier)
	local items = {}
	local count = 0
	for _,item in ipairs(AllNeutrals) do
	  if item.tier == tier then
	  	table.insert(items,item)
	  	count = count + 1
	  end
	end		
  return items, count
end

-- selects a random item from the list (by tier and role) and returns the item
function NeutralItems:SelectRandomItem(tier, unit)
	-- Get items that qualify
	-- if they didn't pass a unit, go full random
	local items,count
	if unit == nil then
		items,count = NeutralItems:GetTableForTier(tier)
  else
		items,count = NeutralItems:GetTableForTierAndRole(tier,unit)
	end
	if items == nil then return nil end
	-- pick one at random
	local item = items[math.random(count)]
	-- if there was a valid item, remove it from the table (if settings tell us to)
	if item ~= nil and Settings.neutralItems.isRemoveUsedItems then
		-- note that this loop only works because we only want to remove one item
		for i,_ in ipairs(AllNeutrals) do
			if item == AllNeutrals[i] then
		  	table.remove(AllNeutrals,i)
		  	break
			end
		end
  end
  -- return the selected item
  if item ~= nil then
	  return item
	else
		return nil
	end
end

-- returns the pretty item name for a neutral
function NeutralItems:GetLocalizedItemName(dataTable, itemName)
	for _,item in ipairs(dataTable) do
		if item.name == itemName then
			return item.realName
		end
	end
end

-- Returns the bot that wants a new item the most
function NeutralItems:GetNeediestBot(tier)
	local data = {}
  -- ipairs sorts bots by role 1-5
  for i, bot in ipairs(Bots) do
  	local isUpgrade = tier > bot.stats.neutralTier
  	local isSidegrade = (tier == bot.stats.neutralTier) and (not bot.stats.hasSuitableNeutral)
  	-- for our bots, cores are assholes and always want a new item 
  	-- until they get one they like	
  	if i <= 3 and isUpgrade or isSidegrade then
  		return bot
  	-- For 4/5, try to prefer pure upgrades
  	elseif i > 3 and isUpgrade then
  		return bot
  	end
  end
  -- if we made it this far, 
  -- No one found
  return nil
end

-- Returns the 'goodness' of an item for a bot, higher is better
function NeutralItems:GetBotDesireForItem(bot, item)
  local attackTypeScore = 0
  -- Bots are never willing to take an item of the wrong attack type
  if not bot.stats.isMelee then
  	attackTypeScore = item.ranged
  elseif bot.stats.isMelee then
  	attackTypeScore = item.melee
  end
	if attackTypeScore <= 0 then return 0 end
  -- Get validity from role
  local roleScore = item.roles[bot.stats.role]
  -- ##TODO: Make this less arbitrary
  -- for now we'll just say each tier is worth 10 points
  local tierScore = item.tier * 10
  return attackTypeScore + roleScore + tierScore
end

-- Returns  true if the bot would prefer a specific item 
-- over what it has
function NeutralItems:DoesBotPreferItem(bot, item)
	local currentItemDesire
	if bot.stats.assignedNeutral ~= nil then
  	currentItemDesire = NeutralItems:GetBotDesireForItem(bot, bot.stats.assignedNeutral)
  else
  	currentItemDesire = 0
  end
  local newItemDesire = NeutralItems:GetBotDesireForItem(bot, item)
  return newItemDesire > currentItemDesire, newItemDesire, currentItemDesire
end

-- ensures that all bots are set to find the proper tier when one
-- has had all of its items found
-- Yes, there's probably an edge case bug where a bot is somehow
-- two tiers behind.  
-- This method preserves the previous tier's variance and neutral 
-- award subtractions.
function NeutralItems:CloseBotFindTier(tier)
	for _, bot in ipairs(Bots) do
		-- if this is the case, the bot is behind and needs to be updated to new tier.
	  if bot.stats.neutralsFound < tier then
	  	NeutralItems:SetBotFindTier(bot, tier + 1)
	  end
	end
end

-- Sets all bots to find tier 1 items.
function NeutralItems:InitializeFindTimings()
	for _, bot in ipairs(Bots) do
  	bot.stats.neutralsFound = 0
  	bot.stats.neutralTiming = Settings.neutralItems.timings[1] + 
															Utilities:GetIntegerVariance(Settings.neutralItems.variance)
		Debug:Print(bot.stats.name..': Neutral Timing for Tier 1: '..bot.stats.neutralTiming)														
	end
end

-- sets a particular bot for a timing to find a specific tier
function NeutralItems:SetBotFindTier(bot, tier)
	-- Is this a valid tier tier?
	local nextTiming = Settings.neutralItems.timings[tier]
	if nextTiming ~= nil then
		local previousTiming
		-- this should normally be the case
		if Settings.neutralItems.timings[tier - 1] ~= nil then
			previousTiming = Settings.neutralItems.timings[tier - 1]
		else
			previousTiming = 0
		end		
		-- normal case: bot has found an item one tier below what we're setting it to
		-- meaning we called this function immediately after finding it.  Get new
		-- variance, don't preserve neutral awards (might change that via setting someday)
		if bot.stats.neutralsFound == tier - 1 then		
			bot.stats.neutralTiming = Settings.neutralItems.timings[tier] + 
															  Utilities:GetIntegerVariance(Settings.neutralItems.variance)
	  -- if we're further behind, the bot never found an item.  We want to preserve
	  -- the existing randomness for the timing (including neutral awards), so we just 
	  -- add the difference
	  else
	  	bot.stats.neutralTiming = bot.stats.neutralTiming + nextTiming - previousTiming
	  	-- flag them as having found the proper tier of item
			bot.stats.neutralsFound = tier - 1
		end
		-- Sanity check
		if bot.stats.neutralTiming < 0 then bot.stats.neutralTiming = 0 end
	-- no next timing: disable the timer.
	else
		bot.stats.neutralTiming = -1
	end
	Debug:Print(bot.stats.name..': Neutral Timing for Tier '..tier..': '..bot.stats.neutralTiming)													
end