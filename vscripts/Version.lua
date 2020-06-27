version = '0.4.3.1'
versionString = [[Changelog:
Removed Tobi's sound cues.  They're no longer in the game files, but I shouldn't
be referencing them either.  

Adjusted AwardBonus:levels() to return if the target bot is already
level 30.  I don't recall this ever having been an issue, but it's good
sense.

Implemented dynamic difficulty adjustments for awards other than GPM and XPM.
Current settings are experimental.

Added announce setting for various dynamic difficulty knobs.  Set to false
by default.  If true, knob adjustments are announced to chat.

Fixed DynamicDifficulty:MakeAdjustment() so that it never attempts to
divide by 0.

Enabled dynamic difficulty by default in standard and role scaled difficulties.

Added timeGate setting to death bonuses that prevents them from being awarded
until a certain number of seconds of game time have elapsed.

Fixed a bug with awarding levels around 30.

Disabled dynamic levels by default.

Tweaked difficulty a little bit more.
]]
