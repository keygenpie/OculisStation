/mob/living/simple_animal/formic/panopticon_beast
	name = "Panopticon Beast"
	desc = "A vague, quadrupedal figure. Its form is hard to make out."
	icon = 'modular_oculis/modules/contact_science/icons/observer.dmi'
	icon_state = "observer"

	nanotrasen_id = "NT-ARDB-004"
	primary_hazard_labels = "N/A"
	secondary_hazard_labels = "Hostile manifestation"
	initial_line = "Request. Feed. Logistics. Reward."
	hidden_description = "An antiperceptive quadrupedal creature. It seems to want to be fed logistical data, cargo shipping manifests should work? We advise you do not let it grow hungry."
	dialogue_lines = list(
		"Observe. Grow. Help.",
		"Storm. Cold. Cold. Cold.",
		"Supply. Data. Feed. Reward.",
		"Watch. Listen. Speak.",
		"Hunger. Thirst. Logistics. Feed.",
		"Know. Logistics. Know. Everything.",
		"Distant. Close. Connect."
	)
	echoes = list(
		"feed from my hand",
		"what is my reward",
		"are you hungry"
	)

	var/points = 0
	var/rewards = 0 //gain 1 reward per 3 points
	var/feeding_timer = 220
	var/feeding_timer_current = 220 //dont let it get hungry!

	var/list/obj/item/potential_rewards = list(
		/obj/item/clothing/glasses/night/panopticon,
		/obj/item/organ/eyes/robotic/binoculars/panopticon,
		/obj/item/organ/ears/cybernetic/whisper/panopticon,
		/obj/item/clothing/glasses/meson/panopticon
	)

/mob/living/simple_animal/formic/panopticon_beast/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(feeding_timer_current > 0)
		feeding_timer_current -= 1
	else //break out once its starving
		if(!breaching)
			breaching = TRUE
			sound_to_playing_players('sound/effects/magic/lightning_chargeup.ogg')
			addtimer(CALLBACK(src, PROC_REF(breach)), 80, TIMER_UNIQUE | TIMER_DELETE_ME)

/mob/living/simple_animal/formic/panopticon_beast/proc/breach()
	priority_announce("An anomalous resonance form has breached containment within [station_name()]. Please route to subdue the hostile form.")
	new /mob/living/simple_animal/hostile/panopticon_beast(get_turf(src))
	qdel(src)

/mob/living/simple_animal/formic/panopticon_beast/echo_success()
	var/successful_echo = awaiting_response
	if(breaching)
		return
	if(successful_echo == "feed from my hand") //feed from the hands of the speaker
		last_response = "feed from my hand"
		if(get_dist(src, last_speaker) > 1) //must be adjacent
			say("Closer. Hand. Forward.")
		else
			feed_logistics(last_speaker)
	if(successful_echo == "what is my reward") //get rewards
		last_response = "what is my reward"
		if(rewards > 0)
			give_reward(last_speaker)
		else
			say("Feed. More. Then. Reward.")
	if(successful_echo == "are you hungry") //check the timer
		last_response = "are you hungry"
		if(feeding_timer_current < feeding_timer * 0.25) //less than 25%
			say("Starving. Feed. Feed. Feed.")
		else if(feeding_timer_current < feeding_timer * 0.5) //less than 50%
			say("Hungry. Feed. Feed.")
		else if(feeding_timer_current < feeding_timer * 0.75) //less than 75%
			say("Peckish. Feed. Data.")
		else
			say("Full. Yet. Hungry. Always. Feed.")

/mob/living/simple_animal/formic/panopticon_beast/proc/feed_logistics(mob/living/carbon/human/feeder)
	var is_success = FALSE
	for(var/obj/item/feeding_item in feeder.held_items)
		if(istype(feeding_item, /obj/item/paper/fluff/jobs/cargo/manifest)) //eat cargo manifest
			points += 1
			if(points >= 3)
				points -= 3
				rewards += 1
			is_success = TRUE
			to_chat(feeder, span_warning("The manifest disappears as its essence is absorbed by the creature."))
			qdel(feeding_item)
	if(is_success)
		say("Feed. Gratitude. Grow.")
		playsound(feeder, 'sound/effects/portal/portal_travel.ogg', 25)
		feeding_timer -= 5 //reduce the max timer, little by little. it will get out eventually
		feeding_timer_current += feeding_timer * 0.25
	else
		say("Cannot. Feed. Bring. Data.")

/mob/living/simple_animal/formic/panopticon_beast/proc/give_reward(mob/living/carbon/human/rewardee)
	to_chat(rewardee, span_warning("The creature regurgitates item(s) at you!"))
	for(var/i in 1 to rewards)
		var/obj/item/reward_to_give = pick(potential_rewards)
		var/obj/item/reward_to_throw = new reward_to_give(get_turf(src))
		reward_to_throw.throw_at(rewardee, 7, 3, thrower = src, gentle = TRUE)
	rewards = 0
	say("Reward.")

/obj/item/clothing/glasses/night/panopticon //unique reward, special NVGs which grant invisibility sight
	name = "panopticon goggles"
	desc = "A pair of night-vision goggles with antiperceptive sensors. You can't turn them off."
	icon = 'modular_oculis/modules/contact_science/icons/observer_items.dmi'
	icon_state = "night"
	color_cutoffs = list(20, 20, 20)
	glass_colour_type = /datum/client_colour/glass_colour/gray
	invis_view = INVISIBILITY_REVENANT
	invis_override = 50
	actions_types = null //no turning them off

/obj/item/wallframe/camera/all //cut unique reward, camera assembly which autoinstalls with all upgrades. the panopticon wants more eyes. cut because its kinda lame
	name = "panopticon camera assembly"
	desc = "An automatic construction assembly for a fully-upgraded camera."
	result_path = /obj/machinery/camera/all

/obj/item/ammo_casing/shotgun/panopticon //cut unique reward, shotgun shell with the breach monster's projectile. cut for not really fitting, kept for admin shenanigans
	name = "forever gaze"
	desc = "A strange shotgun shell, loaded with... what is that? It feels hungry."
	icon = 'modular_oculis/modules/contact_science/icons/observer_items.dmi'
	icon_state = "panshell"
	projectile_type = /obj/projectile/panopticon_ball

/obj/item/organ/eyes/robotic/binoculars/panopticon //unique reward, digital magnification optics with night vision
	name = "panopticon optics"
	desc = "A pair of cybernetic eyes with night vision and zoom capabilities. They look eager to surveil."
	icon = 'modular_oculis/modules/contact_science/icons/observer_items.dmi'
	icon_state = "eyes"
	eye_color_left = "#ffffff"
	eye_color_right = "#ffffff"
	organ_flags = ORGAN_ROBOTIC
	color_cutoffs = list(15, 15, 15)

/obj/item/organ/ears/cybernetic/whisper/panopticon //unique reward, cybernetic ears with whisper-hearing and xray hearing
	name = "panopticon ears"
	desc = "A pair of hypersensitive cybernetic ears with whisper sensitivity and wall-ignorant audioperception. They look hungry for whispers."
	icon = 'modular_oculis/modules/contact_science/icons/observer_items.dmi'
	icon_state = "ears"
	organ_traits = list(TRAIT_GOOD_HEARING, TRAIT_XRAY_HEARING)
	damage_multiplier = 2.5

/obj/item/clothing/glasses/meson/panopticon
	name = "panopticon visor"
	desc = "A pair of meson goggles which channels your hearing into the ability to see life-matrices through walls, at the price of deafness."
	icon = 'modular_oculis/modules/contact_science/icons/observer_items.dmi'
	icon_state = "meson"
	vision_flags = SEE_MOBS | SEE_TURFS
	clothing_traits = list(TRAIT_MADNESS_IMMUNE, TRAIT_DEAF)

/mob/living/simple_animal/hostile/panopticon_beast //breaching version
	name = "Panopticon Beast"
	desc = "Hungry. Feed. Starving. Devour."
	health = 1000
	maxHealth = 1000
	speed = 8
	icon = 'modular_oculis/modules/contact_science/icons/observer.dmi'
	icon_state = "observer"
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	melee_damage_lower = 20
	melee_damage_upper = 30
	melee_damage_type = BRUTE
	obj_damage = 80
	ranged = TRUE
	ranged_cooldown_time = 90
	projectiletype = /obj/projectile/panopticon_ball
	vision_range = 27 //vision range is very high. the panopticon will find you
	aggro_vision_range = 27
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	mob_size = MOB_SIZE_LARGE
	attack_verb_continuous = "slashes at"
	attack_verb_simple = "slash at"
	incorporeal_move = INCORPOREAL_MOVE_BASIC
	ai_controller = /datum/ai_controller/basic_controller/panbeast
	death_sound = 'sound/effects/portal/portal_travel.ogg'
	death_message = "vanishes, just as quickly as it came."
	var/list/projectile_lines = list(
		"Suffocate. Starve.",
		"Die.",
		"Hate. Drown."
	)

/mob/living/simple_animal/hostile/panopticon_beast/Initialize(mapload)
	. = ..()
	say("Devour. Devour. Devour.")

/mob/living/simple_animal/hostile/panopticon_beast/OpenFire()
	. = ..()
	say(pick(projectile_lines))
	playsound(src, 'sound/effects/portal/portal_travel.ogg', 35)

/obj/projectile/panopticon_ball //slow, piercing projectile which deals suffocation damage
	name = "panopticon sphere"
	icon = 'modular_oculis/modules/contact_science/icons/observer_items.dmi'
	icon_state = "beast_projectile"
	hitsound = 'sound/effects/portal/portal_travel.ogg'
	projectile_piercing = PASSTABLE | PASSGLASS | PASSGRILLE | PASSMOB | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSFLAPS | PASSDOORS
	speed = 0.4
	damage = 25
	stamina = 10
	immobilize = 1 SECONDS
	jitter = 1 SECONDS
	damage_type = OXY
	reflectable = FALSE
	armor_flag = ENERGY

/datum/ai_controller/basic_controller/panbeast
	behavior_tree_json = "modular_oculis/modules/contact_science/ai/panbeast_ai.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
