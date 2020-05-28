-- Creates stats tables for units
-- containts helper functions for manipulating data

-- Global Debug flag
require 'Debug';
 -- Other Flags
require 'Flags'
-- Makes a unit strong
require 'BuffUnit'
-- Settings
require 'Settings'
-- Convenience Utilities
require 'Utilities'
local role = require('RoleUtility')


-- local debug flags
local thisDebug = true
local isDebug = Debug.IsDebug() and thisDebug
local isChatDebug = Debug.IsDebug() and false
local isVerboseDebug = Debug.IsDebug() and false
local isBuff = false

-- Globals 
Bots = {};
Players = {};
AllUnits = {};

-- convenient constants for dumb valve integers
local RADIANT = 2
local DIRE = 3

-- Instantiate the class
if DataTables == nil then
	DataTables = class({});
end

-- Sets up data tables, buffs Fret for debug
function DataTables:Initialize()
	-- Don't do this more than once.
	--if Flags.isStatsInitialized then return end;
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
		  Debug:Print(unit:GetName())
  		local id = PlayerResource:GetSteamID(unit:GetMainControllingPlayer());	
  		local isFret = Debug:IsFret(id);
  		-- Buff Fret for Debug purposes
  		if isFret and not Flags.isDebugBuffed and isBuff then
  			--NeutralItems:GiveRandom(unit,2,1)
        BuffUnit:Hero(unit)		   	      	
        Flags.isDebugBuffed = true
		  end  			
		  -- Initialize data tables for this unit
		  DataTables:GenerateStatsTables(unit);
	end
	-- Purge human side bots 
	DataTables:PurgeHumanSideBots()
	-- Assign a support Pos 5
	DataTables:SetBotPositionFive()
  -- Set Initialized Flag
  Flags.isStatsInitialized = true;
	
	-- debug prints
	if isDebug then
		if Players ~= nil then
			for i,unit in pairs(Players) do
				print('Stats table for Player '.. i)
				DeepPrintTable(unit.stats)
			end
		end
		if Bots ~= nil then
			for i,unit in pairs(Bots) do
				print('Stats table for Bot '.. i)
				DeepPrintTable(unit.stats)
			end
		end		
	end
	
end

-- Generates various data used to track bot stats
function DataTables:GenerateStatsTables(unit)
	-- Is this a bot?
  local thisIsBot = false
  local thisRole = 0
  local thisTeam = 0
	local thisId = 0
	local steamId = PlayerResource:GetSteamID(unit:GetMainControllingPlayer())
	-- Drop out for non-real hero units
	if not DataTables:IsRealHero(unit) then return end
	-- Is bot?
  if PlayerResource:GetSteamID(unit:GetMainControllingPlayer())==PlayerResource:GetSteamID(100) then
  	thisIsBot = true
    table.insert(Bots, unit)
  else
    table.insert(Players, unit)
  end
  table.insert(AllUnits,unit)	
-- PlayerID, Team, Role
  if unit:GetPlayerID() ~= nil then
	  thisId = unit:GetPlayerID()
	  thisTeam=PlayerResource:GetTeam(thisId)
	  thisRole = 0;
	  -- If this is a bot, determine their role - This is by slot for BotXP 			
	  -- Radiant
	  if thisIsBot and (thisTeam == 2) then
	  	if thisId == 0 then thisRole = 2
	  	elseif thisId == 1 then thisRole = 3
	  	elseif thisId == 2 then thisRole = 4
	  	elseif thisId == 3 then thisRole = 5
	  	elseif thisId == 4 then thisRole = 1
	  	end
	  end
	  if thisIsBot and (thisTeam == 3) then
	  	if thisId == 5 then thisRole = 2
	  	elseif thisId == 6 then thisRole = 1
	  	elseif thisId == 7 then thisRole = 5
	  	elseif thisId == 8 then thisRole = 4
	  	elseif thisId == 9 then thisRole = 3
	    end
	  end
 	end
	-- name for debug purposes
 	local thisName = unit:GetName()
  thisRole = DataTables:GetRole(thisName)
 	
	-- create a stats table for the bot
	local stats = 
	  {
	  	-- Number of kills
	  	kills 		=			0,
	  	-- Number of deaths: There is listener for this, we should register and track there	
	  	deaths 		= 		0,
	  	-- If KillStreak gets large, negatively affect multiplier
	  	killStreak = 0,
	  	-- If DeathStreak grows, enhance multiplier
	  	deathStreak = 0,
	  	-- teamNetWorth could be useful for a multiplier for bonuses	  	
	  	teamNetWorth = 0,
	  	-- enemyTeamNetWorth could be useful for a multiplier for bonuses	  	
	  	enemyTeamNetWorth = 0,
	  	-- netowrth
	  	netWorth = 0,
	  	-- Is this a bot?
	  	isBot = thisIsBot,
	  	-- Team
	  	team = thisTeam,
	  	-- Role
	  	role = thisRole,
	  	-- Damage Table (by type)
	  	damageTable = {DAMAGE_TYPE_PHYSICAL=0, DAMAGE_TYPE_MAGICAL=0, DAMAGE_TYPE_PURE=0},
	  	-- Unit name
	  	name = thisName,
	  	-- Skill
	  	skill = DataTables:GetSkill(thisName, thisRole),
	  	-- Current death bonus chances
	  	chance = 
	  	{
	  	  gold = 0,
	  	  armor = 0,
	  	  magicResist = 0,
	  	  levels = 0,
	  	  neutral = 0,
	  	  stats = 0	
	  	},
	  	-- Death bonus awards
	  	awards = 
      {
   			gold 					= 0,
				armor 				= 0,
				magicResist 	= 0,
				levels 				= 0,
				neutral	      = 0,
				stats 				= 0   	
      },	
	  	-- current level of neutral item
	  	neutralTier = 0,
	  	-- Hero isMelee
	  	isMelee = role.IsMelee(unit:GetBaseAttackRange()),
	  	-- player ID
	  	id = thisId
	  }
	  -- Reduce human skill
	  if not thisIsBot then stats.skill = stats.skill * 0.5 end
	  -- Insert the stats object to the bot
	  unit.stats = stats;
	  -- update non-accruing deathBonus chances since they will never change
	  for _, award in pairs(Settings.deathBonus.order) do
			if not Settings.deathBonus.accrue[award] then
				unit.stats.chance[award] = Settings.deathBonus.chance[award]
			end
		end
	  
	  if (isDebug) then
	  	print('Data tables initialized for ' ..thisName .. '. Unit ID: ' .. tostring(stats.id))
	  end
end 

-- Called by OnEntityKilled to update stats of the victim
function DataTables:DoDeathUpdate(victim, killer)
	-- ignore kills by non-heroes (they won't have stats tables)
	if killer.stats == nil then return end
	-- don't track players		
  if not victim.stats.isBot then return end
  -- Most of these numbers are predicated on being killed by the enemy team (ignore denies)
  if victim.stats.team == killer.stats.team then return end
	-- get current kills/deaths (as opposed to stats table)
	local kills = PlayerResource:GetKills(victim.stats.id)
	-- Determine the killstreak at the time of death
	local killStreak = kills - victim.stats.kills 
 -- if killstreak at death is zero, increment death streak
	victim.stats.deathStreak = victim.stats.deathStreak + 1
	-- Kill streak is obviously zero now
  victim.stats.killStreak = 0
	-- Update deaths
	victim.stats.deaths = PlayerResource:GetDeaths(victim.stats.id)
	-- Update kills
	victim.stats.kills = kills
	-- Update Team Worths
	victim.stats.teamNetWorth = DataTables:GetTeamNetWorth(victim.stats.team)
	victim.stats.enemyTeamNetWorth = DataTables:GetTeamNetWorth(killer.stats.team)
	if isDebug then
		print('Updated stats table for ' .. victim.stats.name)
		if isVerboseDebug then DeepPrintTable(victim.stats) end
	end
end

-- Get team net worth 
function DataTables:GetTeamNetWorth(team)
	local net = 0;
	for _,unit in pairs(AllUnits) do
		if unit.stats.team == team then
			net = net + PlayerResource:GetNetWorth(unit.stats.id)
		end
	end
	return net
end
	
-- Returns the net worth of the comparable position on the human side	
-- or zero if there is no mathing human
function DataTables:GetRoleNetWorth(bot)
	local worths = {}
	for _,unit in pairs(AllUnits) do
		if unit.stats.team ~= bot.stats.team then
			table.insert(worths,PlayerResource:GetNetWorth(unit.stats.id))
		end
	end
	Utilities:SortHighToLow(worths)
	if worths[bot.stats.role] ~= nil then
	  return worths[bot.stats.role]
	else
		return 0
	end
end

-- Returns the GPM the comparable position on the human side	
-- or zero if there is no mathing human
function DataTables:GetRoleGPM(bot)
	local data = {}
	local names = {}
	for _,unit in pairs(Players) do
		local num = PlayerResource:GetGoldPerMin(unit.stats.id)
		table.insert(data,num)
	  table.insert(names, unit.stats.name)
	end
	Utilities:SortHighToLow(data)
	if isVerboseDebug then
		print('GPM Table:')
		DeepPrintTable(data)
	end
	if data[bot.stats.role] ~= nil then
	  return data[bot.stats.role], names[bot.stats.role]
	-- specific debug case, pretend we have more players than we do
	elseif isDebug and #Players == 1 then
		return data[1] / bot.stats.role, names[1]	  
	else
		return 0	
	end
end

-- Returns the XPM of the comparable position on the human side	
-- or zero if there is no mathing human
function DataTables:GetRoleXPM(bot)
	local data = {}
	local names = {}
	for _,unit in pairs(Players) do
		local num = PlayerResource:GetXPPerMin(unit.stats.id)
		table.insert(data,num)
		table.insert(names, unit.stats.name)
	end
	Utilities:SortHighToLow(data)
	if isVerboseDebug then
		print('XPM Table:')
		DeepPrintTable(data)
	end
	-- edge case: bot mid is pos2 but the human mid will probably be 1st in this chart
	-- so swap these
	local role = bot.stats.role
	if role == 2 then 
		role = 1
	elseif role == 1 then
		role = 2
	end
	if data[role] ~= nil then
	  return data[role], names[role]
	-- specific debug case, pretend we have more players than we do
	elseif isDebug and #Players == 1 then
		return data[1] / role, names[1]	  
	else
		return 0	
	end
end

-- returns a flat multiplier to represent the skill of the bot, combined with their role.
-- This affects all numeric bonuses
function DataTables:GetSkill(name, role)
	-- valid roles only
	if role < 1 or role > 5 then return 0 end
	-- remember math.Random only returns integers, so multiply / divide by 100
  local skill = math.random(Settings.skill.variance[role][1] * 100, Settings.skill.variance[role][2] * 100) / 100
  -- Warn humans, maybe
  if Settings.skill.isWarn and skill > Settings.skill.warningThreshold then
    Utilities:Print(name.. ' is very talented!', MSG_BAD, ATTENTION)
  end
  return skill
end
	
-- removes bots on the human team from the bots table
-- note that if there are humans on both sides, it will purge the side with more humans
function DataTables:PurgeHumanSideBots()	
  -- determine humans per side
  local radiant = 0
  local dire = 0
  for _,unit in pairs(AllUnits) do
  	if not unit.stats.isBot and unit.stats.team == RADIANT then
  		radiant = radiant + 1
  	elseif not unit.stats.isBot and unit.stats.team == DIRE then
  		dire = dire + 1
  	end
  end
  if isDebug then 
  	print('Radiant Humans: '..radiant..' Dire Humans: '..dire)
  end
  local team
  local countToRemove
  if radiant > dire then 
  	team = RADIANT
  	countToRemove = 5 - radiant
  else
  	team = DIRE
  	countToRemove = 5 - dire
  end
  if isDebug then 
  	print('Removing '..countToRemove..' bots from the human side.')
  end
  local attempts = 0
  local removed = 0
  while removed < countToRemove and attempts < countToRemove do
  	attempts = attempts + 1
	  for i, unit in pairs(Bots) do
	  	if unit.stats.team == team then
	  		table.remove(Bots,i)
	  		removed = removed + 1
	  		print('Removing '..unit.stats.name..' from the bots list.')
	  		break
	  	end
	  end 
	end
end
	
-- Both support bots will initially be set to position four.  
-- Make one bot support 5 (at random)
function DataTables:SetBotPositionFive()
  for _, bot in pairs(Bots) do
  	-- The first position four selected is the unlucky one
  	if bot.stats.role == 4 then 
  		bot.stats.role = 5
  		break
  	end
  end
end	
	
function DataTables:GetRole(hero)
	-- Carry?
	if role.CanBeSafeLaneCarry(hero) then
		if isDebug then print(hero..': role: '..1) end
		return 1
	-- MidLane
	elseif role.CanBeMidlaner(hero) then
		if isDebug then print(hero..': role: '..2) end
		return 2
	-- Offlane
	elseif role.CanBeOfflaner(hero) then
		if isDebug then print(hero..': role: '..3) end
		return 3
	-- Support is slightly more tricky
  elseif role.CanBeSupport(hero) then
  	if isDebug then print(hero..': role: '..4) end
    return 4
  else 
  	if isDebug then print(hero..': role: '..5) end
  	return 5
  end 	
end	
	
-- Returns true if the unit is an actual hero and not a hero-like unit
function DataTables:IsRealHero(unit)
	return unit:IsHero() and unit:IsRealHero() and not unit:IsIllusion() and not unit:IsClone()	
end
	
-- Run this
DataTables:Initialize()

print('DataTables Loaded')


