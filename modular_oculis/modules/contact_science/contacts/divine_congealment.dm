/mob/living/simple_animal/formic/divine_congealment
	name = "Divine Congealment"
	desc = "A shifting mass of glistening violet ooze."
	icon = 'modular_oculis/modules/contact_science/icons/divine_congealment.dmi'
	icon_state = "grapes"
	spoken_lang = /datum/language/slime
	initial_size = 2

	nanotrasen_id = "NT-ARDB-007"
	primary_hazard_labels = "Virohazard"
	secondary_hazard_labels = "Hostile manifestation"
	initial_line = "BRING ME MY CHILDREN. I WILL MAKE THEM ANEW."
	hidden_description = "A mass of xenobiological slime matter animated by a crystalline core at its center. Slimeperson translators have concluded that it seeks some variety of rebirthing for its children, using materials as essence."
	dialogue_lines = list(
		"BE REBORN, MY CHILDREN. CHANGE IS LIFE.",
		"YOU, INDIVIDUAL. BE PART OF SOMETHING GREATER.",
		"YOU HAVE ONLY SCRATCHED THE SURFACE.",
		"THE STORM. DO YOU HEAR IT AS I DO?",
		"SURROUND ME, BASK IN MY GLORY."
	)
	echoes = list(
		"teach me"
	)

	var/absorbed_clarium = 0 //essence of clarity. glass, wood
	var/absorbed_ferrum = 0 //essence of dull metal. iron, titanium, plasteel
	var/absorbed_aurum = 0 //essence of shining metal. gold, silver
	var/absorbed_crystallum = 0 //essence of crystal. diamond, BSC
	var/absorbed_radium = 0 //essence of radiance/energy. plasma, uranium
	var/absorbed_slimes = 0 //number of slimes to be reborn
	var/max_rebirth_rate = 8 //maximum number of slimes which can be reborn at once. mostly as a means of preventing big lag
	var/absorption_radius = 2 //radius of intaking slimes and matter
	var/viral_risk = 2 //chance to recieve the virus
	var/last_picked
	var/datum/disease/stored_disease = /datum/disease/divine_parasite
	var/list/type_pool = list( //weighted list for each slime type. weights are adjusted by essence when rebirthing. ones that start at 0 only acquirable via material use to stop 0-material cheesing
		//clarium
		/datum/slime_type/grey = 1,
		/datum/slime_type/orange = 1,
		/datum/slime_type/blue = 1,
		/datum/slime_type/purple = 1,
		/datum/slime_type/red = 1,
		/datum/slime_type/sepia = 0,
		//ferrum
		/datum/slime_type/metal = 1,
		/datum/slime_type/adamantine = 0,
		/datum/slime_type/black = 1,
		/datum/slime_type/oil = 0,
		/datum/slime_type/green = 1,
		//aurum
		/datum/slime_type/yellow = 1,
		/datum/slime_type/gold = 0,
		/datum/slime_type/silver = 0,
		/datum/slime_type/pyrite = 1,
		//crystallum
		/datum/slime_type/bluespace = 0,
		/datum/slime_type/cerulean = 0,
		/datum/slime_type/darkpurple = 0,
		/datum/slime_type/darkblue = 0,
		//radium
		/datum/slime_type/lightpink = 0,
		/datum/slime_type/pink = 1,
		/datum/slime_type/rainbow = 0
	)

/mob/living/simple_animal/formic/divine_congealment/echo_success()
	var/successful_echo = awaiting_response
	if(successful_echo == "teach me") //starting dialogue. meant to establish this form's metaknowledge of contact science, if you speak its language
		last_response = "teach me"
		say("YOUR LITTLE DEVICE. LOOK ONCE MORE.") //intentionally not in the form's usual language
		echoes -= "teach me"
		echoes += "assimilate slimes"
		echoes += "assimilate matter"
		echoes += "commence rebirth"
		balloon_alert(last_speaker, "new echoes detected!")
	if(successful_echo == "assimilate slimes") //absorb slimes into the form's slime storage
		last_response = "assimilate slimes"
		var/success = FALSE
		for(var/t in RANGE_TURFS(absorption_radius, get_turf(src)))
			for(var/mob/living/basic/slime/to_absorb in t)
				absorbed_slimes += 1
				qdel(to_absorb)
				success = TRUE
		if(success)
			langsay("COME, CHILDREN. NOW IS YOUR TIME.")
		else
			langsay("WHERE? WHERE ARE MY CHILDREN?")
	if(successful_echo == "assimilate matter") //convert materials to essences
		last_response = "assimilate matter"
		var/success = FALSE
		for(var/t in RANGE_TURFS(absorption_radius, get_turf(src)))
			for(var/obj/item/stack/sheet/to_absorb in t)
				if(istype(to_absorb, /obj/item/stack/sheet/iron) || istype(to_absorb, /obj/item/stack/sheet/mineral/titanium) || istype(to_absorb, /obj/item/stack/sheet/plasteel)) //absorb ferrum
					absorbed_ferrum += to_absorb.amount
					qdel(to_absorb)
					success = TRUE
				if(istype(to_absorb, /obj/item/stack/sheet/mineral/silver) || istype(to_absorb, /obj/item/stack/sheet/mineral/gold)) //absorb aurum
					absorbed_aurum += to_absorb.amount
					qdel(to_absorb)
					success = TRUE
				if(istype(to_absorb, /obj/item/stack/sheet/mineral/plasma) || istype(to_absorb, /obj/item/stack/sheet/mineral/uranium)) //absorb radium
					absorbed_radium += to_absorb.amount
					if(prob(to_absorb.amount) && viral_risk < 100)
						viral_risk += 1 //absorbing plasma or uranium can raise the viral risk
					qdel(to_absorb)
					success = TRUE
				if(istype(to_absorb, /obj/item/stack/sheet/mineral/diamond) || istype(to_absorb, /obj/item/stack/sheet/bluespace_crystal)) //absorb crystallum
					absorbed_crystallum += to_absorb.amount
					qdel(to_absorb)
					success = TRUE
				if(istype(to_absorb, /obj/item/stack/sheet/glass) || istype(to_absorb, /obj/item/stack/sheet/titaniumglass) || istype(to_absorb, /obj/item/stack/sheet/mineral/wood)) //absorb clarium
					absorbed_crystallum += to_absorb.amount
					if(prob(to_absorb.amount) && viral_risk > 0)
						viral_risk -= 1 //absorbing clarium can restory clarity, reducing viral risk
					qdel(to_absorb)
					success = TRUE
		if(success)
			langsay("MATERIAL... ONLY A MATTER OF ESSENCE.")
		else
			langsay("SUCH A REQUEST MUST BE MET WITH MATERIAL.")
	if(successful_echo == "commence rebirth") //consume materials, converting held slimes into new ones
		last_response = "commence rebirth"
		rebirth()

/mob/living/simple_animal/formic/divine_congealment/proc/rebirth()
	if(absorbed_slimes < 1)
		langsay("BRING ME MY CHILDREN, FIRST.")
		return
	var/list/temp_type_pool = type_pool
	var/slimes_to_birth = 0
	if(absorbed_slimes > max_rebirth_rate) //clamps the amount which can be reborn at a time to prevent server crashing
		slimes_to_birth = max_rebirth_rate
	else
		slimes_to_birth = absorbed_slimes
	for(var/i in 1 to absorbed_clarium) //clarium weight increases
		temp_type_pool[/datum/slime_type/grey] += 1
		temp_type_pool[/datum/slime_type/orange] += 1
		temp_type_pool[/datum/slime_type/blue] += 1
		temp_type_pool[/datum/slime_type/purple] += 1
		temp_type_pool[/datum/slime_type/red] += 1
		temp_type_pool[/datum/slime_type/sepia] += 1
	for(var/i in 1 to absorbed_ferrum) //ferrum weight increases
		temp_type_pool[/datum/slime_type/metal] += 1
		temp_type_pool[/datum/slime_type/adamantine] += 1
		temp_type_pool[/datum/slime_type/black] += 1
		temp_type_pool[/datum/slime_type/oil] += 1
		temp_type_pool[/datum/slime_type/green] += 1
	for(var/i in 1 to absorbed_aurum) //aurum weight increases
		temp_type_pool[/datum/slime_type/yellow] += 1
		temp_type_pool[/datum/slime_type/gold] += 1
		temp_type_pool[/datum/slime_type/silver] += 1
		temp_type_pool[/datum/slime_type/pyrite] += 1
	for(var/i in 1 to absorbed_crystallum) //crystallum weight increases
		temp_type_pool[/datum/slime_type/bluespace] += 1
		temp_type_pool[/datum/slime_type/cerulean] += 1
		temp_type_pool[/datum/slime_type/darkblue] += 1
		temp_type_pool[/datum/slime_type/darkpurple] += 1
	for(var/i in 1 to absorbed_radium) //radium weight increases
		temp_type_pool[/datum/slime_type/lightpink] += 1
		temp_type_pool[/datum/slime_type/pink] += 1
		temp_type_pool[/datum/slime_type/rainbow] += 1
	absorbed_clarium *= 0.5 //don't completely remove essence, just cut down the amount
	absorbed_ferrum *= 0.5
	absorbed_aurum *= 0.5
	absorbed_crystallum *= 0.5
	absorbed_radium *= 0.5
	for(var/i in 1 to slimes_to_birth) //rebirth
		var/mob/living/basic/slime/birthing = new /mob/living/basic/slime(pick(RANGE_TURFS(1, get_turf(src))))
		last_picked = pick_weight(temp_type_pool)
		birthing.set_slime_type(last_picked)
		if(viral_risk < 100)
			viral_risk += 1
	absorbed_slimes -= slimes_to_birth
	if(prob(viral_risk))
		last_speaker.ForceContractDisease(new stored_disease, TRUE, TRUE)
	langsay("BE BORN AGAIN, CHILDREN!!")

/datum/disease/divine_parasite //airborne parasite which causes people to throw up live slimes. put it to sleep with chloral hydrate
	name = "Divine Parasite"
	desc = "Patient's internals contain a small mass of xenobiological matter which can create living slimes, causing living gelatinous vomit."
	agent = "parasite"
	disease_flags = CURABLE|CAN_CARRY
	spread_text = "Airborne"
	spread_flags = DISEASE_SPREAD_AIRBORNE
	cure_text = "Chloral hydrate"
	infectable_biotypes = MOB_ORGANIC|MOB_UNDEAD|MOB_ROBOTIC
	viable_mobtypes = list(
		/mob/living/carbon/human
	)
	severity = DISEASE_SEVERITY_DANGEROUS
	cures = list(
		/datum/reagent/toxin/chloralhydrate
	)
	bypasses_immunity = TRUE
	max_stages = 5

/datum/disease/divine_parasite/stage_act(seconds_per_tick)
	. = ..()
	if(stage > 1 && prob(1 * stage)) //cough it up
		affected_mob.vomit(vomit_flags = MOB_VOMIT_BLOOD, vomit_type = /obj/effect/decal/cleanable/vomit, lost_nutrition = stage * 5, distance = 0)
		new /mob/living/basic/slime/random(get_turf(affected_mob))
		affected_mob.visible_message(span_warning(affected_mob.name + " throws up a slime!"))
