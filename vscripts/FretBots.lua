-- Dependencies
 -- global debug flag
require 'resources/Debug'
 -- Other Flags
require 'resources/Flags'
 -- DataTables has helper functions for generating data structures we consume, and querying/acting on that data
require 'resources/DataTables'
 -- Entity Killed monitors kills and provides bonuses (if settings dictate)
require 'resources/OnEntityKilled'
 -- Entity hurt monitors damage and updates stat tables accordingly
require 'resources/OnEntityHurt'
-- Version information
require 'resources/Version'
-- Timers for periodic bonuses
require 'resources/BonusTimers'
-- Utilities
require 'resources/Utilities'
-- Dynamic Difficulty Adjustor
require 'resources/DynamicDifficulty'
-- Settings
require 'resources/Settings'
-- Timers
require 'resources/Timers'
-- Hero Specifc Extensions
require 'resources/HeroLoneDruid'
-- Role Determination
require 'resources/RoleDetermination'

-- Instantiate ourself
if FretBots == nil then
  FretBots = {}
end

-- local debug flag
local thisDebug = false; 
-- set true to prevent initialize from returning when it realizes
-- that it has already been run once
local isAllowMultipleStarts = false;
local isDebug = Debug.IsDebug() and thisDebug;

-- other local vars
local playersLoadedTimerName = 'playersLoadedTimerName'
local isAllPlayersSpawned = false
local playerSpawnCount = 0
-- if game time goes past this point, then assume all players loaded
local playerLoadFailSafe = -75
-- Time at which to stop the BotRoleDetermination timer and declare rols
local BotRoleDeterminationTime = 60

-- Starting this script is largely handled by the requires, as separate pieces start
-- themselves. DataTables cannot be initialized until all players have loaded, so
-- this function (which gets called at the beginning of pre game) in turn starts a 
-- timer method to monitor for all players being loaded, which will in turn
-- initialize the data tables
function FretBots:Initialize()
	-- Randomize!
	FretBots:SetRandomSeed()
	-- Register the listener that will check for all players spawning and then init datatables
	ListenToGameEvent('dota_on_hero_finish_spawn', Dynamic_Wrap(FretBots, 'OnPlayerSpawned'), FretBots)
	Timers:CreateTimer(playersLoadedTimerName, {endTime = 1, callback = FretBots['PlayersLoadedTimer']} )

end

-- Runs until all players are loaded in and then initializes the DataTables
function FretBots:PlayersLoadedTimer()
	-- if all players are loaded, initialize datatables and stop timer
	if isAllPlayersSpawned then
		DataTables:Initialize()
		-- Set the host ID for whitelisting settings chat commands
		Settings:SetHostPlayerID()
		-- Start bonus timers (they require DataTables to exist)
		BonusTimers:Initialize()
		-- Start bot role determination timer
		RoleDetermination:Initialize()		
		-- Register EntityHurt Listener
		EntityHurt:RegisterEvents()
		-- Register EntityKilled Listener
		EntityKilled:RegisterEvents()
		-- Hero Specific extensions - these will stop themselves if they 
		-- determine that they are not enabled
		-- Disabled until this works
		-- HeroLoneDruid:Initialize()
		-- Remove this timer
		Timers:RemoveTimer(playersLoadedTimerName)
	  return nil
	end
	-- Check once per second until all players have loaded
	local count = Utilities:GetPlayerCount()
	if playerSpawnCount == count then
		Debug:Print('All players have spawned.')
		isAllPlayersSpawned = true
	end
	-- Check if we're past the load timeout
	local gameTime = Utilities:GetAbsoluteTime()
	if gameTime > playerLoadFailSafe then
		Debug:Print('Spawn timer limit exceeded.  Proceeding.')
		isAllPlayersSpawned = true
	end
	--Debug:Print('Waiting for players to spawn: '..math.ceil(gameTime)..' : '..playerLoadFailSafe)
	return 1
end

function FretBots:OnPlayerSpawned(event)
	playerSpawnCount = playerSpawnCount + 1
end

-- Sets the random seed for the game, and burns off the initial bad random number
function FretBots:SetRandomSeed()
	local timeString = GetSystemTime()
	timeString = string.gsub(timeString,':','')
	local serverTime = Time()
	serverTime = serverTime - math.floor(serverTime)
	local seed = tonumber(timeString) + serverTime 
	seed = math.floor(seed * 100000)
	math.randomseed(seed)
	local temp = math.random()
end

-- Start things up (only once)
if not Flags.isFretBotsInitialized then
	-- Print version to console 
	print('Version: ' .. version)
	print(versionString)
	-- Welcome Message
	Utilities:Print('Bots are fatter than you! Version: ' .. version .. '. These bots are absolutely unfair based on the difficulty you choose, so do not feel bad if you lose. Enjoy the game. Credit to Fretmute.', MSG_GOOD, MATCH_READY)	
	-- Register the listener that will run Initialize() once the game starts
	Utilities:RegsiterGameStateListener(FretBots, 'Initialize', DOTA_GAMERULES_STATE_PRE_GAME )
	Flags.isFretBotsInitialized = true
end
