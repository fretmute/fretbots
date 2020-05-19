-- Should require the constants file, or at least know what they are, I suppose
require 'BotBuffMgrConstants'


-- All Plugins must declare top level objects with their name
if TestPlugin == nil then
	TestPlugin =
	{
		-- Required Config Info
		Config = 
		{
			-- When this plugin should be fired
			Event 			=   'EVENT_DEATH'
			
		}
	}
end


PluginInfo = 