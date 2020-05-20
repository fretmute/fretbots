-- Registers a timer function that's used to do things at certain points during the game

-- This register the Timer helpers
require 'Timers'
 -- global debug flag
require 'Debug'
-- NeutralItem Handling
require 'NeutralItems'
-- DataTables and associated globals
require 'DataTables'

-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;

-- Instantiate ourself
if BonusTimers == nil then
  BonusTimers = {}
end

-- timer names
local names = 
{
	NeutralItemTimer = 'NeutralItemTimer',
	PerMinuteTimer = 'PerMinuteTimer'
}
local inits = 
{
	NeutralItemTimer = false,
	PerMinuteTimer = false	
}

-- Internal flags for flagging if stuff has been done
local awardedTier1 = false;
local awardedTier2 = false;
local awardedTier3 = false;
local awardedTier4 = false;
local awardedTier5 = false;
local awardTier1 = 400;
local awardTier2 = 800;
local awardTier3 = 1200;
local awardTier4 = 1600;
local awardTier5 = 2000;
local isInitShown = false

-- Runs every five seconds.  Gets actual elapsed dota time.  Insert logic and functions calls to do things
-- periodically here.  
function NeutralItemTimer()
	-- inform we've register
	if not inits.NeutralItemTimer then
		print('NeutralItemTimer method registered')
		inits.NeutralItemTimer = true
	end
  -- This returns the number of seconds on the game clock (once the game starts at 00:00 as opposed
  -- to the negative time the game starts with
  time = GameRules:GetDOTATime(false, false)
  -- Logic to do things here, we'll use this method primarily for giving neutrals to bots  
    if time > awardTier1 and not awardedTier1 then
      NeutralItems:GiveTierToBots(1)
	    awardedTier1 = true;
    elseif time > awardTier2 and not awardedTier2 then
    	NeutralItems:GiveTierToBots(2)
	    awardedTier2 = true;
    elseif time > awardTier3 and not awardedTier3 then
    	NeutralItems:GiveTierToBots(3)
	    awardedTier3 = true;
    elseif time > awardTier4 and not awardedTier4 then
    	NeutralItems:GiveTierToBots(4)
	    awardedTier4 = true;
    elseif time > awardTier5 and not awardedTier5 then
    	NeutralItems:GiveTierToBots(5)
	    awardedTier5 = true;
	    Timers:RemoveTimer(names.NeutralItemTimer)
    end
  -- Required by timers, tells the helper when to rerun this method
  return 5
end
  
-- Register the timers and start them
Timers:CreateTimer(names.NeutralItemTimer, {callback = NeutralItemTimer} )
  