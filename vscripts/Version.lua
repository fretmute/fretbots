version = '0.2.1.0'
versionString = [[Adjusted settings initialization function to use a GameState listener to
prevent it from running before all players have loaded. It should now be
possible to start the script in any game state without issues.

Made existing debug difficulty the baseline difficulty level.  
Renamed to standard.

Changed standard difficulty skil variance lower bound to 1.0 for all 
positions.

Added additional difficulty levels.

Implemented Utilities:DeepCopy() to make applying difficulties a bit simpler.

Adjusted AwardBonus:ShouldAward() to actually play attention to the 
deathStreakThreshold setting.

Implemented Utilities:PlayerCount() to replace PlayerResource:PlayerCount(),
since we never care about non-players, and it returns coaches, etc.

Fixed bug: voting previously included coaches, observers, etc (see above).

Fixed bug: player_chat event listener now returns playerid instead of 
userid (which previously caused some internal confusion).

Reworked vote tracking system to be less crappy.

Vote tracking messages are now color coded by the color of the player 
that voted.

Add Utilities:ColorString() to facilitate more easy coloring of messages.

Reworked Utilities:Print() to facilitate more nuanced coloring of messages.

Improved vote acceptance messages (printed by color of voting player).

Improved award message printing (color coded award types).

Tweaked random sound lists.

Added a nag message if isBuff is enabled.

Cleaned up some untidy code.]]
