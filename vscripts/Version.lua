version = '0.4.0.1'
versionString = [[Changelog:
Implemented 'Easier' difficulty.

Fixed dumb bug with Debug:Print().

Implemented 'difficulty' chat command.  Lobby hose can dynamically override
the selected difficulty once one has been applied. 'difficulty <votename>'
to apply.

Refactored Settings.lua.  NeutralItem table and difficulty tables
have been moved to external files, and are loaded via require/dofile.

Local 'difficulties' table from Settings.lua is now global as 'Difficulties'
in order to facilitate dynamic difficulty assertion.

'Difficulties' table copies all difficulties into indices by name as
they are loaded.  Difficulties are still also arranged by numeric index
in order to allow the voting list to appear in order.

Bugfix: The colon immediately following the bot's name in death award 
messages is now the color of the bot's name (was previously green.)
]]
