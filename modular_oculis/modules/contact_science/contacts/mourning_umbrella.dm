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
	var/breaching = FALSE

	//weather stuff, mostly copied from weather anomaly code
	var/rain_type = /datum/weather/particle/rain_storm
	var/thunder_chance = THUNDER_CHANCE_HIGH
	var/area/weather_area
	VAR_PRIVATE/list/active_weathers
	var/telegraph = dissipation_timer / 15 // 1/15th of the time is dedicated to telegraphing, to give people time to get outta the way
	var/end_dur = dissipation_timer / 15 // then 1/15th of the time is dedicated to winding down
	var/total_dur = dissipation_timer - telegraph - end_dur

/mob/living/simple_animal/formic/mourning_umbrella/Initialize(mapload)
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
	active_weathers -= weather_datum
	UnregisterSignal(weather_datum, COMSIG_QDELETING)

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

/mob/living/simple_animal/formic/mourning_umbrella/proc/feed_biometric(mob/living/carbon/human/feeder)
	var is_success = FALSE
	for(var/obj/item/feeding_item in feeder.held_items)
		if(istype(feeding_item, /obj/item/paper/medical_report)) //eat health scan
			dissipation_timer_current -= 5 //reduce the max timer, little by little. it will pass eventually
			is_success = TRUE
			to_chat(feeder, span_warning("The paper disappears as its essence is absorbed by the creature."))
			qdel(feeding_item)
	if(is_success)
		say("Thank you. This should help the rain pass.")
		playsound(feeder, 'sound/effects/portal/portal_travel.ogg', 25)
	else
		say("This will not do. Present biometric data.")
