-- Easier Difficulty.  
-- Note that difficulty files should contain subsets of the settings 
-- table from SettingsDefault.lua
    
local settings =
{
	name = 'Easier',
	description = "Very minor death bonuses. Probably pretty easy.",
	votes = 0,
	color = '#00ffaa',	
	neutralItems = 
	{
		enabled = true,
		isRemoveUsedItems = true,
		maxPerTier = 4,
		tierOffset = 0,
		timings = {420, 1020, 1620, 2220, 3600}
	},	
	deathBonus = 
  {
    isRangeTimeScaleEnable = true,
    isClampTimeScaleEnable = true, 		
		clampTimeScale = 
		{
 			gold 					= 2400,
			armor 				= 2400,
			magicResist 	= 2400,
			levels 				= 2400,
			neutral 			= 2400,
			stats 				= 2400,   					
		},	
		rangeTimeScale = 
		{
 			gold 					= 2400,
			armor 				= 2400,
			magicResist 	= 2400,
			levels 				= 2400,
			neutral 			= 2400,
			stats 				= 2400,   					
		},		
		clamp = 
	  {
	  	gold 					= {100, 300},
	    armor 				= {0, 1},
	    magicResist 	= {0, 1},
	    levels 				= {0, 1},
	    neutral 			= {0, 60},
	    stats					= {0, 1},	
	  },  	
	}, 
}

return settings
