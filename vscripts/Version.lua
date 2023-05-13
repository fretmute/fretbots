version = '0.6.4.0'
versionString = [[Changelog: 
  Adjusted SettingsNeutralItemTable.lua to reflect changes from patch 7.33.
  
  Reworked the neutral item award methodology to reflect the 7.33 system.
  When a bot 'finds' an item, the greediest bot (by role) will now select
  the item it most wants from a list of five. Unfortunately, this change
  has revealed holes in my desire system, which was passable when there
  were only five different items to choose from, but is now less good
  when each bot can pick the best item it wants from its own list. So, if
  you hate what items bots are picking, feel free to create an issue and 
  offer your own suggestions SettingsNeutralItemTable.lua.
  
  Eventually I ought to create a desire list per tier for each hero, but
  that's an awful lot of typing.
]]
