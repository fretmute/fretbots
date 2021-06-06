-- Dependencies
-- global debug flag
require "resources/Debug"
-- Other Flags
require "resources/Flags"
-- Timers
require "resources/Timers"
-- Utilities
require "resources/Utilities"
-- Version
require "resources/Version"

-- local debug flag
local thisDebug = false
local isDebug = Debug.IsDebug() and thisDebug
Settings = nil

-- Other local variables
local settingsTimerName = "settingsTimerName"
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
-- default difficulty if no one votes
local noVoteDifficulty = 5

local minDifficulty = 0
local maxDifficulty = 20

-- Instantiate ourself
if Settings == nil then
    Settings = dofile("resources/SettingsDefault")
end

-- neutral item drop settings
AllNeutrals = dofile("resources/SettingsNeutralItemTable")

-- cheat command list
local cheats = dofile("resources/CheatList")

-- Difficulty values voted for
difficulties = {}

-- Valid commands for altering settings from chat
local chatCommands = {
    "nudge",
    "get",
    "set",
    "ddenable",
    "ddsuspend",
    "ddtoggle",
    "ddreset",
    "difficulty",
    "stats",
    "goodsound",
    "badsound",
    "asound",
    "csound",
    "esound",
    "playsound",
    "kb",
    "help",
    "networth"
}

-- Sets difficulty value
function Settings:Initialize(difficulty)
    -- no argument implies default, do nothing
    if difficulty == nil then
        return
    end
    -- Adjust bot skill values by the difficulty value
    Settings.difficultyScale = 1 + ((difficulty - 5) / 10)
    Settings.difficultyScale = Utilities:Round(Settings.difficultyScale, 2)
    -- Print
    local msg = "Difficulty Scale: " .. Settings.difficultyScale
    Debug:Print(msg)
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
        local msg = "Difficulty voting is now open!" .. " Default difficulty is currently: " .. tostring(noVoteDifficulty)
        Utilities:Print(msg, MSG_GOOD)
        msg = "* Note the difficulty range is " .. minDifficulty .. "-" .. maxDifficulty
        Utilities:Print(msg, MSG_GOOD)
        msg = "* Bots no longer get any awards for their death"
        Utilities:Print(msg, MSG_GOOD)
        msg = "* Dynamic Difficulty " .. (Settings.dynamicDifficulty.enabled and "" or "not") .. " enabled."
        Utilities:Print(msg, MSG_GOOD)
        msg = "* Dynamic Difficulty means bots get dynamic (instead of static) bonus gold/exp/stats mainly based on the selected difficulty and how much they are behind the players on the other side."
        Utilities:Print(msg, MSG_GOOD)
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
    local difficulty
    -- edge case: no one voted
    if #difficulties == 0 then
        -- otherwise, average the votes
        difficulty = noVoteDifficulty
    else
        local total = 0
        for _, value in ipairs(difficulties) do
            total = total + value
        end
        difficulty = total / #difficulties
        difficulty = Utilities:Round(difficulty, 1)
    end
    msg = "Difficulty Selected: " .. difficulty
    Debug:Print(msg)
    Utilities:Print(msg, MSG_GOOD)
    Settings:Initialize(difficulty)
    Settings.difficulty = difficulty
end

-- Returns true if voting should close due to game state
function Settings:ShouldCloseVoting()
    -- voting ends immediately if we reach voteEndState
    local state = GameRules:State_Get()
    if state > Settings.voteEndState then
        return true
    end
    -- Warn about impending closure if necessary
    Utilities:Warn(Settings.voteEndTime - votingTimeElapsed, Settings.voteWarnTimes, "Voting ends in %d seconds!")
    -- Voting ends a set number of seconds after it begins
    if votingTimeElapsed >= Settings.voteEndTime then
        return true
    end
    return false
end

-- Register a chat listener for settings voting
function Settings:RegisterChatEvent()
    if not Flags.isPlayerChatRegistered then
        -- set max number of vote
        maxVotes = Utilities:GetNumberOfHumans()
        ListenToGameEvent("player_chat", Dynamic_Wrap(Settings, "OnPlayerChat"), Settings)
        print("Settings: PlayerChat event listener registered.")
        Flags.isPlayerChatRegistered = true
    end
end

-- Monitors chat for votes on settings
function Settings:OnPlayerChat(event)
    -- Get event data
    local playerID, rawText = Settings:GetChatEventData(event)
    -- Check to see if they're cheating
    Settings:DoChatCheatParse(playerID, rawText)
    -- Remove dashes (potentially)
    local text = Utilities:CheckForDash(rawText)
    -- Handle votes if we're still in the voting phase
    if not isVotingClosed then
        Settings:DoChatVoteParse(playerID, text)
    end
    -- if Settings have been chosen then monitor for commands to change them
    if Flags.isSettingsFinalized then
        -- Some commands are available for everyone
        Settings:DoUserChatCommandParse(text)
        if playerID == hostID or Debug:IsPlayerIDFret(playerID) then
            -- check for 'light' commands
            local isSuccess = Settings:DoSuperUserChatCommandParse(text)
            -- if not that, then try to pcall arbitrary text
            Utilities:PCallText(text)
        end
    end
end

-- Parse for commands anyone can use
function Settings:DoUserChatCommandParse(text)
    local tokens = Utilities:Tokenize(text)
    local command = Settings:GetCommand(tokens)
    -- No command, return false
    if command == nil then
        return false
    end
    -- Random good sound
    if command == "goodsound" then
        Utilities:RandomSound(GOOD_LIST)
    end
    -- Random bad sound
    if command == "badsound" then
        Utilities:RandomSound(BAD_LIST)
    end
    -- Random Asian soundboard
    if command == "asound" then
        Utilities:RandomSound(ASIAN_LIST)
    end
    -- Random CIS soundboard
    if command == "csound" then
        Utilities:RandomSound(CIS_LIST)
    end
    -- Random English soundboard
    if command == "esound" then
        Utilities:RandomSound(ENGLISH_LIST)
    end
    -- Play Specific Sound
    if command == "playsound" then
        Utilities:PlaySound(tokens[2])
    end
    -- Display team net worths
    if command == "networth" then
        Debug:Print("Net Worth!")
        Settings:DoDisplayNetWorth()
    end
    -- get prints a setting to chat
    if command == "get" then
        Settings:DoGetCommand(tokens)
    end
    -- print stats
    if command == "stats" then
        Settings:DoGetStats(tokens)
    end

    if command == 'help' then
        local msg = "Dynamic Difficulty " .. (Settings.dynamicDifficulty.enabled and "" or "not") .. " enabled. Difficulty Selected: " .. Settings.difficulty
        Utilities:Print(msg, MSG_GOOD)
        Settings:DoDisplayNetWorth()
    end

    return true
end

-- Parse commands for superusers
function Settings:DoSuperUserChatCommandParse(text)
    local tokens = Utilities:Tokenize(text)
    local command = Settings:GetCommand(tokens)
    -- No command, return false
    if command == nil then
        return false
    end
    -- Otherwise process
    --set writes to something
    if command == "set" then
        Settings:DoSetCommand(tokens)
    end
    --set writes to something
    if command == "nudge" then
        Settings:DoNudgeCommand(tokens)
    end
    -- Toggle dynamic difficulty
    if command == "ddtoggle" then
        Settings:DoDDToggleCommand()
    end
    -- suspend dynamic difficulty
    if command == "ddsuspend" then
        Settings:DoDDSuspendCommand()
    end
    -- reset dynamic difficulty (this restores default GPM/XPM)
    if command == "ddreset" then
        Settings:DoDDResetCommand()
    end
    -- enable dynamic difficulty
    if command == "ddenable" then
        Settings:DoDDEnableCommand(tokens)
    end
    -- enable dynamic difficulty
    if command == "difficulty" then
        Settings:DoSetDifficultyCommand(tokens)
    end
    -- Kill a bot
    if command == "kb" then
        Settings:DoKillBotCommand(tokens)
    end
    return true
end

-- Display net worths
function Settings:DoDisplayNetWorth()
    local msg = ""
    local botMsg = ""
    local botTeamNetWorth = 0
    local playerTeamNetWorth = 0
    local netWorth = 0
    local roundedNetWorth = 0
    for _, bot in ipairs(Bots) do
        netWorth = PlayerResource:GetNetWorth(bot.stats.id)
        botTeamNetWorth = netWorth + botTeamNetWorth
        roundedNetWorth = Utilities:Round(netWorth, -2)
        roundedNetWorth = roundedNetWorth / 1000
        botMsg =
            Utilities:ColorString(
            bot.stats.name .. ": " .. tostring(roundedNetWorth) .. "k",
            Utilities:GetPlayerColor(bot.stats.id)
        )
        msg = msg .. "  " .. botMsg
    end
    Utilities:Print(msg)
    for _, player in ipairs(Players) do
        netWorth = PlayerResource:GetNetWorth(player.stats.id)
        playerTeamNetWorth = netWorth + playerTeamNetWorth
    end
    roundedNetWorth = Utilities:Round(playerTeamNetWorth, -2)
    roundedNetWorth = roundedNetWorth / 1000
    msg = "Player Team Net Worth: " .. tostring(roundedNetWorth) .. "k"
    Utilities:Print(msg, MSG_CONSOLE_GOOD)
    roundedNetWorth = Utilities:Round(botTeamNetWorth, -2)
    roundedNetWorth = roundedNetWorth / 1000
    msg = "AI-Bot Team Net Worth: " .. tostring(roundedNetWorth) .. "k"
    Utilities:Print(msg, MSG_CONSOLE_BAD)
end

-- Gets stats
function Settings:DoGetStats(tokens)
    -- tokens[2] will contain the stat to display
    local stat = tokens[2]
    for _, bot in ipairs(Bots) do
        local value = bot.stats.awards[stat]
        if value ~= nil then
            local msg = ""
            msg = msg .. bot.stats.name .. ": " .. stat .. ": " .. value
            Utilities:Print(msg, MSG_CONSOLE_GOOD)
        end
    end
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
        local msg = "Assigning difficulty: " .. tostring(difficultyName)
        Utilities:Print(msg, difficulty.color)
        Utilities:DeepCopy(difficulty, Settings)
    else
        local msg = tostring(difficulty) .. " is not a valid difficulty."
        Utilities:Print(msg, MSG_CONSOLE_GOOD)
    end
end

-- Toggles Dynamic difficulty
function Settings:DoDDToggleCommand()
    DynamicDifficulty:Toggle()
    local msg = "Dynamic Difficulty Enable Toggled: " .. tostring(Settings.dynamicDifficulty.enabled)
    Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Enables Dynamic difficulty
function Settings:DoDDEnableCommand(tokens)
    Settings.dynamicDifficulty.enabled = true
    local msg = "Dynamic Difficulty Enabled."
    -- check for additional settings commands
    if tokens[2] ~= nil then
        local number = tonumber(tokens[2])
        if number ~= nil then
            -- Assign threshold
            Settings.dynamicDifficulty.gpm.advantageThreshold = number
            Settings.dynamicDifficulty.xpm.advantageThreshold = number
            msg = msg .. " advantageThreshold set to " .. tokens[2] .. ". "
        end
    end
    -- check for additional settings commands
    if tokens[3] ~= nil then
        local number = tonumber(tokens[3])
        if number ~= nil then
            -- Assign incrementEvery
            Settings.dynamicDifficulty.gpm.incrementEvery = number
            Settings.dynamicDifficulty.xpm.incrementEvery = number
            msg = msg .. " incrementEvery set to " .. tokens[3] .. ". "
        end
    end
    Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Resets Dynamic difficulty (GPM/XPM to default)
function Settings:DoDDResetCommand()
    DynamicDifficulty:Reset()
    Settings.dynamicDifficulty.enabled = false
    local msg =
        "Dynamic Difficulty Reset and Disabled. Default Bonus Offsets Restored:" ..
        " GPM: " .. Settings.gpm.offset .. " XPM: " .. Settings.xpm.offset
    Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Suspends Dynamic difficulty
function Settings:DoDDSuspendCommand()
    DynamicDifficulty:Suspend()
    local msg =
        "Dynamic Difficulty Suspended. Current Bonus Offsets:" ..
        " GPM: " .. Settings.gpm.offset .. " XPM: " .. Settings.xpm.offset
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
        Utilities:Print("Set requires a target object argument.", MSG_CONSOLE_BAD)
        return
    end
    local stringTarget = tokens[2]
    local target = Settings:GetObject(stringTarget)
    if target == nil then
        Utilities:Print("Set requires a target object argument.", MSG_CONSOLE_BAD)
        return
    end
    -- tokens[3] is target value
    if tokens[3] == nil then
        Utilities:Print("Set requires a value argument.", MSG_CONSOLE_BAD)
        return
    end
    local value = Utilities:TableFromString(tokens[3])
    if value == nil then
        Utilities:Print("Invalid value for set command.", MSG_CONSOLE_BAD)
        return
    end
    if Settings:IsValidSet(target, value) then
        -- tables
        if type(value) == "table" then
            -- Otherwise a literal
            Utilities:DeepCopy(value, target)
            Utilities:Print(stringTarget .. " set successfully: " .. Utilities:Inspect(value), MSG_CONSOLE_GOOD)
        else
            if Settings:SetValue(stringTarget, value) then
                Utilities:Print(stringTarget .. " set successfully: " .. tostring(value), MSG_CONSOLE_GOOD)
            else
                Utilities:Print("Unable to set " .. stringTarget .. ".", MSG_CONSOLE_BAD)
            end
        end
    else
        Utilities:Print("Invalid value for set command.", MSG_CONSOLE_BAD)
        return
    end
end

-- Executes the 'nudge' command
function Settings:DoNudgeCommand(tokens)
    -- All sorts of testing!
    -- tokens[2] will be the target object string
    if tokens[2] == nil then
        Utilities:Print("Nudge requires a target object argument.", MSG_CONSOLE_BAD)
        return
    end
    local stringTarget = tokens[2]
    local target = Settings:GetObject(stringTarget)
    if target == nil then
        Utilities:Print("Nudge requires a target object argument.", MSG_CONSOLE_BAD)
        return
    end
    if type(target) ~= "table" and type(target) ~= "number" then
        Utilities:Print("Nudge targets must be tables or numbers.", MSG_CONSOLE_BAD)
        return
    end
    -- tokens[3] is target value
    if tokens[3] == nil then
        Utilities:Print("Nudge requires a value argument.", MSG_CONSOLE_BAD)
        return
    end
    local value = Utilities:TableFromString(tokens[3])
    if value == nil then
        Utilities:Print("Invalid value for nudge command.", MSG_CONSOLE_BAD)
        return
    end
    if type(value) ~= "number" then
        Utilities:Print("Nudge values must be numbers", MSG_CONSOLE_BAD)
        return
    end
    -- Ok, we think we can apply this
    -- Nudge simply adds the value to each value of a table (or directly to a number)
    if type(target) == "table" then
        -- create offset table values
        local valTable = {}
        for _, val in ipairs(target) do
            table.insert(valTable, val + value)
        end
        Utilities:DeepCopy(valTable, target)
        Utilities:Print(stringTarget .. " nudged successfully: " .. Utilities:Inspect(target), MSG_CONSOLE_GOOD)
    else
        local val = target + value
        Settings:SetValue(stringTarget, val)
        Utilities:Print(stringTarget .. " nudged successfully: " .. val, MSG_CONSOLE_GOOD)
    end
end

-- Executes the 'kb' command
function Settings:DoKillBotCommand(tokens)
    -- tokens[2] will be the target object string (if it exists)
    -- trivial case - no tokens[2]
    if tokens[2] == nil then
        Debug:KillBot()
    elseif tonumber(tokens[2]) ~= nil then
        Debug:KillBot(tonumber(tokens[2]))
    else
        Debug:KillBot(tokens[2])
    end
end

-- Parses chat message for valid settings votes and handles them.
function Settings:DoChatVoteParse(playerID, text)
    -- return if the player is not on a team
    if not Utilities:IsTeamPlayer(playerID) then
        return
    end
    -- if no vote from the player, check if he's voting for a difficulty
    if playerVoted[tostring(playerID)] == nil then
        -- If voted for difficulty, reflect that
        local difficulty = tonumber(text)
        if difficulty ~= nil then
            -- players can only vote once
            playerVoted[tostring(playerID)] = true
            -- coerce (if necessary)
            if difficulty > maxDifficulty then
                difficulty = maxDifficulty
            elseif difficulty < minDifficulty then
                difficulty = minDifficulty
            end
            difficulty = Utilities:Round(difficulty, 1)
            -- save voted value
            table.insert(difficulties, difficulty)
            -- increment number of votes
            numVotes = numVotes + 1
            -- let players know the vote counted
            local msg = PlayerResource:GetPlayerName(playerID) .. " voted: " .. difficulty .. "."
            Utilities:Print(msg, Utilities:GetPlayerColor(playerID))
        end
    end
end

-- Checks to see if a player is entering cheat commands
function Settings:DoChatCheatParse(playerID, text)
    local tokens = Utilities:Tokenize(text)
    for _, cheat in pairs(cheats) do
        -- tokens 1 is the potential cheat code
        -- I am an idiot use .lower!
        if string.lower(tokens[1]) == string.lower(cheat) then
            local msg = PlayerResource:GetPlayerName(playerID) .. " is cheating: " .. text
            Utilities:CheatWarning()
            Utilities:Print(msg, Utilities:GetPlayerColor(playerID))
        end
    end
end

-- returns true if target and value share the same properties, e.g.
-- both are a literal, or a table of literals with the same number
-- of entries
function Settings:IsValidSet(target, value)
    if type(target) == "number" and type(value) == "number" then
        return true
    end
    if type(target) == "string" and type(value) == "string" then
        return true
    end
    if type(target) == "boolean" and type(value) == "boolean" then
        return true
    end
    -- tables are a little harder
    if type(target) == "table" and type(value) == "table" then
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
            if type(value) == "table" then
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
    local tokens = Utilities:Tokenize(objectText, ".")
    -- Just in case
    if tokens == nil then
        return
    end
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
    local tokens = Utilities:Tokenize(objectText, ".")
    -- Just in case
    if tokens == nil then
        return false
    end
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
    Debug:Print("Begining Settings Initialization.")
    Settings:RegisterChatEvent()
    Timers:CreateTimer(settingsTimerName, {endTime = 1, callback = Settings["DifficultySelectTimer"]})
end

--Don't run initialization until all players have loaded into the game.
-- I'm not sure if things like GetPlayerCount() track properly before this,
-- and am not willing to test since this facility is in place and is easier.
if not Flags.isSettingsInitialized then
    Utilities:RegsiterGameStateListener(Settings, "InitializationTimer", DOTA_GAMERULES_STATE_HERO_SELECTION)
    Flags.isSettingsInitialized = true
end
