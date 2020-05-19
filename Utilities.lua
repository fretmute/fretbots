-- Provides for common utilites
if Utulities == nil then
	Utilities = {}
end

-- constants for use in these methods
MSG_GOOD = 1
MSG_WARNING = 2
MSG_BAD = 3
-- sound constants
DISASTAH				 = 'soundboard.disastah'
FIRECRACKER 		 = 'soundboard.new_year_firecrackers'
MATCH_READY      = 'Stinger.MatchReady'
ATTENTION        = 'soundboard.rimshot'
BEAUTIFUL        = 'soundboard.krasavchik'

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
	EmitGlobalSound(sound)
end

-- clamps a number between two values, returns clamp rounded to nearest integer
function Utilities:RoundedClamp(number, minimum, maximum)
	local num = Utilities:Clamp(number, minimum, maximum)
	return Utilities:Round(num)
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
  return GameRules:GetDOTATime(false, false)
end

function Utilities:SortHighToLow(data)
  table.sort(data, function(x,y) return x > y end)
  return data
end
