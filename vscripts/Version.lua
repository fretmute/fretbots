version = '0.4.2.0'
versionString = [[Changelog:
Further reworked neutral item awards (ideas shanelessly
stolen from I'm Bad):
	
	Split neutral timers; there is now a 'drop' timer that tracks 
	when items are spawned, and a 'dole' timer that handles assigning.
	
	Neutral items now have separate drop amounts per tier.
	
	Items that are removed from the bots are returned to a virtual
	stash so that they can be allocated to a new bot.
	
	Added settings for how to assign neutrals: truly randomly, or
	the old method where each bot gets assigned directly an item
	it can use.
	
	Moved functions for handling neutrals out of AwardBonus and into 
	a dediciated file (NeutralItems).
]]
