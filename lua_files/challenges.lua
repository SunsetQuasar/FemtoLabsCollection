local threekanban = SMODS.Challenge({
    key = "threekanban",
    loc_txt = {
        name = "Simon Says"
    },
    rules = {
        custom = {
            {id = 'flc_purple_stake_scaling'}
        },
        modifiers = {
            {id = 'hands', value = 3},
            {id = 'joker_slots', value = 1},
        }
    },
    jokers = {
        {id = "j_femtoLabsCollection_kanban", eternal = true, edition = 'negative'},
        {id = "j_femtoLabsCollection_kanban", eternal = true, edition = 'negative'},
        {id = "j_femtoLabsCollection_kanban", eternal = true, edition = 'negative'},
    },
    restrictions = {
        banned_cards = {
            {id = 'c_femtoLabsCollection_life'},
            {id = 'c_femtoLabsCollection_presence'},
            {id = 'c_ectoplasm'},
        },
        banned_tags = {
            {id = 'tag_negative'},
        },
        banned_other = {
            {id = 'bl_femtoLabsCollection_flc_teal_tempest', type = 'blind'},
        }
    }
})

local start_runRef = Game.start_run

Game.start_run = function(self, args)
    start_runRef(self, args)
    if G.GAME.modifiers['flc_purple_stake_scaling'] then
        self.GAME.modifiers.scaling = 4
        G:save_settings()
    end
end
--[[
local HelloIAmScragglyOne = SMODS.Challenge({
    key = "HelloIAmScragglyOne",
    loc_txt = {
        name = "Hello! I am Scraggly1."
    },
    rules = {
        modifiers = {
            {id = 'joker_slots', value = 2},
        }
    },
    jokers = {
        {id = "j_femtoLabsCollection_scraggly", eternal = true},
    },
    restrictions = {
    }
})
]]--