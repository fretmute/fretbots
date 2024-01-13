-- Dependencies
require 'Fretbots.Utilities'
VoTypes		= dofile('Fretbots.VoiceoverTypes')
VoAttitudes = dofile('Fretbots.VoiceoverAttitudes')
VoHeroes	= dofile('Fretbots.VoiceoverHeroes')

local heroSounds =
{
	-- Anti-Mage
	npc_dota_hero_antimage =
	{
		ABOMINATION				= 'antimage_anti_magicuser_01',
	},
	-- Axe Announcer
	announcer_axe =
	{
		EASYMODE =
		{
			sound 		=	'announcer_dlc_axe_announcer_type_easy_mode',
			type 		=	{ VoTypes.MISC, VoTypes.KILL, VoTypes.WIN },
			attitude 	=	VoAttitudes.TAUNT,
		},
	},
	-- Cave Johnson Announcer
	announcer_cave_johnson =
	{
		OGRE =
		{
			sound 		=	'announcer_dlc_cavej_cavej_ann_alchemist_03',
			type 		=	VoTypes.MISC,
			attitude 	=	VoAttitudes.HAPPY,
		},
	},
	-- Bane
	npc_dota_hero_bane =
	{
		BLINK =
		{
			sound 		=	'bane_bane_blink_03',
			type 		=	VoTypes.ITEM,
			attitude 	=	VoAttitudes.NEUTRAL,
		},
		SLURP =
		{
			sound 		=	'bane_bane_ability_brainsap_01',
			type 		=	VoTypes.ABILITY,
			attitude 	=	VoAttitudes.NEUTRAL,
		},
		NOONE =
		{
			sound 		=	'bane_bane_deny_01',
			type 		=	VoTypes.DENY,
			attitude 	=	VoAttitudes.TAUNT,
		},
		DEATHDREAM =
		{
			sound 		=	'bane_bane_kill_06',
			type 		=	VoTypes.KILL,
			attitude 	=	VoAttitudes.TAUNT,
		},
		WELCOME =
		{
			sound 		=	'bane_bane_kill_05',
			type 		=	VoTypes.KILL,
			attitude 	=	VoAttitudes.TAUNT,
		},
		YES =
		{
			sound 		=	'bane_bane_level_05',
			type 		=	VoTypes.LEVEL,
			attitude 	=	VoAttitudes.HAPPY,
		},
		SPAZOUT =
		{
			sound 		=	'bane_bane_level_06',
			type 		=	VoTypes.LEVEL,
			attitude 	=	VoAttitudes.HAPPY,
		},
		COIL =
		{
			sound 		=	'bane_bane_rival_10',
			type 		=	VoTypes.RIVAL,
			attitude 	=	VoAttitudes.TAUNT,
		},
		RAWFISH =
		{
			sound 		=	'bane_bane_rival_12',
			type 		=	VoTypes.RIVAL,
			attitude 	=	VoAttitudes.TAUNT,
		},
		DREAMY =
		{
			sound 		=	'bane_bane_scepter_02',
			type 		=	VoTypes.DENY,
			attitude 	=	VoAttitudes.TAUNT,
		},
	},
	-- Storm Spirit
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
			attitude 	=	{ VoAttitudes.SAD, VoAttitudes.ANGRY },
		},
		DENYFOUR =
		{
			sound 		=	'stormspirit_stormspirit_deny_04',
			type 		=	VoTypes.DENY,
			attitude 	=	VoAttitudes.TAUNT,
		},
		DENYSEVEN =
		{
			sound 		=	'stormspirit_stormspirit_deny_07',
			type 		=	VoTypes.DENY,
			attitude 	=	VoAttitudes.TAUNT,
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
			return HeroSounds:TryPlaySound(sounds[name])
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
		if (type(sound.attitude ) ~= 'table') then
			return sound.attitude == VoAttitudes[attribute]
		else
			for _, item in pairs(sound.attitude) do
				if (item == VoAttitudes[attribute]) then
					return true
				end
			end
		end
	end
	if (VoTypes[attribute] ~= nil) then
		if (type(sound.type ) ~= 'table') then
			return sound.type == VoTypes[attribute]
		else
			for _, item in pairs(sound.type) do
				if (item == VoTypes[attribute]) then
					return true
				end
			end
		end
	end
end

-- Attempts to translate an argument into a hero name
function HeroSounds:ParseHero(argument)
	-- just to be fun and inconsistent, all of the hero aliases are lowercase
	local arg = string.lower(argument)
	if (VoHeroes[arg] ~= nil) then
		return VoHeroes[arg]
	else
		return nil
	end
end

-- Attempts to get a sound name from a sound entry
function HeroSounds:GetSoundName(sound)
	-- if the entry is a table, it should have a .sound
	if (type(sound) == 'table') then
		return sound.sound
	else
		-- Otherwise, assume the value is the sound path
		-- clearly they need to get this right or TestSound will crash dota
		return sound
	end
end

-- Attempts to play a sound
function HeroSounds:TryPlaySound(sound)
	local name = HeroSounds:GetSoundName(sound)
	if (name ~= nil) then
		Utilities:TestSound(name)
		return true
	end
	return false
end