-- Instantiate the class
if Flags == nil then
	Flags = class({});
end

-- Set up global flags
function Flags:Initialize()
	-- Global flags
	Flags.isEntityKilledRegistered = false;
	Flags.isStatsInitialized = false;
	Flags.isEntityHurtRegistered = false;
	Flags.isSettingsLoaded = false;
	Flags.isDebugBuffed = false;
end