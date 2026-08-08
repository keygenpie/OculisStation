/mob/living/simple_animal/formic/forgotten_forge
	name = "Forgotten Forge"
	desc = "An ever-beating heart bearing an unblinking eye. Various bits of clockwork and brass are sticking out of it."
	icon = 'modular_oculis/modules/contact_science/icons/forgotten_forge.dmi'
	icon_state = "heart"

	nanotrasen_id = "NT-ARDB-002"
	primary_hazard_labels = "Somatohazard"
	secondary_hazard_labels = "Bodily alteration"
	initial_line = "Come forth, and be changed, changed."
	hidden_description = "An artificial heart, its internals powered by brass clockwork. We theorize it to be some kind of remnant or memory of the long-forgotten 'Clockwork Cult.' It seems to express a desire to provide augmentation in preparation for something."
	dialogue_lines = list(
		"Even in this age of stagnation, I am present, present.",
		"I will change you for the better. Pledge yourself to me, to me.",
		"One day, the age of brass will return, return.",
		"Your armaments are suboptimal. Allow me to improve them, improve them.",
		"I dream of a world of brass, brass.",
		"Loyal ones, step forth, and be changed, changed.",
		"The clock ticks. What are you waiting for, waiting for?",
		"Pledge loyalty, and I will improve you, improve you."
	)
	echoes = list(
		"i present myself"
		"i present my blade"
	)

	var/loyalty = 0 //goes up by 1 with each augmentation, similar to Philosopher's Camera.
	var/firstaugment = TRUE //after first augment, unlock new echoes

/mob/living/simple_animal/formic/forgotten_forge/echo_success()
	var/successful_echo = awaiting_response
	if(successful_echo == "i present myself")
		last_response = "i present myself"
		if(get_dist(src, last_speaker) > 1) //must be adjacent
			say("Come closer, closer.")
		else
			give_augment(0)
	if(successful_echo == "i present my blade")
		last_response = "i present my blade"
		if(get_dist(src, last_speaker) > 1)
			say("Bring it closer, closer.")
		else
			give_upgrades()

/mob/living/simple_animal/formic/forgotten_forge/proc/give_upgrades() //for both hands, find weapons and give them random upgrades
	var is_success = FALSE
	for(var/upgrading_item in last_speaker.held_items)
		var/upgrade_type = rand(1,3)
		if(!findtext(upgrading_item.name, "brass-")) //if not already augmented, simply works off of name
			if(istype(upgrading_item, /obj/item/gun))
				var/obj/item/gun/upgrading_gun = upgrading_item
				if(upgrade_type == 1) //make weapon more accurate and improve its projectile speed
					upgrading_gun.projectile_speed_multiplier += 0.25
					upgrading_gun.spread *= 0.5
					to_chat(last_speaker, span_notice("The " + upgrading_gun.name + " becomes more accurate. You feel like you could hit anything."))
					upgrading_gun.name = "brass-accurized " + upgrading_gun.name
					is_success = TRUE
				if(upgrade_type == 2) //make weapon suppressed, also increases damage a bit so that it's still an upgrade for already-suppressed weapons
					upgrading_gun.suppressed = SUPPRESSED_QUIET
					upgrading_gun.can_unsuppress = FALSE
					upgrading_gun.projectile_damage_multiplier += 0.1
					to_chat(last_speaker, span_notice("The " + upgrading_gun.name + " becomes suppressed. It feels deadlier in your hands."))
					upgrading_gun.name = "brass-suppressed " + upgrading_gun.name
					is_success = TRUE
				if(upgrade_type == 3) //make weapon light, allowing it to be one-handed. also reduces dual wield spread
					upgrading_gun.weapon_weight = WEAPON_LIGHT
					upgrading_gun.dual_wield_spread *= 0.5
					to_chat(last_speaker, span_notice("The " + upgrading_gun.name + " becomes lightened. Its burdens are removed."))
					upgrading_gun.name = "brass-lightened " + upgrading_gun.name
					is_success = TRUE
			if(istype(upgrading_item, /obj/item/melee) || istype(upgrading_item, /obj/item/spear))
				var/obj/item/upgrading_melee = upgrading_item
				if(upgrade_type == 1) //make weapon better at blocking
					upgrading_melee.block_chance += 20
					to_chat(last_speaker, span_notice("The " + upgrading_melee.name + "'s guarding is improved. You feel safer wielding it."))
					upgrading_melee.name = "brass-guarding " + upgrading_melee.name
					is_success = TRUE
				if(upgrade_type == 2) //make weapon better at penetrating armor
					upgrading_melee.armour_penetration += 20
					balloon_alert(last_speaker, "armor penetration improved!")
					to_chat(last_speaker, span_notice("The " + upgrading_melee.name + "'s armor penetration is improved. No matter its sharpness, it feels sharper in your hands."))
					upgrading_melee.name = "brass-piercing " + upgrading_melee.name
					is_success = TRUE
				if(upgrade_type == 3) //give weapon more force
					upgrading_melee.force += 3
					to_chat(last_speaker, span_notice("The " + upgrading_melee.name + "'s force is improved. Somehow, the weapon feels... guilty?"))
					upgrading_melee.name = "brass-striking " + upgrading_melee.name
					is_success = TRUE
	if(is_success)
		loyalty += 1
		var/limb_to_hit = last_speaker.get_bodypart(last_speaker.get_random_valid_zone(even_weights = TRUE))
		last_speaker.apply_damage(loyalty * 5, BRUTE, limb_to_hit, wound_bonus=CANT_WOUND)
		to_chat(last_speaker, span_warning("An ache creeps around your body."))
		playsound(last_speaker, 'sound/effects/magic/staff_healing.ogg', 50)
		if(firstaugment) //different lines if first upgrade, also first upgrade unlocks echoes
			say("Feel the brass in your hands, hands.")
			firstaugment = FALSE
			echoes += "am i ready"
			balloon_alert(last_speaker, "new echoes detected!")
		else
			say("Feel the brass in your hands, loyal one, loyal one.")
	else
		if(firstaugment)
			say("I cannot forge this, nascent one, nascent one.")
		else
			say("I cannot forge this, forge this.")

/mob/living/simple_animal/formic/forgotten_forge/proc/give_augment(var/num_loops)
	if(num_loops >= 10) //at ten loops, activate failsafe
		say("Your body is already prepared, prepared.")
		return
	var/list/potential_implants = list(
		/obj/item/organ/cyberimp/arm/toolkit/clockwork_spear/left_arm
		/obj/item/organ/cyberimp/arm/toolkit/clockwork_spear/right_arm
	)
	var/obj/item/organ/chosen_implant = pick(potential_implants)
	if(!chosen_implant.Insert(last_speaker)) // pick a special implant and try to insert
		give_augment(num_loops + 1) //increase number of tries by 1 and retry on failing
		return
	else
