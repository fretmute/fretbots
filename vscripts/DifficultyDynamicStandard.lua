-- DynamicStandard Difficulty.  
-- Note that difficulty files should contain subsets of the settings 
-- table from SettingsDefault.lua
    
local settings =
{
	name = 'DynamicStandard',
	description = "Like Standard, but with dynamic adjustments enabled.",
	votes = 0,
	color = '#800080',	
	dynamicDifficulty = 
	{
		enabled					= true
	}
}

return settings
