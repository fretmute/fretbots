-- RoleScaled Difficulty.  
-- Note that difficulty files should contain subsets of the settings 
-- table from SettingsDefault.lua
    
local settings =
{
	name = 'RoleScaled',
	description = "Standard, but awards are scaled per role: top heavy for cores, with squishy supports.",
	votes = 0,
	color = '#DA43EF',	
	gpm = 
	{
		scale 				= {1.2, 1.1, 1.0, 0.8, 0.6},
	},
	xpm = 
	{
		scale 				= {1.2, 1.1, 1.0, 0.8, 0.6},
	},			
	deathBonus = 
  {
		scale = 
		{
			gold 					= {1.2, 1.1, 1.0, 0.8, 0.6},
			armor 				= {1.2, 1.1, 1.0, 0.4, 0.2},
			magicResist 	= {1.2, 1.1, 1.0, 0.4, 0.2},
			levels 				= {1.2, 1.1, 1.0, 0.8, 0.6},
			neutral 			= {1.2, 1.1, 1.0, 0.8, 0.6},
			stats 				= {1.2, 1.1, 1.0, 0.8, 0.6}
		},	 
	}, 
}

return settings
