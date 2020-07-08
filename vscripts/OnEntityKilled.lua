-- Dependencies
 -- global debug flag
require 'Debug'
 -- Global flags
 require 'Flags'
 -- Data Tables and helper functions
require 'DataTables'
-- Awards for bots
require 'AwardBonus'
-- Settings
require 'Settings'
-- Game State Tracker
require 'GameState'

-- local debug flag
local thisDebug = false; 
local isDebug = Debug.IsDebug() and thisDebug;

-- Instantiate ourself
if EntityKilled == nil then
  EntityKilled = {}
end

-- Event Listener
function EntityKilled:OnEntityKilled(event)
  -- Get Event Data
	isHero, victim, killer = EntityKilled:GetEntityKilledEventData(event);
	-- Log Tower/Building kills to track game state
	if victim:IsTower() or victim:IsBuilding() then
		GameState:Update(victim)
	end
	-- Drop out for non hero kills
	if not isHero then return end;
	-- Do Table Update
	DataTables:DoDeathUpdate(victim, killer);	
	-- Dynamic Adjustment (maybe)
	DynamicDifficulty:Adjust(victim)	
	-- Give Awards (maybe)
	AwardBonus:Death(victim)
	-- Sound if it is a player?
	if Settings.isPlayerDeathSound then
	  Utilities:RandomSound(PLAYER_DEATH_LIST)
	end
	-- Debug Print
	if isDebug then
		DeepPrintTable(victim)
  end
end

-- returns useful data about the kill event
function EntityKilled:GetEntityKilledEventData(event)
	-- Victim
	local victim = EntIndexToHScript(event.entindex_killed);
  -- Killer
  local killer = nil;
	if event.entindex_attacker ~= nil then
	  killer = EntIndexToHScript( event.entindex_attacker )
	end
	-- IsHero
	local isHero = false;
	if victim:IsHero() and victim:IsRealHero() and not victim:IsIllusion() and not victim:IsClone() then
		isHero = true;
	end
  return isHero, victim, killer;
end

-- Registers Event Listener    
function EntityKilled:RegisterEvents()
	if not Flags.isEntityKilledRegistered then
	  ListenToGameEvent('entity_killed', Dynamic_Wrap(EntityKilled, 'OnEntityKilled'), EntityKilled)
    Flags.isEntityKilledRegistered = true;
    if true then
  		print('EntityKilled Event Listener Registered.')
		end
  end
end

