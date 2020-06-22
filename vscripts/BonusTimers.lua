-- Registers a timer function that's used to do things at certain points during the game

-- This registers the Timer helpers
require 'Timers'
 -- global debug flag
require 'Debug'
-- DataTables and associated globals
require 'DataTables'
-- Settings 
require 'Settings'
-- Utilities
require 'Utilities'
-- Award functions
require 'AwardBonus'
-- Flags for tracking status
require 'Flags'

-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;
local isDebugChat = isDebug and true

-- announce bonuses to chat?
local isChat = true;

-- Instantiate ourself
if BonusTimers == nil then
  BonusTimers = {}
end

-- timer names
local names = 
{
	neutralItemTimer = 'NeutralItemTimer',
	perMinuteTimer = 'PerMinuteTimer'
}
local inits = 
{
	neutralItemTimer = false,
	perMinuteTimer = false	
}

-- Internal flags for flagging if stuff has been done
-- set to true if any given tier has been awarded
local tiersAwarded = {false,false,false,false,false}
-- current award instance (irrespective of offset). used to index timings
local award = 1
-- default neutral timer interval
local neutralInterval = 1
-- max tier
local maxTier = 5
-- Per Minute Timer Interval
local perMinuteTimerInterval = 60
-- number of tier five neutrals awarded
local tierFivesAwarded = 0

-- Awards neutral items to bots based on Settings 
function NeutralItemTimer()
	-- inform we've registered
	if not inits.neutralItemTimer then
		print('NeutralItemTimer method registered')
		inits.neutralItemTimer = true
	end
  local gameTime = Utilities:GetAbsoluteTime()
  -- Don't do anything if time is negative
  if gameTime < 0 then return math.ceil(gameTime * -1) end
  -- Stop if we've given all bots tier 5 items
  if (tierFivesAwarded >= #Bots) then 
  	Timers:RemoveTimer(names.neutralItemTimer)
  	Utilities:Print('NeutralItemTimer done.  Unregistering.', MSG_CONSOLE_GOOD)
  	return nil
  end
  -- Logic to do things here, we'll use this method primarily for giving neutrals to bots  
  local interval = 0
  -- loop over all bots
  for _, bot in pairs(Bots) do
    -- if time is greater than stats.neutralTiming, we try to award an item
    -- negative numbers disable the award
    if gameTime > bot.stats.neutralTiming and bot.stats.neutralTiming >= 0  and bot.stats.neutralTiming ~= nil then
    	local tier = bot.stats.neutralTier + 1 
    	if tier <= 5 then
    		local isAwarded, itemName = AwardBonus:RandomNeutralItem(bot, tier)
    		if isAwarded then
    			-- set current tier of item
    			bot.stats.neutralTier = tier
    			-- get next neutral timing
    			if tier == 5 then
    				bot.stats.neutralTiming = -1
    				tierFivesAwarded = tierFivesAwarded + 1
    			else
    			bot.stats.neutralTiming = Settings.neutralItems.timings[tier + 1] +
    										 Utilities:GetIntegerVariance(Settings.neutralItems.variance)
					end
					-- announce?
					if Settings.neutralItems.announce then
						Utilities:AnnounceNeutral(bot, tier, itemName)
					end
    		end
    	else
    		-- disable awards
    		bot.stats.neutralTiming = -1
    	end
    end
  end
  return neutralInterval
end

-- timer for adjusting gpm/xpm
function PerMinuteTimer()
	-- inform we've registered
	if not inits.perMinuteTimer then
		print('PerMinuteTimer method registered')
		inits.perMinuteTimer = true
	end
	-- if no bots, unregister 
	if Bots == nil then
	  Timers:RemoveTimer(names.perMinuteTimer)
	  return nil
	end
	local isApply = false
	
	-- Get GPM/XPM tables
	local gpm, xpm = DataTables:GetPerMinuteTables()
	-- loop over all bots
	for _, bot in pairs(Bots) do
		if bot ~= nil then
			-- GPM bonus
			local goldBonus, xpBonus = AwardBonus:GetPerMinuteBonus(bot, gpm, xpm)
			if goldBonus > 0 then
				AwardBonus:gold(bot, goldBonus)
			end
			if xpBonus > 0 then
				AwardBonus:Experience(bot, xpBonus)
			end
		end
	end
	-- return interval
	return perMinuteTimerInterval 
end

-- One time bonus given to bots at game start
function BonusTimers:GameStartBonus()
  local msg = 'Bots given starting bonuses:'
  local awarded = false
  -- Gold
  if Settings.gameStartBonus.gold  > 0 then
  	msg = msg .. ' Gold: '.. Settings.gameStartBonus.gold
  	awarded = true  	
    for _, bot in pairs(Bots) do
    	AwardBonus:gold(bot, Settings.gameStartBonus.gold)
    end
  end 
  -- Armor
  if Settings.gameStartBonus.armor  > 0 then
  	msg = msg .. ' Armor: '.. Settings.gameStartBonus.armor
  	awarded = true  	
    for _, bot in pairs(Bots) do
    	AwardBonus:armor(bot, Settings.gameStartBonus.armor)
    end
  end  
  -- magicResist
  if Settings.gameStartBonus.magicResist  > 0 then
  	msg = msg .. ' Magic Resist: '.. Settings.gameStartBonus.magicResist
  	awarded = true   
    for _, bot in pairs(Bots) do
    	AwardBonus:magicResist(bot, Settings.gameStartBonus.magicResist)
    end
  end    
  -- Levels
  if Settings.gameStartBonus.levels  > 0 then
  	msg = msg .. ' Levels: '.. Settings.gameStartBonus.levels
  	awarded = true
    for _, bot in pairs(Bots) do
    	AwardBonus:levels(bot, Settings.gameStartBonus.levels)
    end
  end   
  -- Levels
  if Settings.gameStartBonus.levels  > 0 then
  	msg = msg .. ' Levels: '.. Settings.gameStartBonus.levels
  	awarded = true  	
    for _, bot in pairs(Bots) do
    	AwardBonus:levels(bot, Settings.gameStartBonus.levels)
    end
  end  
  -- Stats    
  if Settings.gameStartBonus.stats  > 0 then
  	msg = msg .. ' Stats: '.. Settings.gameStartBonus.stats
    awarded = true
    for _, bot in pairs(Bots) do
    	AwardBonus:stats(bot, Settings.gameStartBonus.stats)
    end
  end  
  -- neutral
  if Settings.gameStartBonus.neutral  > 0 then
  	msg = msg .. ' Neutral: '.. Settings.gameStartBonus.neutral
  	awarded = true
    for _, bot in pairs(Bots) do
    	AwardBonus:neutral(bot, Settings.gameStartBonus.neutral)
    end
  end     
  if awarded then
  	Utilities:Print(msg, MSG_WARNING, ATTENTION)
  end
end
  
-- registers the bonus timner listeners
function BonusTimers:Register()
	-- Game start bonus - Special case that happens one time when BonusTimers are registered 
	BonusTimers:GameStartBonus()		  
	-- Register NeutralItemTimer
	if not inits.neutralItemTimer then
		if isDebug then
			DeepPrintTable(Settings.neutralItems)
		end
		print('Registering NeutralItemTimer.')
		Timers:CreateTimer(names.neutralItemTimer, {callback =  NeutralItemTimer} )
		inits.neutralItemTimer = true
	end
	-- Register per minute timer (first executed one minute after game start so we're
	-- not dividing by a decimal and inflating GPM/XPM
	if not inits.perMinuteTimer then
		print('Registering PerMinuteTimer.')
		Timers:CreateTimer(names.perMinuteTimer, {endTime = perMinuteTimerInterval, callback =  PerMinuteTimer} )
		inits.perMinuteTimer = true
	end			
end
  
-- OnGameRulesStateChange callback -- registers timers we only want to run after the game starts
function BonusTimers:OnGameRulesStateChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    BonusTimers:Register()
	end
end
  
-- Registers timers (or listens to events that register timers)
function BonusTimers:Initialize()
	if not Flags.isBonusTimersInitialized then 
		-- Determine where we are
		local state =  GameRules:State_Get()
		-- various ways to implement based on game state
		-- Are we entering this after the horn blew?
		if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			 -- then immediately register listeners
			 BonusTimers:Register()
			 print('Game already in progress.  Registering BonusTimers.')
		-- is game over? Return if so
	  elseif state == DOTA_GAMERULES_STATE_POST_GAME or state == DOTA_GAMERULES_STATE_DISCONNECT then
			return
		-- otherwise we are pre-horn and should register a game state listener 
		-- that will register once the horn sounds
	  else
		  ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( BonusTimers, "OnGameRulesStateChange" ), self)
		  print('Game not in progress.  Registering BonusTimer GameState Listener.')
		end
		Flags.isBonusTimersInitialized = true
	end
end  
  
