version = '0.4.2.1'
versionString = [[Changelog:
Further reworked Neutral Item awards:
	
	Split neutral timers; there is now a 'drop' timer that tracks 
	when items are spawned, and a 'dole' timer that handles assigning.
	
	Neutral items now have separate drop amounts per tier.
	
	Bots now have rudimentary desires for certain items over other ones
	(or would, if the table values were not currently all ones.)
	
	Items that are removed from the bots are returned to a virtual
	stash so that they can be allocated to a new bot.
	
	Added settings for how to assign neutrals: truly randomly, or
	the old method where each bot gets assigned directly an item
	it can use.
	
	Moved functions for handling neutrals out of AwardBonus and into 
	a dediciated file (NeutralItems).
	
	Modfied neutral item table to use numeric values for most differentiators
	(melee flag, ranged flag, roles) numbered 0-x.  These values are now used
	in the GetBotDesireForItem() function.  This should provide some 
	granularity to this function, whereas before it was pretty basic.
]]
