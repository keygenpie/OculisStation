/mob/living/simple_animal/formic/mourning_umbrella
	name = "Mourning Umbrella"
	desc = "An umbrella of deep black coloration. Rain falls around it."
	icon = 'modular_oculis/modules/contact_science/icons/mourning_umbrella.dmi'
	icon_state = "brella"

	nanotrasen_id = "NT-ARDB-005"
	primary_hazard_labels = "Somatohazard"
	secondary_hazard_labels = "Hostile manifestation, weather manifestation"
	initial_line = "Let nobody perish in the presence of the rain."
	hidden_description = "A black umbrella, held up by a localized kinetic force at its base. It seems to have a direct connection to NT crew sensors, monitoring for death. It accepts biometric data from health scanners as feed."
	dialogue_lines = list(
		"Only for a blink in the vast ongoing time do I observe.",
		"To you, I must appear as an umbrella. How fitting.",
		"Do you believe yourself able to keep your colleagues alive?",
		"What a terrible day for it to rain.",
		"Cry, weep, for those dead at your feet.",
		"Do you feel it falling? When it rains, it pours.",
		"The rain falls, and hits the ground, yet the ground does not remember it."
	)
	echoes = list(
		"feed from my hand",
		"how long is the rain",
		"what are you"
	)

	var/dissipation_timer = 600
	var/dissipation_timer_current = 600 //a boon comes when the rain dissipates
	var/death_points = 2 //when this many people die in the presence of the rain, the umbrella causes a breach
	var/scan_reduction_factor = 40
	var/scan_reduction_reduction = 4
	var/butterfly_rate = 20 //chance to spawn a butterfly per tile in an area when breaching
	var/max_butterflies = 12 //to prevent a ridiculous amount of spawns in big areas

	//weather stuff, mostly copied from weather anomaly code
	var/datum/weather/particle/rain_type = /datum/weather/particle/rain_storm
	var/thunder_chance = THUNDER_CHANCE_HIGH
	var/area/weather_area
	VAR_PRIVATE/list/active_weathers
	var/telegraph = 10 SECONDS // time dedicated to telegraphing, to give people time to get outta the way
	var/end_dur = 1 SECONDS // time dedicated to winding down
	var/total_dur = 1200 SECONDS //arbitrarily large. itll end when the umbrella is gone regardless

	var/list/crew_data

/mob/living/simple_animal/formic/mourning_umbrella/Initialize(mapload)
	. = ..()
	weather_area = get_area(src)
	var/list/num_turfs = length(weather_area.get_turfs_from_all_zlevels())
	active_weathers = list()
	var/datum/weather/weather = SSweather.run_weather(
		weather_datum_type = rain_type,
		z_levels = z,
		weather_data = list(
			WEATHER_FORCED_AREAS = list(weather_area),
			WEATHER_FORCED_FLAGS = rain_type::weather_flags | WEATHER_INDOORS | WEATHER_THUNDER | WEATHER_STRICT_ALERT,
			WEATHER_FORCED_THUNDER = thunder_chance,
			WEATHER_FORCED_TELEGRAPH = telegraph,
			WEATHER_FORCED_END = end_dur,
			WEATHER_FORCED_DURATION = total_dur,
		)
	)
	active_weathers += weather
	RegisterSignal(weather, COMSIG_QDELETING, PROC_REF(clear_weather))

/mob/living/simple_animal/formic/mourning_umbrella/proc/clear_weather(datum/weather/weather_datum)
	SIGNAL_HANDLER
	weather_datum.end()
	active_weathers -= weather_datum
	UnregisterSignal(weather_datum, COMSIG_QDELETING)

/mob/living/simple_animal/formic/mourning_umbrella/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	var/turf/this_turf = get_turf(src)
	crew_data = GLOB.crewmonitor.update_data(this_turf.z) //get data to check for death
	var/death_toll = 0 //number of current dead people
	for(var/list/entry in crew_data)
		if(entry["life_status"] == 4)
			death_toll += 1
	if(death_toll >= death_points && !breaching)
		breaching = TRUE
		sound_to_playing_players('sound/effects/magic/lightning_chargeup.ogg')
		addtimer(CALLBACK(src, PROC_REF(breach)), 80, TIMER_UNIQUE | TIMER_DELETE_ME)
		say("The rain has seen death. I cannot stop it any longer. Goodbye.")
	if(!breaching)
		dissipation_timer_current -= 1
		if(dissipation_timer_current <= 0) //the timer is up. grant the boon
			for(var/datum/weather/stopping in active_weathers)
				clear_weather(stopping)
			say("Finally, the rain passes. My boon is yours. May we pass again.")
			addtimer(CALLBACK(src, PROC_REF(reward)), 30, TIMER_UNIQUE | TIMER_DELETE_ME)

/mob/living/simple_animal/formic/mourning_umbrella/echo_success()
	var/successful_echo = awaiting_response
	if(breaching)
		return
	if(successful_echo == "feed from my hand") //feed from the hands of the speaker. accepts biometric data from health scanners
		last_response = "feed from my hand"
		if(get_dist(src, last_speaker) > 1) //must be adjacent
			say("Come closer, so that I may absorb.")
		else
			feed_biometric(last_speaker)
	if(successful_echo == "how long is the rain") //check the timer
		last_response = "how long is the rain"
		if(dissipation_timer_current < dissipation_timer * 0.25) //less than 25%
			say("Not much longer, now.")
		else if(dissipation_timer_current < dissipation_timer * 0.5) //less than 50%
			say("It will be some time longer.")
		else if(dissipation_timer_current < dissipation_timer * 0.75) //less than 75%
			say("The rain has passed somewhat, though there is plenty more.")
		else
			say("The rain has hardly passed yet.")
	if(successful_echo == "what are you") //simple dialogue
		last_response = "what are you"
		say("An arbiter of the rain. It shall pass, so long as it does not sense death.")
		echoes -= "what are you"
		echoes += "what is the rain"
		balloon_alert(last_speaker, "new echoes detected!")
	if(successful_echo == "where is your hunger") //simple dialogue, only after it doesnt want to feed anymore
		last_response = "where is your hunger"
		say("There is only so much data I can feed the rain. Now, we must only allow its surveillance and bide our time.")
	if(successful_echo == "what is the rain") //simple dialogue, only after asking what it is
		if(last_response == "where is your hunger") //if fully fed before doing this dialogue and after performing the other dialogue, text changes. for fun really
			last_response = "what is the rain"
			say("It is what I feed the scans you provide me. It praises life, and your scans have certainly pleased it. But, only so much can be done.")
		last_response = "what is the rain"
		say("It watches your biometrics. It despises death, and praises life. When it rains, it pours.")

/mob/living/simple_animal/formic/mourning_umbrella/proc/feed_biometric(mob/living/carbon/human/feeder)
	var is_success = FALSE
	for(var/obj/item/feeding_item in feeder.held_items)
		if(istype(feeding_item, /obj/item/paper/medical_report)) //eat health scan
			dissipation_timer_current -= scan_reduction_factor //reduce the max timer, little by little. it will pass eventually
			scan_reduction_factor -= scan_reduction_reduction //only so many papers can be submitted
			if(scan_reduction_factor <= 0)
				echoes -= "feed from my hand"
				echoes += "where is your hunger"
				balloon_alert(last_speaker, "new echoes detected!")
			is_success = TRUE
			to_chat(feeder, span_warning("The paper disappears as its essence is absorbed by the creature."))
			qdel(feeding_item)
	if(is_success)
		say("Thank you. This should help the rain pass.")
		playsound(feeder, 'sound/effects/portal/portal_travel.ogg', 25)
	else
		say("This will not do. Present biometric data.")

/mob/living/simple_animal/formic/mourning_umbrella/proc/breach()
	var/butterflies_spawned = 0
	priority_announce("An anomalous resonance form has breached containment within [station_name()]. Please route to subdue the hostile form.")
	for(var/datum/weather/stopping in active_weathers)
		clear_weather(stopping)
	for(var/turf/butterfly_turf in weather_area)
		if(prob(butterfly_rate))
			new /mob/living/simple_animal/hostile/mourning_butterfly(butterfly_turf)
			butterflies_spawned += 1
			if(butterflies_spawned >= max_butterflies)
				qdel(src)
				return
	qdel(src)

/mob/living/simple_animal/formic/mourning_umbrella/proc/reward()
	playsound(src, 'sound/effects/portal/portal_travel.ogg', 50)
	new /obj/item/gun/energy/cell_loaded/medigun/mourning(get_turf(src))
	visible_message(span_warning("The umbrella dissipates just as the rain did, leaving behind a strange weapon."))
	qdel(src)

/obj/item/gun/energy/cell_loaded/medigun/mourning
	name = "umbrella's boon"
	desc = "An odd medigun with an umbrella shrouding its barrel. An inscription in its grip reads 'ABHOR DEATH, PRAISE LIFE.' Can be loaded with up to four medicells, and fires in three-round bursts."
	icon = 'modular_oculis/modules/contact_science/icons/mourning_umbrella.dmi'
	icon_state = "medigun"
	inhand_icon_state = "riotgun" //close enough
	maxcells = 4
	selfcharge = 1
	can_charge = FALSE
	emp_resistance = 2
	block_chance = 25
	weapon_weight = WEAPON_MEDIUM
	burst_size = 3
	cell_type = /obj/item/stock_parts/power_store/cell/medigun/weeping

/obj/item/gun/energy/cell_loaded/medigun/mourning/add_deep_lore() //overrides original medigun deepdesc
	return

/obj/item/stock_parts/power_store/cell/medigun/weeping
	name = "weeping medigun cell"
	maxcharge = STANDARD_CELL_CHARGE * 2
	chargerate = STANDARD_CELL_CHARGE * 0.2

/mob/living/simple_animal/hostile/mourning_butterfly
	name = "mourning butterfly"
	desc = "An aspect of the rain. Its razor-sharp wings smell of rot."
	health = 80
	maxHealth = 80
	speed = 3
	icon = 'modular_oculis/modules/contact_science/icons/mourning_umbrella.dmi'
	icon_state = "butterfly"
	environment_smash = ENVIRONMENT_SMASH_WALLS
	melee_damage_lower = 5
	melee_damage_upper = 10
	melee_damage_type = BRUTE
	obj_damage = 20
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	attack_verb_continuous = "flies at"
	attack_verb_simple = "fly at"
	wound_bonus = 25
	ai_controller = /datum/ai_controller/basic_controller/mournfly
	rapid_melee = 2

/datum/ai_controller/basic_controller/mournfly
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree
	)
