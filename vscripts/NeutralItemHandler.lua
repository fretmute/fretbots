-- Dependencies
 -- global debug flag
require "Debug"
 -- Other Flags
require "Flags"
 -- DataTables has helper functions for generating data structures we consume, and querying/acting on that data
require "DataTables"

-- Instantiate ourself
if NeutralItemHandler == nil then
  NeutralItemHandler = {}
end

-- constants for neutral tables

-- Returns a handle to the units current item
function NeutralItemHandler:GetCurrent(unit)
  -- Neutral slot is 16, if the item is in backpack we don't care
  item = unit.GetItemInSlot(16);
  return item;  
end

-- Removes a neutral item if the unit has one equipped
function NeutralItemHandler:RemoveEquipped(unit)
  item = NeutralItemHandler:GetCurrent(unit);
  if item ~= nil then
  	unit:RemoveItem(item);
  end
end

function NeutralItemHandler:GiveBots()
	for _,unit in pairs(Bots)	do
		
	end
end 

function NeutralItemHandler:GetRandom(tier)
  if tier == 1 then
  end
end
