-- Dependencies
 -- global debug flag
require "Debug"
 -- Other Flags
require "Flags"

-- local debug flag
local thisDebug = true; 
local isDebug = Debug.IsDebug() and thisDebug;

-- Instantiate ourself
if ItemSettings == nil then
  ItemSettings = {}
end

-- Helper function for setting neutral item settings
function ItemSettings:Do 