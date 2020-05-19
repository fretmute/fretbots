ListenToGameEvent('entity_hurt', damage_counter, nil)

-- create damage table based on player IDs
function create_damage_table(ids)
	damage_table={}
	for i in pairs(ids) do
		damage_table[ids[i]]={DAMAGE_TYPE_PHYSICAL=0, DAMAGE_TYPE_MAGICAL=0, DAMAGE_TYPE_PURE=0}
	end
end


create_damage_table({0})

function damage_counter(event)
	-- get the victim id
	victim_id=EntIndexToHScript(event.entindex_killed):GetPlayerID()

	-- get damage type
	if event.entindex_inflictor~=nil then
		inflictor_table=EntIndexToHScript(event.entindex_inflictor):GetAbilityKeyValues()
		if inflictor_table['AbilityUnitDamageType'] == nil then -- assume item damage is magical
			damage_type='DAMAGE_TYPE_MAGICAL'
		else
			damage_type=tostring(inflictor_table['AbilityUnitDamageType'])
		end
	else
		damage_type=tostring('DAMAGE_TYPE_PHYSICAL')
	end

	-- get damage value
	damage=event.damage

	-- accumulate damage values
	if damage_table[victim_id] then 
		damage_table[victim_id][damage_type]=damage_table[victim_id][damage_type]+damage
		GameRules:SendCustomMessage(damage_type .. ': ' .. tostring(damage_table[victim_id][damage_type]),1,1)
	end
end
