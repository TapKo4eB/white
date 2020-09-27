/datum/element/decal/blood
	//dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/element/decal/blood/Attach(datum/target, _icon, _icon_state, _dir, _cleanable=CLEAN_TYPE_BLOOD, _color, _layer=ABOVE_OBJ_LAYER)
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	. = ..()

	RegisterSignal(target, COMSIG_ATOM_GET_EXAMINE_NAME, .proc/get_examine_name)
	RegisterSignal(target, COMSIG_WIPE_BLOOD_DNA, .proc/Detach)

/datum/element/decal/blood/generate_appearance(_icon, _icon_state, _dir, _layer, _color, _alpha, source)
	var/obj/item/I = source
	if(!_icon)
		_icon = 'icons/effects/blood.dmi'
	if(!_icon_state)
		_icon_state = "itemblood"
	var/icon = initial(I.icon)
	var/icon_state = initial(I.icon_state)
	if(!icon || !icon_state)
		// It's something which takes on the look of other items, probably
		icon = I.icon
		icon_state = I.icon_state
	var/static/list/blood_splatter_appearances = list()
	//try to find a pre-processed blood-splatter. otherwise, make a new one
	var/index = "[REF(icon)]-[icon_state]"
	pic = blood_splatter_appearances[index]

	if(!pic)
		var/icon/blood_splatter_icon = icon(initial(I.icon), initial(I.icon_state), , 1)		//we only want to apply blood-splatters to the initial icon_state for each object
		blood_splatter_icon.Blend("#fff", ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
		blood_splatter_icon.Blend(icon(_icon, _icon_state), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
		pic = mutable_appearance(blood_splatter_icon, initial(I.icon_state))
		blood_splatter_appearances[index] = pic
	return TRUE

/datum/element/decal/blood/proc/get_examine_name(datum/source, mob/user, list/override)
	SIGNAL_HANDLER

	var/atom/A = source
	override[EXAMINE_POSITION_ARTICLE] = A.gender == PLURAL? "" : ""
	override[EXAMINE_POSITION_BEFORE] = " (в крови) "
	return COMPONENT_EXNAME_CHANGED
