/datum/disease/cumvirus
	name = "Cumthiris+61"
	max_stages = 6
	stage_prob = 1
	spread_text = "On contact"
	cure_text = "Галоперидол & Святая вода"
	spread_flags = DISEASE_SPREAD_CONTACT_FLUIDS
	cures = list(/datum/reagent/medicine/haloperidol,/datum/reagent/water/holywater)
	cure_chance = 7.5
	agent = "Cumthiris"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Симптомы заставляют зараженный субъект непроизвольно эякулировать."
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	permeability_mod = 1
	bypasses_immunity = TRUE
	infectable_biotypes = MOB_ORGANIC|MOB_UNDEAD|MOB_ROBOTIC|MOB_MINERAL
	severity = DISEASE_SEVERITY_BIOHAZARD

/datum/disease/cumvirus/stage_act(delta_time, times_fired)
	. = ..()
	if(!. || !ishuman(affected_mob))
		return
	var/mob/living/carbon/human/H = affected_mob
	switch(stage)
		if(2)
			if(DT_PROB(5, delta_time))
				H.emote("cough")
		if(3)
			if(DT_PROB(5, delta_time))
				H.emote("moan")
			if(DT_PROB(10, delta_time))
				to_chat(H, span_danger("Чувствую себя возбужденным."))
		if(4)
			to_chat(H, span_userdanger("Чувствую очень сильное напряжение в своем половом органе!"))
			if(DT_PROB(40, delta_time))
				H.emote("moan")
				H.end_dance()
				H.adjustStaminaLoss(3.5, FALSE)
				shake_camera(H, 1, 1)
			if(DT_PROB(20, delta_time))
				to_chat(H, span_danger("Чувствую себя ОЧЕНЬ возбужденным."))
		if(5)
			to_chat(H, span_userdanger("Непроизвольно кончаю!"))
			if(DT_PROB(30, delta_time))
				H.emote("moan")
				H.end_dance()
				H.adjustStaminaLoss(10, FALSE)
				shake_camera(H, 1, 2)
			if(DT_PROB(20, delta_time))
				H.end_dance()
				H.Paralyze(40)
				H.add_confusion(8)
				shake_camera(H, 2, 3)
				H.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash)
				H.clear_fullscreen("flash", 4.5)
		if(6)
			if(DT_PROB(30, delta_time))
				H.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash)
				H.clear_fullscreen("flash", 8.5)
				to_chat(H, span_userdanger("ТЕРЯЮ ПОСЛЕДНИЙ ОГОНЕК РАЗУМА!!"))
				H.ai_controller = new /datum/ai_controller/raper(H)
				H.ghostize(FALSE)
				H.eye_color = "f00"
				H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
				H.update_body()
			if(DT_PROB(10, delta_time))
				H.end_dance()
				H.emote("moan")
				H.do_jitter_animation(30)
