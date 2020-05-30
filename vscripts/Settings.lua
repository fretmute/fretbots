-- Dependencies
 -- global debug flag
require 'Debug'
 -- Other Flags
require 'Flags'
 -- Timers
 require 'Timers'
 -- Utilities
 require 'Utilities'

settings = nil

-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;
Settings = nil    

-- Other local variables
local settingsTimerName = 'settingsTimerName'
-- number of human players
local players = 0
-- table to keep track of player votes
local playerVoted = {}
-- is voting closed
local isVotingClosed = false
-- Have voting directions been posted?
local isVotingOpened = false

-- Instantiate ourself
if Settings == nil then
	-- default settings here, override only what you change in Initialize()
  Settings =  
  {  
  	-- Change this to select the default difficulty (chosen if 
  	-- no one votes during difficulty voting time)
  	defaultDifficulty = 'debug',
  	-- game state in which voting should end
  	voteEndState = DOTA_GAMERULES_STATE_PRE_GAME,
  	-- voting ends when state is above and time is > this
  	voteEndTime = -50,  	
  	-- are multipliers multiplicative, or additive (multiplicative is harder)
  	isMultiplicative = true,
  	-- Taunt humans when they die with chatwheel sounds?
  	isPlayerDeathSound = true,
		-- this represents a multiplier to all bonuses.  This allows each game to be slightly different
		skill = 
		{
			-- percentages, by role (1, 2, 3, 4, 5).  A random number is chosen between the clamps
			variance = 
			{
				{1.0, 1.3},
				{0.9, 1.3},
				{0.9, 1.3},
				{0.8, 1.3},
				{0.8, 1.3}
			},
			-- Warns players that the bot is very strong if they are over this threshold
			warningThreshold = 1.2,
			-- disable warnings altogether here
			isWarn = true
		},
  	neutralItems = 
		{
      -- duh
			enabled = true,
			-- Set to false to reroll on the entier table every time.  True makes the awards more like real
			-- jungle drops)
			isRemoveUsedItems = true,
			-- Max neutrals awarded per tier. You might be tempted to make this less than 5 to hinder the bots
			-- a bit, but note that the award method doesn't prioritize bot roles, so you might end up with a
			-- carry that doesn't have an item.
			maxPerTier = 5,
			-- adds this number to the awards as they come out (make this positive to give better items early
			-- make it negative to cause errors, probably.  If you want slower items just change the timings)
			tierOffset = 0,
			-- game time (seconds) at which awards are given.  Note that if offset is ~=0 then the latter ones
			-- will never happen). 
			timings = {420, 1020, 1620, 2220, 2820}
		},
		-- used for awarding bonus gold periodically.  The method that does this award calculates target
		-- gpm and then adds gold to the bot to attempt to force it to that level of gpm, modified by
		-- the clamps.
		-- exact formula: clamp( ( (targetGPM) + offset) * variance * bot.skill * scale) ) 
		gpm = 
		{
			-- offset is a flat offset for the target award relative to the player with the same role
			offset 				= 0,
			-- award multiplied by a random number between these values
			variance 			= {1, 1},
			-- awards are clamped to these numbers. Note that if you make the minimum non-zero, then the
			-- bot's actual GPM will increase by that amount every minute (you don't want to do this)
			clamp 				= {0, 50},
			-- ignore clamps?
			clampOverride = false,
			-- scales (per role) for multipliers if necessary
			scale 				= {1, 1, 1, 1, 1},
			-- Add this to the max clamp per minute
			perMinuteScale = 1
		},
		-- see gpm, same idea
		xpm = 
		{
			offset 				= 0,
			variance 			= {1, 1},
			clamp 				= {0, 50},
			clampOverride = false,
			scale 				= {1, 1, 1, 1, 1},
			perMinuteScale = 1
		},
		deathBonus = 
		{	
		  -- Order awards are given (useful when maxAwards is less than number of types)
  	  -- this also defines the names of the types (used to index tables for other settings)
      order = {'neutral', 'levels', 'stats', 'armor', 'magicResist', 'gold'},
      --The maximum number of awards per death
      maxAwards = 2,
			-- individual bonus enables (Default is off)
			enabled = 
			{
				gold 					= false,
				armor 				= false,
				magicResist 	= false,
				levels 				= false,
				neutral 			= false,
				stats 				= false
			},
			-- Enabled for humans, or just bots?
			isBotsOnly = 
			{
				gold 					= true,
				armor 				= true,
				magicResist 	= true,
				levels 				= true,
				neutral 			= true,
				stats 				= true
			},			
			-- bonuses always given once this threshold is reached. 
			-- if this number is negative, mandatory awards are never given.
			deathStreakThreshold = -1,
			-- range for each award.  This is the base number, which gets scaled with skill / etc.
			-- clamps are applied to the scaled value
			range = 
			{
      	gold 					= {0, 500},
        armor 				= {0, 3},
        magicResist 	= {0, 3},
        levels 				= {0, 2},
        neutral 			= {0, 1},
        stats					= {0, 3}					
			},
			-- (Seconds) Both ends of the range multiplied by gametime / this value. 
			-- Adjust this to prevent large awards early.  Note that clamp has its
			-- own scaling, so you can, for example, grow quickly but still 
			-- clamp late.   
			-- If this is enabled and no default numbers changed, it should
			-- prevent early game OH SHIT moments, or provide late game OH SHIT moments.
			-- Default scales to nominal range at 30 minutes (and more beyond)
			rangeTimeScale  = 
			{
   			gold 					= 1800,
				armor 				= 1800,
				magicResist 	= 1800,
				levels 				= 1800,
				neutral 			= 1800,
				stats 				= 1800   					
			},						
			isRangeTimeScaleEnable = true,
			-- bonus clamps.  Awards given are clamped between these values
      clamp = 
      {
      	gold 					= {100, 1500},
        armor 				= {1, 3},
        magicResist 	= {1, 3},
        levels 				= {1, 2},
        neutral 			= {1, 2},
        stats					= {1, 3}	
      },
      -- if override is true, then the clamps aren't applied
      clampOverride = 
			{
				gold 					= false,
				armor 				= false,
				magicResist 	= false,
				levels 				= false,
				neutral 			= false,
				stats 				= false
			},	
			-- (Seconds) Upper clamp end scaled by this value.
			-- Note the lower clamp is never adjusted.  
			-- Adjust this to allow even greater late game OH SHIT moments.
			-- Default scales to nominal range at 30 minutes (and more beyond)
			clampTimeScale = 
			{
   			gold 					= 1800,
				armor 				= 1800,
				magicResist 	= 1800,
				levels 				= 1800,
				neutral 			= 1800,
				stats 				= 1800   					
			},							
			isClampTimeScaleEnable = true,			
      -- chances per indivdual award.  current levels tracked in bot.stats.chance
      chance = 
      {
      	gold 					= 0.15,
        armor 				= 0.05,
        magicResist 	= 0.05,
        levels 				= 0.10,
        neutral 			= 0.10,
        stats 				= 0.05	
      },
      -- if accrue is true, chances accumulate per death
      accrue = 
			{
				gold 					= true,
				armor 				= true,
				magicResist 	= true,
				levels 				= false,
				neutral 			= false,
				stats 				= true
			},      
      -- flat offsets for bonus per type
      offset = 
      {
   			gold 					= 0,
				armor 				= 0,
				magicResist 	= 0,
				levels 				= 0,
				neutral 			= 0,
				stats 				= 0   	
      },
      -- variance per type
      variance = 
      {
      	gold 				= {0.8, 1.3},
        armor 			= {0.8, 1.3},
        magicResist = {0.8, 1.3},
        levels 			= {0.8, 1.3},
        neutral 		= {0.8, 1.3},
        stats				= {0.8, 1.3}
      },
      -- is this award always loud?
      isLoud = 
			{
				gold 					= false,
				armor 				= false,
				magicResist 	= false,
				levels 				= true,
				neutral 			= true,
				stats 				= false
			},	 
      -- is this award loud if it gets clamped on the high side?
      isClampLoud = 
			{
				gold 					= true,
				armor 				= false,
				magicResist 	= false,
				levels 				= false,
				neutral 			= false,
				stats 				= false
			},	 		
			-- Awards multiplied by this (per role) if enabled
			scale = 
			{
				gold 					= {1, 1, 1, 1, 1},
				armor 				= {1, 1, 1, 1, 1},
				magicResist 	= {1, 1, 1, 1, 1},
				levels 				= {1, 1, 1, 1, 1},
				neutral 			= {1, 1, 1, 1, 1},
				stats 				= {1, 1, 1, 1, 1}
			},	   
			-- Enable role scaling?  
			scaleEnabled = 
			{
				gold 					= false,
				armor 				= false,
				magicResist 	= false,
				levels 				= false,
				neutral 			= false,
				stats 				= false
			},
      -- sets whether to announce in chat if awards have been given
      announce			= true  
    },
    -- One Time awards (granted at game start)
    -- note that neutral is not the count, it is the tier
    -- still, it's probably better to just fix neutral timing rather than award one here
    gameStartBonus = 
    {
    	  gold 					= 0,
				armor 				= 0,
				magicResist 	= 0,
				levels 				= 0,
				neutral       = 0,
				stats 				= 0   	
    },
   	-- caps for awards per game
		awardCap = 
    {
 			gold 					= 25000,
			armor 				= 25,
			magicResist 	= 25,
			levels 				= 10,
			neutral 			= 5,
			stats 				= 25   	
    },		
  }
  Flags.isSettingsLoaded = true;
end

-- neutral item drop settings
allNeutrals = 
{ 
	--                                              roles= 1,2,3,4,5
	{name = 'item_arcane_ring', 					tier = 1, ranged = true, 	melee = true, 	roles={1,1,1,1,1}},
	{name = 'item_broom_handle', 					tier = 1, ranged = false, melee = true,		roles={1,1,1,0,0}},
	{name = 'item_faded_broach', 					tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_iron_talon', 						tier = 1, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_keen_optic', 						tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_mango_tree', 						tier = 1, ranged = true, 	melee = true,		roles={0,0,0,0,0}},
	{name = 'item_ocean_heart',						tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_poor_mans_shield',			tier = 1, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_royal_jelly', 					tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_trusty_shovel',					tier = 1, ranged = true, 	melee = true,		roles={0,0,0,0,0}},
	{name = 'item_ironwood_tree',					tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	-- tier 2                                                                    		
	{name = 'item_dragon_scale', 					tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_essence_ring', 					tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_grove_bow', 						tier = 2, ranged = true, 	melee = false,	roles={1,1,1,1,1}},
	{name = 'item_imp_claw', 							tier = 2, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_nether_shawl', 					tier = 2, ranged = true, 	melee = true,		roles={0,0,0,0,0}},
	{name = 'item_philosophers_stone', 		tier = 2, ranged = true, 	melee = true,		roles={0,0,0,0,0}},
	{name = 'item_pupils_gift',						tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_vambrace',							tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_ring_of_aquila', 				tier = 2, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_vampire_fangs',					tier = 2, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_clumsy_net', 						tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}},	
	-- tier 3                                                                    		
	{name = 'item_craggy_coat', 					tier = 3, ranged = true, 	melee = true,		roles={0,0,1,1,1}},
	{name = 'item_enchanted_quiver', 			tier = 3, ranged = true, 	melee = false,	roles={1,1,1,1,1}},
	{name = 'item_greater_faerie_fire', 	tier = 3, ranged = true,	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_mind_breaker', 					tier = 3, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_orb_of_destruction', 		tier = 3, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_paladin_sword',					tier = 3, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_quickening_charm',			tier = 3, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_spider_legs', 					tier = 3, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_titan_sliver',					tier = 3, ranged = true, 	melee = true,		roles={1,1,1,1,1}},	
	{name = 'item_repair_kit',				    tier = 3, ranged = true, 	melee = true,		roles={0,0,1,1,1}},
  {name = 'item_spy_gadget', 						tier = 3, ranged = true, 	melee = false,	roles={0,0,0,1,1}},	
	-- tier 4                                                                    		
	{name = 'item_flicker', 							tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_havoc_hammer', 					tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_illusionsts_cape', 			tier = 4, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_panic_button', 					tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_minotaur_horn', 				tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_ninja_gear', 						tier = 4, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_princes_knife',					tier = 4, ranged = true, 	melee = false,	roles={1,1,1,1,1}},
	{name = 'item_spell_prism',						tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_the_leveller',					tier = 4, ranged = true, 	melee = true,		roles={1,1,0,0,0}},	
	{name = 'item_timeless_relic',				tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}},	
	{name = 'item_witless_shako',					tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}},	
	-- tier 5                                                                    		
	{name = 'item_apex', 									tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_ballista', 							tier = 5, ranged = true, 	melee = false,	roles={1,1,1,0,0}},
	{name = 'item_demonicon', 						tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_ex_machina', 						tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_fallen_sky', 					  tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_force_boots', 					tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_mirror_shield',					tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_pirate_hat',						tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}},
	{name = 'item_seer_stone', 						tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}},
	{name = 'item_desolator_2',						tier = 5, ranged = true, 	melee = true,		roles={1,1,0,0,0}},	
	{name = 'item_trident',				        tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}},	
	{name = 'item_woodland_striders',			tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}},				
}

-- Difficulty names
local difficulties =
{
  debug = 
  {
  	name = 'debug',
  	description = "Currently: Bots are 1 full tier ahead on neutrals, and receive moderate death bonuses.",
  	votes = 0
  },
  default = 
  {
  	name = 'default',
  	description = "Aims for perfect balance (bots are still dumb). Bot XPM and GPM equal to equivalent player. Neutral tiers align.",
  	votes = 0
  },
  --debugHard = 
  --{
  --	name = 'debugHard',
  --	description = "Bots 1 full tier ahead on neutrals.  Death bonuses double every 10 minutes.",
  --	votes = 0
  --},  
}

-- Sets difficulty value
function Settings:Initialize(difficulty)
	-- no argument implies default, do nothing
  -- Default -- This aims to make bots exactly the GPM / XPM of the humans with no other bonuses
	if difficulty == nil then return end
	-- Replicate and add more if statements for custom difficulties
	-- Debug diffculty - speeds timings
	if difficulty == 'debug' then
  	-- override neutral timings for speed (this puts bots ~ 1/2 a full tier ahead)
  	--Settings.neutralItems.timings = {200, 620, 1220, 1820, 2420}
  	Settings.neutralItems.timings = {0, 420, 1020, 1620, 2220}
  	-- Also override deathbonus settings for test
  	Settings.deathBonus.enabled = 
  	{
			gold 					= true,
			armor 				= true,
			magicResist 	= true,
			levels 				= true,
			neutral 			= true,
			stats 				= true
		}
		-- adjust game start bonus here
		Settings.gameStartBonus = 
    {
    	  gold 					= 0,
				armor 				= 2,
				magicResist 	= 2,
				levels 				= 0,
				neutral       = 0,
				stats 				= 3   	
    }    
    -- Disable DeathBonus time scale
    Settings.deathBonus.isRangeTimeScaleEnable = false
    Settings.deathBonus.isClampTimeScaleEnable = false 
	end		
end

-- Periodically checks to see if settings have been chosen
function Settings:DifficultySelectTimer()
	-- If voting is closed, apply settings, remove timer
	if isVotingClosed then
		Settings:ApplyVoteSettings()
	  Timers:RemoveTimer(settingsTimerName)
	  return nil
	end
	-- If voting not yet open, display directions
	if not isVotingOpen then
		local msg = 'Difficulty voting is now open! Type a difficulty into chat to vote. Choices follow:'
		Utilities:Print(msg, MSG_GOOD)
		for _, difficulty in pairs(difficulties) do
		  msg = difficulty.name..': '..difficulty.description
		  Utilities:Print(msg, MSG_GOOD)
		end
	  isVotingOpen = true
	end
	-- Check voting status
	local haveAllVoted = true
	-- anyone hasn't voted, voting isn't done
	for _, voted in pairs(playerVoted) do
	  haveAllVoted = haveAllVoted and voted
	end
	-- set voting closed
	if haveAllVoted or Settings:ShouldCloseVoting() then
	  isVotingClosed = true
	end
	-- run again in 1 second
	return 1
end

-- Determine winner of voting and applies settings (or applies default difficulty)
function Settings:ApplyVoteSettings()
	local maxVotes = 0
	local winner = nil
	for i, difficulty in pairs(difficulties) do
	  if difficulty.votes > maxVotes then
	  	winner = difficulty
	  end
	end
  -- edge case: no one voted
  if winner == nil then
  	winner = difficulties[Settings.defaultDifficulty]
  end
  -- Apply
	Settings:Initialize(winner.name)
	msg = 'Voting closed. Applied difficulty: '..winner.name
  Utilities:Print(msg, MSG_GOOD)
  Debug:DeepPrint(Settings)
end

-- Returns true if voting should close due to game state
function Settings:ShouldCloseVoting()
  local state =  GameRules:State_Get()
  if state > Settings.voteEndState then
  	return true
  end
  if state == Settings.voteEndState then
    local gameTime = Utilities:GetAbsoluteTime()
		if gameTime > Settings.voteEndTime then
			return true
		end
	end
	return false
end

-- Register a chat listener for settings voting
function Settings:RegisterChatEvent()
  if not Flags.isPlayerChatRegistered then
  	-- size playerVoted array
  	local playerCount = Utilities:GetNumberOfHumans() 
  	for i = 1, playerCount do
  		table.insert(playerVoted, false)
  	end 
  	ListenToGameEvent("player_chat", Dynamic_Wrap(Settings, 'OnPlayerChat'), Settings)
  	print('Settings: PlayerChat event listener registered.')
  	Flags.isPlayerChatRegistered = true
  end
end

-- Monitors chat for votes on settings
function Settings:OnPlayerChat(event)
	-- return if voting is closed
	if isVotingClosed then return end
	-- Get event data
	local playerID, text = Settings:GetChatEventData(event)
	-- if no vote from the player, check if he's voting for a difficulty
	if playerVoted[playerID] ~= nil then
		if not playerVoted[playerID] then
		  for _, difficulty in pairs(difficulties) do
		  	print(text..': '..difficulty.name)
		  	-- If voted for difficulty, reflect that
		    if text == difficulty.name then
		    	-- players can only vote once
		    	playerVoted[playerID] = true
		    	-- increment votes for diff
		      difficulty.votes = difficulty.votes + 1
		      -- let players know the vote counted
		      local msg = 'Player '..playerID..' voted for '..difficulty.name..'. '
		      msg = msg..difficulty.votes..' total votes for '..difficulty.name
		      Utilities:Print(msg, MSG_GOOD)
		    end
		  end
		end
	end
end

-- Parse chat event information 
function Settings:GetChatEventData(event)
	local userID = event.userid
	local text = event.text
	return userID, text
end

-- Register settings vote timer and chat event monitor
Settings:RegisterChatEvent()
Timers:CreateTimer(settingsTimerName, {endTime = 1, callback =  Settings['DifficultySelectTimer']} )



