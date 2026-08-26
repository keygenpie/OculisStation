/mob/living/simple_animal/formic/philosophers_camera
	name = "Philosopher's Camera"
	desc = "A plastic mannequin in a suit, with a camera in place of its head."
	icon = 'modular_oculis/modules/contact_science/icons/philosopher_camera.dmi'
	icon_state = "philosophers_camera"

	nanotrasen_id = "NT-ARDB-001"
	primary_hazard_labels = "Neurohazard, atmos-hazard"
	secondary_hazard_labels = "Spatial aberration, chronological acceleration"
	initial_line = "Come, come! Don't you want to take a picture?"
	hidden_description = "A mannequin comprised of a plastic-like substance, its head replaced by a camera. Neither the mannequin or its camera contain any components, either organic or synthetic, that would suggest the means by which it is sapient. It seems to be adamant on taking a picture."
	dialogue_lines = list(
		"We all change, but a photograph stays the same! You wouldn't want to be forgotten, would you?",
		"I'm just waiting on you, friend! Let's take a picture!",
		"Silver to gold, gold to silver! Smile!",
		"Come now, let us savor this moment in unity!",
		"What was my name again? I've forgotten...",
		"You're just a picture away! I'll remember your name forever!",
		"Won't you help me remember?",
		"It's so cold out here..."
	)
	echoes = list(
		"take a picture"
	)

	var/firstpic = TRUE //whether or not the first picture has been taken. echoes list vastly expands after a picture is first taken with this form
	var/list/memoriam
	var/decay_level = 0 //taking pictures slowly accumulates decay, which transforms the environment
	VAR_PRIVATE/atom/movable/light_holder

/mob/living/simple_animal/formic/philosophers_camera/Initialize(mapload) //establish stuff for camera flash
	. = ..()
	var/atom/movable/parent = loc
	light_holder = src
	while(!(isnull(parent) || ismob(parent) || isturf(parent)))
		light_holder = parent
		parent = light_holder.loc
	light_holder.AddComponentFrom(REF(src), /datum/component/overlay_lighting/camera, light_range, light_power, light_color, FALSE, TRUE, FALSE, TRUE)

/mob/living/simple_animal/formic/philosophers_camera/echo_success()
	var/successful_echo = awaiting_response
	if(successful_echo == "take a picture") //take a picture, transforming the environment and transmuting material
		last_response = "take a picture"
		playsound(src, SFX_POLAROID, 75, TRUE, -3)
		light_holder.set_light_on(TRUE)
		addtimer(CALLBACK(src, PROC_REF(flash_end)), FLASH_LIGHT_DURATION, TIMER_OVERRIDE|TIMER_UNIQUE)
		var/turf/target_turf = get_turf(last_speaker)
		var/list/target_turfs = RANGE_TURFS(2, target_turf)
		transmute(target_turfs)
		decay(target_turfs)
		decay_level += 1
		if(firstpic) //add new commands after first picture
			firstpic = FALSE
			echoes += "forget me"
			echoes += "do you remember me"
			balloon_alert(last_speaker, "new echoes detected!")
		if(memoriam)
			if(!memoriam.Find(last_speaker))
				memoriam += last_speaker
				langsay("Click! I'll remember you forever!")
			else
				langsay("Click! Another for the books!")
		else //if list isnt initialized yet, make it
			memoriam = list(last_speaker)
			langsay("Click! Glad to make your acquaintance!")
	if(successful_echo == "forget me") //be forgotten from the list, taking brain damage but reducing decay level.
		last_response = "forget me"
		if(memoriam.Find(last_speaker))
			memoriam -= last_speaker
			if(decay_level > 0)
				last_speaker.adjust_organ_loss(ORGAN_SLOT_BRAIN, decay_level * 4, 20)
				decay_level *= 0.5
				to_chat(last_speaker, span_warning("You feel the camera's entropy slow down... your head pounds."))
				langsay("Don't worry! I've... already forgotten.")
		else //still causes brain damage if not found
			langsay("But... I don't know who you are. What do you mean, friend?")
			last_speaker.adjust_organ_loss(ORGAN_SLOT_BRAIN, decay_level * 2, 20)
	if(successful_echo == "do you remember me") //let the decay level increase, curing some brain damage. causes them to forget afterwards to prevent spam
		last_response = "do you remember me"
		if(memoriam.Find(last_speaker))
			memoriam -= last_speaker
			last_speaker.adjust_organ_loss(ORGAN_SLOT_BRAIN, decay_level * -2, 20)
			to_chat(last_speaker, span_warning("You feel the camera's entropy accelerate... yet your head feels clearer."))
			decay_level += 2
			langsay("I remember you! But... I'm already forgetting.")
		else
			langsay("I can't seem to! Perhaps we should take a picture?")
	return

/mob/living/simple_animal/formic/philosophers_camera/proc/transmute(list/turfs)
	for(var/turf/changing_turf in turfs)
		for(var/obj/item/stack/T in changing_turf) //here's where the material transmutations are placed
			playsound(changing_turf, SFX_SPARKS, 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			if(istype(T, /obj/item/stack/sheet/mineral/silver)) //silver to gold
				var/obj/item/stack/sheet/mineral/newmat = new /obj/item/stack/sheet/mineral/gold(get_turf(T))
				newmat.amount = T.amount
				qdel(T)
			if(istype(T, /obj/item/stack/sheet/mineral/gold)) //gold to silver
				var/obj/item/stack/sheet/mineral/newmat = new /obj/item/stack/sheet/mineral/silver(get_turf(T))
				newmat.amount = T.amount
				qdel(T)
			if(istype(T, /obj/item/stack/sheet/glass)) //glass to iron
				var/obj/item/stack/sheet/mineral/newmat = new /obj/item/stack/sheet/iron(get_turf(T))
				newmat.amount = T.amount
				qdel(T)
			if(istype(T, /obj/item/stack/sheet/iron)) //iron to glass
				var/obj/item/stack/sheet/mineral/newmat = new /obj/item/stack/sheet/glass(get_turf(T))
				newmat.amount = T.amount
				qdel(T)
			if(istype(T, /obj/item/stack/sheet/mineral/titanium)) //titanium to plastic
				var/obj/item/stack/sheet/mineral/newmat = new /obj/item/stack/sheet/plastic(get_turf(T))
				newmat.amount = T.amount
				qdel(T)
			if(istype(T, /obj/item/stack/sheet/plastic)) //plastic to titanium
				var/obj/item/stack/sheet/mineral/newmat = new /obj/item/stack/sheet/mineral/titanium(get_turf(T))
				newmat.amount = T.amount
				qdel(T)
			if(istype(T, /obj/item/stack/sheet/mineral/diamond)) //diamond to BSC
				var/obj/item/stack/sheet/mineral/newmat = new /obj/item/stack/ore/bluespace_crystal/artificial(get_turf(T))
				newmat.amount = T.amount
				qdel(T)
			if(istype(T, /obj/item/stack/ore/bluespace_crystal/artificial)) //BSC to diamond
				var/obj/item/stack/sheet/mineral/newmat = new /obj/item/stack/sheet/mineral/diamond(get_turf(T))
				newmat.amount = T.amount
				qdel(T)

/mob/living/simple_animal/formic/philosophers_camera/proc/decay(list/turfs)
	for(var/turf/changing_turf in turfs)
		if(decay_level >= 2) //at decay 2, spread rust
			if(iswallturf(changing_turf) && prob(15 + 5 * decay_level))
				changing_turf.ChangeTurf(/turf/closed/wall/rust, flags = CHANGETURF_INHERIT_MOUNTS)
				playsound(changing_turf, SFX_SPARKS, 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			if(isfloorturf(changing_turf) && prob(15 + 5 * decay_level))
				changing_turf.ChangeTurf(/turf/open/floor/plating/rust, flags = CHANGETURF_INHERIT_AIR | CHANGETURF_INHERIT_MOUNTS)
				playsound(changing_turf, SFX_SPARKS, 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		if(decay_level >= 3) //at decay 3, start breaking lights
			for(var/obj/machinery/light/light in changing_turf)
				if(prob(25 + 5 * decay_level))
					light.break_light_tube()
		if(decay_level >= 6) //at decay 6, start creating miasma
			if(prob(5 * decay_level))
				var/datum/gas_mixture/mix_to_spawn = new()
				mix_to_spawn.adjust_gas(/datum/gas/miasma, 2 * decay_level)
				changing_turf.assume_air(mix_to_spawn)

/mob/living/simple_animal/formic/philosophers_camera/proc/flash_end()
	PRIVATE_PROC(TRUE)

	light_holder.set_light_on(FALSE)
