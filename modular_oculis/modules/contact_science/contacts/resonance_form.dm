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
	var/list/echoes
	var/dialogue_timer_current = 0
	var/dialogue_timer = 30
	var/interaction_cooldown_current = 0
	var/interaction_cooldown = 2

/mob/living/simple_animal/formic/process(seconds_per_tick)
	if(interaction_cooldown_current > 0)
		interaction_cooldown_current -= seconds_per_tick
	if(dialogue_timer_current < dialogue_timer)
		dialogue_timer_current += dialogue_timer
		if(dialogue_timer_current >= dialogue_timer)
			perform_dialogue()

/mob/living/simple_animal/formic/proc/perform_dialogue()
	dialogue_timer_current = 0
	if(interaction_cooldown_current > 0) //don't speak if there was recent interaction to prevent awkward dialogue spam
		return
	var/performed_dialogue = pick(dialogue_lines)
	say(performed_dialogue)
