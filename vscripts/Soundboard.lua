-- sound constants

local sounds = 
{
	-- Effects
	FIRECRACKER						= 'soundboard.new_year_firecrackers',
	MATCH_READY						= 'Stinger.MatchReady',
	ATTENTION							= 'soundboard.rimshot',
	BEEP									= 'DotaSOS.TestBeep',
	ROSHAN								= 'Roshan.Death',
	SAD_TROMBONE					= 'soundboard.sad_bone',
	GROAN									= 'soundboard.ti9.crowd_groan',
	APPLAUSE							= 'soundboard.applause',
	CHEAT									= 'Loot_Drop_Stinger_Short',
-- English Casters (or Glados)
	HOLY_MOLY             = 'soundboard.holy_moly',									  
	PATIENCE							= 'soundboard.patience',										
	ALL_DEAD              = 'soundboard.all_dead',									
	WOW										= 'soundboard.wow',							
	BRUTAL								= 'soundboard.brutal',					
	PLAYING_TO_WIN   			= 'soundboard.playing_to_win',			
	QUESTIONABLE					= 'soundboard.that_was_questionable',		
	WHAT_HAPPENED					= 'soundboard.what_just_happened',	
	HERO          				= 'soundboard.youre_a_hero',
	PERFECT								= 'absolutely_perfect',	  -- Broken??plA
	DISAPPOINTED					= 'soundboard.glados.disappointed',
	LOOKING_SPICY         = 'soundboard.looking_spicy',
	COMING_THROUGH        = 'soundboard.coming_through_with_the_woooo',
	NOTHING_THAT	        = 'soundboard.nothing_that_can_stop_this_man',
	OH_MY_GOD			        = 'soundboard.oh_my_god_what_oh_oh',
	SEE_YOU_LATER			    = 'soundboard.see_you_later_nerds',
	WHAT_THE_F				    = 'soundboard.what_the_f_just_happened',	
-- Asian Casters -- Opinons on lines in languages I don't speak are my own
	TIAN_HUO							= 'soundboard.tian_huo',
	WAN_BU								= 'soundboard.wan_bu_liao_la',  			--GREAT
	JIA_YOU								= 'soundboard.jia_you',								--GREAT
	PO_LIANG							= 'soundboard.po_liang_lu',
	ZOU_HAO								= 'soundboard.zou_hao_bu_song',
	GAO_FU								= 'soundboard.gao_fu_shuai',
	DUIYOU_NE							= 'soundboard.duiyou_ne',							--GREAT
	HU_LU_WA							= 'soundboard.hu_lu_wa',
	LIU_LIU_LIU						= 'soundboard.liu_liu_liu',
	NI_QI									= 'soundboard.ni_qi_bu_qi',						-- Good if you want to annoy someone, I guess
	LAKAD									= 'soundboard.ta_daaaa',							-- Obviously the best
	OY_OY_OY              = 'soundboard.oy_oy_oy',							-- Good
	NEXT_LEVEL						= 'soundboard.next_level',						-- GREAT
	EASIEST_MONEY					= 'soundboard.easiest_money',					
	ECHO_SLAMA						= 'soundboard.echo_slama_jama',		
	ZAI_JIAN							= 'soundboard.zai_jian_le_bao_bei',		
	LIAN_DOU							= 'soundboard.lian_dou_xiu_wai_la',		
	PIAO_LIANG						= 'soundboard.piao_liang',						-- He's very disappointed about something 
	BAI_TUO								= 'soundboard.bai_tuo_shei_qu',				-- Very dismissive woman, be sure to trigger someone with this
	GAN_MA								= 'soundboard.gan_ma_ne_xiong_di',	
	GOODNESS_GRACIOUS     = 'soundboard.goodness_gracious',		
	NAKUPUUU					    = 'soundboard.nakupuuu',							-- Nakupuuu!!!!!
	WHATS_COOKING  		    = 'soundboard.whats_cooking',	
	AY_AY_AY_CN	  		    = 'soundboard.ay_ay_ay_cn',						-- Ah, ah, ah ,ah ? Ahhhhh :(
	HUI_TIAN		  		    = 'soundboard.hui_tian_mie',					-- HUI TIAN NIIIICE AH	
	LAI_NI			  		    = 'soundboard.lai_ni_da',	
	NI_XING			  		    = 'soundboard.ni_xing_ni',						-- I feel this meant no big deal or something.  
	WO_SHI			  		    = 'soundboard.wo_shi_yi',							-- I AM A HEARTLESS FARMING ROBOT
	TIAO_ZOU		  		    = 'soundboard.tiao_zou_le',						-- TO ZHOU LAH!
-- CIS Casters
	AY_AY_AY							= 'soundboard.ay_ay_ay',
	RUSSIAN_REKT					= 'soundboard.eto_prosto_netchto',
	EHTO_GG								= 'soundboard.ehto_g_g',	
	BOZHE_TI							= 'soundboard.bozhe_ti_posmotri',
	OY_OY									= 'soundboard.oy_oy_bezhat',
	ETO_SOCHNO						= 'soundboard.eto_sochno',								-- This sounds like a damn muppet
	KRASAVCHIK						= 'soundboard.krasavchik',	
	BOZHE_KAK							= 'soundboard.bozhe_kak_eto_bolno',				-- He's very mournful
	ETO										= 'soundboard.eto_nenormalno',	
	KREASA								= 'soundboard.kreasa_kreasa', 						-- Something or another was very close
	KAK_BOYGE							= 'soundboard.kak_boyge_te_byechenya', 	
	ETO_GE								= 'soundboard.eto_ge_popayx_feeda', 	
	WOT_ETO								= 'soundboard.wot_eto_bru', 							-- Might not be sad, but he sounds disappointed
	DA_DA_DA_NYET  				= 'soundboard.da_da_da_nyet', 						-- Doc's Fave
	A_NET									= 'soundboard.a_net_net_da',							-- Mosquito Naaaaaaay then DDAAAAAAAAAAAAAAH
	A_NU									= 'soundboard.a_nu_ka_idi_suda',					-- The really weird one Doc hates	
	AAAH_AAAH							= 'soundboard.aaah_aaah_chto',						-- BABUYAAAAAAAAAH? EH? STOY?
	CHTO_ETO  						= 'soundboard.chto_eto_kakaya_zhest',	
	ETO_TAKAYA						= 'soundboard.eto_takaya_dushka',	
	TAKAYA								= 'soundboard.takaya_haliava',		
	-- Recent battlepass / fan sounds
	SLACKS								= 'teamfandom.ti2021.Siractionslacks',
	EPHEY									= 'teamfandom.ti2021.Ephey',
	FOGGED								= 'teamfandom.ti2021.Fogged',
	LYRICAL								= 'teamfandom.ti2021.Lyrical',
	CAP										= 'teamfandom.ti2021.Cap',
	ODPIXEL								= 'teamfandom.ti2021.ODPixel',
	-- Because it's great
	BLINK									= 'bane_bane_blink_03',
	
	AsianCasters = 
	{
		'soundboard.tian_huo',
		'soundboard.wan_bu_liao_la',
		'soundboard.jia_you',
		'soundboard.po_liang_lu',
		'soundboard.zou_hao_bu_song',
		'soundboard.gao_fu_shuai',
		'soundboard.duiyou_ne',
		'soundboard.hu_lu_wa',
		'soundboard.liu_liu_liu',
		'soundboard.ni_qi_bu_qi',		
		'soundboard.ta_daaaa',	
		'soundboard.oy_oy_oy',	
		'soundboard.next_level',	
		'soundboard.easiest_money',		
		'soundboard.echo_slama_jama',			
	}, 
	
	EnglishCasters = 
	{
		'soundboard.holy_moly',									  
		'soundboard.patience',										
		'soundboard.all_dead',									
		'soundboard.wow',							
		'soundboard.brutal',					
		'soundboard.playing_to_win',			
		'soundboard.that_was_questionable',		
		'soundboard.what_just_happened',	
		'soundboard.youre_a_hero',
		'absolutely_perfect',	  -- Broken??plA
		'soundboard.glados.disappointed',
		'soundboard.looking_spicy',
		'soundboard.coming_through_with_the_woooo',
		'soundboard.nothing_that_can_stop_this_man',
		'soundboard.oh_my_god_what_oh_oh',
		'soundboard.see_you_later_nerds',
		'soundboard.what_the_f_just_happened',
	},

	CisCasters = 
	{
		'soundboard.ay_ay_ay',
		'soundboard.eto_prosto_netchto',
		'soundboard.ehto_g_g',	
		'soundboard.bozhe_ti_posmotri',
		'soundboard.oy_oy_bezhat',
		'soundboard.eto_sochno',								
		'soundboard.krasavchik',	
		'soundboard.bozhe_kak_eto_bolno',				
		'soundboard.eto_nenormalno',	
		'soundboard.kreasa_kreasa', 						
		'soundboard.kak_boyge_te_byechenya', 	
		'soundboard.eto_ge_popayx_feeda', 	
		'soundboard.wot_eto_bru', 							
		'soundboard.da_da_da_nyet', 						
		'soundboard.a_net_net_da',							
		'soundboard.a_nu_ka_idi_suda',					
		'soundboard.aaah_aaah_chto',						
		'soundboard.chto_eto_kakaya_zhest',	
		'soundboard.eto_takaya_dushka',	
		'soundboard.takaya_haliava',		
	},	
	
	FretsFavorites = 
	{
		'soundboard.da_da_da_nyet', 					
		'soundboard.a_nu_ka_idi_suda',					
		'soundboard.aaah_aaah_chto',		
		'soundboard.krasavchik',			
		'soundboard.wan_bu_liao_la',  		
		'soundboard.jia_you',							
		'soundboard.duiyou_ne',						
		'soundboard.ta_daaaa',						
		'soundboard.oy_oy_oy',						
		'soundboard.next_level',					
		'soundboard.nakupuuu',						
		'soundboard.ay_ay_ay_cn',					
		'soundboard.hui_tian_mie',				
		'soundboard.tiao_zou_le',				
		'teamfandom.ti2021.Siractionslacks',		
	},
	
	GoodSounds = 
	{
		'soundboard.holy_moly',									  
		'soundboard.patience',										
		'soundboard.all_dead',										
		'soundboard.playing_to_win',			
		'soundboard.youre_a_hero',
		'soundboard.looking_spicy',
		'soundboard.coming_through_with_the_woooo',
		'soundboard.nothing_that_can_stop_this_man',
		'soundboard.see_you_later_nerds',
		'soundboard.ta_daaaa',		
		'soundboard.next_level',						
		'soundboard.easiest_money',					
		'soundboard.echo_slama_jama',			
		'soundboard.nakupuuu',							
		'soundboard.hui_tian_mie',					
		'soundboard.tiao_zou_le',		
	},
	
	BadSounds = 
	{
		'soundboard.brutal',					
		'soundboard.that_was_questionable',		
		'soundboard.what_just_happened',	
		'soundboard.glados.disappointed',
		'soundboard.oh_my_god_what_oh_oh',
		'soundboard.see_you_later_nerds',
		'soundboard.what_the_f_just_happened',
		'soundboard.ni_qi_bu_qi',					
		'soundboard.piao_liang',						
		'soundboard.bai_tuo_shei_qu',				
		'soundboard.ay_ay_ay_cn',						
		'soundboard.ay_ay_ay',
		'soundboard.eto_prosto_netchto',
		'soundboard.ehto_g_g',	
		'soundboard.bozhe_kak_eto_bolno',				
		'soundboard.eto_nenormalno',	
		'soundboard.kreasa_kreasa', 						
		'soundboard.wot_eto_bru', 							
		'soundboard.da_da_da_nyet', 						
		'soundboard.a_net_net_da',							
		'soundboard.a_nu_ka_idi_suda',					
		'soundboard.aaah_aaah_chto',		
		'teamfandom.ti2021.Siractionslacks',		
	}		
}

return sounds