--[[local medusa = SMODS.Challenge({
    key = "medusa",
    loc_txt = {
        name = "Medusa's Madness"
    },
    rules = {
        custom = {
            {id = 'no_interest'},
            {id = 'no_reward_specific', value = 'Small'},
        },
        modifiers = {
            {id = 'hand_size', value = 10},
            {id = 'hands', value = 3},
        }
    },
    jokers = {
        {id = "j_femtoLabsCollection_flc_medusas_gaze", eternal = true},
        {id = "j_pareidolia", eternal = true}
    },
    restrictions = {
        banned_cards = {
            {id = 'j_stone'},
            {id = 'j_marble'},
            {id = 'j_femtoLabsCollection_flc_transmutation'},
            {id = 'j_femtoLabsCollection_drill'},
            {id = 'j_femtoLabsCollection_rollingstones'},
            {id = 'c_pluto'},
            
            {id = 'c_magician'},
            {id = 'c_empress'},
            {id = 'c_heirophant'},
            {id = 'c_lovers'},
            {id = 'c_chariot'},
            {id = 'c_justice'},
            {id = 'c_devil'},
            {id = 'c_tower'}
        },
        banned_other = {
            {id = 'bl_plant', type = 'blind'},
            {id = 'bl_mark', type = 'blind'},
        }
    }
})]]--