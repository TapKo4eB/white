/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	active_power_usage = 3000
	max_integrity = 200
	integrity_failure = 0.5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 40, ACID = 20)
	var/brightness_on = 1
	var/icon_keyboard = "generic_key"
	var/icon_screen = "generic"
	var/time_to_screwdrive = 20
	var/authenticated = 0
	var/clued = FALSE

/obj/machinery/computer/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()

	power_change()

/obj/machinery/computer/Destroy()
	. = ..()

/obj/machinery/computer/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE
	return TRUE

/obj/machinery/computer/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		. += "[icon_keyboard]_off"
		return
	. += icon_keyboard

	// This whole block lets screens ignore lighting and be visible even in the darkest room
	var/overlay_state = icon_screen
	if(machine_stat & BROKEN)
		overlay_state = "[icon_state]_broken"
	. += mutable_appearance(icon, overlay_state, layer, plane)
	. += mutable_appearance(icon, overlay_state, layer, EMISSIVE_PLANE)

/obj/machinery/computer/power_change()
	. = ..()
	if(machine_stat & NOPOWER)
		set_light(0)
	else
		set_light(brightness_on)

/obj/machinery/computer/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(clued)
		to_chat(user, span_notice("Чиню развёртку монитора..."))
		clued = FALSE
		icon_screen = initial(icon_screen)
		update_icon()
		tgui_id = initial(tgui_id)
		return TRUE
	if(circuit && !(flags_1&NODECONSTRUCT_1))
		to_chat(user, span_notice("You start to disconnect the monitor..."))
		if(I.use_tool(src, user, time_to_screwdrive, volume=50))
			deconstruct(TRUE, user)
	return TRUE

/obj/machinery/computer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
			else
				playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/computer/obj_break(damage_flag)
	if(!circuit) //no circuit, no breaking
		return
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		set_light(0)

/obj/machinery/computer/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		switch(severity)
			if(1)
				if(prob(50))
					obj_break(ENERGY)
			if(2)
				if(prob(10))
					obj_break(ENERGY)

/obj/machinery/computer/deconstruct(disassembled = TRUE, mob/user)
	on_deconstruction()
	if(!(flags_1 & NODECONSTRUCT_1))
		if(circuit) //no circuit, no computer frame
			var/obj/structure/frame/computer/A = new /obj/structure/frame/computer(src.loc)
			A.setDir(dir)
			A.circuit = circuit
			// Circuit removal code is handled in /obj/machinery/Exited()
			circuit.forceMove(A)
			A.set_anchored(TRUE)
			if(machine_stat & BROKEN)
				if(user)
					to_chat(user, span_notice("The broken glass falls out."))
				else
					playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
				new /obj/item/shard(drop_location())
				new /obj/item/shard(drop_location())
				A.state = 3
				A.icon_state = "3"
			else
				if(user)
					to_chat(user, span_notice("You disconnect the monitor."))
				A.state = 4
				A.icon_state = "4"
		for(var/obj/C in src)
			C.forceMove(loc)
	qdel(src)

/obj/machinery/computer/can_interact(mob/user)
	if(clued && ishuman(user) && !IS_DREAMER(user))
		playsound(src, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "dreamer", /datum/mood_event/seen_dream, clued)
		return FALSE
	if(..())
		return TRUE

/obj/machinery/computer/AltClick(mob/user)
	. = ..()
	if((IS_DREAMER(user) && !clued))
		if(!user.CanReach(src))
			return
		for(var/i in 1 to 10)
			playsound(src, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			if(!do_after(user, (rand(9, 15)), target = src))
				return
		clued = pick(GLOB.dreamer_clues)
		to_chat(user, span_revenbignotice("[clued]... ЭТОТ ШЕДЕВР ДОЛЖНЫ УЗРЕТЬ!"))
		icon_screen = "clued"
		update_icon()
		tgui_id = "DreamerCorruption"
		return
	if(!user.canUseTopic(src, !issilicon(user)) || !is_operational)
		return

/obj/machinery/computer/examine(mob/user)
	. = ..()
	if((IS_DREAMER(user)))
		. += "<hr>"
		if(clued)
			. += span_revenbignotice("Чудо [clued]!")
		else
			. += span_revenbignotice("СПРАВА есть АЛЬТЕРНАТИВНЫЙ секрет.")
	else if (clued)
		can_interact(user)
