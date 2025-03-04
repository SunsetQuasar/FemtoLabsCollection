function SMODS.current_mod.process_loc_text()

	G.localization.descriptions.Other.flc_card_extra_mult = {
		text={
			"{C:mult}+#1#{} extra Mult",
		}
	}

	if not G.localization.descriptions.Mod then G.localization.descriptions.Mod = {} end
	G.localization.descriptions.Mod.FemtoLabsCollection = {
		name = "Femto Labs Collection",
		text = {
			"Adds a bit of everything, with no particular theme.",
			"{C:attention}Code{}: sunsetquasar",
			"{C:attention}Concepts{}: sunsetquasar, ABuffZucchini, goose!, tobyaaa & zeodexic",
			"{C:attention}Art{}: sunsetquasar, ABuffZucchini, tobyaaa, xolimono & dewdrop",
			"{C:attention}Playtesting{}: JayTeff, zeodexic, ABuffZucchini, tobyaaa, vitellary", 
			"{C:attention}Special thanks{}: vitellary",
		}
	}
end