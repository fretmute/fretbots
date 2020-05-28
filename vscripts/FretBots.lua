-- Dependencies
 -- global debug flag
require 'Debug'
 -- Other Flags
require 'Flags'
 -- DataTables has helper functions for generating data structures we consume, and querying/acting on that data
require 'DataTables'
 -- Entity Killed monitors kills and provides bonuses (if settings dictate)
require 'OnEntityKilled'
 -- Entity hurt monitors damage and updates stat tables accordingly
require 'OnEntityHurt'
-- Version information
require 'Version'
-- Timers for periodic bonuses
require 'BonusTimers'
-- Utilities
require 'Utilities'


-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;

-- Starting this script is largely handled by the requires, as separate pieces start
-- themselves.  However, every time we reload this we want to reinitialize the initial table, so
-- that is called here.
function Initialize()
	-- Override difficulty, perhaps -- note there could be possible race conditions, but this is unlikely due to the
	-- "immediate" bot bonus being offset some from the script being loaded
	-- ##TODO:  Implement that -^
	Settings:Initialize('debug')
	DataTables:Initialize()
	-- Print version to console 
	print(versionString);
	print('Version: ' .. version);
	Utilities:Print('Fret Bots! Version: ' .. version, MSG_GOOD, MATCH_READY)
end

-- Execute
Initialize()