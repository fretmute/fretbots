-- define the functions for the thinker to take
-- the function itself
function SuperBots()
	-- defione the current game time
	time=GameRules:GetDOTATime(false, true)
	--condition for the bonuses to be given: game not paused, time has passed time period.
	run_condition= GameRules:IsGamePaused()==false and time>=period*freq
	if run_condition then -- if the condition or bonuses is met
		bonus_message(give_bonus(period)) -- give the bonus for that period
		period=period+1 -- advance 1 period
		return 1 -- check every second
	else 
		return 1
	end
end


-- get the bots 
function find_bots()
	Units = FindUnitsInRadius(2,
	                              Vector(0, 0, 0),
	                              nil,
	                              FIND_UNITS_EVERYWHERE,
	                              3,
	                              DOTA_UNIT_TARGET_HERO,
	                              88,
	                              FIND_ANY_ORDER,
	                              false)

	bots={}
	for _,unit in pairs(Units) do
	      if PlayerResource:GetSteamID(unit:GetMainControllingPlayer())==PlayerResource:GetSteamID(100) then
	        table.insert(bots, _,unit)
	      end
	end
end

-- the function that define the bonuses for each period
function give_bonus(period)
	if period==0 then -- 0 min
		GameRules:SendCustomMessage('[=Superbots=] Match Start',1,1)
		return{
		add_hp_regen(1),
		add_mana_regen(1),
		add_armor(1),
		add_magic_resist(2)}
	elseif period==1 then -- 5 min 
		GameRules:SendCustomMessage('[=Superbots=] 5:00',1,1)
		return{
		give_level(1),
		give_tp(),
		add_hp_regen(1),
		add_mana_regen(1),
		add_armor(1),
		add_magic_resist(2)}
	elseif period==2 then -- 10 min
		GameRules:SendCustomMessage('[=Superbots=] 10:00',1,1)
		return{
		give_level(2),
		give_tp(),
		add_hp_regen(1),
		add_mana_regen(1),
		add_magic_resist(2),
		add_stats(5)}
	elseif period==3 then -- 15 min
		GameRules:SendCustomMessage('[=Superbots=] 15:00',1,1)
		return{
		give_level(2),
		give_tp(),
		add_hp_regen(1),
		add_mana_regen(1),
		add_armor(1),
		add_magic_resist(4),
		add_stats(5)}
	elseif period==4 then -- 20 min
		GameRules:SendCustomMessage('[=Superbots=] 20:00',1,1)
		return{
		give_level(2),
		add_stats(5),
		give_tp(),
		add_hp_regen(1),
		add_mana_regen(1),
		add_magic_resist(4)}
	elseif period==5 then -- 25 min
		GameRules:SendCustomMessage('[=Superbots=] 25:00 - Neutral Item',1,1)
		SendToConsole('dota_bot_give_item item_timeless_relic')
		return{
		give_level(2),
		add_stats(10),
		add_armor(-1),
		give_tp(),
		add_magic_resist(4)}
	elseif period==6 then -- 30 min
		GameRules:SendCustomMessage('[=Superbots=] 30:00',1,1)
		return{
		give_level(2),
		add_stats(10),
		add_armor(-1),
		give_tp()}
	elseif period==7 then -- 35 min
		GameRules:SendCustomMessage('[=Superbots=] 35:00',1,1)
		return{
		give_tp(),
		give_level(2),
		add_stats(10),
		add_armor(-1)}
	elseif period==8 then -- 40 min
		GameRules:SendCustomMessage('[=Superbots=] 40:00 Script Complete',1,1)
		return{
		add_stats(10),
		give_level(3),
		add_armor(-1)}
	end
end



--------------------- the functions to do the bonuses ------------------------------
-- add stats 
function add_stats(n)
	for _,bot in pairs(bots) do
      stat=bot:GetBaseStrength()
      bot:SetBaseStrength(stat+n)
      stat=bot:GetBaseAgility()
      bot:SetBaseAgility(stat+n)
      stat=bot:GetBaseIntellect()
      bot:SetBaseIntellect(stat+n)
  	end
  	return tostring(n) .. ' stats'
end

-- add armor
function add_armor(n)
	for _,bot in pairs(bots) do
		armor=bot:GetPhysicalArmorBaseValue()
    	basearmor=bot:GetAgility()*0.16
    	bot:SetPhysicalArmorBaseValue(armor-basearmor+n)
	end
	return tostring(n) .. ' armor'
end

-- add magic resist
function add_magic_resist(n)
	for _,bot in pairs(bots) do
      mr=bot:GetBaseMagicalResistanceValue()
      bot:SetBaseMagicalResistanceValue(mr+n)
    end
    return tostring(n) .. ' MR' 
end

-- add hp regen
function add_hp_regen(n)
	for _,bot in pairs(bots) do
      strregen=bot:GetStrength()/10
      basehpregen=bot:GetBaseHealthRegen()
      bot:SetBaseHealthRegen(basehpregen-strregen+n)
  	end
  	return tostring(n) .. ' hp regen'
end

-- add mana regen
function add_mana_regen(n)
	for _,bot in pairs(bots) do
      intregen=bot:GetIntellect()/20
      manaregen=bot:GetBaseManaRegen()
      bot:SetBaseManaRegen(manaregen-intregen+n)
  	end
  	return tostring(n) .. ' mana regen'
end

-- add primary attribute 
function add_primary_attr(n)
	for _,bot in pairs(bots) do
		primeattr=bot:GetPrimaryAttribute()
		if primeattr==0 then 
			stat=bot:GetBaseStrength()
			bot:SetBaseStrength(stat+n)
		elseif primeattr==1 then 
			stat=bot:GetBaseAgility()
			bot:SetBaseAgility(stat+n)
		elseif primeattr==2 then 
			stat=bot:GetBaseIntellect()
			bot:SetBaseIntellect(stat+n)
		end
	end
	return tostring(n) .. ' Primary stat'
end

-- give tp scroll 
function give_tp()
	SendToConsole('dota_bot_give_item item_tpscroll')
	return 'TP scroll'
end

-- give level
function give_level(n)
	SendToConsole('dota_bot_give_level ' .. tostring(n))
	return tostring(n) .. 'level'
end



------ utility to send message about the bonuses. 
function bonus_message(bonuses)
	msg=''
	for b in pairs(bonuses) do
		msg=msg .. bonuses[b] .. '.  '
	end
	GameRules:SendCustomMessage(msg,1,1)
end


------ the function that initiate variables used by the script
function superbots_initiate()
	-- find the bots
	find_bots()

	-- period starts at 0
	period=0

	-- frequency that the script should give bonuses and advance to next period.
	freq= 300 -- every 5 mins
	------ finds a player to set the thinker fnction on
	thinker_player=nil
	i=0
	while thinker_player==nil do
		if PlayerResource:GetPlayer(i)~=nil then
			thinker_player = PlayerResource:GetPlayer(i)
		end
		i=i+1
	end
end


-- if script is already running, don't run another instance
if is_running==nil then
	is_running=true
	superbots_initiate()
	GameRules:SendCustomMessage('[=Superbots=] Superbots TryHard Botscript Initiated',1,1)
	SendToConsole('script_reload_code 'GPM.lua'')
	thinker_player:SetThink(SuperBots, nil, 'SuperBots')
else 
	GameRules:SendCustomMessage('Superbots start failed. [=Superbots=] Is already running!',1,1)
end