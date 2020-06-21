version = '0.4.0.5'
versionString = [[Changelog:
Implemented 'Easier' difficulty.

Fixed dumb bug with Debug:Print().

Implemented 'difficulty' chat command.  Lobby host can dynamically override
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

Adjusted dynamic clamps to be rounded to the same number of deciamsl as
the setting they clamp.

Reworked voting closure methodology, now ends a set number of seconds
after it began rather than a number of seconds into a game state.

'ddenable' chat command now takes additional optional arguments to 
set advantageThreshold and incrementEvery.

Added Utilities:Warn() method for printing messages to chat when
variables are equal to certain values.

Modified Debug:Print to print an optional header.

Refactored the functions for returning GPM and XPM bonuses for
the BonusTimer awards.

Added 'RoleScaled' difficulty to promote testing of role scaling.

Finally extracted chat_wheel.txt.  Added some new sounds to the 
random tables.

Adjusted the various AwardBonus methods to not attempt to award
if the bonus is not greater than zero.
]]
