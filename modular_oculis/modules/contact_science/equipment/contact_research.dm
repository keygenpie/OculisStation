#define TECHWEB_NODE_CONTACT_SCIENCE "contact_science"

/datum/techweb_node/contact_science
	id = TECHWEB_NODE_CONTACT_SCIENCE
	display_name = "Storm Contact"
	description = "Make contact with anomalous resonances trapped within the Storm. Speak with them, learn their secrets."
	prereq_ids = list(TECHWEB_NODE_BLUESPACE_TRAVEL)
	design_ids = list(
		"contact_scanner",
		"contact_platform",
		"contact_analyzer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
