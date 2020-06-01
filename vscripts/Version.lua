version = '0.3.0.0'
versionString = [[Changelog:

Improved Settings chat listener functionality. Settings can now be manipulated via chat:

	'get'				:		Prints the apprpriate Settings table value to chat.
	'set'				:		Modifes the appropriate Settings table value.
	'nudge'			:		Adds the nudge value to all values of a Settings table entry.
	'ddenable'	:		Enables Dynamic Difficulty.
	'ddsuspend' :		Suspends dynamic difficulty.  Current offset bonuses remain.
	'ddreset'		:   Restores offset bonuses to the default of the current settings.
	'ddtoggle'	:		Toggles the enable state of Dynamic Difficulty.

Note that only the host or Fret can currently issue these commands.

Added an option argument to Utilities:Round() to allow rounding to decimal places
rather than just to integers.

Armor, Magic Resist, and Level awards are now rounded to two decimal places rather
than an integer value.

Adjusted random number generator for base awards to return decimal values between
the limits rather than integers; this will result in more granular awards 
for those awards that were adjusted to round to decimals.

Adjusted Level Award logic:
	
	Previously	:		An award of 2 levels would place a bot at the zero experience point
									of the level 2 levels higher than it currently is, which could,
									in theory, mean that it gets basically 1.1 levels if it is already
									near to levelling.  Awards were in integer format.
	Now					:		Awards are rounded to two decimal places.  The XP for the 
									difference between the current level and the ceiling of the bonus
									is calculated.  This value is then averaged by the ceiling of 
									the bonus in order to determine the average amount of XP per
									level awarded.  This average number is then multiplied by the
									levels bonus.  tldr: level awards are now more granular and 
									consistent.  

Implemented first attempt at dynamic difficulty adjustment.  Currently alters
GPM / XPM target offsets based on human kill advantage.  WIP.

Made console debug print messages for death awards more consistent and useful.

Fixed typo in the neutrals table preventing the localized name for clumsy 
net from being printed in awards messages.
]]
