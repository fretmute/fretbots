	-- Default settings table, returns the table, so use 
	-- local <x> = require 'SettingsDefault' to include in another file.
	
	-- default settings here, override only what you change in Initialize()
  local settings =  
  { 
  	-- Name of the settings group (difficulty)
  	name = 'Standard',
  	-- Printed to chat when voting
  	description = "Bots are 1 full tier ahead on neutrals, and receive moderate death bonuses.",
  	-- Used to track votes of the settings
  	votes = 0,
  	-- Color in which to print to chat
  	color = '#00ff00',
  	-- Change this to select the default difficulty (chosen if 
  	-- no one votes during difficulty voting time)
  	defaultDifficulty = 'standard',
  	-- game state in which voting should end
  	voteEndState = DOTA_GAMERULES_STATE_PRE_GAME,
  	-- voting ends when this amount of time has passed since voting began
  	voteEndTime = 30,  	
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
				{0.9, 1.3},
				{0.9, 1.3},
				{0.9, 1.3},
				{0.9, 1.3},
				{0.9, 1.3}
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
			timings = {0, 420, 1020, 2020, 3600}
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
			-- individual bonus enables 
			enabled = 
			{
				gold 					= true,
				armor 				= true,
				magicResist 	= true,
				levels 				= true,
				neutral 			= true,
				stats 				= true
			},
			-- Further option to only enable if the bots are behind in kills
			isEnabledOnlyWhenBehind = 
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
			isRangeTimeScaleEnable = false,
			-- bonus clamps.  Awards given are clamped between these values
      clamp = 
      {
      	gold 					= {100, 1500},
        armor 				= {0, 3},
        magicResist 	= {0, 3},
        levels 				= {0, 2},
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
			isClampTimeScaleEnable = false,			
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
      -- Awards are rounded to this many decimal places after scaling
      round = 
      {
   			gold 					= 0,
				armor 				= 2,
				magicResist 	= 2,
				levels 				= 2,
				neutral 			= 0,
				stats 				= 0,   	
      },      
      -- variance per type
      variance = 
      {
      	gold 				= {0.8, 1.2},
        armor 			= {0.8, 1.2},
        magicResist = {0.8, 1.2},
        levels 			= {0.8, 1.2},
        neutral 		= {0.8, 1.2},
        stats				= {0.8, 1.2}
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
			neutral 			= 1,
			stats 				= 25,   	
    },		
    -- Settings for dynamically adjusting difficulty
    dynamicDifficulty = 
    {
    	-- Set to false to disable completely.
    	enabled 				= false, 
    	-- Settings related to kill deficits
    	gpm = 
    	{
	    	-- Set to false to disable adjustments based on kills.
	    	enabled				= true,
	    	-- if the bots are this many kills behind, begin adjusting
	    	advantageThreshold = 5,
	    	-- Awards scaled by scale amount every <this many> kills beyond the threshold
	    	incrementEvery = 2,
	    	-- base bonus increased by this much when over threshold
	    	base					= 50,
				-- incremental amounts are added to the base every time
				-- the increment amount is reached, i.e. if threshold is 5,
				-- incrementEvery is 2, and the bots are 9 kills behind,
				-- then the nudge will be base + (increment * 2)
	    	increment 		= 25,
	    },    	
    	xpm = 
    	{
	    	-- Set to false to disable adjustments based on kills.
	    	enabled				= true,
	    	-- if the bots are this many kills behind, begin adjusting
	    	advantageThreshold = 5,
	    	-- Awards scaled by scale amount every <this many> kills beyond the threshold
	    	incrementEvery = 2,
	    	-- base bonus increased by this much when over threshold
	    	base					= 50,
				-- incremental amounts are added to the base every time
				-- the increment amount is reached, i.e. if threshold is 5,
				-- incrementEvery is 2, and the bots are 9 kills behind,
				-- then the nudge will be base + (increment * 2)
	    	increment 		= 25,
	    },    	    
    },
  }
  
  return settings