version = '0.5.0.4'
versionString = [[Changelog:
	Added rudimentary GameState(read: Who is winning?) tracker  to throttle
	bot awards if they're running down mid despite being behind in kills.
	Note: This is way more game designer experimental than I ever planned 
	to be an is probably way off.  Apologies.	
	The current intent is that the bot bonues will scale somewhere from 
	full if they are less than one lane ahead, to stop if they are slightly
	greater than one lane ahead.  
	
	Added sanity checks for both bad throttle states (<0, >1).
	
	Fixed (maybe) weirdness when the bot team has 1 human.
	
	Added experimental support for moving Lone Druid's items to his bear.
	
	Revamped some debug messages in Fretbots.lua to be less spammy and 
	more debuggy.
	
	Actually fixed weirdness when the bot team has humans.
]]
