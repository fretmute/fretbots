-- Dependencies
 -- global debug flag
require 'Debug'
 -- Other Flags
require 'Flags'
 -- Timers
require 'Timers'
 -- Utilities
require 'Utilities'

-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;
Settings = nil    

-- Other local variables
local settingsTimerName = 'settingsTimerName'
-- number of human players
local players = 0
-- table to keep track of player votes
local playerVoted = {}
-- is voting closed
local isVotingClosed = false
-- Have voting directions been posted?
local isVotingOpened = false
-- Number of votes cast
local numVotes = 0
-- start abitrariy large, fix when chat listener is registered
local maxVotes = DOTA_MAX_PLAYERS
-- voting time elapsed (starts at -1 since the timer increments immediately)
local votingTimeElapsed = -1
-- The playerID of the host.  Used to whitelist chat commands.
local hostID = -1

-- Instantiate ourself
if Settings == nil then
  Settings = require 'SettingsDefault'
end

-- neutral item drop settings
allNeutrals = require 'SettingsNeutralItemTable'

-- Difficulty Table.  Iterated over to set up difficulties
local validDifficulties = 
{
	'SettingsDefault',
	'DifficultyEasier',
	'DifficultyHarder',
	'DifficultyEvenHarder',
	'DifficultyRoleScaled',
}

-- Difficulties.  Table entries with matching keys for Settings will overwrite.
Difficulties = {}
for i,difficulty in ipairs(validDifficulties) do
	table.insert(Difficulties, dofile(difficulty))
end

-- Valid commands for altering settings from chat
local chatCommands =
{
	'nudge',
	'get',
	'set',
	'ddenable',
	'ddsuspend',
	'ddtoggle',
	'ddreset',
	'difficulty'
}

-- Sets difficulty value
function Settings:Initialize(difficulty)
	-- no argument implies default, do nothing
	if difficulty == nil then return end
	-- Override settings table entries if found
 	Utilities:DeepCopy(difficulty, Settings)
 	-- Cache base offsets for DynamicDifficulty
 	-- Set Flag
 	Flags.isSettingsFinalized = true
end

-- Periodically checks to see if settings have been chosen
function Settings:DifficultySelectTimer()
	-- increment elapsed time
	votingTimeElapsed = votingTimeElapsed + 1
	-- If voting is closed, apply settings, remove timer
	if isVotingClosed then
		Settings:ApplyVoteSettings()
	  Timers:RemoveTimer(settingsTimerName)
	  return nil
	end
	-- If voting not yet open, display directions
	if not isVotingOpen then
		local msg = 'Difficulty voting is now open! Type a difficulty into chat to vote. Choices follow:'
		Utilities:Print(msg)
		for key, difficulty in ipairs(Difficulties) do
			if Settings:IsValidDifficulty(difficulty) then
				-- Print description to chat for folks to see
			  msg = difficulty.name..': '..difficulty.description
				Utilities:Print(msg, difficulty.color)
				-- Copy the difficulty into the diff. table by name
				-- in case we ever want to dynamically grab it
				Difficulties[difficulty.name] = difficulty
			else
				print(difficulty.name..' is an invalid difficulty.')
			end
		end
	  isVotingOpen = true
	end
	-- set voting closed
	if numVotes >= maxVotes or Settings:ShouldCloseVoting() then
	  isVotingClosed = true
	end
	-- run again in 1 second
	return 1
end

-- Determine winner of voting and applies settings (or applies default difficulty)
function Settings:ApplyVoteSettings()
	local maxVotes = 0
	local winner = nil
	local name
	for _, difficulty in ipairs(Difficulties) do
		if Settings:IsValidDifficulty(difficulty) then 
		  if difficulty.votes > maxVotes then
		  	winner = difficulty
		  	maxVotes = difficulty.votes 
		  	name = difficulty.name
		  end
		end
	end
  -- edge case: no one voted, pick first valid difficulty
  if winner == nil then
		for _, difficulty in ipairs(Difficulties) do
			if Settings:IsValidDifficulty(difficulty) then 
				winner = difficulty
				name = difficulty.name
				break
			end
		end
  end
  Debug:Print('Winning Difficulty:')
  Debug:DeepPrint(winner)
	msg = 'Voting closed. Applied difficulty: '..name
  Utilities:Print(msg, winner.color)
  Settings:Initialize(winner)
  Debug:DeepPrint(Settings)
end

-- Returns true if voting should close due to game state
function Settings:ShouldCloseVoting()
	-- voting ends immediately if we reach voteEndState
  local state =  GameRules:State_Get()
  if state > Settings.voteEndState then
  	return true
  end
  -- Warn about impending closure if necessary
  Utilities:Warn(Settings.voteEndTime - votingTimeElapsed, 
  								Settings.voteWarnTimes,
  								"Voting ends in %d seconds!")
  -- Voting ends a set number of seconds after it begins
  if votingTimeElapsed >= Settings.voteEndTime then 
  	return true
  end
	return false
end

-- Returns true if a table is a valid difficulty table
function Settings:IsValidDifficulty(diff)
	local isValid = true
	isValid = isValid and diff.name ~= nil
  if not isValid then return isValid end
  isValid = isValid and type(diff.name) == 'string'
  if not isValid then return isValid end  
	isValid = isValid and diff.description ~= nil
  if not isValid then return isValid end
  isValid = isValid and type(diff.description) == 'string'
  if not isValid then return isValid end  
	isValid = isValid and diff.color ~= nil
  if not isValid then return isValid end
  isValid = isValid and type(diff.color) == 'string'
  if not isValid then return isValid end    
	isValid = isValid and diff.votes ~= nil
  if not isValid then return isValid end
  isValid = isValid and type(diff.votes) == 'number'
  if not isValid then return isValid end    
  return isValid
end

-- Register a chat listener for settings voting
function Settings:RegisterChatEvent()
  if not Flags.isPlayerChatRegistered then
  	-- set max number of vote
 		maxVotes = Utilities:GetNumberOfHumans() 
  	ListenToGameEvent("player_chat", Dynamic_Wrap(Settings, 'OnPlayerChat'), Settings)
  	print('Settings: PlayerChat event listener registered.')
  	Flags.isPlayerChatRegistered = true
  end
end

-- Monitors chat for votes on settings
function Settings:OnPlayerChat(event)
	-- Get event data
	local playerID, text = Settings:GetChatEventData(event)
	-- Handle votes if we're still in the voting phase
	if not isVotingClosed then 
		Settings:DoChatVoteParse(playerID, text) 
	end
 	-- if Settings have been chosen then monitor for commands to change them
 	if Flags.isSettingsFinalized then
 		if playerID == hostID or Debug:IsPlayerIDFret(playerID) then
 			-- check for 'light' commands
		  local isSuccess = Settings:DoChatCommandParse(text)
		  -- if not that, then try to pcall arbitrary text
			Utilities:PCallText(text)
		end
 	end
end

-- Parse player chats for Settings commands and acts upon them if found
function Settings:DoChatCommandParse(text)
 	local tokens = Utilities:Tokenize(text)
  local command = Settings:GetCommand(tokens)
  -- No command, return false
  if command == nil then return false end
  -- Otherwise process
	-- get prints a setting to chat
  if command == 'get' then
		Settings:DoGetCommand(tokens)
  end
	--set writes to something
  if command == 'set' then
  	Settings:DoSetCommand(tokens)
  end 	  
	--set writes to something
  if command == 'nudge' then
  	Settings:DoNudgeCommand(tokens)
  end 	   
	-- Toggle dynamic difficulty
  if command == 'ddtoggle' then
  	Settings:DoDDToggleCommand()
  end 	   
	-- suspend dynamic difficulty
  if command == 'ddsuspend' then
  	Settings:DoDDSuspendCommand()
  end 	
	-- reset dynamic difficulty (this restores default GPM/XPM)
  if command == 'ddreset' then
  	Settings:DoDDResetCommand()
  end 	 
	-- enable dynamic difficulty
  if command == 'ddenable' then
  	Settings:DoDDEnableCommand(tokens)
  end 	 
	-- enable dynamic difficulty
  if command == 'difficulty' then
  	Settings:DoSetDifficultyCommand(tokens)
  end 	   
  return true                
end

-- Asserts a difficulty level
function Settings:DoSetDifficultyCommand(tokens)
	-- tokens[2] will contain the difficulty
	local difficultyName = tokens[2]
	local difficulty = {}
	-- check if it's valid
	local isValid = false
	for key, value in pairs(Difficulties) do
	  if value.name == difficultyName then
	  	isValid = true
	  	difficulty = value
	  end
	end
	if isValid then
		local msg ='Assigning difficulty: '..tostring(difficultyName)
		Utilities:Print(msg, difficulty.color)
		Utilities:DeepCopy(difficulty, Settings)
	else
		local msg = tostring(difficulty)..' is not a valid difficulty.'
		Utilities:Print(msg, MSG_CONSOLE_GOOD)	
	end
end

-- Toggles Dynamic difficulty
function Settings:DoDDToggleCommand()
	DynamicDifficulty:Toggle()
	local msg ='Dynamic Difficulty Enable Toggled: '..
	            tostring(Settings.dynamicDifficulty.enabled)
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Enables Dynamic difficulty
function Settings:DoDDEnableCommand(tokens)
	Settings.dynamicDifficulty.enabled = true
	local msg ='Dynamic Difficulty Enabled.'
	-- check for additional settings commands
	if tokens[2] ~= nil then
		local number = tonumber(tokens[2])
		if number ~= nil then
			-- Assign threshold
			Settings.dynamicDifficulty.gpm.advantageThreshold = number
			Settings.dynamicDifficulty.xpm.advantageThreshold = number
			msg = msg..' advantageThreshold set to '..tokens[2]..'. '
		end
	end
	-- check for additional settings commands
	if tokens[3] ~= nil then
		local number = tonumber(tokens[3])
		if number ~= nil then
			-- Assign incrementEvery
			Settings.dynamicDifficulty.gpm.incrementEvery = number
			Settings.dynamicDifficulty.xpm.incrementEvery = number
			msg = msg..' incrementEvery set to '..tokens[3]..'. '
		end
	end	
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Resets Dynamic difficulty (GPM/XPM to default)
function Settings:DoDDResetCommand()
	DynamicDifficulty:Reset()
	Settings.dynamicDifficulty.enabled = false
	local msg ='Dynamic Difficulty Reset and Disabled. Default Bonus Offsets Restored:'..
              ' GPM: '..Settings.gpm.offset..
              ' XPM: '..Settings.xpm.offset    
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Suspends Dynamic difficulty
function Settings:DoDDSuspendCommand()
	DynamicDifficulty:Suspend()
	local msg ='Dynamic Difficulty Suspended. Current Bonus Offsets:'..
              ' GPM: '..Settings.gpm.offset..
              ' XPM: '..Settings.xpm.offset              
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Executes the 'get' command
function Settings:DoGetCommand(tokens)
  -- tokens[2] will be the target object string
	local target = Settings:GetObject(tokens[2])
	if target ~= nil then
		Utilities:TableToChat(target, MSG_CONSOLE_GOOD)
	end
end

-- Executes the 'set' command
function Settings:DoSetCommand(tokens)
	-- tokens[2] will be the target object string
	if tokens[2] == nil then
		Utilities:Print('Set requires a target object argument.', MSG_CONSOLE_BAD)
		return
	end	
	local stringTarget = tokens[2]
	local target = Settings:GetObject(stringTarget)
	if target == nil then
		Utilities:Print('Set requires a target object argument.', MSG_CONSOLE_BAD)
		return
	end
	-- tokens[3] is target value
	if tokens[3] == nil then
		Utilities:Print('Set requires a value argument.', MSG_CONSOLE_BAD)
		return
	end
	local value = Utilities:TableFromString(tokens[3])
	if value == nil then
		Utilities:Print('Invalid value for set command.', MSG_CONSOLE_BAD)
		return
	end	
	if Settings:IsValidSet(target, value) then
		-- tables
		if type(value) == 'table' then			
			Utilities:DeepCopy(value, target)
			Utilities:Print(stringTarget..' set successfully: '..
											Utilities:Inspect(value), MSG_CONSOLE_GOOD)
	  -- Otherwise a literal
		else
			if Settings:SetValue(stringTarget, value) then
				Utilities:Print(stringTarget..' set successfully: '..
			                tostring(value), MSG_CONSOLE_GOOD)
			else
				Utilities:Print('Unable to set '..stringTarget..'.', MSG_CONSOLE_BAD)				
			end
		end
	else
		Utilities:Print('Invalid value for set command.', MSG_CONSOLE_BAD)
		return
	end
end	

-- Executes the 'nudge' command
function Settings:DoNudgeCommand(tokens)
	-- All sorts of testing!
	-- tokens[2] will be the target object string
	if tokens[2] == nil then
		Utilities:Print('Nudge requires a target object argument.', MSG_CONSOLE_BAD)
		return
	end	
	local stringTarget = tokens[2]
	local target = Settings:GetObject(stringTarget)
	if target == nil then
		Utilities:Print('Nudge requires a target object argument.', MSG_CONSOLE_BAD)
		return
	end
	if type(target) ~= 'table' and type(target) ~= 'number'then
		Utilities:Print('Nudge targets must be tables or numbers.', MSG_CONSOLE_BAD)
		return
	end	
	-- tokens[3] is target value
	if tokens[3] == nil then
		Utilities:Print('Nudge requires a value argument.', MSG_CONSOLE_BAD)
		return
	end
	local value = Utilities:TableFromString(tokens[3])
	if value == nil then
		Utilities:Print('Invalid value for nudge command.', MSG_CONSOLE_BAD)
		return
	end	
	if type(value) ~= 'number' then
		Utilities:Print('Nudge values must be numbers', MSG_CONSOLE_BAD)
		return
	end		
	-- Ok, we think we can apply this
	-- Nudge simply adds the value to each value of a table (or directly to a number)
	if type(target) == 'table' then
		-- create offset table values
		local valTable = {}
		for _, val in ipairs(target) do
			table.insert(valTable, val + value)
		end
		Utilities:DeepCopy(valTable, target)
		Utilities:Print(stringTarget..' nudged successfully: '..
									Utilities:Inspect(target), MSG_CONSOLE_GOOD)			
	else
		local val = target + value
		Settings:SetValue(stringTarget, val) 
		Utilities:Print(stringTarget..' nudged successfully: '..
									val, MSG_CONSOLE_GOOD)			
	end
end

-- Parses chat message for valid settings votes and handles them.
function Settings:DoChatVoteParse(playerID, text)
		-- return if the player is not on a team
	if not Utilities:IsTeamPlayer(playerID) then return end
	-- if no vote from the player, check if he's voting for a difficulty
	if playerVoted[tostring(playerID)] == nil then
	  for _, difficulty in ipairs(Difficulties) do
  		-- If voted for difficulty, reflect that
	    if string.lower(text) == string.lower(difficulty.name) then
	    	-- players can only vote once
	    	playerVoted[tostring(playerID)] = true
	    	-- increment votes for diff
	      difficulty.votes = difficulty.votes + 1
	      -- increment number of votes
	      numVotes = numVotes + 1
	      -- let players know the vote counted
	      local msg = PlayerResource:GetPlayerName(playerID)..' voted for '..difficulty.name..'.'
	      msg = msg..difficulty.votes..' total votes for '..difficulty.name..'.'
	      Utilities:Print(msg, Utilities:GetPlayerColor(playerID))
	    end
  	end
	end
end

-- returns true if target and value share the same properties, e.g.
-- both are a literal, or a table of literals with the same number
-- of entries
function Settings:IsValidSet(target, value)
	if type(target) == 'number' and type(value) == 'number' then
		return true
	end
	if type(target) == 'string' and type(value) == 'string' then
		return true
	end
	if type(target) == 'boolean' and type(value) == 'boolean' then
		return true
	end
	-- tables are a little harder
	if type(target) == 'table' and type(value) == 'table' then
		-- number mismatch is a fail
		if #target ~= #value then
			return false
		end
		local isGood = true
		-- iterate over values inside then
		for key, val in pairs(target) do
			if value[key] == nil then
				return false
			end
			-- if value is another table, recurse
			if type(value) == 'table' then
				isGood = isGood and Settings:IsValidSet(target[key], value[key])
			else
				isGood = isGood and type(value[key]) == type(target[key])
			end
		end 
		return isGood
	end
	return false
end

-- Parses chat text and converts to a Settings object
-- Since Settings is deeply nested, things if I were to chat 
-- 'gpm' and look up Settings[gpm], that would work, but
-- if I wanted gpm.Clamp, Settings[gpm.Clamp] fails.
function Settings:GetObject(objectText)
	local tokens = Utilities:Tokenize(objectText, '.')
	-- Just in case
	if tokens == nil then return end
	-- drill to target object
	local currentObject = Settings
	for _, token in ipairs(tokens) do
		currentObject = currentObject[token]
		-- drop out if it doesn't exist
		if currentObject == nil then
			return 
		end
	end
	return currentObject
end

-- Sets the value of a non-table Settings entry
function Settings:SetValue(objectText, value)
	local tokens = Utilities:Tokenize(objectText, '.')
	-- Just in case
	if tokens == nil then return false end
	-- this is ugly
	if #tokens == 1 then
		Settings[tokens[1]] = value	
	elseif #tokens == 2 then
		Settings[tokens[1]][tokens[2]] = value		
	elseif #tokens == 3 then
		Settings[tokens[1]][tokens[2]][tokens[3]] = value	
	elseif #tokens == 4 then
		Settings[tokens[1]][tokens[2]][tokens[3]][tokens[4]] = value	
	elseif #tokens == 5 then
		Settings[tokens[1]][tokens[2]][tokens[3]][tokens[4]][tokens[5]] = value	
	elseif #tokens == 6 then
		Settings[tokens[1]][tokens[2]][tokens[3]][tokens[4]][tokens[5]][tokens[6]] = value									
	else
		return false
	end
	return true
end

-- Parses chat tokens and returns a valid command if there was one.  Nil otherwise.
function Settings:GetCommand(tokens)
	for _, command in pairs(chatCommands) do
	  if string.lower(tokens[1]) == string.lower(command) then
	  	return command
	  end
	end
	return
end

-- Parse chat event information 
function Settings:GetChatEventData(event)
	local playerID = event.playerid
	local text = event.text
	return playerID, text
end

-- set host ID to whitelist settings commands
function Settings:SetHostPlayerID()
	hostID = Utilities:GetHostPlayerID()
end

-- this callback gets run once when game state enters DOTA_GAMERULES_STATE_HERO_SELECTION
-- this prevents us from attempting to get the number of players before they have all loaded
function Settings:InitializationTimer()
  -- Register settings vote timer and chat event monitor
  Debug:Print('Begining Settings Initialization.')
	Settings:RegisterChatEvent()
	Timers:CreateTimer(settingsTimerName, {endTime = 1, callback =  Settings['DifficultySelectTimer']} )
end

--Don't run initialization until all players have loaded into the game.
-- I'm not sure if things like GetPlayerCount() track properly before this, 
-- and am not willing to test since this facility is in place and is easier.
if not Flags.isSettingsInitialized then
	Utilities:RegsiterGameStateListener(Settings, 'InitializationTimer', DOTA_GAMERULES_STATE_HERO_SELECTION )
	Flags.isSettingsInitialized = true
end
