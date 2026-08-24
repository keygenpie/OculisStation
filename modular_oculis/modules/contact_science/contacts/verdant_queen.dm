/mob/living/simple_animal/formic/verdant_queen
	name = "Verdant Queen"
	desc = "A huge, jade-green ant. Light reflects off of its surfaces, as if it were polished"
	icon = 'modular_oculis/modules/contact_science/icons/verdant_queen.dmi'
	icon_state = "ant"

	nanotrasen_id = "NT-ARDB-006"
	primary_hazard_labels = "Virohazard"
	secondary_hazard_labels = "Bodily alteration"
	initial_line = "Bring me the dead. Rebirth. Lessons."
	spoken_lang = /datum/language/buzzwords
	hidden_description = "A creature made of millions of ant-like nanomachines, each with an external composition similar to jade. From what we can tell, it wants corpses, and will grant 'lessons' in exchange."
	dialogue_lines = list(
		"Corpses of your own. Workers. Drones.",
		"The hive must grow. Death. Rebirth.",
		"Do you like it? My chitin of jade.",
		"Lessons. Assimilation. What do you think?"
	)
	echoes = list(
		"commence assimilation"
	)

	var/firstassim = TRUE //unlock more echoes after the first body is eaten
