//////////////////Imp

/mob/living/simple_animal/hostile/imp
	name = "imp"
	real_name = "imp"
	unique_name = TRUE
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("кудахчет")
	emote_hear = list("кудахчет","визжит")
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "бьёт"
	response_harm_simple = "бьёт"
	icon = 'icons/mob/mob.dmi'
	icon_state = "imp"
	icon_living = "imp"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = TRUE
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 250 //Weak to cold
	maxbodytemp = INFINITY
	faction = list("hell")
	attack_verb_continuous = "яростно разрывает"
	attack_verb_simple = "яростно разрывает"
	maxHealth = 200
	health = 200
	healable = 0
	obj_damage = 40
	melee_damage_lower = 10
	melee_damage_upper = 15
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	del_on_death = TRUE
	deathmessage = "screams in agony as it sublimates into a sulfurous smoke."
	deathsound = 'sound/magic/demon_dies.ogg'
	var/playstyle_string = "<span class='big bold'>You are an imp,</span><B> a mischievous creature from hell. You are the lowest rank on the hellish totem pole \
							Though you are not obligated to help, perhaps by aiding a higher ranking devil, you might just get a promotion. However, you are incapable	\
							of intentionally harming a fellow devil.</B>"
	discovery_points = 10000

/datum/antagonist/imp
	name = "Imp"
	antagpanel_category = "Devil"
	show_in_roundend = FALSE
	greentext_reward = 5

/datum/antagonist/imp/on_gain()
	. = ..()
	give_objectives()

/datum/antagonist/imp/proc/give_objectives()
	var/datum/objective/newobjective = new
	newobjective.explanation_text = "Try to get a promotion to a higher devilic rank."
	newobjective.owner = owner
	objectives += newobjective
