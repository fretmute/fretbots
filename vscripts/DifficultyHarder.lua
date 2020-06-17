-- Harder Difficulty.  
-- Note that difficulty files should contain subsets of the settings 
-- table from SettingsDefault.lua
    
local settings =
{
	name = 'Harder',
	description = "More aggressive death scaling past twenty minutes.",
	votes = 0,
	color = '#e8fc51',	
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
}

return settings
