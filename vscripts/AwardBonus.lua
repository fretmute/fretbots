-- Helpers to add bonuses to bots

-- Dependencies
require 'Settings'
require 'DataTables'
require 'Debug'
require 'Flags'

-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;


-- Instantiate ourself
if AwardBonus == nil then
	AwardBonus = {}
end

-- constants for levelling
local xpPerLevel =
{
	0,		
	230, 	
	600, 	
	1080, 	
	1660, 	
	2260, 	
	2980, 	
	3730, 	
	4620, 	
	5550, 	
	6520, 	
	7530, 	
	8580, 	
	9805, 	
	11055, 
	12330, 
	13630, 
	14955, 
	16455, 
	18045, 
	19645, 
	21495, 
	23595, 
	25945, 
	28545, 
	32045,
	36545, 
	42045,
	48545, 
	56045 
}

-- Gold
function AwardBonus:gold(bot, bonus)
	if bot.stats.awards.gold < Settings.awardCap.gold then
	  PlayerResource:ModifyGold(bot.stats.id, bonus, false, 0)
	  bot.stats.awards.gold = bot.stats.awards.gold + bonus
	  return true  
	end
	return false
end

-- All stats 
function AwardBonus:stats(bot, bonus)
	if bot.stats.awards.stats < Settings.awardCap.stats then
		local stat
	  stat = bot:GetBaseStrength()
	  bot:SetBaseStrength(stat + bonus)
	  stat = bot:GetBaseAgility()
	  bot:SetBaseAgility(stat + bonus)
	  stat = bot:GetBaseIntellect()
	  bot:SetBaseIntellect(stat + bonus)
	  bot.stats.awards.stats = bot.stats.awards.stats + bonus
	  return true
	end
	return false
end

--Armor
function AwardBonus:armor(bot, bonus)
	if bot.stats.awards.armor < Settings.awardCap.armor then
		local armor
		local base
		armor = bot:GetPhysicalArmorBaseValue()
	 	base = bot:GetAgility() * 0.16
	 	bot:SetPhysicalArmorBaseValue(armor - base + bonus)
	 	bot.stats.awards.armor = bot.stats.awards.armor + bonus
	 	return true
	end
	return false
end

-- Magic Resist
function AwardBonus:magicResist(bot, bonus)	
	if bot.stats.awards.magicResist < Settings.awardCap.magicResist then
	  local resistance
	  resistance = bot:GetBaseMagicalResistanceValue()
	  bot:SetBaseMagicalResistanceValue(resistance + bonus)
	  bot.stats.awards.magicResist = bot.stats.awards.magicResist + bonus
	  return true
	end
	return false
end

-- Levels
function AwardBonus:levels(bot, levels)		
	if bot.stats.awards.levels < Settings.awardCap.levels then
	  -- get current level and XP
	  local currentLevel = PlayerResource:GetLevel(bot.stats.id)
	  local currentXP = bot:GetCurrentXP()
	  -- get target XP
	  local targetXP = xpPerLevel[currentLevel + levels]
	  -- award the difference
	  bot:AddExperience(targetXP - currentXP, 0, false, true)
	  bot.stats.awards.levels = bot.stats.awards.levels + levels
	  return true
	end
	return false
end

-- XP
function AwardBonus:Experience(bot, bonus)
  bot:AddExperience(bonus, 0, false, true)
end

-- neutral
function AwardBonus:neutral(bot, bonus)
  local tier = bot.stats.neutralTier + bonus
  local isSuccess 
  local itemName
  isSuccess, itemName = AwardBonus:RandomNeutralItem(bot, tier)
  return isSuccess, itemName
end

-- Gives a random neutral item to a unit
function AwardBonus:RandomNeutralItem(unit, tier)
	local role = unit.stats.role
	-- check if the bot already has an item from this tier (or higher)
	if unit.stats.neutralTier >= tier then 
		if isDebug then
			print('Bot has an item from tier '..unit.stats.neutralTier..'. This is equal to or better than '..tier)
			return false
		end
	end
	-- check if the unit is at or above the award limit
	if unit.stats.awards.neutral >= Settings.awardCap.neutral then
		if isDebug then
			print('Bot is at the award limit of '..unit.stats.awards.neutral)
		  return false
	  end
	end
	-- select a new item from the list
	local item, realName = AwardBonus:SelectRandomNeutralItem(tier, unit)	
	-- award the new item if one was available
	if item ~= nil then
	  -- determine if the unit already has one (neutrals always in slot 16)
		local currentItem = unit:GetItemInSlot(16)
		-- remove if so
		if currentItem ~= nil then
			unit:RemoveItem(currentItem)
		end
		AwardBonus:NeutralItem(unit, item, tier)
		return true, realName
	end
	return false
end

-- Give someone a specific neutral item
function AwardBonus:NeutralItem(bot, itemName, tier)
	-- check if the bot already has an item from this tier (or higher)
	if bot.stats.neutralTier >= tier then 
		if isDebug then
			print('Bot has an item from tier '..bot.stats.neutralTier..'. This is equal to or better than '..tier)
			return false
		end
	end
	-- check if the unit is at or above the award limit
	if bot.stats.awards.neutral >= Settings.awardCap.neutral then
		if isDebug then
			print('Bot is at the award limit of '..bot.stats.awards.neutral)
		  return false
	  end
	end	
  if bot:HasRoomForItem(itemName, true, true) then
  	local item = CreateItem(itemName, bot, bot)
    item:SetPurchaseTime(0)
    bot:AddItem(item)
    bot.stats.neutralTier = tier
    bot.stats.awards.neutral = bot.stats.awards.neutral + 1
    return true
  end
  return false
end

-- Returns valid items for a given tier and role
function AwardBonus:GetNeutralTableForTierAndRole(tier,unit)
	local items = {}
	local count = 0
	for _,item in ipairs(allNeutrals) do
		-- Melee / Ranged
		if item.ranged and not unit.stats.isMelee then
		  if item.tier == tier and item.roles[unit.stats.role] ~= 0 then
		  	table.insert(items,item)
		  	count = count + 1
		  end
		elseif item.melee and unit.stats.isMelee then
		  if item.tier == tier and item.roles[unit.stats.role] ~= 0 then
		  	table.insert(items,item)
		  	count = count + 1
		  end
		end
	end		
  return items, count
end

-- selects a random item from the list (by tier and role) and returns the internal item name
function AwardBonus:SelectRandomNeutralItem(tier, unit)
	-- Get items that qualify
	local items,count = AwardBonus:GetNeutralTableForTierAndRole(tier,unit)
	if items == nil then return nil end
	-- pick one at random
	local item = items[math.random(count)]
	-- print selection for debug
	if isDebug and item ~= nil then
		print('Valid Neutral Items, Tier '..tier..':')
		for _, it in pairs(items) do
			print('  '..it.name)
		end
		print('Random item selected: ' .. item.name)
	end
	-- if there was a valid item, remove it from the table (if settings tell us to)
	if item ~= nil and Settings.neutralItems.isRemoveUsedItems then
		-- note that this loop only works because we only want to remove one item
		for i,_ in ipairs(allNeutrals) do
			if item == allNeutrals[i] then
		  	table.remove(allNeutrals,i)
		  	break
			end
		end
  end
  -- return the selected item
  if item ~= nil then
	  return item.name, item.realName
	else
		return nil
	end
end

-- Attempts to give all of the bots an item from the given tier
function AwardBonus:GiveTierToBots(tier)
	local awards = 0
	-- sanity check
  if Bots == nil then return end
	for _, bot in pairs(Bots) do
		if bot ~= nil then
			if awards < Settings.neutralItems.maxPerTier then 
				if isDebug then
					print('Giving tier '..tostring(tier)..', Role '..tostring(bot.stats.role) ..' item to '..bot:GetName())
				end
			  AwardBonus:RandomNeutralItem(bot, tier, bot.stats.role)
			  awards = awards + 1
			end
		end
	end
end

-- Gives the bot his death awrds, if there are any
function AwardBonus:Death(bot)
	local awardsTable = {}
	table.insert(awardsTable, bot)
	-- Drop out for edge cases (LD bear, AW clone)
	if not DataTables:IsRealHero(bot) then
		Debug:Print(bot:GetName()..' is not a real hero unit.  No Death Award given.')
		return
	end	
	-- to be printed to players
	local msg = bot.stats.name .. ' Death Bonus Awarded:'
	local isAwarded = false
	local isLoudWarning = false
	-- accrue chances
	AwardBonus:AccruetDeathBonusChances(bot)
	-- track awards
	local awards = 0
	-- loop over bonuses in order
	for _, award in pairs(Settings.deathBonus.order) do
		-- this event gets fired for humans to, so drop out here if we don't want to give rewards to humans
		if not bot.stats.isBot and Settings.deathBonus.isBotsOnly[award] then
			if isDebug then 
				print(bot.stats.name..' is a player and does not get death bonuses for '..award..'.') 
				return
			end
		end		
		-- check if enabled
		if Settings.deathBonus.enabled[award] then
			local isAward = AwardBonus:ShouldAward(bot,award)
			-- increment awards if awarded
			if isAward then 
			  awards = awards + 1
			end
			-- if this award is greater than max, then break
			if awards > Settings.deathBonus.maxAwards then
				if isDebug then print('Max awards of '..Settings.deathBonus.maxAwards..' reached.') end
				break 
			end			
			-- make the award
			if isAward then
				local value = 0
				local isLoud = false
				local isSuccess
				local name
				-- Get value
				value, isLoud  = AwardBonus:GetValue(bot, award)			
        -- Attempt to assign the award
        isSuccess, name = AwardBonus[award](AwardBonus, bot, value)
        -- if success, set isAwarded, isLoudWarning, Clear chance, Update message
        if isSuccess then
        	if name == nil then
        	  table.insert(awardsTable, {award, value})
        	else
        		table.insert(awardsTable, {award, name})
        	end
        	isAwarded = true
					isLoudWarning = (isLoud or isLoudWarning) 
					if name == nil then
					  msg = msg .. ' '..award..': '..value
					else
						-- special case for neutrals, they return the name of the neutral
						msg = msg .. ' '..award..': '..name
					end
					if isDebug then
						print('Awarded '..award..': '..value)
					end
					-- Clear the chance for this award (if accrued)
					if Settings.deathBonus.accrue[award] then
						bot.stats.chance[award] = 0
					end
				end
			end
		end
	end
	if Settings.deathBonus.announce then
		if isAwarded and not isLoudWarning then
			Utilities:Print(awardsTable, MSG_AWARD, ATTENTION)
			--Utilities:Print(msg, MSG_WARNING, ATTENTION)
		elseif isAwarded and isLoudWarning then
			Utilities:Print(awardsTable, MSG_AWARD, BAD_LIST)
		 --Utilities:Print(msg, MSG_BAD, BAD_LIST)
		end
	end
end

-- Increments the chance of all accruing bonus awards
function AwardBonus:AccruetDeathBonusChances(bot)
	for _, award in pairs(Settings.deathBonus.order) do
		if bot.stats.chance[award] ~= nil and Settings.deathBonus.chance[award] ~= nil then
			if Settings.deathBonus.accrue[award] then
				bot.stats.chance[award] = bot.stats.chance[award] + Settings.deathBonus.chance[award]
			end
		end
	end
end

-- Returns a numerical value to award
function AwardBonus:GetValue(bot, award)
	local isLoud = false
	local dotaTime
  -- base bonus is always the same
	local base = math.random(Settings.deathBonus.range[award][1], Settings.deathBonus.range[award][2])
	-- if range scaling is enabled, then scale
	if Settings.deathBonus.isRangeTimeScaleEnable then	
  	base = base * Utilities:GetTime() / Settings.deathBonus.rangeTimeScale[award]
	end	
	--scale base by skill and variance
	local scaled = base * bot.stats.skill * Utilities:GetVariance(Settings.deathBonus.variance[award])
	-- scale by role if enabled
	if Settings.deathBonus.scaleEnabled[award] then
		scaled = scaled * Settings.deathBonus.scale[award][bot.stats.role]
		--Debug:Print(award..': Scaling by Role '..bot.stats.role..': Scale: '..Settings.deathBonus.scale[award][bot.stats.role])
	end
	-- Round and maybe clamp
	local clamped = 0
	if Settings.deathBonus.clampOverride[award] then
		clamped = Utilities.Round(scaled)
	else
		-- base clamp
		local upperClamp = Settings.deathBonus.clamp[award][2]
		-- Perhaps scale upper clamp, if enabled
		if Settings.deathBonus.isClampTimeScaleEnable then 
			dotaTime =  Utilities:GetTime()
		  upperClamp = upperClamp * Utilities:GetTime() / Settings.deathBonus.clampTimeScale[award]	
		end
		clamped = Utilities:RoundedClamp(scaled, Settings.deathBonus.clamp[award][1], upperClamp)
	end
	-- set isLoud
	isLoud = (Settings.deathBonus.isClampLoud[award] and clamped == Settings.deathBonus.clamp[award][2])
	         or
	         Settings.deathBonus.isLoud[award]
	if isDebug then print(award..': Base Award: '..base..' Scaled: '..scaled..' Clamped: '..clamped) end
	if isDebug then 
		--print(award..': Is Clamp Loud: '..tostring(Settings.deathBonus.isClampLoud[award])..
		--                           ' isLoud: '..tostring(Settings.deathBonus.isLoud[award])) 
  end
	return clamped, isLoud
end

-- Determines if an award should be given
function AwardBonus:ShouldAward(bot,award)
	-- trivial case
	if bot.stats.chance[award] >= 1 then 
		if isDebug then print(bot.stats.name..': Chance for '..award..' was 1 or greater.') end
		return true 
	end
	-- alsmost as trivial case: check if deathStreakThreshold is enabled
	if Settings.deathBonus.deathStreakThreshold >= 0 then
		if bot.stats.deathStreak >= Settings.deathBonus.deathStreakThreshold then
			if isDebug then print(bot.stats.name..': automatic '..award..' bonus due to death streak of '..bot.stats.deathStreak..'.') end
			return true
		end
	end
	-- otherwise roll for it
	local roll = math.random()
	local isAward = roll < bot.stats.chance[award]
	--Debug:Print('Death Award: '..award..': roll: '..roll..' chance: '..bot.stats.chance[award])
	return isAward
end


-- Returns the bonus gold to award to the bot this interval to achieve target GPM
function AwardBonus:GetGPMBonus(bot)
	if isDebug then print('Bot GPM Bonus: '..bot.stats.name) end
  local botGPM = PlayerResource:GetGoldPerMin(bot.stats.id)
  local targetGPM = 0
  local playerGPM, playerName = DataTables:GetRoleGPM(bot)
  -- the above will return zero if the is no counterpart, if that is the case return
  if playerGPM ==0 then
  	if isDebug then print('No player for this bot.') end
  	return 0 
  end
  -- add offset to the target
  targetGPM = targetGPM + playerGPM + Settings.gpm.offset
  -- Get individual multipliers
  local skill = bot.stats.skill
  local scale = Settings.gpm.scale[bot.stats.role]
  local variance = Utilities:GetVariance(Settings.gpm.variance)
  -- Get total multiplier
  local multiplier = AwardBonus:GetPerMinuteMultiplier(skill, scale, variance)
  if isDebug then
  	local msg = ' '
  	msg = msg..' skill: '..skill
  	msg = msg..' scale: '..scale
  	msg = msg..' variance: '..variance
  	msg = msg..' multiplier: '..multiplier
  	print(msg)
  end
  -- multiply
  targetGPM = targetGPM * multiplier
  -- if the bot is already better than this, do not give award
  if botGPM > targetGPM then 
  	-- These seem bug free, but too lazy to give them their own flag to disable
  	--if isDebug then print('Bot GPM too high for bonus: '..botGPM..' vs '..targetGPM..' Hero Base GPM: '..playerGPM..' Player Hero: '..playerName) end
  	return 0 
  end
  -- get GPM difference
  gpmDifference = targetGPM - botGPM
  -- clamp?
  local clampedGPM = 0
  if not Settings.gpm.clampOverride then
  	-- ##TODO: MAKE THIS A FUNCTION INSTEAD OF A HACK
  	-- Adjust clamp per mintue
  	local minutes =  Utilities:Round(Utilities:GetTime()/60)
  	local adjustedClamp = Settings.gpm.clamp[2]
  	if Settings.gpm.perMinuteScale ~= 0 then 
  		adjustedClamp = adjustedClamp + Settings.gpm.perMinuteScale * minutes
  		Debug:Print('minutes: '..minutes..' Clamp bonus: '.. Settings.gpm.perMinuteScale * minutes.. ' adjusted clamp: '..adjustedClamp)
  	end
  	clampedGPM = Utilities:RoundedClamp(gpmDifference, Settings.gpm.clamp[1], adjustedClamp)
  else
  	clampedGPM = Utilities:Round(gpmDifference)
  end
  -- Figure out how much gold this is to provide the bump
  local bonus = Utilities:Round(clampedGPM * (Utilities:GetTime() / 60))
  -- debug
  if isDebug then
  	local msg = ' '
  	msg = msg..' Bot: '..bot.stats.name
  	msg = msg..' Role: '..bot.stats.role
  	msg = msg..' Bot GPM: '..botGPM
  	msg = msg..' Player GPM: '..playerGPM
  	msg = msg..' Target GPM: '..targetGPM
  	msg = msg..' GPM Difference: '..gpmDifference
  	msg = msg..' Clamped GPM: '..clampedGPM
  	msg = msg..' Bonus Gold: '..bonus	
  	print(msg)
  end
  return bonus
end

-- Returns the bonus gold to award to the bot this interval to achieve target XPM
function AwardBonus:GetXPMBonus(bot)
	if isDebug then print('Bot XPM Bonus: '..bot.stats.name) end
  local botXPM = PlayerResource:GetXPPerMin(bot.stats.id)
  local targetXPM = 0
  local playerXPM, playerName = DataTables:GetRoleXPM(bot)
  -- the above will return zero if the is no counterpart, if that is the case return
  if playerXPM == 0 then
  	if isDebug then print('No player for this bot.') end
  	return 0  	   
  end
  -- add offset to the target
  targetXPM = targetXPM + playerXPM + Settings.xpm.offset
  -- Get individual multipliers
  local skill = bot.stats.skill
  local scale = Settings.xpm.scale[bot.stats.role]
  local variance = Utilities:GetVariance(Settings.xpm.variance)
  -- Get total multiplier
  local multiplier = AwardBonus:GetPerMinuteMultiplier(skill, scale, variance)
  if isDebug then
  	local msg = ' '
  	msg = msg..' skill: '..skill
  	msg = msg..' scale: '..scale
  	msg = msg..' variance: '..variance
  	msg = msg..' multiplier: '..multiplier
  	print(msg)
  end
  -- multiply
  targetXPM = targetXPM * multiplier
  -- if the bot is already better than this, do not give award
  if botXPM > targetXPM then 
  	if isDebug then print('Bot XPM too high for bonus: '..botXPM..' vs '..targetXPM..' Player Base XPM: '..playerXPM..' Player Hero: '..playerName) end
  	return 0 
  end
  -- get XPM difference
  xpmDifference = targetXPM - botXPM
  -- clamp?
  local clampedXPM = 0
  if not Settings.xpm.clampOverride then
  	-- ##TODO: MAKE THIS A FUNCTION INSTEAD OF A HACK
  	-- Adjust clamp per mintue
  	local minutes = Utilities:GetTime()/60
  	local adjustedClamp = Settings.xpm.clamp[2]
  	if Settings.xpm.perMinuteScale ~= 0 then 
  		adjustedClamp = adjustedClamp + Settings.xpm.perMinuteScale * minutes
  	end  	
  	clampedXPM = Utilities:RoundedClamp(xpmDifference, Settings.xpm.clamp[1], Settings.xpm.clamp[2])
  else
  	clampedXPM = Utilities:Round(xpmDifference)
  end
  -- Figure out how much gold this is to provide the bump
  local bonus = Utilities:Round(clampedXPM * (Utilities:GetTime() / 60))
  -- debug
  if isDebug then
  	local msg = ' '
  	msg = msg..' Bot: '..bot.stats.name
  	msg = msg..' Role: '..bot.stats.role
  	msg = msg..' Bot XPM: '..botXPM
  	msg = msg..' Player XPM: '..playerXPM
  	msg = msg..' Target XPM: '..targetXPM
  	msg = msg..' XPM Difference: '..xpmDifference
  	msg = msg..' Clamped XPM: '..clampedXPM
  	msg = msg..' Bonus XP: '..bonus	
  	print(msg)
  end
  return bonus
end


-- Returns total multiplier for the bonus
-- this is either strictly multiplicative, or additive
function AwardBonus:GetPerMinuteMultiplier(skill, scale, variance)
  if Settings.isMultiplicative then
    return skill * scale * variance
  else
  	return skill + scale + variance - 3
  end
end