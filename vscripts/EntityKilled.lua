-- Dependencies
require "Debug"  

-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;

-- Instantiate the class
if EntityKilled == nil then
	EntityKilled = {};
  -- register for the event
  ListenToGameEvent("entity_killed", Dynamic_Wrap(EntityKilled, 'OnEntityKilled'),self)
	if (isDebug) then
		GameRules:SendCustomMessage("Entity_Killed event listener registered.", 1, 1);
	end
end


-- Callback for the event
function EntityKilled:OnEntityKilled(event)
	if (isDebug) then
		print("Entity Killed Fired!")
	end
	-- Get data
	isHero, victim, killer = EntityKilled:GetEntityKilledEventData(event);
	victim.stats.Deaths = victim.stats.Deaths + 1;
	GameRules:SendCustomMessage("Deaths: " .. tostring(victim.stats.Deaths), 1, 1);
	-- Drop out if the thing killed was not a hero
  if not isHero then return end;

end

-- returns useful data about the kill event
function EntityKilled:GetEntityKilledEventData(event)
	local victim = EntIndexToHScript(event.entindex_killed);
  local killer = nil;
	if event.entindex_attacker ~= nil then
	  killer = EntIndexToHScript( event.entindex_attacker )
	end
	local isHero = false;
	if victim:IsHero() and victim:IsRealHero() and notvictim:IsIllusion() and not victim:IsClone() then
		isHero = true;
	end
  return isHero, victim, killer;
end
