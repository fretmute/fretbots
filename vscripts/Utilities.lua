-- Provides for common utilites
if Utulities == nil then
	Utilities = 
	{
		listeners = 
		{
			names = {},
			objects = {}
		}
	}
end

-- constants for use in these methods
MSG_GOOD = 1
MSG_WARNING = 2
MSG_BAD = 3
-- sound constan		ts
DISASTAH						 = 'soundboard.disastah'
FIRECRACKER 				 = 'soundboard.new_year_firecrackers'
MATCH_READY     		 = 'Stinger.MatchReady'
ATTENTION       		 = 'soundboard.rimshot'
BEAUTIFUL       		 = 'soundboard.krasavchik'
BEEP            		 = 'DotaSOS.TestBeep'
ROSHAN          		 = 'Roshan.Death'
RUSSIAN_REKT    		 = 'soundboard.eto_prosto_netchto'
SAD_TROMBONE    		 = 'soundboard.sad_bone'
BRUTAL          		 = 'soundboard.brutal'
GG              		 = 'soundboard.ehto_g_g'
OH_MY_LORD      		 = 'soundboard.oh_my_lord'
QUESTIONABLE    		 = 'soundboard.that_was_questionable'
WHAT_HAPPENED   		 = 'soundboard.what_just_happened'
NEXT_LEVEL      		 = 'soundboard.next_level'
PERFECT         		 = 'absolutely_perfect'
DISAPPOINTED    		 = 'soundboard.glados.disappointed'
PATIENCE        		 = 'soundboard.patience'
NORMALIN        		 = 'soundboard.eto_nenormalno'
HERO            		 = 'soundboard.youre_a_hero'
GROAN           		 = 'soundboard.ti9.crowd_groan'
APPLAUSE             = 'soundboard.applause'
                		

BAD_LIST					   = {DISASTAH, RUSSIAN_REKT, GG, OH_MY_LORD, BEAUTIFUL}
PLAYER_DEATH_LIST 	 = {PATIENCE, DISAPPOINTED, APPLAUSE, PERFECT, QUESTIONABLE, SAD_TROMBONE, WHAT_HAPPENED}

-- message colors
local colors = 
{
	good = '#00ff00', 
	warning = '#fbff00',
	bad = '#ff0000', 
}

-- Evidently dota lua doesn't like ... arguments and you just have to overload and check for nil. Whatever.
-- This method will print a message to the players, with optional color and sound.   
function Utilities:Print(msg, msgType, sound)
  local color
	local isColor = false
	-- invalid arguments
	if msg == nil then return end
	-- no color
	if msgType == nil then
		GameRules:SendCustomMessage(msg,0,0)
		return
	end
	-- handle color, only use valid ones
	if msgType == MSG_GOOD then
		color = colors.good
		isColor = true
	elseif msgType == MSG_WARNING then
		color = colors.warning
		isColor = true
	elseif msgType == MSG_BAD then
		color = colors.bad
		isColor = true
	end
	-- valid color
	if isColor then
		local message = "<font color='"..color.."'>"..msg..'</font>'
		GameRules:SendCustomMessage(message,0,0) 
	-- use default when they screw up
	else
		GameRules:SendCustomMessage(msg,0,0)
	end
	-- no sound
	if sound == nil then return end
	-- play sound
	if type(sound) == 'string' then
	  EmitGlobalSound(sound)
	else
		EmitGlobalSound(sound[math.random(#sound)])
	end
end

-- Gets a random sound from a table
function Utilities:GetSound(list)
	return list[math.random(1,table.getn(list))]
end

-- clamps a number between two values, returns clamp rounded to nearest integer
function Utilities:RoundedClamp(number, minimum, maximum)
	local num = Utilities:Clamp(number, minimum, maximum)
	return Utilities:Round(num)
end 

-- Emits a random sound from a table
function Utilities:RandomSound(sound)
	EmitGlobalSound(sound[math.random(#sound)])
end

-- clamps a number
function Utilities:Clamp(number, minimum, maximum)
	if number < minimum then return minimum end
	if number > maximum then return maximum end
	return number
end

-- Rounds to nearest integer
function Utilities:Round(num)
	local decimal = num - math.floor(num)
	if decimal >= 0.5 then
	  return math.ceil(num) 
	else
		return math.floor(num)
	end
end 

-- Returns a variance multipler (picks a random number between the two numbers (both integers) then divides by 100
function Utilities:GetVariance(data)
	-- sanity check
	if data == nil then 
		return 0 
	end
	if data[1] == nil or data[2] == nil then 
		return 0 
	end
	-- remember math.Random only returns integers, so multiply / divide by 100
	local percentage = math.random(data[1] * 100, data[2] * 100) / 100
	return percentage
end

-- Gets game time
function Utilities:GetTime()
  local dotaTime = GameRules:GetDOTATime(false, false)
  if dotaTime == nil or dotaTime < 0 then return 0 end
  return dotaTime
end

-- Get absolute time
function Utilities:GetAbsoluteTime()
  local dotaTime = GameRules:GetDOTATime(false, true)
  return dotaTime
end

-- Sorts a table
function Utilities:SortHighToLow(data)
  table.sort(data, function(x,y) return x > y end)
  return data
end

-- Returns true if a player (by ID) is a bot
function Utilities:IsPlayerBot(playerID)
	return PlayerResource:GetSteamAccountID(playerID) == 0
end

-- returns the number of human players in the game
function Utilities:GetNumberOfHumans()
	local count = PlayerResource:GetPlayerCount()
	local humans = 0
	for i = 0, count-1 do
		local isBot = Utilities:IsPlayerBot(i)
	  if not isBot then 
	  	humans = humans + 1
	  end
	end
	return humans
end

-- Used to register game state listeners (with a generic functionality)
-- Gets current game state.  If game is over, returns.  If the game is
-- otherwise in or past initState, immediately runs an initializer.  
-- Prior to that state, registers a listener function that should
-- handle further game state changes (and call initializer) itself.
function Utilities:RegsiterGameStateListener(o, initializer, initState)
	-- Determine where we are
	local state =  GameRules:State_Get()
	-- various ways to implement based on game state
  if state == DOTA_GAMERULES_STATE_POST_GAME or state == DOTA_GAMERULES_STATE_DISCONNECT then
		return
	-- are we at or past the init state? Then init
	elseif state >= initState then
		local func = o[initializer]
		func(o)
	-- otherwise register a listener that will call init at the proper time.
  else
  	local name = DoUniqueString('listener')
  	local gameStateListener = GameStateListener:New()
	  table.insert(Utilities.listeners.names,name)
	  table.insert(Utilities.listeners.objects, gameStateListener)
	  gameStateListener:Register(o, initializer, initState) 
	end
end

-- GameStateListener class for registering functions that will run once when
-- a certain game state is reached
if GameStateListener == nil then
	GameStateListener = class({})
end

-- Returns an object of the class
function GameStateListener:New (o)
  o = o or {} 
  setmetatable(o, self)
  self.__index = self
  return o
end

-- This function is called when the game event occurs
function GameStateListener:Listen()
	local state =  GameRules:State_Get()
	if state == self.initState then
		local func = self.object[self.initializer]
		func(self.object)
	end
end

-- Sets internal data and registers a game state listener
function GameStateListener:Register(o, initializer, initState)
	print('Registering GameStateListener')
	-- set internal pointers
  self.object = o
	self.initializer = initializer
	self.initState = initState
	-- Register listener
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'Listen'), self)
end
