/obj/item/clockwork/weapon/brass_spear/implant
	name = "implanted brass spear"
	desc = "A razor-sharp spear made of brass emerging from your arm. It thrums with barely-contained energy."
	w_class = WEIGHT_CLASS_BULKY

/obj/item/organ/cyberimp/arm/toolkit/clockwork_spear
	name = "brass spear implant"
	desc = "A tiny, trapped pocket dimension containing a brass spear, able to emerge and retract at will."
	items_to_create = list(/obj/item/clockwork/weapon/brass_spear/implant)
	extend_sound = 'sound/items/unsheath.ogg'
	retract_sound = 'sound/items/sheath.ogg'

/obj/item/organ/cyberimp/arm/toolkit/clockwork_spear/left_arm
	zone = BODY_ZONE_L_ARM
	slot = ORGAN_SLOT_LEFT_ARM_AUG

/obj/item/organ/cyberimp/arm/toolkit/clockwork_spear/right_arm
	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_RIGHT_ARM_AUG
