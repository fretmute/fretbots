	-- Default neutral items table, returns the table, so use 
	-- local <x> = require 'SettingsNeutralItemTable' to include in another file.
	
local	neutrals = 
{ 
	--                                              roles= 1,2,3,4,5
	{name = 'item_arcane_ring', 					tier = 1, ranged = true, 	melee = true, 	roles={1,1,1,1,1}, realName = 'Arcane Ring'},
	{name = 'item_broom_handle', 					tier = 1, ranged = false, melee = true,		roles={1,1,1,0,0}, realName = 'Broom Handle'},
	{name = 'item_faded_broach', 					tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Faded Broach'},
	{name = 'item_iron_talon', 						tier = 1, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Iron Talon'},
	{name = 'item_keen_optic', 						tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Keen Optic'},
	{name = 'item_mango_tree', 						tier = 1, ranged = true, 	melee = true,		roles={0,0,0,0,0}, realName = 'Mango Tree'},
	{name = 'item_ocean_heart',						tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Ocean Heart'},
	{name = 'item_poor_mans_shield',			tier = 1, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = "Poor Man's Shield"},
	{name = 'item_royal_jelly', 					tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Royal Jelly'},
	{name = 'item_trusty_shovel',					tier = 1, ranged = true, 	melee = true,		roles={0,0,0,0,0}, realName = 'Trusty Shovel'},
	{name = 'item_ironwood_tree',					tier = 1, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Ironwood Tree'},
	-- tier 2                                                                    		
	{name = 'item_dragon_scale', 					tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Dragon Scale'},
	{name = 'item_essence_ring', 					tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Essence Ring'},
	{name = 'item_grove_bow', 						tier = 2, ranged = true, 	melee = false,	roles={1,1,1,1,1}, realName = 'Grove Bow'},
	{name = 'item_imp_claw', 							tier = 2, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Imp Claw'},
	{name = 'item_nether_shawl', 					tier = 2, ranged = true, 	melee = true,		roles={0,0,0,0,0}, realName = 'Nether Shawl'},
	{name = 'item_philosophers_stone', 		tier = 2, ranged = true, 	melee = true,		roles={0,0,0,0,0}, realName = "Philosopher's Stone"},
	{name = 'item_pupils_gift',						tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = "Pupil's Gift"},
	{name = 'item_vambrace',							tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Vambrace'},
	{name = 'item_ring_of_aquila', 				tier = 2, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Ring of Aquila'},
	{name = 'item_vampire_fangs',					tier = 2, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Vampire Fangs'},
  {name = 'item_clumsy_net', 						tier = 2, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Clumsy Net'},	
	-- tier 3                                                                    		
	{name = 'item_craggy_coat', 					tier = 3, ranged = true, 	melee = true,		roles={0,0,1,1,1}, realName = 'Craggy Coat'},
	{name = 'item_enchanted_quiver', 			tier = 3, ranged = true, 	melee = false,	roles={1,1,1,1,1}, realName = 'Enchanted Quiver'},
	{name = 'item_greater_faerie_fire', 	tier = 3, ranged = true,	melee = true,		roles={1,1,1,0,0}, realName = 'Greater Faerie Fire'},
	{name = 'item_mind_breaker', 					tier = 3, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Mind Breaker'},
	{name = 'item_orb_of_destruction', 		tier = 3, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Orb of Destruction'},
	{name = 'item_paladin_sword',					tier = 3, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Paladin Sword'},
	{name = 'item_quickening_charm',			tier = 3, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Quickening Charm'},
	{name = 'item_spider_legs', 					tier = 3, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Spider Legs'},
	{name = 'item_titan_sliver',					tier = 3, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Titan Sliver'},	
	{name = 'item_repair_kit',				    tier = 3, ranged = true, 	melee = true,		roles={0,0,1,1,1}, realName = 'Repair Kit'},
  {name = 'item_spy_gadget', 						tier = 3, ranged = true, 	melee = false,	roles={0,0,0,1,1}, realName = 'Telescope'},	
	-- tier 4                                                                    		
	{name = 'item_flicker', 							tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Flicker'},
	{name = 'item_havoc_hammer', 					tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Havoc Hammer'},
	{name = 'item_illusionsts_cape', 			tier = 4, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = "Illusionist's Cape"},
	{name = 'item_panic_button', 					tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Magic Lamp'},
	{name = 'item_minotaur_horn', 				tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Minotaur Horn'},
	{name = 'item_ninja_gear', 						tier = 4, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Ninja Gear'},
	{name = 'item_princes_knife',					tier = 4, ranged = true, 	melee = false,	roles={1,1,1,1,1}, realName = "Prince's Knife"},
	{name = 'item_spell_prism',						tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Spell Prism'},
	{name = 'item_the_leveller',					tier = 4, ranged = true, 	melee = true,		roles={1,1,0,0,0}, realName = 'The Leveller'},	
	{name = 'item_timeless_relic',				tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Timeless Relic'},	
	{name = 'item_witless_shako',					tier = 4, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Witless Shako'},	
	-- tier 5                                                                    		
	{name = 'item_apex', 									tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Apex'},
	{name = 'item_ballista', 							tier = 5, ranged = true, 	melee = false,	roles={1,1,1,0,0}, realName = 'Ballista'},
	{name = 'item_demonicon', 						tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Book of the Dead'},
	{name = 'item_ex_machina', 						tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Ex Machina'},
	{name = 'item_fallen_sky', 					  tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Fallen Sky'},
	{name = 'item_force_boots', 					tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Force Boots'},
	{name = 'item_mirror_shield',					tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Mirror Shield'},
	{name = 'item_pirate_hat',						tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Pirate Hat'},
	{name = 'item_seer_stone', 						tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Seer Stong'},
	{name = 'item_desolator_2',						tier = 5, ranged = true, 	melee = true,		roles={1,1,0,0,0}, realName = 'Stygian Desolator'},	
	{name = 'item_trident',				        tier = 5, ranged = true, 	melee = true,		roles={1,1,1,0,0}, realName = 'Trident'},	
	{name = 'item_woodland_striders',			tier = 5, ranged = true, 	melee = true,		roles={1,1,1,1,1}, realName = 'Woodland Striders'},				
}

return neutrals