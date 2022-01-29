/datum/component/dreamer
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/prob_variability = 23
	var/animation_intensity = 7
	var/turf_plane
	var/speak_probability = 7

	var/mob/living/carbon/human/our_dreamer
	var/list/fucked_turfs = list()

/datum/component/dreamer/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSobj, src)
	our_dreamer = parent

	if(!our_dreamer?.client)
		stack_trace("DREAMER ADDED IN MOB WITHOUT CLIENT!")

	our_dreamer.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC

	make_sounds()

	if(our_dreamer?.dna?.species)
		our_dreamer.dna.species.armor = 50
		our_dreamer.dna.species.heatmod = 0.1
		our_dreamer.dna.species.coldmod = 0.1
		our_dreamer.dna.species.stunmod = 0.1
		our_dreamer.dna.species.siemens_coeff = 0.1
		our_dreamer.dna.species.punchdamagelow = 25
		our_dreamer.dna.species.punchdamagehigh = 50
	else
		stack_trace("DREAMER IS FUCKED UP SOMEHOW!")

/datum/component/dreamer/proc/make_sounds()
	SIGNAL_HANDLER

	var/client/C = our_dreamer.client

	fucked_turfs = list()

	if(C.prefs.toggles & SOUND_SHIP_AMBIENCE)
		C.prefs.toggles ^= SOUND_SHIP_AMBIENCE

	if(our_dreamer?.client?.prefs.toggles & SOUND_JUKEBOX)
		C.prefs.toggles ^= SOUND_JUKEBOX

	if(our_dreamer?.client?.prefs.toggles & SOUND_AMBIENCE)
		C.prefs.toggles ^= SOUND_AMBIENCE

	DIRECT_OUTPUT(our_dreamer, sound(null))
	C?.tgui_panel?.stop_music()

	SEND_SOUND(our_dreamer, sound('white/valtos/sounds/lifeweb/dreamer_is_still_asleep.ogg', repeat = TRUE, wait = 0, volume = 75, channel = CHANNEL_BUZZ))

/datum/component/dreamer/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_SAY, .proc/handle_speech)
	RegisterSignal(parent, COMSIG_MOB_LOGIN, .proc/make_sounds)
	return

/datum/component/dreamer/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_SAY)
	UnregisterSignal(parent, COMSIG_MOB_LOGIN)
	return

/datum/component/dreamer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/dreamer/process(delta_time)

	var/list/fuckfloorlist = list()

	for(var/turf/T in RANGE_TURFS(15, our_dreamer))
		if(!prob(prob_variability))
			continue
		if(T in fucked_turfs)
			continue
		if(isgroundlessturf(T))
			continue
		var/image/I = image(icon = T.icon, icon_state = T.icon_state, loc = T)

		I.alpha = rand(200, 255)
		I.copy_overlays(T)
		I.plane = turf_plane ? turf_plane : T.plane

		var/matrix/M = matrix()
		M.Translate(0, rand(-animation_intensity, animation_intensity))

		animate(I, transform = M, time = rand(animation_intensity * 2, animation_intensity * 4), loop = -1, easing = SINE_EASING)
		animate(transform = null, time = rand(animation_intensity * 2, animation_intensity * 4), easing = SINE_EASING)

		fucked_turfs += T
		fuckfloorlist += I

	our_dreamer.heal_overall_damage(5, 5, 5)
	our_dreamer.setOxyLoss(0)
	our_dreamer.setToxLoss(0)
	our_dreamer.blood_volume = BLOOD_VOLUME_NORMAL

	if(our_dreamer.handcuffed)
		var/obj/O = our_dreamer.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
		if(istype(O))
			our_dreamer.clear_cuffs(O, TRUE)
			playsound(get_turf(our_dreamer), 'sound/effects/grillehit.ogg', 80, 1, -1)

	if(prob(speak_probability))
		speak_from_above()

	if(our_dreamer?.client)
		our_dreamer.client.images |= fuckfloorlist

/datum/component/dreamer/proc/handle_speech(mob/speaker, speech_args)
	SIGNAL_HANDLER

	if(speaker == our_dreamer || prob(25))
		var/tmp_msg = speech_args[SPEECH_MESSAGE]
		spawn(rand(10, 50))
			speak_from_above(tmp_msg)
		spawn(rand(10, 50))
			if(prob(25))
				SEND_SOUND(our_dreamer, sound('white/hule/SFX/rjach.ogg'))

/datum/component/dreamer/proc/speak_from_above(what_we_should_say)

	if(!what_we_should_say)
		what_we_should_say = pick("Это всё не настоящее", "Ты не настоящий", "Умри", \
								"Действуй", "Я тебя ненавижу", "Ебанутый", "Остановись", \
								"У тебя мало времени", "Убей", "Убийца", "Ты настоящий", \
								"Это всё настоящее", "[pick_list_replacements(HAL_LINES_FILE, "conversation")]", \
								"[pick_list_replacements(HAL_LINES_FILE, "help")]", \
								"[pick_list_replacements(HAL_LINES_FILE, "accusations")]", \
								"[pick_list_replacements(HAL_LINES_FILE, "advice")]")
	if(prob(25))
		what_we_should_say = uppertext(what_we_should_say)
	else if(prob(5))
		what_we_should_say = slur(what_we_should_say)
	else if(prob(5))
		what_we_should_say = Gibberish(what_we_should_say)
	else if(prob(1))
		what_we_should_say = ddlc_text(what_we_should_say)

	what_we_should_say = capitalize(what_we_should_say)

	if(prob(25))
		what_we_should_say = "[what_we_should_say]! [what_we_should_say]! [what_we_should_say]!"

	for(var/i in 1 to rand(1, 3))
		var/list/tlist = list()

		for(var/obj/O in view(6, our_dreamer))
			if(!isobj(O))
				continue
			tlist += O

		var/atom/A = pick(tlist)

		var/image/speech_overlay = image('icons/mob/talk.dmi', A, "default2", FLY_LAYER)
		spawn(rand(10, 50))
			INVOKE_ASYNC(GLOBAL_PROC, /proc/flick_overlay, speech_overlay, list(our_dreamer?.client), 30)
			our_dreamer.Hear(what_we_should_say, A, our_dreamer.get_random_understood_language(), what_we_should_say)

	spawn(rand(10, 50))
		SEND_SOUND(our_dreamer, pick(RANDOM_DREAMER_SOUNDS))
