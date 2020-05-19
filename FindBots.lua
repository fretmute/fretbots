-- Dependencies
 -- global debug flag
require "Debug"
 -- Other Flags
require "Flags"
 -- DataTables has helper functions for generating data structures we consume, and querying/acting on that data
require "DataTables"
 -- Entity Killed monitors kills and updates stats accordingly
require "OnEntityKilled"
 -- Entity hurt monitors damage and updates stats accordingly
require "OnEntityHurt"
-- Version information
require "Version"
-- Timers for periodic buff
require "UpgradeTimer"


-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;


-- Set up Player / Dota Table Data
function InitializeHeroTables()
	-- Don't do this more than once.
	--if Flags.isInitialized then return end;
	-- Lifted From Anarchy - Props
	Units = FindUnitsInRadius(2,
	                              Vector(0, 0, 0),
	                              nil,
	                              FIND_UNITS_EVERYWHERE,
	                              3,
	                              DOTA_UNIT_TARGET_HERO,
	                              88,
	                              FIND_ANY_ORDER,
	                              false);

	Bots={};
	Players={};
	AllUnits = {};
	for i,unit in pairs(Units) do
  		local id = PlayerResource:GetSteamID(unit:GetMainControllingPlayer());	
  		local isFret = Debug:IsFret(id);
  		-- Buff Fret for Debug purposes
  		if (isFret and true) then
  			--NeutralItems:GiveRandom(unit,2,1)
        BuffHero(unit)		   	      	
		  end  			
		  -- Initialize data tables for this unit
		  DataTables:GenerateStatsTables(unit);
		  -- Set Initialized Flag
		  Flags.isInitialized = true;
	end
	
	if Players ~= nil then
		for _,bot in pairs(Players) do
			DeepPrintTable(bot.stats)
		end
	end
		
	-- Print version to console 
	print(versionString);
	print('Version: ' .. version);
end

-- Make someone stronk
function BuffHero(unit)
	-- Gotta go fast
  GiveItem("item_travel_boots_2", unit);
  GiveItem("item_yasha_and_kaya", unit);
  GiveItem("item_cyclone", unit);
  GiveItem("item_force_boots", unit);
  GiveItem("item_blink", unit);
  -- Make Stronk
  unit:ModifyStrength(1000);
	unit:ModifyAgility(1000);	
	unit:ModifyIntellect(1000);	
	unit:ModifyGold(30000, true, 0);
	for i=1,29 do
	  unit:HeroLevelUp(false)
	end
	for i=0,16 do
		item = unit:GetItemInSlot(i)
		if item and isDebug then
			print('Slot ' .. tostring(i) .. ": " .. item:GetName());
		end
	end
end

-- Give someone an item
function GiveItem(itemName, unit)
  if unit:HasRoomForItem(itemName, true, true) then
  	local item = CreateItem(itemName, unit, unit)
    item:SetPurchaseTime(0)
    unit:AddItem(item)
  end
end

-- Execute
InitializeHeroTables()