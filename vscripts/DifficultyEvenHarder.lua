-- EvenHarder Difficulty.  
-- Note that difficulty files should contain subsets of the settings 
-- table from SettingsDefault.lua
    
local settings =
{
	name = 'EvenHarder',
	description = "Aggressive death scaling with upper clamps disabled. Bots will be rich.",
	votes = 0,
	color = '#e8961c',
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
	    neutral 			= {30, 	420},
	    stats					= {1, 	10},	
	  },	
    clampOverride = 
		{
			gold 					= true,
			armor 				= true,
			magicResist 	= true,
			levels 				= true,
			neutral 			= true,
			stats 				= true
		},		  
		range = 
		{
    	gold 					= {0, 750},
      armor 				= {0, 4},
      magicResist 	= {0, 4},
      levels 				= {0, 2},
      neutral 			= {30, 180},
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
}

return settings
