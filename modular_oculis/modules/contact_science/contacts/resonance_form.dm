/mob/living/simple_animal/formic
	name = "anomalous resonance form"
	desc = "An anomalous contact, brought forth from the Storm."
	wander = 0

	var/nanotrasen_id = "Identification: H1-001"
	var/hazard_labels = "Cognitohazard"
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
	for(var/needle in echoes)
		if(findtext(haystack, needle)) //success
			echo_success(needle)
			return

/mob/living/simple_animal/formic/proc/echo_success(successful_echo) //put interactions here
	if(interaction_cooldown_current <= 0) //brief cooldown to ensure interactions are not spammed
		interaction_cooldown_current = interaction_cooldown
		if(successful_echo == "who are you")
			say("Insert response here.")
		return

/mob/living/simple_animal/formic/proc/establish_link(mob/living/target)
	RegisterSignal(target, COMSIG_MOB_SAY, PROC_REF(respond_to_command))
	balloon_alert(target, "speech linked!")
