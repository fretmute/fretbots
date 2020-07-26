-- Dependencies
 -- global debug flag
require 'Debug'
 -- Global flags
 require 'Flags'
 -- Data Tables and helper functions
require 'DataTables'
 -- This registers the Timer helpers
require 'Timers'

-- local debug flag
local thisDebug = false
local isDebug = Debug.IsDebug() and thisDebug

-- Instantiate ourself
if HeroLoneDruid == nil then
  HeroLoneDruid = {}
  -- Global bear entity
  HeroLoneDruid.Bear = nil
end

-- if they don't summon the bear before two minutes, then they don't get items
local bearSpawnCount					= 	0
local bearSpawnInterval				=		5
local bearSpawnFailSafe 			=   120
local bearSpawnTimerName 			= 'bearSpawnTimerName'

-- Event Listener
function HeroLoneDruid:OnEventCallback(event)
	-- Get other event data
	local itemname, playerID = HeroLoneDruid:GetItem(event)
end

-- Returns event data
function HeroLoneDruid:GetItem(event)
  local itemname = nil
  local playerID = nil
  if event.itemname  ~= nil then
	  itemname = event.itemname
	end
	if event.PlayerID ~= nil then
		playerID = event.PlayerID
	end
  return itemname, playerID
end

-- returns the lone druid bear entity if it exists
function HeroLoneDruid:FindBear()
	local units = FindUnitsInRadius(2,
	                              Vector(0, 0, 0),
	                              nil,
	                              FIND_UNITS_EVERYWHERE,
	                              3,
	                              DOTA_UNIT_TARGET_HERO,
	                              88,
	                              FIND_ANY_ORDER,
	                              false);                             
	for _, unit in pairs(units) do
		if unit:GetName() == 'npc_dota_lone_druid_bear' then
			Debug:Print('Found lone druid bear.')
			return unit
		end
	end	      
	-- nil if not found   
	return nil
end    


-- Registers Event Listener    
function HeroLoneDruid:RegisterEvents()
	if not Flags.isHeroLoneDruidRegistered then
	  ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(HeroLoneDruid, 'OnEventCallback'), HeroLoneDruid)
    Flags.isHeroLoneDruidRegistered = true;
    if isDebug then
  		print("HeroLoneDruid Event Listener Registered.")
		end
  end
end

-- Waits for lone druid to summon his bear.  Caches bear entity when this is done.
-- Also registers item watcher.
function HeroLoneDruid:BearSpawnTimer()
	local isFound = false
	local bear = HeroLoneDruid:FindLoneDruidBear()
	-- bear found, do stuff and then stop this timer
	if bear ~= nil then
		Debug:Print('HeroLoneDruid: Bear Found. Starting LoneDruid item event watcher.')
		HeroLoneDruid.Bear = bear
		Timers:RemoveTimer(bearSpawnTimerName)
		return nil
	end
	-- bear not found, try again in five seconds
	bearSpawnCount = bearSpawnCount + bearSpawnInterval
	if bearSpawnCount < bearSpawnFailSafe then
		return bearSpawnInterval	
	else
		Debug:Print('Bear not found before fail safe timer reached.')
		Timers:RemoveTimer(bearSpawnTimerName)
		return nil
	end
end

-- Performs initialization activies
-- Right now this whole object is just used to force items onto the lone druid bear, so 
-- if a lone druid isn't in the game, this will do nothing
function HeroLoneDruid:Initialize()
	-- If settings aren't enabled, do nothing
	if not Settings.heroSpecific.loneDruid.enabled then
		Debug:Print('Lone Druid Specific Extensions are disabled.  HeroLoneDruid Exiting.')
		return
	end
	local isContinue = false
	for _, unit in pairs(AllUnits) do
		if unit:GetName() == 'npc_dota_hero_lone_druid' then
			isContinue = true
			break
		end
	end
	-- Drop out if lone druid not found
	if not isContinue then 
			Debug:Print('Lone Druid Specific Extensions are enabled, but Lone Druid is not present.  HeroLoneDruid Exiting.')
		return
	end
	-- The bear doesn't exist until it gets cast once, so start a time to wait for that
	-- This method will cache the bear entity and start the item listener once it spawns
	Timers:CreateTimer(bearSpawnTimerName, {endTime = 1, callback =  HeroLoneDruid['BearSpawnTimer']} )
end