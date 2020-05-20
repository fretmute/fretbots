require 'Debug'

-- Instantiate ourself
if BuffUnit == nil then
  BuffUnit = {}
end


-- Make someone stronk
function BuffUnit:Hero(unit)
	-- Gotta go fast
  BuffUnit:GiveItem('item_travel_boots_2', unit);
  BuffUnit:GiveItem('item_yasha_and_kaya', unit);
  BuffUnit:GiveItem('item_cyclone', unit);
  BuffUnit:GiveItem('item_force_boots', unit);
  BuffUnit:GiveItem('item_blink', unit);
  -- Make Stronk
  unit:ModifyStrength(1000);
	unit:ModifyAgility(1000);	
	unit:ModifyIntellect(1000);	
	-- Make Rich
	unit:ModifyGold(30000, true, 0);
  -- Level25
	for i=1,24 do
	  unit:HeroLevelUp(false)
	end
end

-- Give someone an item
function BuffUnit:GiveItem(itemName, unit)
  if unit:HasRoomForItem(itemName, true, true) then
  	local item = CreateItem(itemName, unit, unit)
    item:SetPurchaseTime(0)
    unit:AddItem(item)
  end
end