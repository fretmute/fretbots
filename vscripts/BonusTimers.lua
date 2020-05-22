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
-- default retry interval
local retryInterval = 2
-- max tier
local maxTier = 5
-- Per Minute Timer Interval
local perMinuteTimerInterval = 60

-- Awards neutral items to bots based on Settings 
function NeutralItemTimer()
	-- inform we've registered
	if not inits.neutralItemTimer then
		print('NeutralItemTimer method registered')
		inits.neutralItemTimer = true
	end
  -- This returns the number of seconds on the game clock (once the game starts at 00:00 as opposed
  -- to the negative time the game starts with
  local gametime = GameRules:GetDOTATime(false, false)
  -- if time is zero we're in pregame and shouldn't do anything (try again in 2 seconds)
  if gametime == 0 then return retryInterval end
  -- set tier we're attempting to award
  tier = award + Settings.neutralItems.tierOffset
  -- If we hit tier 6 quit and stop the timer
  if (tier > maxTier) then 
  	Timers:RemoveTimer(names.neutralItemTimer)
  	if isDebug then
  		print('NeutralItemTimer done.  Unregistering.')
    end
  	return
  end
  -- Logic to do things here, we'll use this method primarily for giving neutrals to bots  
  local interval = 0
  if isDebug then
    print('Tier: '..tostring(tier).. ' award: ' .. tostring(award)..' Time: '..tostring(gametime).. ' Bonus time: '..tostring(Settings.neutralItems.timings[award]))
  end
  if gametime > Settings.neutralItems.timings[award] and not tiersAwarded[tier] then
    AwardBonus:GiveTierToBots(tier)
    tiersAwarded[tier] = true
    award = award + 1     
	  -- Required by timers, tells the helper when to rerun this method
	  local chatMessage
	  if Settings.neutralItems.timings[award] ~= nil then
	  	-- if there is another tier, wait for its timing
	  	interval = math.ceil(Settings.neutralItems.timings[tier+1] - gametime)
	  	-- sanity check
	  	if interval < 0 then interval = retryInterval end
	  	chatMessage = 'Tier '..tostring(tier)..' neutral items awarded. Next award in '..tostring(interval)..' seconds.'
	  else
	  	-- if there isn't a next tier, quit
	  	Timers:RemoveTimer(names.neutralItemTimer)
	  	chatMessage = 'Tier '..tostring(tier)..' neutral items awarded. NeutralItemTimer exiting.'
	  end
	  -- debug message
	  if isDebug then
	  	print('NeutralItemTimer complete. Rerunning in ' .. tostring(interval) .. ' seconds.')
	  end
	  -- chat message
	  if isChat then
	  	Utilities:Print(chatMessage,MSG_WARNING)
	  end
	else
		-- if not awarded, try again
		-- first try a smart wait
		if Settings.neutralItems.timings[award] ~= nil then
			interval = Settings.neutralItems.timings[award]		
		else
			interval = retryInterval;  
		end
	end 
	  -- return time until next instance
	  -- sanity check
	if interval < 0 then interval = retryInterval end
  return interval
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
	end
	local isApply = false
	-- loop over all bots
	for _, bot in pairs(Bots) do
		if bot ~= nil then
			-- GPM bonus
			local goldBonus = DataTables:GetGPMBonus(bot)
			if goldBonus > 0 then
				AwardBonus:gold(bot, goldBonus)
			end
			-- XPM bonus
			local xpBonus = DataTables:GetXPMBonus(bot)
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
  	msg = msg .. ' Neutral Tier: '.. Settings.gameStartBonus.neutral
  	awarded = true
    for _, bot in pairs(Bots) do
    	AwardBonus:RandomNeutralItem(bot, Settings.gameStartBonus.neutral)
    end
  end     
  if awarded then
  	Utilities:Print(msg, MSG_WARNING, ATTENTION)
  end
end
  
-- OnGameRulesStateChange callback -- registers timers we only want to run after the game starts
function BonusTimers:OnGameRulesStateChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		-- Game start bonus
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
end
  
-- Registers timers (or listens to events that register timers)
function BonusTimers:Initialize()
	-- We want some timers to start immediately (in pre time) and others to only happen after the game starts
	-- register those timers in the DOTA_GAMERULES_STATE_GAME_IN_PROGRESS event
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( BonusTimers, "OnGameRulesStateChange" ), self )
end  
  
-- Initialize
BonusTimers:Initialize()
  