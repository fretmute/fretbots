-- Functions for dynamically adjusting bot diffculty

-- Global Debug flag
require 'Debug';
 -- Other Flags
require 'Flags'
-- Settings
require 'Settings'
-- Convenience Utilities
require 'Utilities'

-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;
local isDebugChat = isDebug and true

-- announce bonuses to chat?
local isChat = true;

-- timer names
local settingsCacheTimerName = 'settingsCacheTimerName'

-- Instantiate ourself
if DynamicDifficulty == nil then
  DynamicDifficulty = {}
end

-- this represents the settings prior to any adjustments
if cache == nil then
	local cache = {}
end

-- Dynamically adjusts settings values to adjust difficulty dynamically.
-- argument is always the victim of a kill, since this is called from within
-- the OnEntityKilled() event handler
function DynamicDifficulty:Adjust(victim)
	-- don't attempt this before it's ready
	if not Flags.isDynamicDifficultyFinalized then return end
	-- ensure we're enabled
	if not Settings.dynamicDifficulty.enabled then return end
	-- do not do anything for humans
	if not victim.stats.isBot then return end
	-- GPM
	DynamicDifficulty:MakeAdjustment('gpm')
	-- XPM
	DynamicDifficulty:MakeAdjustment('xpm')
end

-- Makes an adjustment to one of the two knobs (gpm / xpm)
function DynamicDifficulty:MakeAdjustment(knob)
	local bonus, advantage, increments =  
			DynamicDifficulty:GetCurrentAdjustment(Settings.dynamicDifficulty[knob], victim)
	if bonus > 0 then
		Settings[knob].offset = cache[knob].offset + bonus
		-- adjust upper clamp as well
		Settings[knob].clamp[2] = cache[knob].clamp[2] + bonus
		if isDebugChat then
			local msg = 'Bots are behind! Human advantage: '..advantage..' kills. '
			local msg = msg..'Adjusting Bot '..string.upper(knob)..
			            ' Offset: '..bonus..' ('..(increments+1)..' deficit increments)'
			Utilities:Print(msg,MSG_WARNING)
		end
	-- if bonus drops to zero, reapply cached values
	else
		Utilities:DeepCopy(cache[knob], Settings[knob])
	end	
end
	
	
-- Returns current scaling data for a given dynamic adjustment
function DynamicDifficulty:GetCurrentAdjustment(settings, victim)
	--if this adjustment is not enabled, return 0
	if not settings.enabled then 
		return 0 
	end
	local bonus = 0
	local kills = victim.stats.humanKillAdvantage
	local threshold = settings.advantageThreshold
	local base = settings.base
	local incrementEvery = settings.incrementEvery
	local incrementValue = settings.increment
	-- get human advantage
	local advantage = victim.stats.humanKillAdvantage
	if advantage > settings.advantageThreshold then
		-- determine actual value
  	bonus = bonus + settings.base
  	local increments = math.floor((kills - threshold) / incrementEvery)
  	bonus = bonus + (increments * incrementValue)
  	return bonus, advantage, increments
  -- below threshold, return 0
  else
		return 0
	end
end	

-- Disables dynamic difficulty (without adjusting current offsets)
function DynamicDifficulty:Suspend()
  Settings.dynamicDifficulty.enabled = false
end

-- Enables dynamic difficulty
function DynamicDifficulty:Enable()
  Settings.dynamicDifficulty.enabled = true
end

-- Restores GPM/XPM offsets to default
function DynamicDifficulty:Reset()
  Utilities:DeepCopy(cache.gpm,Settings.gpm)
  Utilities:DeepCopy(cache.xpm,Settings.xpm)
end

-- Toggles the enable state of DynamicDifficulty
function DynamicDifficulty:Toggle()
  Settings.dynamicDifficulty.enabled = not Settings.dynamicDifficulty.enabled
end

-- Waits until settings are chosen and then caches them
function DynamicDifficulty:SettingsCacheTimer()
  -- check if settings are ready, try again later if not
  if not Flags.isSettingsFinalized then
  	return 1
  end
  -- otherwise, cache values and stop the timer
  cache = Utilities:CloneTable(Settings)
 	Debug:Print('Dynamic Difficulty Settings Cached Timer Complete. Exiting.')
 	Timers:RemoveTimer(settingsCacheTimerName)
 	Flags.isDynamicDifficultyFinalized = true 	
	return nil 
end

-- This file depends on caching the default offset values when the settings
-- are initialized.  Start a timer that watches for the isSettingsFinalized
-- flag and caches when it sets to true.
if not Flags.isDynamicDifficultyInitialized then	
	Debug:Print('Registering Dynamic Difficulty Settings Cache Timer')
	Timers:CreateTimer(settingsCacheTimerName, {endTime = 1, callback =  DynamicDifficulty['SettingsCacheTimer']} )
	Flags.isDynamicDifficultyInitialized = true
end
