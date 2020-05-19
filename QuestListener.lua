-- Dependencies
 -- global debug flag
require "Debug"

-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;

QuestListener = {}

function QuestListener:onUnitDeath(keys)
	isHero, victim, killer = QuestListener:GetEntityKilledEventData(keys);
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	local killerEntity = nil

	if keys.entindex_attacker ~= nil then
	  killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end
	if isDebug then
		DeepPrintTable(keys)
		DeepPrintTable(victim)
  end
end


-- returns useful data about the kill event
function QuestListener:GetEntityKilledEventData(event)
	local victim = EntIndexToHScript(event.entindex_killed);
  local killer = nil;
	if event.entindex_attacker ~= nil then
	  killer = EntIndexToHScript( event.entindex_attacker )
	end
	local isHero = false;
	if victim:IsHero() and victim:IsRealHero() and not victim:IsIllusion() and not victim:IsClone() then
		isHero = true;
	end
  return isHero, victim, killer;
end

    
function QuestListener.registerEvents()
	ListenToGameEvent("entity_killed", Dynamic_Wrap(QuestListener, 'onUnitDeath'), QuestListener)
end
print("Hey-ho from the QuestListener")
QuestListener.registerEvents()