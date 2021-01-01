version = '0.5.2.6'
versionString = [[Changelog:
	Now with more branding!
	
	Default no-vote difficulty is now 2.
	
	Added chat parsing for playing chatwheel sounds. Commands as follows:
		goodsound	: Plays a sound from the good list.
		badsound	: Plays a sound from the bad list.		 
		asound		: Plays a random line from an Asian caster.
		csound		: Plays a random line from a CIS caster.
		esound		: Plays a random line from an English caster.
		playsound	: with an argument from Soundboard.lua, plays that specific sound.
								This will require homework and keybinds, a la
								bind "kp_6" "say playsound EHTO_GG"
								
	Moved soundboard to its own file so as not to pollute the greater
	project with a bunch of sound constants. Was lazy and globaled some of
	the usages that were implemented previously (ATTENTION, whatever the 
	start match gong is).
	
	Moved chat wheel command parsing to its own function and made it public 
	facing (rather than just the lobby host).
	
	Chat monitor now looks for commands prefixed with a dash.  This allows commnads
	to be parsed that were not actually printed to chat.
	
	Added kb shorthand to chat command parser as a macro for Debug:KillBot().
	
	Added overloading for Debug:KillBot() to kill by name or position in addition
	to killing randomly when no argument is present.  
	
	Debug:KillBot() random kill is now actually random instead of iterating 
	over the Bots table by position.
	
	Added additional chat commands for displaying stats. 
	
	Added Mistwoods Update neutral items.
	
	Added 'get' to the list of all-user chat parses.
	
]]
