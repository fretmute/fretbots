# About
The Fretbots scripts are run in conjunction with bot behavioral scripts in order to increase the difficulty of the bots in Dota 2.  Until very recently, most bot scripts ended underfarmed and underleveled, due to their tendency to roam as five past the laning stage.  These scripts attempt to rectify this by adding to the bots GPM and XPM based on their purported role in the game, relative to the corresponding player on the human side.  Furthermore, the bots will receive random bonuses each time they die, as well as being assigned neutral items periodically.  Most settings are user configurable; see `SettingsDefault.lua` for details.

# How To
1. Download the script and extract the files from `vscripts` to your Dota 2 vscripts directory.
This is typically `<SteamDir>\steamapps\common\dota 2 beta\game\dota\scripts\vscripts`.
2. Launch Dota 2 with the console enabled. The console can be enabled under `Advanced Options`.
![](https://github.com/fretmute/fretbots/blob/master/images/EnableConsole.png)
3. Create a lobby. Use whatever third party bot script that you care to. Ensure that `Enable Cheats` is checked; this is required because the scripts use functions that are considered cheats to give gold, items, stats, and experience to the bots. The scripts monitor player chat, and will announce to chat when any player enters cheat commands.
![](https://github.com/fretmute/fretbots/blob/master/images/EnableCheats.png)
4. After starting the game, open the console, and input `sv_cheats 1; script_reload_code fretbots`.
5. The scripts are now running! You should receive a message in chat with the current version string.  If you did not, you probably received an error message in the console instead.
![](https://github.com/fretmute/fretbots/blob/master/images/FretBotsWelcome.png)
6. Voting for difficulty will begin when all players have loaded into the game.  Difficulty scales from 0 to 10. To vote, simply type a number into chat. Values beyond the limits will be coerced to the nearest valid value. Each player may only vote once. Note that at higher difficuty levels, the bots will be sigificantly higher level and wealthier than the human players.
7. That's it! The bots will receive their bonuses once per minute past the sounding of the horn, and potentially when they die.  
8. The default settings represent what my friends and I consider to be fun; feel free to tinker to your heart's content.  

