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
	if bot.stats.awards.gold < Settings.awardCap.gold and bonus > 0 then
	  PlayerResource:ModifyGold(bot.stats.id, bonus, false, 0)
	  bot.stats.awards.gold = bot.stats.awards.gold + bonus
	  Debug:Print('Awarding gold to '..bot.stats.name..'.')
	  return true  
	end
	return false
end

-- All stats 
function AwardBonus:stats(bot, bonus)
	if bot.stats.awards.stats < Settings.awardCap.stats and bonus > 0 then
		local stat
	  stat = bot:GetBaseStrength()
	  bot:SetBaseStrength(stat + bonus)
	  stat = bot:GetBaseAgility()
	  bot:SetBaseAgility(stat + bonus)
	  stat = bot:GetBaseIntellect()
	  bot:SetBaseIntellect(stat + bonus)
	  bot.stats.awards.stats = bot.stats.awards.stats + bonus
	  Debug:Print('Awarding stats to '..bot.stats.name..'.')
	  return true
	end
	return false
end

--Armor
function AwardBonus:armor(bot, bonus)
	if bot.stats.awards.armor < Settings.awardCap.armor and bonus > 0 then
		local armor
		local base
		armor = bot:GetPhysicalArmorBaseValue()
	 	base = bot:GetAgility() * (1/6)
	 	bot:SetPhysicalArmorBaseValue(armor - base + bonus)
	 	bot.stats.awards.armor = bot.stats.awards.armor + bonus
	 	Debug:Print('Awarding armor to '..bot.stats.name..'.')
	 	return true
	end
	return false
end

-- Magic Resist
function AwardBonus:magicResist(bot, bonus)	
	if bot.stats.awards.magicResist < Settings.awardCap.magicResist and bonus > 0 then
	  local resistance
	  resistance = bot:GetBaseMagicalResistanceValue()
	  bot:SetBaseMagicalResistanceValue(resistance + bonus)
	  bot.stats.awards.magicResist = bot.stats.awards.magicResist + bonus
	  Debug:Print('Awarding magic resist to '..bot.stats.name..'.')
	  return true
	end
	return false
end

-- Levels
function AwardBonus:levels(bot, levels)	
	if bot.stats.awards.levels < Settings.awardCap.levels and levels > 0 then
	  -- get current level and XP
	  local currentLevel = PlayerResource:GetLevel(bot.stats.id)
	  -- if bot is level 30, exit
	  if currentLevel == 30 then 
	    Debug:Print(bot.stats.name..': Already level 30, cannot award levels.')
	  	return
	  end
	  local currentXP = bot:GetCurrentXP()
	  local currentLevelXP = xpPerLevel[currentLevel]
	  local targetLevel = math.ceil(levels)
	  -- Sanity check
	  local target = currentLevel + targetLevel
	  if target > 30 then target = 30 end
	  local targetLevelXP = xpPerLevel[target]
	  -- get the average amount of experience per level difference
	  local averageXP = (targetLevelXP - currentLevelXP) / targetLevel
	  -- award average XP per level times levels 
	  local awardXP = Utilities:Round(averageXP * levels)
	  bot:AddExperience(awardXP, 0, false, true)
	  bot.stats.awards.levels = bot.stats.awards.levels + levels
	  Debug:Print('Awarding levels  to '..bot.stats.name..'.')
	  return true
	end
	return false
end

-- neutral
function AwardBonus:neutral(bot, bonus)
	if bot.stats.awards.neutral < Settings.awardCap.neutral then
	  local tier = bot.stats.neutralTier + bonus
	  local isSuccess 
	  bot.stats.neutralTiming = bot.stats.neutralTiming - bonus
	  if bot.stats.neutralTiming < 0 then
	  	bot.stats.neutralTiming = 0
	  end
	  bot.stats.awards.neutral = bot.stats.awards.neutral + bonus
	  Debug:Print('Awarding neutral to '..bot.stats.name..'.')
	  return true, bonus
	else
		Debug:Print('Bot has reached the neutral award limit of '..Settings.awardCap.neutral)
		return false
	end
end

-- XP
function AwardBonus:Experience(bot, bonus)
	if bonus > 0 then 
  	bot:AddExperience(bonus, 0, false, true)
  	Debug:Print('Awarding experience to '..bot.stats.name..'.')
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
	for _, award in ipairs(Settings.deathBonus.order) do
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
						print(bot.stats.name..': Awarded '..award..': '..value)
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
	local debugTable = {}
	debugTable.award = award
  debugTable.range = {Settings.deathBonus.range[award][1], Settings.deathBonus.range[award][2]}
  -- base bonus is always the same
	local base = Utilities:RandomDecimal(Settings.deathBonus.range[award][1], Settings.deathBonus.range[award][2])
	debugTable.baseAward = base
	-- if range scaling is enabled, then scale
	if Settings.deathBonus.isRangeTimeScaleEnable then	
  	base = base * Utilities:GetTime() / Settings.deathBonus.rangeTimeScale[award]
  	debugTable.rangeScale = Settings.deathBonus.rangeTimeScale[award]
	end	
	--scale base by skill and variance
	local variance = Utilities:GetVariance(Settings.deathBonus.variance[award])
	local scaled = base * bot.stats.skill * variance
	debugTable.skill = bot.stats.skill
	debugTable.variance = variance
	-- scale by role if enabled
	if Settings.deathBonus.scaleEnabled[award] then
		debugTable.roleScale = Settings.deathBonus.scale[award][bot.stats.role]
		scaled = scaled * Settings.deathBonus.scale[award][bot.stats.role]
	end
	-- add offset
	scaled = scaled + Settings.deathBonus.offset[award]
	debugTable.scaled = scaled	
	-- Round and maybe clamp
	local clamped = 0
	if Settings.deathBonus.clampOverride[award] then
		clamped = Utilities:Round(scaled, Settings.deathBonus.round[award])
	else
		-- base clamp
		local upperClamp = Settings.deathBonus.clamp[award][2]
		-- Perhaps scale upper clamp, if enabled
		if Settings.deathBonus.isClampTimeScaleEnable then 
			dotaTime =  Utilities:GetTime()
		  upperClamp = upperClamp * Utilities:GetTime() / Settings.deathBonus.clampTimeScale[award]	
		end
		-- round clamp (adjustments are probably dumb decimals)
		upperClamp = Utilities:Round(upperClamp, Settings.deathBonus.round[award])
		debugTable.clamps = {Settings.deathBonus.clamp[award][1], upperClamp}
		local rounded = Utilities:Round(scaled, Settings.deathBonus.round[award])
		clamped = Utilities:Clamp(rounded, Settings.deathBonus.clamp[award][1], upperClamp)
	  debugTable.rounded = rounded
	end
	debugTable.clamped = clamped
	-- set isLoud
	isLoud = (Settings.deathBonus.isClampLoud[award] and clamped == Settings.deathBonus.clamp[award][2])
	         or
	         Settings.deathBonus.isLoud[award]
  --Debug:DeepPrint(debugTable)
	return clamped, isLoud
end

-- Determines if an award should be given
function AwardBonus:ShouldAward(bot,award)
	-- trivial case
	if bot.stats.chance[award] >= 1 then 
		if isDebug then print(bot.stats.name..': Chance for '..award..' was 1 or greater.') end
		return true 
	end
	-- check timeGate
	local gameTime = Utilities:GetTime()
	if gameTime < Settings.deathBonus.timeGate[award] then
		local msg = ''
		msg = msg..bot.stats.name..': '..award
		msg = msg..' bonus not given because the time gate has not been met: '
		msg = msg..gameTime..', '.. Settings.deathBonus.timeGate[award]	
		Debug:Print(msg)
		return false
	end
	-- almost as trivial case: check if deathStreakThreshold is enabled
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

-- Returns total multiplier for the bonus
-- this is either strictly multiplicative, or additive
function AwardBonus:GetPerMinuteMultiplier(skill, scale, variance)
  if Settings.isMultiplicative then
    return skill * scale * variance
  else
  	return skill + scale + variance - 3
  end
end

-- Returns amounts to award to achieve target GPM/XPM
function AwardBonus:GetPerMinuteBonus(bot, gpm, xpm)
	local botGPM = Utilities:Round(PlayerResource:GetGoldPerMin(bot.stats.id))
	local gpmBonus, debugTable = AwardBonus:GetSpecificPerMinuteBonus(bot, botGPM, gpm, Settings.gpm)
	local botXPM = Utilities:Round(PlayerResource:GetXPPerMin(bot.stats.id))
	local xpmBonus, debugTable = AwardBonus:GetSpecificPerMinuteBonus(bot, botXPM, xpm, Settings.xpm)
	return gpmBonus, xpmBonus
end

-- determines an amount to award to reach a specifc per minute amount
function AwardBonus:GetSpecificPerMinuteBonus(bot, pmBot, roleTable, settings)
	local debugTable = {}
	-- Ensure there is a target amount for this bot
	if roleTable[bot.stats.role] == nil then
  	return 0, 'No human counterpart for '..bot.stats.name..'.'
  end
  -- counterparts PM
  local pmPlayer = roleTable[bot.stats.role]
	-- add offset to get the target
  local pmTarget = pmPlayer + settings.offset
  -- Get individual multipliers
  local skill = bot.stats.skill
  local scale = settings.scale[bot.stats.role]
  local variance = Utilities:GetVariance(settings.variance)
  -- Get total multiplier
  local multiplier = AwardBonus:GetPerMinuteMultiplier(skill, scale, variance)
  -- multiply
  pmTarget = Utilities:Round(pmTarget * multiplier)
  -- if the bot is already better than this, do not give award
  if pmBot > pmTarget then 
  	return 0 , bot.stats.name..' is above the target PM: '..tostring(pmBot)..', '..tostring(pmTarget)
  end
  -- get PM difference
  local pmDifference = pmTarget - pmBot
  -- clamp?
  local pmClamped = 0
  if not settings.clampOverride then
  	-- Adjust clamp per mintue
  	local minutes =  Utilities:Round(Utilities:GetTime()/60)
  	local adjustedClamp = settings.clamp[2]
  	if settings.perMinuteScale ~= 0 then 
  		adjustedClamp = adjustedClamp + settings.perMinuteScale * minutes
  	end
  	pmClamped = Utilities:RoundedClamp(pmDifference, settings.clamp[1], adjustedClamp)
  else
  	pmClamped = Utilities:Round(pmDifference)
  end
  -- Figure out how much gold this is to provide the bump
  local bonus = Utilities:Round(pmClamped * (Utilities:GetTime() / 60))
  -- debug data
  debugTable.role = bot.stats.role
  debugTable.pmPlayer = pmPlayer
  debugTable.pmBot = pmBot
  debugTable.pmTarget = pmTarget
  debugTable.skill = skill
  debugTable.scale = scale
  debugTable.variance = variance
  debugTable.multiplier = multiplier
  debugTable.adjustedClamp = adjustedClamp
  debugTable.pmClamped = pmClamped
  debugTable.bonus = bonus
	return bonus, debugTable
end

-- Punishes humans for abusing bot AI to get kills before the horn around runes
function AwardBonus:PunishForAbuse()
	local state =  GameRules:State_Get()
	if state == DOTA_GAMERULES_STATE_PRE_GAME then
		local msg = 'Bot rune AI abuse is a bad idea!'
		Utilities:Print(msg, MSG_BAD, BAD_LIST)
		for _, bot in ipairs(Bots) do
			local awardsTable = {}
			table.insert(awardsTable, bot)
	    local isSuccess = AwardBonus['levels'](AwardBonus, bot, 17)
	    -- if success, set isAwarded, isLoudWarning, Clear chance, Update message
	    if isSuccess then
	    	table.insert(awardsTable, {'levels', 17})
	    end
	    local isSuccess = AwardBonus['stats'](AwardBonus, bot, 25)
	    -- if success, set isAwarded, isLoudWarning, Clear chance, Update message
	    if isSuccess then
	    	table.insert(awardsTable, {'stats', 25})
	    end	 
	    Utilities:Print(awardsTable, MSG_AWARD, BAD_LIST)   
		end
	end
end