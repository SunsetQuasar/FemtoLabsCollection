local sunset_tag = SMODS.Tag({
    key = "sunset",
    loc_txt = {
        name = "Sunset Tag",
        text = {
            "Gives a free",
            "{V:1}Mega Nightfall Pack",
        }
    },
    config = {},
    min_ante = 2,
    atlas = 'tag_flc_tags', 
    pos = { x = 0, y = 0 },
    discovered = true
})

sunset_tag.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS['p_femtoLabsCollection_twilight_mega']
    return {
        vars = {
            colours = {
                flc_twilight_colour
            }
        }
    }
end

sunset_tag.apply = function(self, tag, context)
    if context.type == 'new_blind_choice' and not G.CONTROLLER.locks.use then
        G.CONTROLLER.locks.use = true
        tag:yep('+', HEX('AA9186'), function() 
            local key = 'p_femtoLabsCollection_twilight_mega'
            local card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
            G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[key], {bypass_discovery_center = true, bypass_discovery_ui = true})
            card.cost = 0
            card.from_tag = true
            G.FUNCS.use_card({config = {ref_table = card}})
            card:start_materialize()
            return true
        end)
        tag.triggered = true
    end
end

local summon_tag = SMODS.Tag({
    key = "summon",
    loc_txt = {
        name = "Summon Tag",
        text = {
            "Creates two {C:dark_edition}Negative",
            "{C:spectral}Spectral{} cards after the",
            "{C:attention}Boss Blind{} is defeated"
        }
    },
    config = {extra = 2},
    min_ante = 2,
    atlas = 'tag_flc_tags', 
    pos = { x = 1, y = 0 },
    discovered = true
})

summon_tag.apply = function(self, tag, context)
    if context.type == 'eval' and G.GAME.last_blind and G.GAME.last_blind.boss then
        tag:yep('+', G.C.SECONDARY_SET.Spectral, function() 
            for i=1, 2 do
                local card = SMODS.create_card({
                    set = 'Spectral',
                    area = G.consumeables,
                    legendary = false,
                    skip_materialize = true,
                    key_append = 'flc_summon_tag',
                    no_edition = true,
                })
                card:start_materialize()
                card:add_to_deck()
                card:set_edition({negative = true}, nil, true)
                G.consumeables:emplace(card)
                card:juice_up(1, 0.5)
            end
            play_sound('negative', 1.5, 0.6)
            return true end)
        
        tag.triggered = true
    end
end