-- Dependencies
require 'Fretbots.Utilities'
VoTypes		= dofile('Fretbots.VoiceoverTypes')
VoAttitudes = dofile('Fretbots.VoiceoverAttitudes')

local heroSounds =
{
	npc_dota_hero_storm_spirit =
	{
		CHARMS =
		{
			sound 		=	'stormspirit_stormspirit_rival_14',
			type 		=	VoTypes.RIVAL,
			attitude 	=	VoAttitudes.TAUNT,
		},
		NO =
		{
			sound 		=	'stormspirit_ss_lose_04',
			type 		=	VoTypes.LOSE,
			attitude 	=	VoAttitudes.SAD,
		},
		INTHEBAG =
		{
			sound 		=	'stormspirit_ss_inthebag_02',
			type 		=	VoTypes.INTHEBAG,
			attitude 	=	VoAttitudes.TAUNT,
		},
		SHITTYWIZARD =
		{
			sound 		=	'stormspirit_ss_shitwiz_01',
			type 		=	VoTypes.MISC,
			attitude 	=	VoAttitudes.SAD,
		},
	},
}

-- Instantiate the class
if HeroSounds == nil then
	HeroSounds = class({})
end

-- Attempts to play a hero sound by name. Returns false if this did not work.
function HeroSounds:PlaySoundByName(hero, soundName)
	-- longstanding tradtion has our sounds in all caps, help the player out here
	local name = string.upper(soundName)
	if (heroSounds[hero] ~= nil) then
		local sounds = heroSounds[hero]
		if (sounds[name] ~= nil) then
			Utilities:TestSound(sounds[name].sound)
			return true
		end
		return false
	end
	return false
end

-- Attempts to play a random sound that matches the attribute passed
function HeroSounds:PlaySoundByAttribute(hero, attributeValue)
	local soundList = {}
	local attribute = string.upper(attributeValue)
	if (heroSounds[hero] ~= nil) then
		local sounds = heroSounds[hero]
		for _, sound in pairs(sounds) do
			if (HeroSounds:MatchesAttribute(sound, attribute)) then
				table.insert(soundList, sound.sound)
			end
		end
		local size = Utilities:GetTableSize(soundList)
		if (size > 0) then
			Utilities:TestSound(soundList[math.random(size)])
		end
	end
end

-- Determines if a sound matches an attribute
function HeroSounds:MatchesAttribute(sound, attribute)
	if (VoAttitudes[attribute] ~= nil) then
		return sound.attitude == VoAttitudes[attribute]
	else
		if (VoTypes[attribute] ~= nil) then
			return sound.type == VoTypes[attribute]
		end
	end
end