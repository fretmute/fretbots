version = '0.7.0.0'
versionString = [[Changelog: 
  Moved dependencies to /Fretbots subfolder. This means that all lua files from this project, with the exception of
  fretbots.lua, can be deleted from the /vscripts folder.

  Added / removed neutral items per 7.35 patch changes. Commented out code related to dealing with the old version of
  royal jelly, just in case they decide to un-rework it.

  Added Muerta to HeroNames.lua and RoleUtility.lua.

  Reformatted various files to look pretty with the new text editor.

  Removed tracker.txt and some superfluous files from the git repo/

  Added a new methodology to play sounds that are optionally tagged with attributes. These can be used to select sounds
  that match from a wider table of sounds.

  Added many hero voicelines and caster sounds to a new table (Thanks, Silvont.)  Since hero sounds are only loaded if
  that particular hero is in the game, I added a new system to quickly play your own heroes sounds (if they exist,
  obviously.) 'me' will play a random sound from your hero. 'me <x>' will attempt to play a specific sounds, or one
  with a given attribute or attitude. See HeroSoundsTable, VoiceoverTypes, and VoiceoverAttitudes for details. See also
  VoiceoverHeros for chat aliases for the various heroes.

  Added chat command 'vo' for play voiceover lines from the new system. A second argument is expected to select the
  hero. The third (optional) argument functions as it does in 'me'.

  Added 'voc' chat command that essentially aliases 'vo c' to directly play caster lines. This is mainly in
  anticipation of 'vo c' typos.

  TODO: Add attribute details for all of the caster / fan pack lines. I haven't yet done so because I haven't heard
  most of them, and have no idea what their attitude is.
]]
