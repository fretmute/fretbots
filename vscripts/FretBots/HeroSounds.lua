-- Dependencies
require 'Fretbots.Utilities'
VoTypes		= dofile('Fretbots.VoiceoverTypes')
VoAttitudes = dofile('Fretbots.VoiceoverAttitudes')

local sounds =
{
	npc_dota_hero_storm_spirit =
	{
		CHARMS =
		{
			sound 		=	'stormspirit_stormspirit_rival_14',
			type 		=	VoTypes.RIVAL,
			attitude 	=	VoAttitudes.TAUNT,
		},
	},
}

-- Instantiate the class
if HeroSounds == nil then
	HeroSounds = class({})
end

-- Attempts to play a hero sound by name
function HeroSounds:PlaySoundByName(hero, name)
	if (sounds[hero] ~= nil) then
		local heroSounds = sounds[hero]
		if (heroSounds[name] ~= nil) then
			Utilities:TestSound(heroSounds[name].sound)
		end
	end
end