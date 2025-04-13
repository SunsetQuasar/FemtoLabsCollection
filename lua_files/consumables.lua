local twilight_cards = SMODS.ConsumableType({
    key = "m_femtoLabsCollection_twilight",
    primary_colour = HEX('715D91'),
    secondary_colour = HEX('AA9186'),
    default = "c_femtoLabsCollection_horizon",
    loc_txt = {
        name = 'Twilight',
        collection = 'Twilight Cards', 
        undiscovered = {
            name = 'Undiscovered',
            text = { ':3' },
        },
    },
    collection_rows = { 4, 5 },
    shop_rate = 0
})

flc_twilight_colour = twilight_cards.secondary_colour

-------------------

local card_initRef = Card.init
Card.init = function(self, X, Y, W, H, card, center, params)
    card_initRef(self, X, Y, W, H, card, center, params)
    if self.ability.set == 'Booster' then

        local extra_choices = 0
        local goobers = SMODS.find_card('j_femtoLabsCollection_gooseberry')
        for i=1, #goobers do
            extra_choices = goobers[i].ability.extra.choices
        end   
        if G.GAME.starting_params.flc_gradientdeck then
            self.ability.extra = self.ability.extra + 1
        end
		self.ability.choose = math.min(self.ability.choose + extra_choices, self.ability.extra)
    elseif self.ability.set == 'm_femtoLabsCollection_twilight' and G.GAME['m_femtolabscollection_twilight_negatives'] and pseudorandom('flc_twilight_negative') < 1/5 then
        self:set_edition({negative = true}, true)
    end
end

local openRef = Card.open
Card.open = function(self)
    local scrags = SMODS.find_card('j_femtoLabsCollection_scraggly')
    for _, v in pairs(scrags) do
        self.ability.extra = math.ceil(pseudorandom('flc_scraggly_booster') * 10);
        self.ability.choose = math.min(math.ceil(pseudorandom('flc_scraggly_booster') * 10), self.ability.extra)
        card_eval_status_text(v, 'extra', nil, nil, nil, {message = 'Hello!', colour = G.C.FILTER, instant = true})
    end
    openRef(self)
end

function ease_bg_nightfall()
    ease_background_colour{new_colour = HEX('895F52'), special_colour = darken(G.C.BLACK, 0.6), tertiary_colour = HEX('513B4C'), contrast = 2}
end

function particles_nightfall()
    G.booster_pack_stars = Particles(1, 1, 0,0, {
        timer = 0.04,
        scale = 0.2,
        initialize = true,
        lifespan = 4,
        speed = 0.7,
        padding = -4,
        attach = G.ROOM_ATTACH,
        colours = {HEX('D8C5C5'), HEX('CE9A6D'), HEX('8F72C1')},
        fill = true
    })
    G.booster_pack_meteors = Particles(1, 1, 0,0, {
        timer = 1,
        scale = 0.05,
        lifespan = 3,
        speed = 3,
        attach = G.ROOM_ATTACH,
        colours = {G.C.WHITE},
        fill = true
    })
end

-- nightfall pack 1

local std1 = SMODS.Booster({
    key = 'twilight_normal_1',
    loc_txt = {
        name = "Nightfall Pack",
        group_name = "Nightfall Pack",
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{V:1} Twilight{} cards to be",
            "added to your {C:attention}consumables",
            "{C:inactive}(Must have room)",
        }
    },
    config = { extra = 2, choose = 1 },
    atlas = "p_flc_twilight",
    pos = { x = 0, y = 0 },
    discovered = true,
    cost = 4,
    weight = 0.5,
    draw_hand = false,
    kind = "p_flc_twilight",
    select_card = "consumeables",
    select_exclusions = {'c_femtoLabsCollection_samsara'}
})

std1.loc_vars = function(self, loc_vars, card)
    return {
        vars = {
            card.ability.choose,
            card.ability.extra,
            colours = {
                flc_twilight_colour
            }
        }
    }
end

std1.create_card = function(self, card, i)
    return {set = "m_femtoLabsCollection_twilight", area = G.pack_cards, key_append = "m_flc_booster_"..i, soulable = true, no_edition = true, skip_materialize = true}
end

std1.ease_background_colour = function(self)
    ease_bg_nightfall()
end

std1.particles = function(self)
    particles_nightfall()
end

-- nightfall pack 2

local std2 = SMODS.Booster({
    key = 'twilight_normal_2',
    loc_txt = {
        name = "Nightfall Pack",
        group_name = "Nightfall Pack",
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{V:1} Twilight{} cards to be",
            "added to your {C:attention}consumables",
            "{C:inactive}(Must have room)",
        }
    },
    config = { extra = 2, choose = 1 },
    atlas = "p_flc_twilight",
    pos = { x = 1, y = 0 },
    discovered = true,
    cost = 4,
    weight = 0.5,
    draw_hand = false,
    kind = "p_flc_twilight",
    select_card = "consumeables",
    select_exclusions = {'c_femtoLabsCollection_samsara'}
})

std2.loc_vars = function(self, loc_vars, card)
    return {
        vars = {
            card.ability.choose,
            card.ability.extra,
            colours = {
                flc_twilight_colour
            }
        }
    }
end

std2.create_card = function(self, card, i)
    return {set = "m_femtoLabsCollection_twilight", area = G.pack_cards, key_append = "m_flc_booster_"..i, soulable = true, no_edition = true, skip_materialize = true}
end

std2.ease_background_colour = function(self)
    ease_bg_nightfall()
end

std2.particles = function(self)
    particles_nightfall()
end

-- jumbo nightfall pack

local jumbo = SMODS.Booster({
    key = 'twilight_jumbo',
    loc_txt = {
        name = "Jumbo Nightfall Pack",
        group_name = "Nightfall Pack",
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{V:1} Twilight{} cards to be",
            "added to your {C:attention}consumables",
            "{C:inactive}(Must have room)",
        }
    },
    config = { extra = 4, choose = 1 },
    atlas = "p_flc_twilight",
    pos = { x = 2, y = 0 },
    discovered = true,
    cost = 6,
    weight = 0.5,
    draw_hand = false,
    kind = "p_flc_twilight",
    select_card = "consumeables",
    select_exclusions = {'c_femtoLabsCollection_samsara'}
})

jumbo.loc_vars = function(self, loc_vars, card)
    return {
        vars = {
            card.ability.choose,
            card.ability.extra,
            colours = {
                flc_twilight_colour
            }
        }
    }
end

jumbo.create_card = function(self, card, i)
    return {set = "m_femtoLabsCollection_twilight", area = G.pack_cards, key_append = "m_flc_booster_"..i, soulable = true, no_edition = true, skip_materialize = true}
end

jumbo.ease_background_colour = function(self)
    ease_bg_nightfall()
end

jumbo.particles = function(self)
    particles_nightfall()
end

-- mega nightfall pack

local mega = SMODS.Booster({
    key = 'twilight_mega',
    loc_txt = {
        name = "Mega Nightfall Pack",
        group_name = "Nightfall Pack",
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{V:1} Twilight{} cards to be",
            "added to your {C:attention}consumables",
            "{C:inactive}(Must have room)",
        }
    },
    config = { extra = 4, choose = 2 },
    atlas = "p_flc_twilight",
    pos = { x = 3, y = 0 },
    discovered = true,
    cost = 8,
    weight = 0.5,
    draw_hand = false,
    kind = "p_flc_twilight",
    select_card = "consumeables",
    select_exclusions = {'c_femtoLabsCollection_samsara'}
})

mega.loc_vars = function(self, loc_vars, card)
    return {
        vars = {
            card.ability.choose,
            card.ability.extra,
            colours = {
                flc_twilight_colour
            }
        }
    }
end

mega.create_card = function(self, card, i)
    return {set = "m_femtoLabsCollection_twilight", area = G.pack_cards, key_append = "m_flc_booster_"..i, soulable = true, no_edition = true, skip_materialize = true}
end

mega.ease_background_colour = function(self)
    ease_bg_nightfall()
end

mega.particles = function(self)
    particles_nightfall()
end

-- horizon

local horizon = SMODS.Consumable({
    key = "horizon",
    set = "m_femtoLabsCollection_twilight",
    config = {extra = {prob_success = 4}},
	pos = {x = 0, y = 0},
	loc_txt = {
        name = 'Horizon',
        text = {
    "Randomizes all {C:attention}Consumables",
    "in your possession"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

horizon.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

horizon.can_use = function(self, card)
    return G.consumeables and G.consumeables.cards and #G.consumeables.cards-1 > 0
end

horizon.use = function(self, card, area, copier)
    for i=#G.consumeables.cards, 1, -1 do
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            card:juice_up()
            local _set = G.consumeables.cards[i].ability.set
            local ed = G.consumeables.cards[i].edition
            local new = SMODS.create_card({
                set = _set,
                skip_materialize = true,
                key_append = 'flc_horizon'
            })
            local percent = 0.85 + (i-0.999)/(#G.consumeables.cards-0.998)*0.3
            play_sound('tarot2', percent, 0.6);
            G.consumeables.cards[i]:remove_from_deck()
            G.consumeables.cards[i]:remove()
            new:add_to_deck()
            new:set_edition(ed, nil, true)
            G.consumeables:emplace(new)
            new:juice_up(0.3, 0.3)
            return true end }))
    end
end

horizon.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

-- fleeting

local fleeting = SMODS.Consumable({
    key = "fleeting",
    set = "m_femtoLabsCollection_twilight",
    config = {mod_conv = 'm_femtoLabsCollection_ice_card', max_highlighted = 2},
	pos = {x = 1, y = 0},
	loc_txt = {
        name = 'Fleeting',
        text = {
            "Enhances up to {C:attention}#1#",
            "selected cards to",
            "{C:attention}#2#s"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

fleeting.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

fleeting.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS.m_femtoLabsCollection_ice_card
    return {
        vars = {
            card.ability.max_highlighted,
            localize{type = 'name_text', set = 'Enhanced', key = 'm_femtoLabsCollection_ice_card'}
        }
    }
end

fleeting.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

-- moment

local moment = SMODS.Consumable({
    key = "moment",
    set = "m_femtoLabsCollection_twilight",
    config = {extra = {prob_success = 4}},
	pos = {x = 2, y = 0},
	loc_txt = {
        name = 'Moment',
        text = {
    "Creates a",
    "{C:attention}Summon Tag"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

moment.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = {key = 'tag_femtoLabsCollection_summon', set = 'Tag'}
end

moment.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

moment.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

moment.can_use = function(self, card)
    return true
end

moment.use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
        func = (function()
            add_tag(Tag('tag_femtoLabsCollection_summon'))
            play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
            play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
            return true
        end)
    }))
end

-- sampo

local sampo = SMODS.Consumable({
    key = "sampo",
    set = "m_femtoLabsCollection_twilight",
    config = {extra = {destroy = 1, gold = 4}},
	pos = {x = 3, y = 0},
	loc_txt = {
        name = 'Sampo',
        text = {
    "Destroys {C:attention}#1#{} random card",
    "in hand, enhance {C:attention}#2#{} random",
    "cards in hand to {C:attention}Gold Cards{}"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

sampo.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

sampo.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

sampo.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS.m_gold
    return {
        vars = {
            card.ability.extra.destroy,
            card.ability.extra.gold
        }
    }
end

sampo.can_use = function(self, card)
    if (G.STATE == G.STATES.SELECTING_HAND or G.STATES.SMODS_BOOSTER_OPENED) and #G.hand.cards > 0 then
        return true
    end
    return false
end

sampo.use = function(self, card, area, copier)
    local temp_hand = {}
    for i=1, #G.hand.cards do
        table.insert(temp_hand, G.hand.cards[i])
    end

    pseudoshuffle(temp_hand, pseudoseed('flc_sampo'))

    local destroyed_cards = {}

    for i=1, math.min(card.ability.extra.destroy, #temp_hand) do
        destroyed_cards[#destroyed_cards+1] = temp_hand[i]

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function() 
                for i=#destroyed_cards, 1, -1 do
                    local _card = destroyed_cards[i]
                    if _card.ability.name == 'Glass Card' then 
                        _card:shatter()
                    else
                        _card:start_dissolve(nil, i ~= #destroyed_cards)
                    end
                end
                return true 
            end }))
    end
    delay(0.2)
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
        play_sound('tarot1')
        card:juice_up(0.3, 0.5)
        return true end }))
    for i=card.ability.extra.destroy+1, math.min(#temp_hand, card.ability.extra.destroy + card.ability.extra.gold) do
        local percent = 1.15 - ((i - card.ability.extra.destroy)-0.999)/(math.min(#temp_hand, card.ability.extra.gold)-0.998)*0.3
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() temp_hand[i]:flip();play_sound('card1', percent);temp_hand[i]:juice_up(0.3, 0.3);return true end }))
    end
    delay(0.2)
    for i=card.ability.extra.destroy+1, math.min(#temp_hand, card.ability.extra.destroy + card.ability.extra.gold) do
        temp_hand[i]:set_ability(G.P_CENTERS.m_gold, nil, true)
        local percent = 0.85 + ((i - card.ability.extra.destroy)-0.999)/(math.min(#temp_hand, card.ability.extra.gold)-0.998)*0.3
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() temp_hand[i]:flip();play_sound('tarot2', percent, 0.6);temp_hand[i]:juice_up(0.3, 0.3);return true end }))
    end
    delay(0.3)
    for i = 1, #G.jokers.cards do
        G.jokers.cards[i]:calculate_joker({remove_playing_cards = true, removed = destroyed_cards})
    end
end

-- theseus

local theseus = SMODS.Consumable({
    key = "theseus",
    set = "m_femtoLabsCollection_twilight",
    config = {extra = {mult = 3, chips = 15}},
	pos = {x = 4, y = 0},
	loc_txt = {
        name = 'Theseus',
        text = {
    "Removes the {C:attention}Enhancement of",
    "a selected card, permanently",
    "give it {C:mult}+#1#{} Mult and {C:chips}+#2#{} Chips"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

theseus.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

theseus.loc_vars = function(self, info_queue, card)
    return {
        vars = {
            card.ability.extra.mult,
            card.ability.extra.chips,
        }
    }
end

theseus.can_use = function(self, card)
    return #G.hand.highlighted == 1 and G.hand.highlighted[1].ability.set == "Enhanced"
end

theseus.use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
        play_sound('tarot1')
        card:juice_up(0.3, 0.5)
        return true end }))
    for i=1, #G.hand.highlighted do
        local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
    end
    delay(0.2)
    for i=1, #G.hand.highlighted do
        G.hand.highlighted[i]:set_ability(G.P_CENTERS.c_base, nil, true)
        G.hand.highlighted[i].ability.perma_bonus = G.hand.highlighted[i].ability.perma_bonus or 0
        G.hand.highlighted[i].ability.perma_bonus = G.hand.highlighted[i].ability.perma_bonus + card.ability.extra.chips
        G.hand.highlighted[i].ability.perma_mult = G.hand.highlighted[i].ability.perma_mult or 0
        G.hand.highlighted[i].ability.perma_mult = G.hand.highlighted[i].ability.perma_mult + card.ability.extra.mult
        local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
    end
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    delay(0.5)
end


theseus.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

-- light

local light = SMODS.Consumable({
    key = "light",
    set = "m_femtoLabsCollection_twilight",
    config = {},
	pos = {x = 5, y = 0},
	loc_txt = {
        name = 'Light',
        text = {
    "{C:attention}Doubles{} the {C:money}sell value",
    "of a selected {C:joker}Joker",
    "{C:inactive}(Max of {C:money}$30{C:inactive})"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

light.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

light.can_use = function(self, card)
    return G.jokers and G.jokers.highlighted and #G.jokers.highlighted > 0
end

light.use = function(self, card, area, copier)
    delay(0.3)
    card:juice_up(0.3, 0.5)
    play_sound('tarot1')
    delay(0.1)
    local inc = 0
    if G.jokers.highlighted[1].set_cost then 
        inc = math.min(G.jokers.highlighted[1].sell_cost, 30)
        G.jokers.highlighted[1].ability.extra_value = (G.jokers.highlighted[1].ability.extra_value or 0) + inc
        G.jokers.highlighted[1]:set_cost()
    end
    card_eval_status_text(G.jokers.highlighted[1], 'dollars', inc)
    delay(0.5)
    G.jokers:unhighlight_all()
end

light.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

-- penumbra

local penumbra = SMODS.Consumable({
    key = "penumbra",
    set = "m_femtoLabsCollection_twilight",
    config = {},
	pos = {x = 6, y = 0},
	loc_txt = {
        name = 'Penumbra',
        text = {
    "Turns {C:attention}a selected",
    "card in your hand",
    "into a {C:dark_edition}Negative{} card",
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

penumbra.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = {key = "e_negative_playing_card", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
    return {
        vars = {
        }
    }
end

penumbra.can_use = function(self, card)
    return #G.hand.highlighted == 1 and not (G.hand.highlighted[1].edition and G.hand.highlighted[1].edition.negative) and not G.hand.highlighted[1].debuff
end

penumbra.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

penumbra.use = function(self, card, area, copier)
    delay(0.2)
    for i=1, #G.hand.highlighted do
        if not (G.hand.highlighted[i].edition and G.hand.highlighted[i].edition.negative) then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function() 
                    play_sound('negative', 1.5, 0.6)
                    card:juice_up()
                    G.hand.highlighted[i]:juice_up(1, 0.5)
                    G.hand.highlighted[i]:set_edition({negative = true}, nil, true)
                return true end }))
        end
    end 
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
    delay(0.5)
end

penumbra.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

-- egress

local egress = SMODS.Consumable({
    key = "egress",
    set = "m_femtoLabsCollection_twilight",
    config = {extra = 'femtoLabsCollection_bronze_seal', max_highlighted = 1},
	pos = {x = 7, y = 0},
	loc_txt = {
        name = 'Egress',
        text = {
    "Add a {V:1}Bronze Seal{}",
    "to {C:attention}#1#{} selected",
    "card in your hand"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

egress.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_SEALS['femtoLabsCollection_bronze_seal']
    return {
        vars = {
            card.ability.max_highlighted,
            colours = {
                flc_twilight_colour
            }
        }
    }
end

egress.use = function(self, card)
    local conv_card = G.hand.highlighted[1]
    G.E_MANAGER:add_event(Event({func = function()
        play_sound('tarot1')
        card:juice_up(0.3, 0.5)
        return true end }))
    
    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        conv_card:set_seal(card.ability.extra, nil, true)
        return true end }))
    
    delay(0.5)
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
end

egress.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

egress.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

-- decay

local decay = SMODS.Consumable({
    key = "decay",
    set = "m_femtoLabsCollection_twilight",
    config = {extra = 25},
	pos = {x = 8, y = 0},
	loc_txt = {
        name = 'Decay',
        text = {
    "Removes {C:dark_edition}Edition{} from",
    "a random {C:joker}Joker,",
    "gain {C:money}$#1#",
    "{C:inactive,s:0.8}(Cannot remove {C:dark_edition,s:0.8}Negative{}{C:inactive,s:0.8})"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

decay.loc_vars = function(self, info_queue, card)
    return {
        vars = {
            card.ability.extra
        }
    }
end

decay.can_use = function(self, card)
    if G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
        local edtable = {}
        for i=1, #G.jokers.cards do
            if G.jokers.cards[i].edition and not G.jokers.cards[i].edition.negative then
                table.insert(edtable, G.jokers.cards[i])
            end
        end
        if #edtable > 0 then return true end
    end
end

decay.use = function(self, card, area, copier)

    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
        play_sound('tarot1')
        card:juice_up(0.3, 0.5)
        local edtable = {}
        for i=1, #G.jokers.cards do
            if G.jokers.cards[i].edition and not G.jokers.cards[i].edition.negative then
                table.insert(edtable, G.jokers.cards[i])
            end
        end
        local _card = pseudorandom_element(edtable, pseudoseed('flc_decay_colon_3'))
        _card:set_edition(nil, nil, false)
        _card:juice_up()
        return true end }))
    delay(0.5)
    ease_dollars(card.ability.extra)
end

decay.in_pool = function(self, args)
    return self:can_use(nil), {allow_duplicates = false}
end

decay.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

-- fulfillment

local fulfillment = SMODS.Consumable({
    key = "fulfillment",
    set = "m_femtoLabsCollection_twilight",
    config = {extra = {prob_success = 4}},
	pos = {x = 9, y = 0},
	loc_txt = {
        name = 'Fulfillment',
        text = {
    "Destroys a selected {C:joker}Joker{}, creates a",
    "random {C:joker}Joker{} of a superior {C:attention}Rarity",
    "{C:inactive,s:0.8}(Cannot create {C:legendary,E:1,s:0.8}Legendary{C:inactive,s:0.8} Jokers from {C:red,s:0.8}Rare{C:inactive,s:0.8} Jokers)"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

fulfillment.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

fulfillment.can_use = function(self, card)
    return G.jokers and G.jokers.highlighted and #G.jokers.highlighted > 0 and not G.jokers.highlighted[1].ability.eternal and not (G.jokers.highlighted[1].edition and G.jokers.highlighted[1].edition.negative)
end

fulfillment.use = function(self, card, area, copier)

    local _rarity = G.jokers.highlighted[1].config.center.rarity

    local rarity_new = 0

    if _rarity == 1 then
        rarity_new = 0.8
    else
        rarity_new = 1
    end

    G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.75, func = function()
        G.jokers.highlighted[1]:start_dissolve(nil, true)
        return true end }))
    G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.4, func = function()
        local card = SMODS.create_card({
            set = 'Joker',
            rarity = rarity_new,
            skip_materialize = true,
            key_append = 'flc_fulfill',
            legendary = _rarity == 4
        })
        card:start_materialize()
        card:add_to_deck()
        G.jokers:emplace(card)
        return true end }))
end

fulfillment.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

-- nostalgia

local nostalgia = SMODS.Consumable({
    key = "nostalgia",
    set = "m_femtoLabsCollection_twilight",
    config = {mod_conv = 'm_femtoLabsCollection_ivory_card', max_highlighted = 2},
	pos = {x = 0, y = 1},
	loc_txt = {
        name = 'Nostalgia',
        text = {
    "Enhances up to {C:attention}#1#",
    "selected cards to",
    "{C:attention}#2#s"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

nostalgia.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

nostalgia.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS.m_femtoLabsCollection_ivory_card
    return {
        vars = {
            card.ability.max_highlighted,
            localize{type = 'name_text', set = 'Enhanced', key = 'm_femtoLabsCollection_ivory_card'}
        }
    }
end

nostalgia.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

-- presence

local presence = SMODS.Consumable({
    key = "presence",
    set = "m_femtoLabsCollection_twilight",
    config = {},
	pos = {x = 2, y = 1},
	loc_txt = {
        name = 'Presence',
        text = {
    "Creates a random",
    "{C:dark_edition}Edition{} tag"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

presence.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = {key = 'tag_foil', set = 'Tag'}
    info_queue[#info_queue+1] = {key = 'tag_holo', set = 'Tag'}
    info_queue[#info_queue+1] = {key = 'tag_polychrome', set = 'Tag'}
    info_queue[#info_queue+1] = {key = 'tag_negative', set = 'Tag'}
end

presence.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

presence.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

presence.use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
        func = (function()
            local key = pseudorandom_element({'foil', 'holo', 'polychrome', 'negative'}, pseudoseed('flc_twilight_presence'))
            add_tag(Tag('tag_'..key))
            play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
            play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
            return true
        end)
    }))
end

presence.can_use = function(self, card)
    return true
end

-- life

local life = SMODS.Consumable({
    key = "life",
    set = "m_femtoLabsCollection_twilight",
    config = {},
	pos = {x = 3, y = 1},
	loc_txt = {
        name = 'Life',
        text = {
    "Creates a random",
    "{C:dark_edition}Negative{} {C:blue}Common{C:attention} Joker"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

life.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS.e_negative
end

life.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

life.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

life.use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.4, func = function()
        local card = SMODS.create_card({
            set = 'Joker',
            rarity = 0.1,
            skip_materialize = true,
            key_append = 'flc_life',
            edition = {negative = true}
        })
        card:start_materialize()
        card:add_to_deck()
        G.jokers:emplace(card)
        return true end }))
end

life.can_use = function(self, card)
    return true
end

-- view

local view = SMODS.Consumable({
    key = "view",
    set = "m_femtoLabsCollection_twilight",
    config = {},
	pos = {x = 7, y = 1},
	loc_txt = {
        name = 'View',
        text = {
    "Fills all {C:attention}empty{} consumable",
    "slots with {C:dark_edition}Foil{}, {C:dark_edition}Holographic",
    "or {C:dark_edition}Polychrome {C:planet}Planet Cards{}",
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

view.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS.e_foil; 
    info_queue[#info_queue+1] = G.P_CENTERS.e_holo; 
    info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome; 
end

view.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

view.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

view.use = function(self, card, area, copier)
    for i = 1, G.consumeables.config.card_limit - #G.consumeables.cards do
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            if G.consumeables.config.card_limit > #G.consumeables.cards then
                play_sound('timpani')
                local card = SMODS.create_card({set = 'Planet', key_append = 'flc_view'})
                card:add_to_deck()
                G.consumeables:emplace(card)
                card:juice_up(0.3, 0.5)
                card:set_edition(poll_edition('flc_view_edition', nil, true, true))
            end
            return true end }))
    end
    delay(0.6)
end

view.can_use = function(self, card)
    return true
end

-- forever

local forever = SMODS.Consumable({
    key = "forever",
    set = "m_femtoLabsCollection_twilight",
    config = {},
	pos = {x = 4, y = 1},
	loc_txt = {
        name = 'Forever',
        text = {
    "Makes a selected",
    "{C:Joker}Joker {V:1}Eternal"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

forever.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = {key = 'eternal', set = 'Other'}
    return {
        vars = {
            colours = {
                G.C.ETERNAL
            }
        }
    }
end

forever.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

forever.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

forever.can_use = function(self, card)
    return G.jokers and G.jokers.highlighted and #G.jokers.highlighted > 0 and G.jokers.highlighted[1].config.center.eternal_compat and not G.jokers.highlighted[1].ability.perishable and not G.jokers.highlighted[1].ability.eternal
end

forever.use = function(self, card, area, copier)
    delay(0.3)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.0,func = function() 
            card:juice_up(0.3, 0.5)
            play_sound('tarot1')
            G.jokers.highlighted[1]:juice_up()
            play_sound('gold_seal', 1.2, 0.4)
            G.jokers.highlighted[1]:set_eternal(true)
            return true 
        end }))
    delay(0.5)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.0,func = function() 
            G.jokers:unhighlight_all()
            return true 
        end }))
end

-- aurora

local aurora = SMODS.Consumable({
    key = "aurora",
    set = "m_femtoLabsCollection_twilight",
    config = {extra = 2},
	pos = {x = 5, y = 1},
	loc_txt = {
        name = 'Aurora',
        text = {
            "Creates up to {C:attention}#1#",
            "consumables from",
            "{C:attention}random sets",
            "{C:inactive}(Must have room)",
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

aurora.loc_vars = function(self, info_queue, card)
    return {
        vars = {
            card.ability.extra
        }
    }
end

aurora.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

aurora.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

aurora.use = function(self, card, area, copier)
    for i = 1, math.min(card.ability.extra, G.consumeables.config.card_limit - #G.consumeables.cards) do
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            if G.consumeables.config.card_limit > #G.consumeables.cards then
                play_sound('timpani')
                local card = SMODS.create_card({set = pseudorandom_element(SMODS.ConsumableTypes, pseudoseed('flc_aurora_set')).key, key_append = 'flc_aurora'})
                card:add_to_deck()
                G.consumeables:emplace(card)
                card:juice_up(0.3, 0.5)
            end
            return true end }))
    end
    delay(0.6)
end

aurora.can_use = function(self, card)
    return true
end

-- reflection

local reflection = SMODS.Consumable({
    key = "reflection",
    set = "m_femtoLabsCollection_twilight",
    config = {},
	pos = {x = 6, y = 1},
	loc_txt = {
        name = 'Reflection',
        text = {
    "Creates a {V:1}Perishable{} copy",
    "of a random {C:joker}Joker",
    "{C:inactive}(Must have room)"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

reflection.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = {key = 'perishable', set = 'Other', vars = {G.GAME.perishable_rounds or 1, G.GAME.perishable_rounds}}
    return {
        vars = {
            colours = {
                G.C.PERISHABLE
            }
        }
    }
end

reflection.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

reflection.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

reflection.use = function(self, card, area, copier)
    local chosen_joker = pseudorandom_element(G.jokers.cards, pseudoseed('flc_reflection_choice'))
    G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.4, func = function()
        local card = copy_card(chosen_joker, nil, nil, nil, chosen_joker.edition and chosen_joker.edition.negative)
        card:start_materialize()
        card:set_eternal(false)
        card:set_perishable(true)
        card:add_to_deck()
        if card.edition and card.edition.negative then
            card:set_edition(nil, true)
        end
        G.jokers:emplace(card)
        return true end }))
end

reflection.can_use = function(self, card)
    for k, v in pairs(G.jokers.cards) do
        if v.ability.set == 'Joker' and G.jokers.config.card_limit > 1 then 
            return true
        end
    end
end

check_useRef = Card.check_use
Card.check_use = function(self)
    ret = check_useRef(self)
    if self.config.center_key == 'c_femtoLabsCollection_reflection' then 
        if #G.jokers.cards >= G.jokers.config.card_limit and self.area ~= G.pack_cards then
            alert_no_space(self, G.jokers)
            return true
        end
    end
    return ret
end

-- treasure

local treasure = SMODS.Consumable({
    key = "treasure",
    set = "m_femtoLabsCollection_twilight",
    config = {extra = 10},
	pos = {x = 8, y = 1},
	loc_txt = {
        name = 'Treasure',
        text = {
    "Makes all {C:joker}Jokers{} {V:1}Rental,",
    "gain {C:money}$#1#{} per",
    "{C:joker}Joker{} made {V:1}Rental"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = true,
	atlas = "c_flc_twilight"
})

treasure.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = {key = 'rental', set = 'Other', vars = {G.GAME.rental_rate or 1}}
    return {
        vars = {
            card.ability.extra,
            colours = {
                G.C.RENTAL
            }
        }
    }
end

treasure.in_pool = function(self, args)
    return true, {allow_duplicates = false}
end

treasure.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

treasure.use = function(self, card, area, copier)
    local table2 = {}

    delay(0.3)

    for i=1, #G.jokers.cards do
        if not G.jokers.cards[i].ability.rental then table2[#table2+1] = G.jokers.cards[i] end
    end

    for i=1, #table2 do
        local percent = 0.85 + (i-0.999)/(#table2-0.998)*0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function() 
                table2[i]:juice_up(); 
                play_sound('tarot2', percent, 0.6);
                table2[i]:set_rental(true)
                return true 
            end }))
    end 
    delay(0.3)
    if #table2 > 0 then ease_dollars(card.ability.extra * #table2) end
    delay(0.5)
end

treasure.can_use = function(self, card)
    if G.jokers then
        for i=1, #G.jokers.cards do
            if not G.jokers.cards[i].ability.rental then return true end
        end
    else return false end
end

-- samsara

local samsara = SMODS.Consumable({
    key = "samsara",
    set = "Spectral",
    config = {},
	pos = {x = 1, y = 1},
	loc_txt = {
        name = 'Samsara',
        text = {
    "Creates a {C:dark_edition}Negative{} copy of",
    "{C:legendary,E:1}every{} {C:attention}Joker{} and {C:attention}Consumable",
    "card sold this run"
        }
    },
	cost = 6,
    unlocked = true,
	discovered = false,
    hidden = true,
    soul_set = 'twilight',
	atlas = "c_flc_twilight",
    can_repeat_soul = false
})

samsara.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS.e_negative
    info_queue[#info_queue+1] = {key = 'e_negative_consumable', set = 'Edition', config = {extra = 1}}
end

samsara.can_use = function(self, card)
    return G.flc_soldarea and G.flc_soldarea.cards and #G.flc_soldarea.cards > 0
end

samsara.in_pool = function(self, args)
    return G.flc_soldarea and G.flc_soldarea.cards and #G.flc_soldarea.cards > 0, {allow_duplicates = false}
end

samsara.use = function(self, card, area, copier)

    if not G.flc_soldarea then return end

    local i = 1;

    local sold_count = #G.flc_soldarea.cards

    for _, new in pairs(G.flc_soldarea.cards) do
        local i2 = i
        G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.4, func = function()
            local percent = 0.85 + (i2-0.999)/(sold_count-0.998)*0.3
            play_sound('tarot2', percent, 0.6);
            G.flc_soldarea:remove_card(new)
            new.VT.x = card.VT.x
            new.VT.y = card.VT.y
            card:juice_up(0.3, 0.1)
            new:set_edition({negative = true}, nil, false)
            new:start_materialize()
            new:add_to_deck()
            if new.ability.set == 'Joker' then
                G.jokers:emplace(new)
            else 
                G.consumeables:emplace(new)
            end
            return true end }))
        i = i + 1
    end
    delay(0.5)
end

local sellRef = Card.sell_card

Card.sell_card = function(self)
    sellRef(self)

    local card = copy_card(self, nil, nil, nil, false)

    G.flc_soldarea:emplace(card)
end

