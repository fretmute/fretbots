-- Dependencies
 -- global debug flag
require 'Debug'
 -- Other Flags
require 'Flags'
 -- Timers
require 'Timers'
 -- Utilities
require 'Utilities'

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
-- Number of votes case
local numVotes = 0
-- start abitrariy large, fix when chat listener is registered
local maxvotes = 64
-- The playerID of the host.  Used to whitelist chat commands.
local hostID = -1

-- Instantiate ourself
if Settings == nil then
	-- default settings here, override only what you change in Initialize()
  Settings =  
  {  
  	-- Change this to select the default difficulty (chosen if 
  	-- no one votes during difficulty voting time)
  	defaultDifficulty = 'standard',
  	-- game state in which voting should end
  	voteEndState = DOTA_GAMERULES_STATE_PRE_GAME,
  	-- voting ends when state is above and time is > this
  	voteEndTime = -80,  	
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
				{1.0, 1.3},
				{1.0, 1.3},
				{1.0, 1.3},
				{1.0, 1.3}
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
			timings = {0, 420, 1020, 1620, 2220}
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
				gold 					= true,
				armor 				= true,
				magicResist 	= true,
				levels 				= true,
				neutral 			= true,
				stats 				= true
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
				stats 				= 0   	
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
				armor 				= 2,
				magicResist 	= 2,
				levels 				= 0,
				neutral       = 0,
				stats 				= 3   	
    },    
   	-- caps for awards per game
		awardCap = 
    {
 			gold 					= 25000,
			armor 				= 25,
			magicResist 	= 25,
			levels 				= 10,
			neutral 			= 2,
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
end

-- neutral item drop settings
allNeutrals = 
{ 
	--                                              roles= 1,2,3,4,5
	{name = 'item_arcane_ring', 					tier = 1, ranged = true, 	melee = true, 	roles={1,1,1,1,1}, realName = 'Arcane Ring'},
	{name = 'item_broom_handle', 					tier = 1, ranged = false, melee = true,		roles={1,1,1,0,0}, realName = 'Broom Handle'},
	{name = 'item_faded_broach', 					tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Faded Broach'},
	{name = 'item_iron_talon', 						tier = 1, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Iron Talon'},
	{name = 'item_keen_optic', 						tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Keen Optic'},
	{name = 'item_mango_tree', 						tier = 1, ranged = true, 	melee = true,		roles={0,0,0,0,0}, realName = 'Mango Tree'},
	{name = 'item_ocean_heart',						tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Ocean Heart'},
	{name = 'item_poor_mans_shield',			tier = 1, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = "Poor Man's Shield"},
	{name = 'item_royal_jelly', 					tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Royal Jelly'},
	{name = 'item_trusty_shovel',					tier = 1, ranged = true, 	melee = true,		roles={0,0,0,0,0}, realName = 'Trusty Shovel'},
	{name = 'item_ironwood_tree',					tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Ironwood Tree'},
	-- tier 2                                                                    		
	{name = 'item_dragon_scale', 					tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Dragon Scale'},
	{name = 'item_essence_ring', 					tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Essence Ring'},
	{name = 'item_grove_bow', 						tier = 2, ranged = true, 	melee = false,	roles={1,1,1,1,1}, realName = 'Grove Bow'},
	{name = 'item_imp_claw', 							tier = 2, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Imp Claw'},
	{name = 'item_nether_shawl', 					tier = 2, ranged = true, 	melee = true,		roles={0,0,0,0,0}, realName = 'Nether Shawl'},
	{name = 'item_philosophers_stone', 		tier = 2, ranged = true, 	melee = true,		roles={0,0,0,0,0}, realName = "Philosopher's Stone"},
	{name = 'item_pupils_gift',						tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = "Pupil's Gift"},
	{name = 'item_vambrace',							tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Vambrace'},
	{name = 'item_ring_of_aquila', 				tier = 2, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Ring of Aquila'},
	{name = 'item_vampire_fangs',					tier = 2, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Vampire Fangs'},
  {name = 'item_clumsy_net', 						tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Clumsy Net'},	
	-- tier 3                                                                    		
	{name = 'item_craggy_coat', 					tier = 3, ranged = true, 	melee = true,		roles={0,0,1,1,1}, realName = 'Craggy Coat'},
	{name = 'item_enchanted_quiver', 			tier = 3, ranged = true, 	melee = false,	roles={1,1,1,1,1}, realName = 'Enchanted Quiver'},
	{name = 'item_greater_faerie_fire', 	tier = 3, ranged = true,	melee = true,		roles={1,1,1,0,0}, realName = 'Greater Faerie Fire'},
	{name = 'item_mind_breaker', 					tier = 3, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Mind Breaker'},
	{name = 'item_orb_of_destruction', 		tier = 3, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Orb of Destruction'},
	{name = 'item_paladin_sword',					tier = 3, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Paladin Sword'},
	{name = 'item_quickening_charm',			tier = 3, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Quickening Charm'},
	{name = 'item_spider_legs', 					tier = 3, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Spider Legs'},
	{name = 'item_titan_sliver',					tier = 3, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Titan Sliver'},	
	{name = 'item_repair_kit',				    tier = 3, ranged = true, 	melee = true,		roles={0,0,1,1,1}, realName = 'Repair Kit'},
  {name = 'item_spy_gadget', 						tier = 3, ranged = true, 	melee = false,	roles={0,0,0,1,1}, realName = 'Telescope'},	
	-- tier 4                                                                    		
	{name = 'item_flicker', 							tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Flicker'},
	{name = 'item_havoc_hammer', 					tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Havoc Hammer'},
	{name = 'item_illusionsts_cape', 			tier = 4, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = "Illusionist's Cape"},
	{name = 'item_panic_button', 					tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Magic Lamp'},
	{name = 'item_minotaur_horn', 				tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Minotaur Horn'},
	{name = 'item_ninja_gear', 						tier = 4, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Ninja Gear'},
	{name = 'item_princes_knife',					tier = 4, ranged = true, 	melee = false,	roles={1,1,1,1,1}, realName = "Prince's Knife"},
	{name = 'item_spell_prism',						tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Spell Prism'},
	{name = 'item_the_leveller',					tier = 4, ranged = true, 	melee = true,		roles={1,1,0,0,0}, realName = 'The Leveller'},	
	{name = 'item_timeless_relic',				tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Timeless Relic'},	
	{name = 'item_witless_shako',					tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Witless Shako'},	
	-- tier 5                                                                    		
	{name = 'item_apex', 									tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Apex'},
	{name = 'item_ballista', 							tier = 5, ranged = true, 	melee = false,	roles={1,1,1,0,0}, realName = 'Ballista'},
	{name = 'item_demonicon', 						tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Book of the Dead'},
	{name = 'item_ex_machina', 						tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Ex Machina'},
	{name = 'item_fallen_sky', 					  tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Fallen Sky'},
	{name = 'item_force_boots', 					tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Force Boots'},
	{name = 'item_mirror_shield',					tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Mirror Shield'},
	{name = 'item_pirate_hat',						tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Pirate Hat'},
	{name = 'item_seer_stone', 						tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Seer Stong'},
	{name = 'item_desolator_2',						tier = 5, ranged = true, 	melee = true,		roles={1,1,0,0,0}, realName = 'Stygian Desolator'},	
	{name = 'item_trident',				        tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Trident'},	
	{name = 'item_woodland_striders',			tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Woodland Striders'},				
}

-- Difficulties.  Table entries with matching keys for Settings will overwrite.
difficulties =
{
  {
  	name = 'Standard',
  	description = "Bots are 1 full tier ahead on neutrals, and receive moderate death bonuses.",
  	votes = 0,
  	color = '#00ff00',
  }, 
  {
  	name = 'Harder',
  	description = "More aggressive death scaling past twenty minutes.",
  	votes = 0,
  	color = '#e8fc51',
		-- aggressive death scaling    
    deathBonus = 
    {
	    isRangeTimeScaleEnable = true,
	    isClampTimeScaleEnable = true, 		
			clampTimeScale = 
			{
	 			gold 					= 1200,
				armor 				= 1200,
				magicResist 	= 1200,
				levels 				= 1200,
				neutral 			= 1200,
				stats 				= 1200,   					
			},	
			rangeTimeScale = 
			{
	 			gold 					= 1200,
				armor 				= 1200,
				magicResist 	= 1200,
				levels 				= 1200,
				neutral 			= 1200,
				stats 				= 1200,   					
			},		
			clamp = 
		  {
		  	gold 					= {300, 1500},
		    armor 				= {1, 3},
		    magicResist 	= {1, 3},
		    levels 				= {1, 2},
		    neutral 			= {1, 2},
		    stats					= {1, 3},	
		  },  	
		},
  },   
  {
  	name = 'EvenHarder',
  	description = "Aggresive death scaling with upper clamps disabled. Bots will be rich.",
  	votes = 0,
  	color = '#e8961c',
  	-- very aggressive death scaling
  	deathBonus = 
  	{
	    isRangeTimeScaleEnable = true,
	    isClampTimeScaleEnable = true,	
			rangeTimeScale = 
			{
	 			gold 					= 600,
				armor 				= 600,
				magicResist 	= 600,
				levels 				= 600,
				neutral 			= 600,
				stats 				= 600,   					
			},			
			clamp = 
		  {
		  	gold 					= {300, 7500},
		    armor 				= {1, 	10},
		    magicResist 	= {1, 	10},
		    levels 				= {1, 	4},
		    neutral 			= {1, 	3},
		    stats					= {1, 	10},	
		  },	
			range = 
			{
	    	gold 					= {0, 750},
	      armor 				= {0, 4},
	      magicResist 	= {0, 4},
	      levels 				= {0, 2},
	      neutral 			= {0, 1},
	      stats					= {0, 4},					
			},
			-- increased chance as well
			chance = 
	    {
	    	gold 					= 0.15,
	      armor 				= 0.15,
	      magicResist 	= 0.15,
	      levels 				= 0.20,
	      neutral 			= 0.20,
	      stats 				= 0.1
	    },
	  },
  },
  {
  	name = 'Dynamic',
  	description = "Like Standard, but with dynamic adjustments enabled.",
  	votes = 0,
  	color = '#800080',
  	dynamicDifficulty = 
  	{
  		enabled					= true
  	}
  },     
}

-- Valid commands for altering settings from chat
local chatCommands =
{
	'nudge',
	'get',
	'set',
	'ddenable',
	'ddsuspend',
	'ddtoggle',
	'ddreset',
}

-- Sets difficulty value
function Settings:Initialize(difficulty)
	-- no argument implies default, do nothing
	if difficulty == nil then return end
	-- Override settings table entries if found
 	Utilities:DeepCopy(difficulty, Settings)
 	-- Cache base offsets for DynamicDifficulty
 	-- Set Flag
 	Flags.isSettingsFinalized = true
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
		Utilities:Print(msg)
		for _, difficulty in ipairs(difficulties) do
			if Settings:IsValidDifficulty(difficulty) then
			  msg = difficulty.name..': '..difficulty.description
				Utilities:Print(msg, difficulty.color)
			end
		end
	  isVotingOpen = true
	end
	-- set voting closed
	if numVotes >= maxVotes or Settings:ShouldCloseVoting() then
	  isVotingClosed = true
	end
	-- run again in 1 second
	return 1
end

-- Determine winner of voting and applies settings (or applies default difficulty)
function Settings:ApplyVoteSettings()
	local maxVotes = 0
	local winner = nil
	for _, difficulty in ipairs(difficulties) do
		if Settings:IsValidDifficulty(difficulty) then 
		  if difficulty.votes > maxVotes then
		  	winner = difficulty
		  	maxVotes = difficulty.votes 
		  end
		end
	end
  -- edge case: no one voted, pick first valid difficulty
  if winner == nil then
		for _, difficulty in ipairs(difficulties) do
			if Settings:IsValidDifficulty(difficulty) then 
				winner = difficulty
				break
			end
		end
  end
  Debug:Print('Winning Difficulty:')
  Debug:DeepPrint(winner)
	msg = 'Voting closed. Applied difficulty: '..winner.name
  Utilities:Print(msg, winner.color)
  Settings:Initialize(winner)
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

-- Returns true if a table is a valid difficulty table
function Settings:IsValidDifficulty(diff)
	local isValid = true
	isValid = isValid and diff.name ~= nil
  if not isValid then return isValid end
  isValid = isValid and type(diff.name) == 'string'
  if not isValid then return isValid end
	isValid = isValid and diff.description ~= nil
  if not isValid then return isValid end
  isValid = isValid and type(diff.description) == 'string'
  if not isValid then return isValid end  
	isValid = isValid and diff.color ~= nil
  if not isValid then return isValid end
  isValid = isValid and type(diff.color) == 'string'
  if not isValid then return isValid end    
	isValid = isValid and diff.votes ~= nil
  if not isValid then return isValid end
  isValid = isValid and type(diff.votes) == 'number'
  if not isValid then return isValid end    
  return isValid
end

-- Register a chat listener for settings voting
function Settings:RegisterChatEvent()
  if not Flags.isPlayerChatRegistered then
  	-- set max number of vote
 		maxVotes = Utilities:GetNumberOfHumans() 
  	ListenToGameEvent("player_chat", Dynamic_Wrap(Settings, 'OnPlayerChat'), Settings)
  	print('Settings: PlayerChat event listener registered.')
  	Flags.isPlayerChatRegistered = true
  end
end

-- Monitors chat for votes on settings
function Settings:OnPlayerChat(event)
	-- Get event data
	local playerID, text = Settings:GetChatEventData(event)
	-- Handle votes if we're still in the voting phase
	if not isVotingClosed then 
		Settings:DoChatVoteParse(playerID, text) 
	end
 	-- if Settings have been chosen then monitor for commands to change them
 	if Flags.isSettingsFinalized then
 		if playerID == hostID or Debug:IsPlayerIDFret(playerID) then
 			-- check for 'light' commands
		  local isSuccess = Settings:DoChatCommandParse(text)
		  -- if not that, then try to pcall arbitrary text
			Utilities:PCallText(text)
		end
 	end
end

-- Parse player chats for Settings commands and acts upon them if found
function Settings:DoChatCommandParse(text)
 	local tokens = Utilities:Tokenize(text)
  local command = Settings:GetCommand(tokens)
  -- No command, return false
  if command == nil then return false end
  -- Otherwise process
	-- get prints a setting to chat
  if command == 'get' then
		Settings:DoGetCommand(tokens)
  end
	--set writes to something
  if command == 'set' then
  	Settings:DoSetCommand(tokens)
  end 	  
	--set writes to something
  if command == 'nudge' then
  	Settings:DoNudgeCommand(tokens)
  end 	   
	-- Toggle dynamic difficulty
  if command == 'ddtoggle' then
  	Settings:DoDDToggleCommand()
  end 	   
	-- suspend dynamic difficulty
  if command == 'ddsuspend' then
  	Settings:DoDDSuspendCommand()
  end 	
	-- reset dynamic difficulty (this restores default GPM/XPM)
  if command == 'ddreset' then
  	Settings:DoDDResetCommand()
  end 	 
	-- enable dynamic difficulty
  if command == 'ddenable' then
  	Settings:DoDDEnableCommand()
  end 	 
  return true                
end

-- Toggles Dynamic difficulty
function Settings:DoDDToggleCommand()
	DynamicDifficulty:Toggle()
	local msg ='Dynamic Difficulty Enable Toggled: '..
	            tostring(Settings.dynamicDifficulty.enabled)
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Enables Dynamic difficulty
function Settings:DoDDEnableCommand()
	DynamicDifficulty:Toggle()
	local msg ='Dynamic Difficulty Enabled.'
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Resets Dynamic difficulty (GPM/XPM to default)
function Settings:DoDDResetCommand()
	DynamicDifficulty:Reset()
	local msg ='Dynamic Difficulty Reset. Default Bonus Offsets Restored:'..
              ' GPM: '..Settings.gpm.offset..
              ' XPM: '..Settings.xpm.offset    
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Suspends Dynamic difficulty
function Settings:DoDDSuspendCommand()
	DynamicDifficulty:Suspend()
	local msg ='Dynamic Difficulty Suspended. Current Bonus Offsets:'..
              ' GPM: '..Settings.gpm.offset..
              ' XPM: '..Settings.xpm.offset              
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Executes the 'get' command
function Settings:DoGetCommand(tokens)
  -- tokens[2] will be the target object string
	local target = Settings:GetObject(tokens[2])
	if target ~= nil then
		Utilities:TableToChat(target, MSG_CONSOLE_GOOD)
	end
end

-- Executes the 'set' command
function Settings:DoSetCommand(tokens)
	-- tokens[2] will be the target object string
	if tokens[2] == nil then
		Utilities:Print('Set requires a target object argument.', MSG_CONSOLE_BAD)
		return
	end	
	local stringTarget = tokens[2]
	local target = Settings:GetObject(stringTarget)
	if target == nil then
		Utilities:Print('Set requires a target object argument.', MSG_CONSOLE_BAD)
		return
	end
	-- tokens[3] is target value
	if tokens[3] == nil then
		Utilities:Print('Set requires a value argument.', MSG_CONSOLE_BAD)
		return
	end
	local value = Utilities:TableFromString(tokens[3])
	if value == nil then
		Utilities:Print('Invalid value for set command.', MSG_CONSOLE_BAD)
		return
	end	
	if Settings:IsValidSet(target, value) then
		-- tables
		if type(value) == 'table' then			
			Utilities:DeepCopy(value, target)
			Utilities:Print(stringTarget..' set successfully: '..
											Utilities:Inspect(value), MSG_CONSOLE_GOOD)
	  -- Otherwise a literal
		else
			if Settings:SetValue(stringTarget, value) then
				Utilities:Print(stringTarget..' set successfully: '..
			                tostring(value), MSG_CONSOLE_GOOD)
			else
				Utilities:Print('Unable to set '..stringTarget..'.', MSG_CONSOLE_BAD)				
			end
		end
	else
		Utilities:Print('Invalid value for set command.', MSG_CONSOLE_BAD)
		return
	end
end	

-- Executes the 'nudge' command
function Settings:DoNudgeCommand(tokens)
	-- All sorts of testing!
	-- tokens[2] will be the target object string
	if tokens[2] == nil then
		Utilities:Print('Nudge requires a target object argument.', MSG_CONSOLE_BAD)
		return
	end	
	local stringTarget = tokens[2]
	local target = Settings:GetObject(stringTarget)
	if target == nil then
		Utilities:Print('Nudge requires a target object argument.', MSG_CONSOLE_BAD)
		return
	end
	if type(target) ~= 'table' and type(target) ~= 'number'then
		Utilities:Print('Nudge targets must be tables or numbers.', MSG_CONSOLE_BAD)
		return
	end	
	-- tokens[3] is target value
	if tokens[3] == nil then
		Utilities:Print('Nudge requires a value argument.', MSG_CONSOLE_BAD)
		return
	end
	local value = Utilities:TableFromString(tokens[3])
	if value == nil then
		Utilities:Print('Invalid value for nudge command.', MSG_CONSOLE_BAD)
		return
	end	
	if type(value) ~= 'number' then
		Utilities:Print('Nudge values must be numbers', MSG_CONSOLE_BAD)
		return
	end		
	-- Ok, we think we can apply this
	-- Nudge simply adds the value to each value of a table (or directly to a number)
	if type(target) == 'table' then
		-- create offset table values
		local valTable = {}
		for _, val in ipairs(target) do
			table.insert(valTable, val + value)
		end
		Utilities:DeepCopy(valTable, target)
		Utilities:Print(stringTarget..' nudged successfully: '..
									Utilities:Inspect(target), MSG_CONSOLE_GOOD)			
	else
		local val = target + value
		Settings:SetValue(stringTarget, val) 
		Utilities:Print(stringTarget..' nudged successfully: '..
									val, MSG_CONSOLE_GOOD)			
	end
end

-- Parses chat message for valid settings votes and handles them.
function Settings:DoChatVoteParse(playerID, text)
		-- return if the player is not on a team
	if not Utilities:IsTeamPlayer(playerID) then return end
	-- if no vote from the player, check if he's voting for a difficulty
	if playerVoted[tostring(playerID)] == nil then
	  for _, difficulty in ipairs(difficulties) do
  		-- If voted for difficulty, reflect that
	    if string.lower(text) == string.lower(difficulty.name) then
	    	-- players can only vote once
	    	playerVoted[tostring(playerID)] = true
	    	-- increment votes for diff
	      difficulty.votes = difficulty.votes + 1
	      -- increment number of votes
	      numVotes = numVotes + 1
	      -- let players know the vote counted
	      local msg = PlayerResource:GetPlayerName(playerID)..' voted for '..difficulty.name..'.'
	      msg = msg..difficulty.votes..' total votes for '..difficulty.name..'.'
	      Utilities:Print(msg, Utilities:GetPlayerColor(playerID))
	    end
  	end
	end
end

-- returns true if target and value share the same properties, e.g.
-- both are a literal, or a table of literals with the same number
-- of entries
function Settings:IsValidSet(target, value)
	if type(target) == 'number' and type(value) == 'number' then
		return true
	end
	if type(target) == 'string' and type(value) == 'string' then
		return true
	end
	if type(target) == 'boolean' and type(value) == 'boolean' then
		return true
	end
	-- tables are a little harder
	if type(target) == 'table' and type(value) == 'table' then
		-- number mismatch is a fail
		if #target ~= #value then
			return false
		end
		local isGood = true
		-- iterate over values inside then
		for key, val in pairs(target) do
			if value[key] == nil then
				return false
			end
			-- if value is another table, recurse
			if type(value) == 'table' then
				isGood = isGood and Settings:IsValidSet(target[key], value[key])
			else
				isGood = isGood and type(value[key]) == type(target[key])
			end
		end 
		return isGood
	end
	return false
end

-- Parses chat text and converts to a Settings object
-- Since Settings is deeply nested, things if I were to chat 
-- 'gpm' and look up Settings[gpm], that would work, but
-- if I wanted gpm.Clamp, Settings[gpm.Clamp] fails.
function Settings:GetObject(objectText)
	local tokens = Utilities:Tokenize(objectText, '.')
	-- Just in case
	if tokens == nil then return end
	-- drill to target object
	local currentObject = Settings
	for _, token in ipairs(tokens) do
		currentObject = currentObject[token]
		-- drop out if it doesn't exist
		if currentObject == nil then
			return 
		end
	end
	return currentObject
end

-- Sets the value of a non-table Settings entry
function Settings:SetValue(objectText, value)
	local tokens = Utilities:Tokenize(objectText, '.')
	-- Just in case
	if tokens == nil then return false end
	-- this is ugly
	if #tokens == 1 then
		Settings[tokens[1]] = value	
	elseif #tokens == 2 then
		Settings[tokens[1]][tokens[2]] = value		
	elseif #tokens == 3 then
		Settings[tokens[1]][tokens[2]][tokens[3]] = value	
	elseif #tokens == 4 then
		Settings[tokens[1]][tokens[2]][tokens[3]][tokens[4]] = value	
	elseif #tokens == 5 then
		Settings[tokens[1]][tokens[2]][tokens[3]][tokens[4]][tokens[5]] = value	
	elseif #tokens == 6 then
		Settings[tokens[1]][tokens[2]][tokens[3]][tokens[4]][tokens[5]][tokens[6]] = value									
	else
		return false
	end
	return true
end

-- Parses chat tokens and returns a valid command if there was one.  Nil otherwise.
function Settings:GetCommand(tokens)
	for _, command in pairs(chatCommands) do
	  if string.lower(tokens[1]) == string.lower(command) then
	  	return command
	  end
	end
	return
end

-- Parse chat event information 
function Settings:GetChatEventData(event)
	local playerID = event.playerid
	local text = event.text
	return playerID, text
end

-- set host ID to whitelist settings commands
function Settings:SetHostPlayerID()
	hostID = Utilities:GetHostPlayerID()
end

-- this callback gets run once when game state enters DOTA_GAMERULES_STATE_HERO_SELECTION
-- this prevents us from attempting to get the number of players before they have all loaded
function Settings:InitializationTimer()
  -- Register settings vote timer and chat event monitor
  Debug:Print('Begining Settings Initialization.')
	Settings:RegisterChatEvent()
	Timers:CreateTimer(settingsTimerName, {endTime = 1, callback =  Settings['DifficultySelectTimer']} )
end

--Don't run initialization until all players have loaded into the game.
-- I'm not sure if things like GetPlayerCount() track properly before this, 
-- and am not willing to test since this facility is in place and is easier.
if not Flags.isSettingsInitialized then
	Utilities:RegsiterGameStateListener(Settings, 'InitializationTimer', DOTA_GAMERULES_STATE_HERO_SELECTION )
	Flags.isSettingsInitialized = true
end
