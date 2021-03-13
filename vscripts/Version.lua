version = '0.6.0.0'
versionString = [[Changelog:
	Added support for more dynamically determining bot positions due to their
	lane placement, rather than the legacy tables.  This should result in 
	better performance for bot scripts that do unusual things (for bots anyway)
	like trilaning, dual mid, etc.  As of now I only parse for the scenarios
	that I consider reasonable (i.e. not four guys in one lane). Also note that
	this is not done if there are any humans on the bot team. 
	
	Finally got around to disabling the debug flag for releases. 
	
	Updated the ReadMe per Forest0xia's request. 
	
	Removed now superfluous setting files.
	
	Limited bot neutral item juggling message spam.
]]
