-- Provides for common utilites
-- Hero Names
local heroNames = require('HeroNames')
-- sweet DeepPrint function I cadged from GitHub
local inspect = require('inspect')

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
MSG_GOOD 							= 1
MSG_WARNING 					= 2
MSG_BAD 							= 3
MSG_AWARD							= 4
MSG_CONSOLE_GOOD			= 5
MSG_CONSOLE_BAD				= 6

-- sound constants
DISASTAH							= 'soundboard.disastah'
FIRECRACKER						= 'soundboard.new_year_firecrackers'
MATCH_READY						= 'Stinger.MatchReady'
ATTENTION							= 'soundboard.rimshot'
BEAUTIFUL							= 'soundboard.krasavchik'
BEEP									= 'DotaSOS.TestBeep'
ROSHAN								= 'Roshan.Death'
RUSSIAN_REKT					= 'soundboard.eto_prosto_netchto'
SAD_TROMBONE					= 'soundboard.sad_bone'
BRUTAL								= 'soundboard.brutal'
GG										= 'soundboard.ehto_g_g'
OH_MY_LORD						= 'soundboard.oh_my_lord'
QUESTIONABLE					= 'soundboard.that_was_questionable'
WHAT_HAPPENED					= 'soundboard.what_just_happened'
NEXT_LEVEL						= 'soundboard.next_level'
PERFECT								= 'absolutely_perfect'
DISAPPOINTED					= 'soundboard.glados.disappointed'
PATIENCE							= 'soundboard.patience'
HERO									= 'soundboard.youre_a_hero'
GROAN									= 'soundboard.ti9.crowd_groan'
APPLAUSE							= 'soundboard.applause'
WOW										= 'soundboard.wow'
LAKAD									= 'soundboard.ta_daaaa'
JIAYOU								= 'soundboard.jia_you'
                		
-- tables for random sounds
BAD_LIST							= {DISASTAH, RUSSIAN_REKT, GG, OH_MY_LORD, BEAUTIFUL, JIAYOU}
PLAYER_DEATH_LIST			= {PATIENCE, DISAPPOINTED, APPLAUSE, PERFECT, QUESTIONABLE, 
												 SAD_TROMBONE, WHAT_HAPPENED, NEXT_LEVEL, GROAN,
												 WOW, LAKAD}

-- duh
TEAM_RADIANT					= 2
TEAM_DIRE							= 3

-- message colors
local colors = 
{
	good					= '#00ff00', 
	warning				= '#fbff00',
	bad						= '#ff0000',
	consoleGood 	= '#1ce8b5', 
	consoleBad    = '#e68d39',	
}
-- note that the first index is a blank table because radiant / dire are 2 / 3 
local playerColors = 
{
	{},
	{
		'#3375ff',
		'#66ffbf',
		'#bf00bf',
		'#f3f00b',
		'#ff6b00',
	},
	{
		'#fe86c2',
		'#a1b447',
		'#65d9f7',
		'#008321',
		'#a46900',
	}
}
local awardColors = 
{
	gold 					= '#DAA520',
	armor 				= '#B911FC',
	magicResist 	= '#1A88FC',
	levels 				= '#eb4b4b',
	neutral 			= '#5B388F',
	stats 				= '#CF6A32',	
}
local neutralColors = 
{
	'#A9A9A9',
	'#008000',
	'#0000FF',
	'#800080',
	'#FFA500',
}

-- Shorthand wrappers for functions from chat
function View(object)
	if type(object) == 'table' then
		Utilities:TableToChat(object, MSG_CONSOLE_GOOD)
	else
		Utilities:Print(tostring(object), MSG_CONSOLE_GOOD)
	end
end

-- Evidently dota lua doesn't like ... arguments and you just have to overload and check for nil. Whatever.
-- This method will print a message to the players, with optional color and sound.   
function Utilities:Print(msg, msgType, sound)
  local color
	local isColor = false
	local message = ''
	-- invalid arguments
	if msg == nil then return end
	-- no color (and msg is actually a string)
	if msgType == nil and type(msg) == 'string' then
		GameRules:SendCustomMessage(msg, 0, 0)
		return
	end
	-- handle color, only use valid ones
	if msgType == MSG_GOOD then
		message = Utilities:ColorString(msg, colors.good)
	elseif msgType == MSG_WARNING then
		message = Utilities:ColorString(msg, colors.warning)
	elseif msgType == MSG_BAD then
		message = Utilities:ColorString(msg, colors.bad)
	elseif msgType == MSG_AWARD then
		-- if it's an award message then msg should be a table
		if type(msg) == 'table' then
			message = Utilities:FormatAwardMessage(msg)
		end
	elseif msgType == MSG_CONSOLE_GOOD then
		message = Utilities:ColorString(msg, colors.consoleGood)
	elseif msgType == MSG_CONSOLE_BAD then
		message = Utilities:ColorString(msg, colors.consoleBad)		
	-- check if they passed what we think is a valid color 
	-- I'm aware this is not a full check, but this is good enough for now
	elseif string.find(msgType, '#') ~= nil and string.len(msgType) == 7 then
		message = Utilities:ColorString(msg, msgType)
	end
	-- print the message
	GameRules:SendCustomMessage(message, 0, 0)
	-- no sound
	if sound == nil then return end
	-- play sound
	if type(sound) == 'string' then
	  EmitGlobalSound(sound)
	else
		EmitGlobalSound(sound[math.random(#sound)])
	end
end

-- Returns a color coded string for award announcements
function Utilities:FormatAwardMessage(awards)
	local msg = ''
	local bot = awards[1]
	-- first artifact: hero name, by color
	msg = msg..Utilities:ColorString(bot.stats.name..': ', Utilities:GetPlayerColor(bot.stats.id))
	msg = msg..Utilities:ColorString('Bonus:', colors.good)
	-- Loop over table entries
	for i = 2, #awards do
	  local awardType = awards[i][1]
	  local awardValue = awards[i][2]  	
	  local awardMsg = ' '..Utilities:FirstToUpper(awardType)..': '..awardValue
	  msg = msg..Utilities:ColorString(awardMsg, awardColors[awardType])  
	end
	return msg
end

-- Announces neutral item award
function Utilities:AnnounceNeutral(bot, tier, itemName)
	-- first artifact: hero name, by color
  local msg = ''
	msg = msg..Utilities:ColorString(bot.stats.name..': ', Utilities:GetPlayerColor(bot.stats.id))
	msg = msg..Utilities:ColorString('Received Neutral Item: ', awardColors.neutral)
	msg = msg..Utilities:ColorString(itemName, neutralColors[tier])
	-- print the message
	GameRules:SendCustomMessage(msg, 0, 0)
end

-- Returns the localized hero name, if there is one
function Utilities:GetName(name)
	if heroNames[name] ~= nil then
		return heroNames[name] 
	end
	return name
end

-- returns html encoding to change the text of msg the appropriate color
function Utilities:ColorString(msg, color)
	return "<font color='"..color.."'>"..msg..'</font>'
end

-- Gets a random sound from a table
function Utilities:GetSound(list)
	return list[math.random(1,table.getn(list))]
end

-- Prints a warning to chat if the first argument is equal to any values in the 
-- table of the second argument
function Utilities:Warn(value, values, warning)
	for _,tableValue in ipairs(values) do
		if value == tableValue then
			formattedWarning = string.format(warning,value)
			Utilities:Print(formattedWarning, MSG_WARNING)
		end
	end
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

-- Rounds a number 
function Utilities:Round(num, decimals)
	-- if no decimals argument, round to an integer
	if decimals == nil or decimals <= 0 then
		local decimal = num - math.floor(num)
		if decimal >= 0.5 then
		  return math.ceil(num) 
		else
			return math.floor(num)
		end
	-- otherwise round to decimal places
	else
	  return Utilities:Round(num * 10 ^ decimals) / (10 ^ decimals)
	end
end 

-- Returns a random decimal number between two numbers
function Utilities:RandomDecimal(low, high)
  local percentage = math.random()
  local range = high - low
  local scaled = range * percentage
  return scaled + low
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

-- Returns a random integer between two numbers in a variance table
function Utilities:GetIntegerVariance(data)
		-- sanity check
	if data == nil then 
		return 0 
	end
	if data[1] == nil or data[2] == nil then 
		return 0 
	end
	return math.random(data[1],data[2])
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

-- Returns the number of players in the game
-- note that PlayerResource:GetPlayerCount() also returns coaches etc 
function Utilities:GetPlayerCount()
	return PlayerResource:GetPlayerCountForTeam(TEAM_RADIANT) +  PlayerResource:GetPlayerCountForTeam(TEAM_DIRE)
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

-- returns html color code for the team/position a player occupies
function Utilities:GetPlayerColor(playerID)
	for team = TEAM_RADIANT, TEAM_DIRE do
		for index = 1, 5 do
			if PlayerResource:GetNthPlayerIDOnTeam(team, index) == playerID then
				return playerColors[team][index]
			end
		end
	end
end

-- returns true if the playerID is assigned to a team.  
-- Use this to filter out coaches / observers
function Utilities:IsTeamPlayer(playerID)
	for team = TEAM_RADIANT, TEAM_DIRE do
		for index = 1, 5 do
			if PlayerResource:GetNthPlayerIDOnTeam(team, index) == playerID then
				return true
			end
		end
	end
end

-- Copies matching table fields from source to target
function Utilities:DeepCopy(source, target)
	
  for key, value in pairs(source) do 
    if target[key] ~= nil then
    	if type(value) == 'table' then 
    		Utilities:DeepCopy(source[key], target[key])
      else
      	target[key] = value
    	end
    end
  end
end

-- return a string with the first letter capitalized
function Utilities:FirstToUpper(str)
	return (str:gsub("^%l", string.upper))
end

-- splits a string into tokens based on a splitter character.
-- Returns table of tokens.
function Utilities:Tokenize(text, splitter)
	if splitter == nil then
		splitter = "%s"
	end
	local tokens = {}
	for str in string.gmatch(text, "([^"..splitter.."]+)") do
		table.insert(tokens, str)
	end
	return tokens
end

-- Returns a human readable string (deep print) of a table
function Utilities:Inspect(tableData)
	return inspect(tableData)
end

-- Prints a table to chat
function Utilities:TableToChat(tableData, color)
	if color == nil then
		Utilities:Print(inspect(tableData))
	else
		Utilities:Print(inspect(tableData), color)
	end
end

-- Returns a table from the string version thereof
function Utilities:TableFromString(text)
  return (loadstring or load)("return "..text)()
end

-- Applies an offset to a table
function Utilities:ApplyTableOffset(tableData, offset)
	for key, value in ipairs(tableData) do
		tableData[key] = value + offset
	end
end

-- returns a copy of a table
function Utilities:CloneTable(obj, seen)
	-- Handle non-tables and previously-seen tables.
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	-- New table; mark it as seen an copy recursively.
	local s = seen or {}
	local res = {}
	s[obj] = res
	for k, v in next, obj do res[Utilities:CloneTable(k, s)] = Utilities:CloneTable(v, s) end
	return setmetatable(res, getmetatable(obj))
end

-- Attempts to pcall arbitray text
function Utilities:PCallText(text)
	local command = loadstring(text)
	pcall(command)
end

-- returns the playerID of the host
function Utilities:GetHostPlayerID()
	for i = 0, PlayerResource:GetPlayerCount() do
		local player = PlayerResource:GetPlayer(i)
		local isHost = GameRules:PlayerHasCustomGameHostPrivileges(player)
		if isHost then
			return i
		end
	end
end

-- iterates over a table by keys, alphabetically
function Utilities:PairsByKeys (t, f)
      local a = {}
      for n in pairs(t) do table.insert(a, n) end
      table.sort(a, f)
      local i = 0      -- iterator variable
      local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
      end
      return iter
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

