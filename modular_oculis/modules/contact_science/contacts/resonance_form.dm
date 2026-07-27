/mob/living/simple_animal/formic
	name = "anomalous resonance form"
	desc = "An anomalous contact, brought forth from the Storm."
	wander = 0

	var/nanotrasen_id = "NT-ARDB-000"
	var/primary_hazard_labels = "Cognitohazard"
	var/secondary_hazard_labels = "Conceptual alteration"
	var/initial_line = "Hello!"
	var/hidden_description = "ooOOoo"
	var/list/dialogue_lines = list(
		"Hello!",
		"Goodbye!"
	)
	var/list/echoes = list(
		"who are you"
	)
	var/dialogue_timer_current = 0
	var/dialogue_timer = 30
	var/interaction_cooldown_current = 0
	var/interaction_cooldown = 2
	var/dialogue_delay = 4
	var/list/active_links
	var/last_response = "None"
	var/last_speaker
	var/awaiting_response

/mob/living/simple_animal/formic/Initialize(mapload)
	. = ..()
	say(initial_line)

/mob/living/simple_animal/formic/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(interaction_cooldown_current > 0)
		interaction_cooldown_current -= seconds_per_tick
	if(dialogue_timer_current < dialogue_timer)
		dialogue_timer_current += seconds_per_tick
		if(dialogue_timer_current >= dialogue_timer)
			perform_dialogue()

/mob/living/simple_animal/formic/proc/perform_dialogue()
	dialogue_timer_current = 0
	if(interaction_cooldown_current > 0) //don't speak if there was recent interaction to prevent awkward dialogue spam
		return
	var/performed_dialogue = pick(dialogue_lines)
	say(performed_dialogue)

/mob/living/simple_animal/formic/proc/respond_to_command(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	var/haystack = hearing_args[SPEECH_MESSAGE]
	if(interaction_cooldown_current <= 0) //brief cooldown to ensure interactions are not spammed
		interaction_cooldown_current = interaction_cooldown
		for(var/needle in echoes)
			if(findtext(haystack, needle)) //success
				dialogue_timer_current = 0 //resets dialogue timer to also prevent awkward dialogue spam
				awaiting_response = needle
				last_speaker = source
				addtimer(CALLBACK(src, PROC_REF(echo_success)), dialogue_delay, TIMER_UNIQUE | TIMER_DELETE_ME) //short delay to make dialogue seem more natural
				return

/mob/living/simple_animal/formic/proc/echo_success() //put interactions here
	var/successful_echo = awaiting_response
	if(successful_echo == "who are you")
		say("Insert response here.")
		last_response = "who are you"
	return

/mob/living/simple_animal/formic/proc/establish_link(mob/living/target)
	if(!active_links) //if list is not made yet, make it. errors otherwise because list doesnt exist yet
		RegisterSignal(target, COMSIG_MOB_SAY, PROC_REF(respond_to_command))
		active_links = list(target)
		balloon_alert(target, "speech linked!")
		return
	if(!active_links.Find(target)) //if target is not already linked to this resonant form
		RegisterSignal(target, COMSIG_MOB_SAY, PROC_REF(respond_to_command))
		active_links += target
		balloon_alert(target, "speech linked!")
	else
		balloon_alert(target, "speech already linked!")
