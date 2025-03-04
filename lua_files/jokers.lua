-- radioactivity --

local radioactive = SMODS.Joker({
	name = "flc_Radioactive",
	key = "flc_radioactive",
    config = {extra = {prob_success = 4, mult = 4}},
	pos = {x = 0, y = 0},
	loc_txt = {
        name = 'Radioactivity',
        text = {
	"When a played card scores,",
	"{C:green}#1# in #2#{} chance to increase",
    "its {C:attention}rank{} or change its {C:attention}suit{}",
    "{C:mult}+#3#{} Mult per mutation"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

radioactive.calculate = function(self, card, context)
    if context.individual then
		if context.cardarea == G.play then
            if pseudorandom('radioactive') < G.GAME.probabilities.normal/card.ability.extra.prob_success then
                local other_card = context.other_card
                return {
                    card = context.other_card, message = "Mutated!", colour = G.C.GREEN, func = function()
                        G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = (function()
                            flc_doTheThing(self, card, other_card)
                            return true
                        end)}))
                    end,
                    extra = {mult = card.ability.extra.mult}
                }
            end
        end
    end
end

function flc_doTheThing(self, card, other)
    
        local _card = other
        if pseudorandom('radioactive_rank_or_suit') < 0.5 then
            local suit_prefix = string.sub(_card.base.suit, 1, 1)..'_'
            local rank_suffix = _card.base.id == 14 and 2 or math.min(_card.base.id+1, 14)
            if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
            elseif rank_suffix == 10 then rank_suffix = 'T'
            elseif rank_suffix == 11 then rank_suffix = 'J'
            elseif rank_suffix == 12 then rank_suffix = 'Q'
            elseif rank_suffix == 13 then rank_suffix = 'K'
            elseif rank_suffix == 14 then rank_suffix = 'A'
            end
            _card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
        else
            local new_suit = pseudorandom('radioactive_set_suit') 
            local new_prefixes = {'H', 'S', 'D', 'C'}
            for i=1, #new_prefixes do
                if string.sub(_card.base.suit, 1, 1) == new_prefixes[i] then
                    table.remove(new_prefixes, i)
                    break
                end
            end
            local new_prefix = pseudorandom_element(new_prefixes, pseudoseed('radioactive_prefixes'))..'_'
            local rank_suffix = _card.base.id
            if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
            elseif rank_suffix == 10 then rank_suffix = 'T'
            elseif rank_suffix == 11 then rank_suffix = 'J'
            elseif rank_suffix == 12 then rank_suffix = 'Q'
            elseif rank_suffix == 13 then rank_suffix = 'K'
            elseif rank_suffix == 14 then rank_suffix = 'A'
            end
            _card:set_base(G.P_CARDS[new_prefix..rank_suffix])
        end
        card:juice_up()
end

function radioactive.loc_vars(self, info_queue, card)
	return {vars = {''..(G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.prob_success, card.ability.extra.mult}}
end
-------- end radioactivity --------

-- medusa's gaze --

local medusas_gaze = SMODS.Joker({
	name = "flc_MedusasGaze",
	key = "flc_medusas_gaze",
    config = {},
	pos = {x = 1, y = 0},
	loc_txt = { 
        name = 'Medusa\'s Gaze',
        text = {
	"After a hand is played,",
	"{C:attention}face cards{} held in hand",
    "become {C:attention}Stone Cards{}",
    "with a random {C:dark_edition}Edition{}"
        }
    },
	rarity = 3,
	cost = 11,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

medusas_gaze.calculate = function(self, card, context)
    if context.individual and not context.blueprint then
        if context.cardarea == G.hand then
            if context.other_card:is_face() and context.other_card.ability.name ~= 'Stone Card' then
                local other_card = context.other_card
                return {
                    extra = {focus = other_card, func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 1.2,
                            func = (function()
                                card:juice_up()
                                card_eval_status_text(other_card, 'extra', nil, nil, nil, {message = 'Petrified!', colour = G.C.GREY, instant = true})
                                new_edition = poll_edition('flc_medusa', nil, false, pseudorandom('flc_medusa_a_little_better') > 0.5)
                                other_card:set_ability(G.P_CENTERS['m_stone'])
                                other_card:set_edition(new_edition, true)
                                return true
                            end)}))
                    end},
                    card = other_card,
                }
            end
        end
    end
end

function medusas_gaze.loc_vars(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS.e_foil
    info_queue[#info_queue+1] = G.P_CENTERS.e_holo
    info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
end

-------- end medusa's gaze --------

-- clown car --

local clown_car = SMODS.Joker({
	name = "flc_ClownCar",
	key = "flc_clown_car",
    config = { extra = { mult = 0, treshold = 7, mult_inc = 18 } },
	pos = {x = 2, y = 0},
	loc_txt = { 
        name = 'Clown Car',
        text = {
	"{C:mult}+#1#{} Mult for every rank",
	"containing more than {C:attention}#2#",
    "{C:attention}cards{} of the kind in deck",
    "{C:inactive}(Currently{} {C:red}+#3#{C:inactive} Mult)",
    "{C:inactive,s:0.8}Concept, Art: ABuffZucchini",
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

function clown_car.loc_vars(self, info_queue, card)
    card.ability.extra.mult = self.calc_mult(card)
	return {
        vars = {
            card.ability.extra.mult_inc,
            card.ability.extra.treshold,
            self.calc_mult(card)
        }
    }
end

function clown_car.calculate(self, card, context)
    if context.joker_main and card.ability.extra.mult ~= 0 then
        card.ability.extra.mult = self.calc_mult(card)
        return {
            message = localize {
               type = 'variable',
                key = 'a_mult',
               vars = { card.ability.extra.mult }
             },
         mult_mod = card.ability.extra.mult
         }
    end
end

function clown_car.calc_mult(card)

    local ranks = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    local total = 0

    if G.playing_cards and G.STAGE == G.STAGES.RUN then
        for v, k in ipairs(G.playing_cards) do
            ranks[k.base and k.base.id-1] = ranks[k.base and k.base.id-1] + 1
        end

        for i=1, #ranks do
            if ranks[i] > card.ability.extra.treshold then
                total = total + card.ability.extra.mult_inc
            end
        end
    end
    return total
end

-------- end clown car --------

-- supercollider --

local supercollider = SMODS.Joker({
	name = "flc_Supercollider",
	key = "flc_supercollider",
    config = {},
	pos = {x = 3, y = 0},
	loc_txt = { 
        name = 'Supercollider',
        text = {
	"If {C:attention}first hand{} of round",
    "is a {C:attention}Pair{}, turn one",
    "of the cards {C:dark_edition}Negative"
        }
    },
	rarity = 3,
	cost = 9,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

supercollider.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = {key = "e_negative_playing_card", set = "Edition", config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
end

supercollider.calculate = function(self, card, context)
    if context.blueprint then return end

    if context.first_hand_drawn then
        local eval = function() return G.GAME.current_round.hands_played == 0 end
        juice_card_until(card, eval, true)
    end

    if context.cardarea == G.jokers and context.before and G.GAME.current_round.hands_played == 0 and context.scoring_name and context.scoring_name == 'Pair' then
        for i=1, #context.full_hand do
            if i ~= #context.full_hand then
                if context.full_hand[i].base.id == context.full_hand[i+1].base.id then
                    return {
                        extra = {focus = context.other_card, func = function()
                            G.E_MANAGER:add_event(Event({
                                trigger = 'before',
                                delay = 1.2,
                                func = (function()
                                    card:juice_up()
                                    if pseudorandom('flc_supercollider') < 0.5 then
                                        context.full_hand[i]:set_edition({negative = true}, true)
                                    else
                                        context.full_hand[i+1]:set_edition({negative = true}, true)
                                    end
                                    return true
                                end)}))
                        end},
                        card = context.other_card,
                    }
                end
            end
        end
    end
end

-------- end supercollider --------

-- transmutation --

local transmutation = SMODS.Joker({
	name = "flc_Transmutation",
	key = "flc_transmutation",
    config = {},
	pos = {x = 4, y = 0},
	loc_txt = { 
        name = 'Transmutation',
        text = {
	"Scored {C:attention}Stone Cards{}",
    "become {C:attention}Steel Cards{}",
	"Scored {C:attention}Steel Cards{}",
    "become {C:attention}Gold Cards{}"
        }
    },
	rarity = 2,
	cost = 4,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

transmutation.in_pool = function(self, args)
    if G.deck and G.deck.cards then
        for j = 1, #G.deck.cards do
            if G.deck.cards[j].ability.name == 'Stone Card' then
                return true
            end
            if G.deck.cards[j].ability.name == 'Steel Card' then
                return true
            end
        end
    end
end

transmutation.calculate = function(self, card, context)
    if context.individual and not context.blueprint then
		if context.cardarea == G.play then
            local other_card = context.other_card
            if context.other_card.ability.name == 'Stone Card' then
                return {
                    extra = {focus = context.other_card, func = function()
                        G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 1.2,
                        func = (function()
                            card:juice_up()
                            card_eval_status_text(other_card, 'extra', nil, nil, nil, {message = 'Steel!', colour = G.C.EDITION_DARK, instant = true})
                            other_card:set_ability(G.P_CENTERS['m_steel'])
                            return true
                        end)}))
                    end},
                    card = context.other_card
                }
            elseif context.other_card.ability.name == 'Steel Card' then
                return {
                    extra = {focus = context.other_card,  func = function()
                        G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 1.2,
                        func = (function()
                            card:juice_up()
                            card_eval_status_text(other_card, 'extra', nil, nil, nil, {message = 'Gold!', colour = G.C.GOLD, instant = true})
                            other_card:set_ability(G.P_CENTERS['m_gold'])
                            return true
                        end)}))
                    end},
                    card = context.other_card
                }
            end
        end
    end
end

-------- end transmutation --------

-- jackpot --

local jackpot = SMODS.Joker({
	name = "flc_Jackpot",
	key = "flc_jackpot",
    config = {extra = {chance = 7, money = 25}},
	pos = {x = 5, y = 0},
	loc_txt = { 
        name = 'Jackpot',
        text = {
	"If the played hand has",
    "{C:attention}three or more 7s{},",
    "each {C:attention}7{} has a {C:green}#1# in #2#{}",
    "chance to give {C:money}$#3#{s:0.85}",
    "{C:inactive,s:0.8}Concept: goose!",
    "{C:inactive,s:0.8}Art: ABuffZucchini"
        }
    },
	rarity = 2,
	cost = 5,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

function jackpot.loc_vars(self, info_queue, card)
	return {vars = {''..(G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.chance, card.ability.extra.money}}
end

jackpot.calculate = function(self, card, context)

    local done = false

    if context.individual and context.cardarea == G.play then

        local card_count = 0

        for i=1, #context.full_hand do
            if context.full_hand[i].base.id == 7 then card_count = card_count + 1 end
        end

        if card_count >= 3 and context.other_card.base.id == 7 then
            if pseudorandom('flc_jackpot') < G.GAME.probabilities.normal/card.ability.extra.chance then
                return {
                    dollars = card.ability.extra.money,
                    card = context.other_card
                }
            else 
                return {
                    extra = {focus = context.other_card, message = localize('k_nope_ex'), colour = G.C.SECONDARY_SET.Tarot},
                    card = context.other_card
                }
            end
        end
    end
end

-------- end jackpot --------

-- all balls -- 

local allballs = SMODS.Joker({
	name = "flc_AllBalls",
	key = "flc_allballs",
    config = {extra = {money = 2, Xmult = 2}},
	pos = {x = 6, y = 0},
	loc_txt = { 
        name = 'All Balls...',
        text = {
	"{C:attention}Pairs{} give {C:money}$#1#{s:0.85}",
    "when played",
    "{C:inactive,s:0.8}Art: ABuffZucchini"
        }
    },
	rarity = 1,
	cost = 2,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

function allballs.loc_vars(self, info_queue, card)
	return {vars = {card.ability.extra.money}}
end

allballs.calculate = function(self, card, context)
    if context.cardarea == G.jokers then
        if context.before then
            if context.scoring_name and context.scoring_name == 'Pair' then
                return {
                    dollars = card.ability.extra.money,
                    card = card
                }
            end
        elseif context.joker_main and context.scoring_name and context.scoring_name == 'Pair' then

            local count = 0

            for _, v in ipairs(G.jokers.cards) do
                if v.ability.name == 'flc_AllBalls' then
                    count = count + 1
                end
            end

            if count == 2 then
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}},
                    Xmult_mod = card.ability.extra.Xmult,
                }
            end
        end
    end

end

-------- end all balls --------

-- gyroscope -- 

local gyroscope = SMODS.Joker({
	name = "flc_Gyroscope",
	key = "gyroscope",
    config = {extra = {mult = 6}},
	pos = {x = 0, y = 1},
	loc_txt = { 
        name = 'Gyroscope',
        text = {
	"{C:mult}+#1#{} Mult",
    "{C:dark_edition}Edition{} cycles",
    "every hand",
    "{C:inactive}(Negative Excluded){s:0.85}"
        }
    },
	rarity = 1,
	cost = 4,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

function gyroscope.loc_vars(self, info_queue, card)
	return {vars = {card.ability.extra.mult}}
end

gyroscope.calculate = function(self, card, context)
    if context.joker_main then
        return {
            mult = card.ability.extra.mult,
            card = card
        }
    end

    if context.cardarea == G.jokers and context.after and not context.blueprint then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.0,
            func = (function()
                card:juice_up()
                if not card.edition then
                    card:set_edition({foil = true})
                elseif card.edition.foil then
                    card:set_edition({holo = true})
                elseif card.edition.holo then
                    card:set_edition({polychrome = true})
                elseif card.edition.polychrome then
                    card:set_edition(nil)
                elseif card.edition.negative then
                    if #G.jokers.cards >= G.jokers.config.card_limit - 1 then
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Stuck!', colour = G.C.PERISHABLE, instant = true})
                    else
                        card:set_edition(nil)
                    end
                end
                return true
            end)}))
    end
end

-------- end gyroscope --------

-- alloy -- 

local alloy = SMODS.Joker({
	name = "flc_Alloy",
	key = "alloy",
    config = {extra = {xmult = 1.25, dollars = 1}},
	pos = {x = 1, y = 1},
	loc_txt = { 
        name = 'Alloy',
        text = {
	"{C:attention}Steel Cards{} and {C:attention}Gold Cards",
    "gain a weaker version of",
    "eachother's {C:attention}main{} abilities",
    "{C:inactive}({C:money}$#1#{s:0.85}{C:inactive}, {X:mult,C:white}X#2#{C:inactive} Mult respectively)",
    "{C:inactive,s:0.8}Concept: ABuffZucchini"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

function alloy.loc_vars(self, info_queue, card)
	return {vars = {card.ability.extra.dollars, card.ability.extra.xmult}}
end

alloy.in_pool = function(self, args)
    if G.deck and G.deck.cards then
        for j = 1, #G.deck.cards do
            if G.deck.cards[j].ability.name == 'Gold Card' then
                return true
            end
            if G.deck.cards[j].ability.name == 'Steel Card' then
                return true
            end
        end
    end
end

alloy.calculate = function(self, card, context)
    if context.blueprint then return end
    if context.cardarea == G.hand and context.individual then
        if context.end_of_round then
            if context.other_card.config.center == G.P_CENTERS.m_steel then
                if not context.other_card.debuff then
                    return {
                        dollars = card.ability.extra.dollars,
                        card = card
                    }
                end
            end
        else
            if context.other_card.config.center == G.P_CENTERS.m_gold then
                if not context.other_card.debuff then
                    return {
                        x_mult = card.ability.extra.xmult,
                        card = card
                    }
                end
        end

    end
    end
end

-------- end alloy --------

-- old socks -- 

local oldsocks = SMODS.Joker({
	name = "flc_OldSocks",
	key = "oldsocks",
    config = {extra = {mult_inc = 1, mult = 0}},
	pos = {x = 2, y = 1},
	loc_txt = { 
        name = 'Old Socks',
        text = {
	"This Joker gains {C:mult}+#1#{} Mult",
    "when a {C:attention}Pair{} is discarded",
    "{C:inactive}(Currently {}{C:mult}+#2#{}{C:inactive} Mult)",
    "{C:inactive,s:0.8}Art: ABuffZucchini"
        }
    },
	rarity = 1,
	cost = 4,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

function oldsocks.loc_vars(self, info_queue, card)
	return {vars = {card.ability.extra.mult_inc, card.ability.extra.mult}}
end

oldsocks.calculate = function(self, card, context)
    if context.pre_discard and not context.blueprint then
        if G.FUNCS.get_poker_hand_info(G.hand.highlighted) == "Pair" then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_inc
            return {
                message = localize('k_upgrade_ex'),
                card = card,
                colour = G.C.MULT
            }
        end
    end

    if context.joker_main and card.ability.extra.mult ~= 0 then
        return {
            message = localize {
               type = 'variable',
                key = 'a_mult',
               vars = { card.ability.extra.mult }
             },
         mult_mod = card.ability.extra.mult
         }
    end
end

-------- end old socks --------

-- cascade -- 

local cascade = SMODS.Joker({
	name = "flc_Cascade",
	key = "cascade",
    config = {},
	pos = {x = 3, y = 1},
	loc_txt = { 
        name = 'Cascade',
        text = {
	"{C:attention}First played card{}", 
    "in the round lowers its ",
    "{C:attention}rank{} by {C:attention}2{} before scoring",
    "{C:inactive,s:0.8}Concept: ABuffZucchini"
        }
    },
	rarity = 2,
	cost = 5,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

cascade.calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.before and G.play.cards[1] and G.GAME.current_round.hands_played == 0 then
        return {
            extra = {focus = G.play.cards[1], func = function()
                local _card = G.play.cards[1]
                card:juice_up()
                if context.blueprint then
                    card_eval_status_text(context.blueprint_card, 'extra', nil, nil, nil, {message = 'Rank Down!', colour = G.C.GREEN, instant = true})
                else
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Rank Down!', colour = G.C.GREEN, instant = true})
                end
                _card:juice_up()
                local suit_prefix = string.sub(_card.base.suit, 1, 1)..'_'
                local rank_suffix = _card.base.id == 2 and 13 or _card.base.id == 3 and 14 or math.max(_card.base.id-2, 2)
                if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                elseif rank_suffix == 10 then rank_suffix = 'T'
                elseif rank_suffix == 11 then rank_suffix = 'J'
                elseif rank_suffix == 12 then rank_suffix = 'Q'
                elseif rank_suffix == 13 then rank_suffix = 'K'
                elseif rank_suffix == 14 then rank_suffix = 'A'
                end
                _card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
            end},
            card = G.play.cards[1]
        }
    end
end

-------- end cascade --------

-- laterality -- 

local laterality = SMODS.Joker({
	name = "flc_Laterality",
	key = "laterality",
    config = {extra = 15},
	pos = {x = 4, y = 1},
	loc_txt = { 
        name = 'Laterality',
        text = {
	"{C:attention}Unscored cards in", 
    "played hand permanently",
    "gain {C:chips}+#1#{} Chips"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

function laterality.loc_vars(self, info_queue, card)
	return {vars = {card.ability.extra}}
end

laterality.calculate = function(self, card, context)

    --[[if context.individual and context.cardarea == 'unscored' then
        context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
        context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra
        return {
            message = localize('k_upgrade_ex'),
            colour = G.C.CHIPS
        }
    end]]--

    if context.individual and context.cardarea == G.play and context.other_card == context.scoring_hand[#context.scoring_hand] and #context.scoring_hand < #context.full_hand then
        return {extra = {func = function()
            for _, _card in ipairs(context.full_hand) do
                for _, s in ipairs(context.scoring_hand) do
                    if s == _card then goto continue end
                end
                if _card.debuff then goto continue end
                local ctx = context
                G.E_MANAGER:add_event(Event({func = function() 
                    _card.ability.perma_bonus = _card.ability.perma_bonus or 0
                    _card.ability.perma_bonus = _card.ability.perma_bonus + card.ability.extra
                    _card:juice_up()
                    local c = ctx.blueprint_card or card
                    c:juice_up()
                    card_eval_status_text(_card, 'extra', card.ability.extra, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.CHIPS, instant = true})
                    return true end })) 
                delay(0.8)
                ::continue::
            end
        end}}
    end
end

-------- end laterality --------

-- divine light -- 

local divinelight = SMODS.Joker({
	name = "flc_DivineLight",
	key = "divinelight",
    config = {},
	pos = {x = 5, y = 1},
	loc_txt = { 
        name = 'Divine Light',
        text = {
	"Cards held in hand", 
    "become {C:attention}Bonus Cards{} after",
    "the {C:attention}final hand{} of round",
    "{C:inactive,s:0.8}Concept: ABuffZucchini"
        }
    },
	rarity = 3,
	cost = 7,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

function divinelight.loc_vars(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS['m_bonus']
end

divinelight.calculate = function(self, card, context)
    if context.blueprint then return end
    if context.individual and context.cardarea == G.hand and context.end_of_round then
        local other_card = context.other_card
        if context.other_card.ability.effect ~= 'Bonus Card' and not context.other_card.debuff then return {
            extra = {focus = context.other_card, func = function()
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.8,
                    func = (function()
                        card:juice_up()
                        card_eval_status_text(other_card, 'extra', nil, nil, nil, {message = 'Divine!', colour = G.C.CHIPS, instant = true})
                        other_card:set_ability(G.P_CENTERS['m_bonus'])
                        return true
                    end)}))
            end},
            card = context.other_card,
        }
        end
    end
end

-------- end divinelight --------

-- rolling stones -- 

local rollingstones = SMODS.Joker({
	name = "flc_RollingStones",
	key = "rollingstones",
    config = {extra = 1},
	pos = {x = 6, y = 1},
	loc_txt = { 
        name = 'Rolling Stones',
        text = {
	"{C:attention}Stone Cards{} permanently", 
    "gain {C:mult}+#1#{} Mult when scored",
    "{C:inactive,s:0.8}Concept: ABuffZucchini"
        }
    },
	rarity = 2,
	cost = 7,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

function rollingstones.loc_vars(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS['m_stone']
    return {vars = {card.ability.extra}}
end

rollingstones.in_pool = function(self, args)
    if G.deck and G.deck.cards then
        for j = 1, #G.deck.cards do
            if SMODS.get_enhancements(G.deck.cards[j])['m_stone'] then
                return true
            end
        end
    end
end

rollingstones.calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, 'm_stone') then
        local other_card = context.other_card
        return {
            extra = {focus = other_card, func = function()
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.8,
                    func = (function()
                        other_card:juice_up()
                        card_eval_status_text(other_card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.RED, instant = true})
                        other_card.ability.perma_mult = other_card.ability.perma_mult or 0
                        other_card.ability.perma_mult = other_card.ability.perma_mult + card.ability.extra
                        return true
                    end)}))
            end},
            card = card,
        }
    end
end

-------- end rolling stones --------

-- unfolding -- 

local unfolding = SMODS.Joker({
	name = "flc_Unfolding",
	key = "unfolding",
    config = {extra = {discards = 1, suit = 'Hearts'}},
	pos = {x = 0, y = 2},
	loc_txt = { 
        name = 'Unfolding',
        text = {
	"{C:red}+#1#{} discard this",
    "round if scored hand",
    "contains {V:1}#2#{} cards",
    "{s:0.8}suit changes every hand",
    "{C:inactive,s:0.8}Concept: ABuffZucchini"
        }
    },
	rarity = 1,
	cost = 5,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

unfolding.loc_vars = function(self, info_queue, card)
	return {
        vars = {
	        card.ability.extra.discards,
		    localize(card.ability.extra.suit, 'suits_singular'), 
		    colours = {
		        G.C.SUITS[card.ability.extra.suit]
		    }
	    }
    }
end

unfolding.set_ability = function(self, card, initial, delay_sprites)
    card.ability.extra.suit = pseudorandom_element({'Spades','Hearts','Clubs','Diamonds'}, pseudoseed('flc_unfolding_suit'))
end

unfolding.calculate = function(self, card, context)
    if context.joker_main then
        local found_it = false
        for _, v in ipairs(context.scoring_hand) do
            if v:is_suit(card.ability.extra.suit) then 
                found_it = true
                break
            end
        end
        return {
        extra = {focus = card, func = function()
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.8,
                func = (function()
                    if found_it then
                        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+1 Discard", colour = G.C.RED, instant = true})
                        ease_discard(card.ability.extra.discards)
                    end
                    local suitpool = {'Spades','Hearts','Clubs','Diamonds'}
                    suitpool[card.ability.extra.suit] = nil
                    card.ability.extra.suit = pseudorandom_element(suitpool, pseudoseed('flc_unfolding_suit'))
                    return true
                end)}))
        end},
        card = card,
        }
    end
end

-------- end unfolding --------

-- savoury cheese -- 

local cheese = SMODS.Joker({
	key = "savoury_cheese",
    config = {extra = {Xmult = 1.5, odds = 2}},
	pos = {x = 1, y = 2},
	loc_txt = { 
        name = 'Savoury Cheese',
        text = {
	"{X:mult,C:white}X#1#{} Mult", 
    "{C:green}#2# in #3#{} chance of being",
    "eaten on round end",
    "{C:inactive,s:0.8}Art: ABuffZucchini"
        }
    },
	rarity = 1,
	cost = 2,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = false,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

cheese.loc_vars = function(self, info_queue, card)
	return {
        vars = {
	        card.ability.extra.Xmult,
            ''..(G.GAME and G.GAME.probabilities.normal or 1), 
            card.ability.extra.odds
	    }
    }
end

cheese.set_ability = function(self, card, initial, delay_sprites)
    card.ability.extra.Xmult = 2 + 2.5 * (G.GAME and G.GAME.flc_cheeseindex or 0)
    card.ability.extra.odds = 3 ^ ((G.GAME and G.GAME.flc_cheeseindex or 0) + 1)
end

cheese.calculate = function(self, card, context)
    if context.joker_main then
        return {
            message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}},
            Xmult_mod = card.ability.extra.Xmult
        }
    end
    if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
        if pseudorandom('flc_savoury_cheese') < G.GAME.probabilities.normal/card.ability.extra.odds then 
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                        func = function()
                                G.jokers:remove_card(card)
                                card:remove()
                                card = nil
                            return true; end})) 
                    return true
                end
            })) 
            G.GAME.flc_cheeseindex = G.GAME.flc_cheeseindex and (G.GAME.flc_cheeseindex + 1) or 1
            return {
                message = localize('k_eaten_ex')
            }
        else
            return {
                message = localize('k_safe_ex')
            }
        end
    end
end

-------- end savoury cheese --------

-- gooseberry -- 

local gooseberry = SMODS.Joker({
	key = "gooseberry",
    config = {extra = {choices = 2, choice_mod = 1, active = false}},
	pos = {x = 2, y = 2},
	loc_txt = { 
        name = 'Gooseberries',
        text = {
    "Allows you to {C:attention}pick #1#{} extra card#2#",
	"from {C:attention}Booster Packs{}, reduces by", 
    "{C:red}#3#{} every round after",
    "opening a {C:attention}Booster Pack",
    "{C:inactive,s:0.8}Concept: goose!"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

gooseberry.loc_vars = function(self, info_queue, card)
	return {
        vars = {
	        card.ability.extra.choices,
            card.ability.extra.choices == 1 and '' or 's',
            card.ability.extra.choice_mod
	    }
    }
end

gooseberry.calculate = function(self, card, context)

    if context.blueprint then return end

    if context.open_booster then
        card.ability.extra.active = true
    end

    if context.end_of_round and context.cardarea == G.jokers and card.ability.extra.active then

        card.ability.extra.choices = card.ability.extra.choices - card.ability.extra.choice_mod

        if card.ability.extra.choices <= 0 then

            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                        func = function()
                                G.jokers:remove_card(card)
                                card:remove()
                                card = nil
                            return true; end})) 
                    return true
                end
            })) 

            return {
                message = localize('k_eaten_ex')
            }
        else
            return {
                message = localize{type='variable',key='a_chips_minus',vars={card.ability.extra.choice_mod}},
            }
        end
    end
end

gooseberry.add_to_deck = function(self, card, from_debuff)
    if G.shop_booster and G.shop_booster.cards then
        for i=1, #G.shop_booster.cards do
            G.shop_booster.cards[i].ability.choose = math.min(G.shop_booster.cards[i].ability.choose + card.ability.extra.choices, G.shop_booster.cards[i].ability.extra)
        end
    end
end

gooseberry.remove_from_deck = function(self, card, from_debuff)
    if G.shop_booster and G.shop_booster.cards then
        for i=1, #G.shop_booster.cards do
            G.shop_booster.cards[i].ability.choose = G.shop_booster.cards[i].ability.choose - card.ability.extra.choices
        end
    end
end

-------- end gooseberry --------

-- fizzbuzz -- 

local fizzbuzz = SMODS.Joker({
	key = "fizzbuzz",
    config = {extra = {three = 3, five = 5, trigger = 0}},
	pos = {x = 3, y = 2},
	loc_txt = { 
        name = 'Fizz Buzz',
        text = {
	"{C:money}$#1#{} and/or {C:money}$#2#{} at the", 
    "end of round if blind",
    "is selected with {C:money}money{}",
    "divisible by {C:attention}#1#{} and/or {C:attention}#2#{}"
        }
    },
	rarity = 1,
	cost = 4,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

fizzbuzz.loc_vars = function(self, info_queue, card)
	return {
        vars = {
	        card.ability.extra.three,
            card.ability.extra.five
	    }
    }
end

fizzbuzz.calculate = function(self, card, context)
    if context.blueprint then return end
    if context.setting_blind then
        if G.GAME.dollars % 5 == 0 then
            card.ability.extra.trigger = card.ability.extra.trigger + card.ability.extra.five
        end
        if G.GAME.dollars % 3 == 0 then
            card.ability.extra.trigger = card.ability.extra.trigger + card.ability.extra.three
        end

        if card.ability.extra.trigger == 3 then
            return {
                message = "Fizz!",
                colour = G.C.MONEY
            }
        elseif card.ability.extra.trigger == 5 then
            return {
                message = "Buzz!",
                colour = G.C.MONEY
            }
        elseif card.ability.extra.trigger == 8 then
            return {
                message = "FizzBuzz!",
                colour = G.C.MONEY
            }
        end
    end
end

fizzbuzz.calc_dollar_bonus = function(self, card)
    if card.ability.extra.trigger and card.ability.extra.trigger > 0 then
        temp = card.ability.extra.trigger
        card.ability.extra.trigger = 0
        return temp
    end
end

-------- end fizzbuzz --------

-- the call -- 

local call = SMODS.Joker({
	key = "thecall",
    config = {extra = {curr_key = "m_wild", xmult = 1, xmult_mod = 0.25}},
	pos = {x = 4, y = 2},
	loc_txt = { 
        name = 'The Call',
        text = {
	"This Joker gains {X:mult,C:white}X#1#{} Mult", 
    "for every unscored {C:attention}#2#{}",
    "in played hand",
    "{s:0.8}Enhancement changes every hand",
    "{C:inactive}(Currently {X:mult,C:white}X#3#{}{C:inactive} Mult)"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

call.set_ability = function(self, card, initial, delay_sprites)
    local temp = G.P_CENTER_POOLS["Enhanced"]
    if temp['m_stone'] then temp['m_stone'] = nil end
    card.ability.extra.curr_key = pseudorandom_element(temp, pseudoseed('flc_call_random')).key
end

call.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS[card.ability.extra.curr_key]
    return {
        vars = {
            card.ability.extra.xmult_mod,
            localize{type = 'name_text', set = 'Enhanced', key = card.ability.extra.curr_key},
            card.ability.extra.xmult
        }
    }
end

call.calculate = function(self, card, context)
    if context.cardarea == G.play then
        if context.individual and context.other_card == context.scoring_hand[#context.scoring_hand] and not context.blueprint then

            local cards_affected = {}

            for _, _card in ipairs(context.full_hand) do
                for _, s in ipairs(context.scoring_hand) do
                    if s == _card then goto continue2 end
                end
                if _card.debuff then goto continue2 end

                if SMODS.get_enhancements(_card, false)[card.ability.extra.curr_key] then
                    card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
                    cards_affected[#cards_affected+1] = _card
                end
                ::continue2::
            end

            if #cards_affected > 0 then
                return {extra = {func = function()
                    for i=1, #cards_affected do
                        G.E_MANAGER:add_event(Event({func = function() 
                            card_eval_status_text(card, 'extra', card.ability.extra, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.MULT, instant = true})
                            card:juice_up()
                            cards_affected[i]:juice_up()
                            return true end })) 
                        delay(0.8)
                    end
                end}}
            end
        end
    end
    if context.after and context.cardarea == G.jokers and not context.blueprint then
        local temp = G.P_CENTER_POOLS["Enhanced"]
        if temp['m_stone'] then temp['m_stone'] = nil end
        card.ability.extra.curr_key = pseudorandom_element(temp, pseudoseed('flc_call_random')).key
        return {
            message = localize('k_reset')
        }
    end
    if context.joker_main and card.ability.extra.xmult > 1 then
        return {
            message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.xmult}},
            Xmult_mod = card.ability.extra.xmult
        }
    end
end
    
-------- end the call --------

-- stack of pennies -- 

local pennies = SMODS.Joker({
	key = "pennies",
    config = {extra = {progress = 0, treshold = 3, amt = 3}},
	pos = {x = 5, y = 2},
	loc_txt = { 
        name = 'Stack of Pennies',
        text = {
	"After {C:attention}#1#{} {C:inactive}[#2#]{} rounds, sell",
    "this Joker to add a {C:money}Gold Seal{}",
    "to {C:attention}#3#{} random cards in hand",
    "{C:inactive,s:0.8}Concept, Art: ABuffZucchini"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = true,
	atlas = "j_flc_jokers",
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_SEALS.Gold
        return {
            vars = {
                card.ability.extra.treshold,
                card.ability.extra.treshold - card.ability.extra.progress,
                card.ability.extra.amt
            }
        }
    end,
    calculate = function(self, card, context)
        if context.blueprint then return end
        if context.end_of_round and context.cardarea == G.jokers then
            card.ability.extra.progress = card.ability.extra.progress + 1
            if card.ability.extra.progress == card.ability.extra.treshold then 
                local eval = function(_card) return not _card.REMOVED end
                juice_card_until(card, eval, true)
            end
            return {
                message = (card.ability.extra.progress < card.ability.extra.treshold) and (card.ability.extra.progress..'/'..card.ability.extra.treshold) or localize('k_active_ex'),
            }
        end

        if context.selling_self and card.ability.extra.progress == card.ability.extra.treshold then
            if G.hand and G.hand.cards then
                return {
                    focus = card,
                    func = function()
                        local affected = {}
                        local temp_hand = {}
                        for k, v in ipairs(G.hand.cards) do temp_hand[#temp_hand+1] = v end
                        table.sort(temp_hand, function (a, b) return not a.playing_card or not b.playing_card or a.playing_card < b.playing_card end)
                        pseudoshuffle(temp_hand, pseudoseed('flc_pennies'))

                        for i = 1, card.ability.extra.amt do affected[#affected+1] = temp_hand[i] end

                        for i=#affected, 1, -1 do
                            local __card = affected[i]
                            __card:set_seal('Gold', false, true)
                            __card:juice_up()
                        end
                    end
                }
            end
        end
    end
})

-------- end stack of pennies --------

-- evidence envelope -- 

local envelope = SMODS.Joker({
	key = "envelope",
    config = {extra = {rank = 'Ace', id = 14, suit = 'Spades', hand = 'High Card', destroy_these_mfs = {}}},
	pos = {x = 6, y = 2},
	loc_txt = { 
        name = 'Evidence Envelope',
        text = {
	"If played hand has a {C:attention}#1#{}",
    "of {V:1}#2#{} in a {C:attention}#3#{},",
    "destroy all other played cards",
    "{s:0.8}Rank, Suit and Poker Hand changes each round",
    "{C:inactive,s:0.8}Concept, Art: tobyaaa"
        }
    },
	rarity = 2,
	cost = 7,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

envelope.loc_vars = function(self, info_queue, card)
    return {
        vars = {
            localize(card.ability.extra.rank, 'ranks'),
            localize(card.ability.extra.suit, 'suits_plural'),
            localize(card.ability.extra.hand, 'poker_hands'),
            colours = {
                G.C.SUITS[card.ability.extra.suit]
            }
        }
    }
end

local reset_envelope = function(card)
    card.ability.extra.rank = 'Ace'
    card.ability.extra.suit = 'Spades'
    card.ability.extra.hand = 'High Card'
    if not G.playing_cards then return end
    local valid_envelope_cards = {}
    for k, v in ipairs(G.playing_cards) do
        if v.ability.effect ~= 'Stone Card' then
            valid_envelope_cards[#valid_envelope_cards+1] = v
        end
    end
    if valid_envelope_cards[1] then 
        local envelope_card = pseudorandom_element(valid_envelope_cards, pseudoseed('flc_envelope_card'..G.GAME.round_resets.ante))
        card.ability.extra.rank = envelope_card.base.value
        card.ability.extra.suit = envelope_card.base.suit
        card.ability.extra.id = envelope_card.base.id
    end
    local _poker_hands = {}
    for k, v in pairs(G.GAME.hands) do
        if v.visible and k ~= card.ability.extra.hand then _poker_hands[#_poker_hands+1] = k end
    end
    card.ability.extra.hand = pseudorandom_element(_poker_hands, pseudoseed('flc_envelope_hand'))
    return {
        message = localize('k_reset')
    }
end

envelope.set_ability = function(self, card)
    reset_envelope(card)
end

envelope.calculate = function(self, card, context)
    if context.blueprint then return end
    if context.before and context.cardarea == G.play then
        card.ability.extra.destroy_these_mfs = {}
    end

    if context.individual and context.cardarea == G.play and context.other_card == context.scoring_hand[1] and context.scoring_name == card.ability.extra.hand then
        local found_it = {}
        for i=1, #context.full_hand do
            if context.full_hand[i]:get_id() == card.ability.extra.id and context.full_hand[i]:is_suit(card.ability.extra.suit) then
                found_it[#found_it+1] = context.full_hand[i]
            end
        end
        if #found_it > 0 then
            for i=1, #context.full_hand do
                if not (context.full_hand[i]:get_id() == card.ability.extra.id and context.full_hand[i]:is_suit(card.ability.extra.suit)) then
                    card.ability.extra.destroy_these_mfs[#card.ability.extra.destroy_these_mfs+1] = context.full_hand[i]
                    context.full_hand[i].destroyed = true
                end
            end
        end
    end

    if context.final_scoring_step then
        if #card.ability.extra.destroy_these_mfs > 0 then
            return {message = 'Destroy!', extra = {
                func = function()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        func = (function()
                            for i=1, #card.ability.extra.destroy_these_mfs do 
                                if card.ability.extra.destroy_these_mfs[i].ability.name == 'Glass Card' then 
                                    card.ability.extra.destroy_these_mfs[i]:shatter()
                                else
                                    card.ability.extra.destroy_these_mfs[i]:start_dissolve(nil, i == #card.ability.extra.destroy_these_mfs)
                                end
                                card.ability.extra.destroy_these_mfs[i]:remove_from_deck(false)
                                card.ability.extra.destroy_these_mfs[i].destroyed = true
                            end
                            for i = 1, #G.jokers.cards do
                                G.jokers.cards[i]:calculate_joker({remove_playing_cards = true, removed = card.ability.extra.destroy_these_mfs})
                            end
                            card.ability.extra.destroy_these_mfs = {}
                            return true
                        end)}))
                end}
            }
        end
    end

    if context.end_of_round and context.cardarea == G.jokers then
        return reset_envelope(card)
    end
end

-------- end evidence envelope --------

-- unordered set -- 

local unordered = SMODS.Joker({
	key = "unordered",
    config = {extra = 3},
	pos = {x = 2, y = 3},
	loc_txt = { 
        name = 'Unordered Set',
        text = {
	"Cards held in hand give {C:mult}+#1#{} Mult",
    "if none of their neighbors",
    "contain consecutive values",
    "{C:inactive,s:0.8}Concept: zeodexic"
        }
    },
	rarity = 1,
	cost = 4,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

unordered.loc_vars = function(self, info_queue, card)
    return {
        vars = {
            card.ability.extra
        }
    }
end

unordered.calculate = function(self, card, context)
    if context.individual and context.cardarea == G.hand and not context.end_of_round and not context.other_card.debuff then
        local yep = true
        for i=1, #context.cardarea.cards do
            if context.cardarea.cards[i] == context.other_card then
                local this_rank, nxt, prev = context.other_card:get_id(), (context.other_card:get_id()-1 == 1) and 14 or (context.other_card:get_id()-1), (context.other_card:get_id()+1 == 15) and 2 or (context.other_card:get_id()+1)
                -- left
                if context.cardarea.cards[i-1] and (context.cardarea.cards[i-1]:get_id() == nxt or context.cardarea.cards[i-1]:get_id() == prev) then
                    yep = false
                end
                -- right
                if context.cardarea.cards[i+1] and (context.cardarea.cards[i+1]:get_id() == nxt or context.cardarea.cards[i+1]:get_id() == prev) then
                    yep = false
                end
            end
        end
        if yep then
            return {mult = card.ability.extra}
        end
    end
end

-------- end unordered set --------

-- coconut -- 

local coconut = SMODS.Joker({
	key = "coconut",
    config = {extra = {chips = 40, chip_mod = 2}},
	pos = {x = 5, y = 3},
	loc_txt = { 
        name = 'Coconut',
        text = {
	"Scored cards permanently",
    "gain {C:chips}+#1#{} chips, decreases",
    "by {C:attention}#2#{} per card scored",
    "{C:inactive,s:0.8}Concept: ABuffZucchini; Art: dewdrop"
        }
    },
	rarity = 1,
	cost = 4,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = false,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

coconut.loc_vars = function(self, info_queue, card)
    return {
        vars = {
            card.ability.extra.chips,
            card.ability.extra.chip_mod
        }
    }
end

coconut.calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play then
        card.ability.extra.chips = math.max(card.ability.extra.chips - card.ability.extra.chip_mod, 0)
        context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
        context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra.chips
        return {
            message = localize('k_upgrade_ex'), 
            colour = G.C.CHIPS,
            card = context.other_card,
            extra = card.ability.extra.chips > 0 and {
                focus = card,
                message = localize{type='variable',key='a_chips_minus',vars={card.ability.extra.chip_mod}},
                colour = G.C.CHIPS,
            } or nil,
        }
    end

    if context.after and not context.blueprint then

        if card.ability.extra.chips <= 0 then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                        func = function()
                                G.jokers:remove_card(card)
                                card:remove()
                                card = nil
                            return true; end})) 
                    return true
                end
            })) 
            return {
                message = localize('k_eaten_ex')
            }
        end
    end
end

-------- end coconut --------

-- drill -- 

local drill = SMODS.Joker({
	key = "drill",
    config = {extra = {2, 3, 4}},
	pos = {x = 4, y = 3},
	loc_txt = { 
        name = 'Drill',
        text = {
	"{C:green}#1# in #2#{}, {C:green}#1# in #3#{} and {C:green}#1# in #4#{} chance",
    "for stone cards to retrigger",
    "{C:inactive,s:0.8} Concept, Art: ABuffZucchini"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

drill.in_pool = function(self, args)
    if G.deck and G.deck.cards then
        for j = 1, #G.deck.cards do
            if SMODS.get_enhancements(G.deck.cards[j])['m_stone'] then
                return true
            end
        end
    end
end


drill.loc_vars = function(self, info_queue, card)
    return {
        vars = {
            ''..(G.GAME and G.GAME.probabilities.normal or 1), 
            card.ability.extra[1],
            card.ability.extra[2],
            card.ability.extra[3]
        }
    }
end

drill.calculate = function(self, card, context)
    if context.repetition then
        if SMODS.get_enhancements(context.other_card, false)['m_stone'] then

            local reps = 0

            if pseudorandom('flc_drill_1') < G.GAME.probabilities.normal/card.ability.extra[1] then
                reps = reps + 1
            end

            if pseudorandom('flc_drill_2') < G.GAME.probabilities.normal/card.ability.extra[2] then
                reps = reps + 1
            end

            if pseudorandom('flc_drill_3') < G.GAME.probabilities.normal/card.ability.extra[3] then
                reps = reps + 1
            end

            if reps > 0 then
                return {
                    message = localize('k_again_ex'),
                    repetitions = reps,
                    card = card
                }
            end
        end
    end
end

-------- end drill --------

-- kanban board -- 

flc_kanban_task_table = {
    'booster', 
    'discard_pair', 
    'discard_flush', 
    'reroll', 
    'skip_booster', 
    'play_h', 
    'play_c', 
    'play_s', 
    'play_d', 
    'buy_joker', 
    'buy_tarot', 
    'buy_planet', 
    'use_tarot', 
    'use_planet', 
    'add_card', 
    'destroy_card', 
    'enhance', 
    'seal', 
    'sell_consumable', 
    'contain_pair', 
    'contain_flush',
    'skip_blind', 
    'play_one_ace', 
    'play_one_face', 
    'play_one_number', 
    'sell_joker'
}

flc_kanban_task_table_desc = {
    booster = 'open a Booster Pack', --done
    discard_pair = 'discard a Pair', --done
    discard_flush = 'discard a Flush', --done
    reroll = 'reroll the Shop', --done
    skip_booster = 'skip a Booster Pack', --done
    play_h = 'play Heart cards', --done
    play_c = 'play Club cards', --done
    play_s = 'play Spade cards', --done
    play_d = 'play Diamond cards', --done
    buy_joker = 'buy a Joker card', --done
    buy_tarot = 'buy a Tarot card', --done
    buy_planet = 'buy a Planet card', --done
    use_tarot = 'use a Tarot card', --done
    use_planet = 'use a Planet card', --done
    add_card = 'add a playing card', --done
    destroy_card = 'destroy playing cards', --done
    enhance = 'enhance a card', --done
    seal = 'add a Seal to a card',
    sell_consumable = 'sell a consumable card', --done
    contain_pair = 'play a hand containing a Pair', --done
    contain_flush = 'play a hand containing a Flush', --done
    skip_blind = 'skip a Blind', -- done
    play_one_ace = 'play a single Ace', --done
    play_one_face = 'play a single face card', --done
    play_one_number = 'play a single numbered card', --done
    sell_joker = 'sell a Joker card' --done
}

local reset_kanban = function(card)
    local temp = {}
    for i=1, #flc_kanban_task_table do
        temp[#temp+1] = flc_kanban_task_table[i]
    end
    local rnd = math.floor(pseudorandom(pseudoseed('flc_kanban_task1')) * #temp) + 1
    card.ability.extra.task_do = temp[rnd]
    table.remove(temp, rnd)
    rnd = math.floor(pseudorandom(pseudoseed('flc_kanban_task2')) * #temp) + 1
    card.ability.extra.task_dont = temp[rnd]
end

local kanban = SMODS.Joker({
	key = "kanban",
    config = {extra = {xmult = 1, xmult_mod = 0.25, xmult_reduction = 0.1, task_do = 'booster', task_dont = 'discard'}},
	pos = {x = 3, y = 3},
	loc_txt = { 
        name = 'Kanban Board',
        text = {
	"This Joker gains {X:mult,C:white}X#1#{} Mult when you",
    "{C:attention}#2#{}, and loses {X:mult,C:white}X#3#{} Mult",
    "when you {C:attention}#4#{}",
    "{C:inactive,s:0.8}(Currently {X:mult,C:white,s:0.8}X#5#{C:inactive,s:0.8} Mult, actions change every round)",
        }
    },
	rarity = 3,
	cost = 8,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

kanban.set_ability = function(self, card)
    reset_kanban(card)
end

kanban.loc_vars = function(self, info_queue, card)
    return {
        vars = {
            card.ability.extra.xmult_mod,
            flc_kanban_task_table_desc[card.ability.extra.task_do],
            card.ability.extra.xmult_reduction,
            flc_kanban_task_table_desc[card.ability.extra.task_dont],
            card.ability.extra.xmult
        }
    }
end

kanban.calculate = function(self, card, context) -- i'm scared.

    local prev = card.ability.extra.mult

    if context.joker_main then
        return {
            x_mult = card.ability.extra.xmult
        }
    end
    if context.blueprint then return end

    local extra = 0

    if context.open_booster then
        if card.ability.extra.task_do == 'booster' then
            extra = extra + card.ability.extra.xmult_mod
        end
        if card.ability.extra.task_dont == 'booster' then
            extra = extra - card.ability.extra.xmult_reduction
        end
        card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
        if prev == card.ability.extra.xmult or extra == 0 then return end
        return {
            message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
        }
    end

    if context.skipping_booster then
        if card.ability.extra.task_do == 'skip_booster' then
            extra = extra + card.ability.extra.xmult_mod
        end
        if card.ability.extra.task_dont == 'skip_booster' then
            extra = extra - card.ability.extra.xmult_reduction
        end
        card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
        if prev == card.ability.extra.xmult or extra == 0 then return end
        return {
            message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
        }
    end

    if context.pre_discard then
        if G.FUNCS.get_poker_hand_info(G.hand.highlighted) == 'Pair' then
            if card.ability.extra.task_do == 'discard_pair' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'discard_pair' then
                extra = extra - card.ability.extra.xmult_reduction
            end
            card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
            if prev == card.ability.extra.xmult or extra == 0 then return end
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
            }
        end
        if G.FUNCS.get_poker_hand_info(G.hand.highlighted) == 'Flush' then
            if card.ability.extra.task_do == 'discard_flush' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'discard_flush' then
                extra = extra - card.ability.extra.xmult_reduction
            end
            card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
            if prev == card.ability.extra.xmult or extra == 0 then return end
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
            }
        end
    end

    if context.reroll_shop then
        if card.ability.extra.task_do == 'reroll' then
            extra = extra + card.ability.extra.xmult_mod
        end
        if card.ability.extra.task_dont == 'reroll' then
            extra = extra - card.ability.extra.xmult_reduction
        end
        card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
        if prev == card.ability.extra.xmult or extra == 0 then return end

        G.E_MANAGER:add_event(Event({
            func = (function()
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.xmult}}, colour = G.C.MULT})
            return true
        end)}))
    end

    if context.using_consumeable then
        if context.consumeable.ability.set == 'Planet' then
            if card.ability.extra.task_do == 'use_planet' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'use_planet' then
                extra = extra - card.ability.extra.xmult_reduction
            end
            card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
            if prev == card.ability.extra.xmult or extra == 0 then return end
            G.E_MANAGER:add_event(Event({
                func = function() card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}}); return true
                end}))
            return
        elseif context.consumeable.ability.set == 'Tarot' then
            if card.ability.extra.task_do == 'use_tarot' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'use_tarot' then
                extra = extra - card.ability.extra.xmult_reduction
            end
            card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
            if prev == card.ability.extra.xmult or extra == 0 then return end
            G.E_MANAGER:add_event(Event({
                func = function() card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}}); return true
                end}))
            return
        end
    end

    if context.playing_card_added and not card.getting_sliced then
        if card.ability.extra.task_do == 'add_card' then
            extra = extra + card.ability.extra.xmult_mod
        end
        if card.ability.extra.task_dont == 'add_card' then
            extra = extra - card.ability.extra.xmult_reduction
        end
        card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
        if prev == card.ability.extra.xmult or extra == 0 then return end
        return {
            message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
        }
    end

    if context.remove_playing_cards then
        if card.ability.extra.task_do == 'destroy_card' then
            extra = extra + card.ability.extra.xmult_mod

            if prev == card.ability.extra.xmult or extra == 0 then return end
        end
        if card.ability.extra.task_dont == 'destroy_card' then
            extra = extra - card.ability.extra.xmult_reduction

            if prev == card.ability.extra.xmult or extra == 0 then return end
        end
        card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)

        return {
            message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
        }
    end

    if context.selling_card then
        if context.card.ability.set == 'Joker' then
            if card.ability.extra.task_do == 'sell_joker' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'sell_joker' then
                extra = extra - card.ability.extra.xmult_reduction
            end
            card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
            if prev == card.ability.extra.xmult or extra == 0 then return end
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
            }
        else
            if card.ability.extra.task_do == 'sell_consumable' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'sell_consumable' then
                extra = extra - card.ability.extra.xmult_reduction
            end
            card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
            if prev == card.ability.extra.xmult or extra == 0 then return end
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
            }
        end
    end

    if context.before then
        if next(context.poker_hands['Pair']) then
            if card.ability.extra.task_do == 'contain_pair' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'contain_pair' then
                extra = extra - card.ability.extra.xmult_reduction
            end
        end

        if next(context.poker_hands['Flush']) then
            if card.ability.extra.task_do == 'contain_flush' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'contain_flush' then
                extra = extra - card.ability.extra.xmult_reduction
            end
        end

        if #context.full_hand == 1 then
            if context.full_hand[1]:get_id() == 14 then
                if card.ability.extra.task_do == 'play_one_ace' then
                    extra = extra + card.ability.extra.xmult_mod
                end
                if card.ability.extra.task_dont == 'play_one_ace' then
                    extra = extra - card.ability.extra.xmult_reduction
                end
            elseif context.full_hand[1]:is_face() then
                if card.ability.extra.task_do == 'play_one_face' then
                    extra = extra + card.ability.extra.xmult_mod
                end
                if card.ability.extra.task_dont == 'play_one_face' then
                    extra = extra - card.ability.extra.xmult_reduction
                end
            else
                if card.ability.extra.task_do == 'play_one_number' then
                    extra = extra + card.ability.extra.xmult_mod
                end
                if card.ability.extra.task_dont == 'play_one_number' then
                    extra = extra - card.ability.extra.xmult_reduction
                end
            end
        end

        local has_heart, has_club, has_spade, has_diamond = false, false, false, false
        for i=1, #context.full_hand do
            if context.full_hand[i]:is_suit('Hearts') then has_heart = true end
            if context.full_hand[i]:is_suit('Clubs') then has_club = true end
            if context.full_hand[i]:is_suit('Spades') then has_spade = true end
            if context.full_hand[i]:is_suit('Diamonds') then has_diamond = true end
        end

        if has_heart then
            if card.ability.extra.task_do == 'play_h' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'play_h' then
                extra = extra - card.ability.extra.xmult_reduction
            end
        end

        if has_club then
            if card.ability.extra.task_do == 'play_c' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'play_c' then
                extra = extra - card.ability.extra.xmult_reduction
            end
        end

        if has_spade then
            if card.ability.extra.task_do == 'play_s' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'play_s' then
                extra = extra - card.ability.extra.xmult_reduction
            end
        end

        if has_diamond then
            if card.ability.extra.task_do == 'play_d' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'play_d' then
                extra = extra - card.ability.extra.xmult_reduction
            end
        end

        card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
        if prev == card.ability.extra.xmult or extra == 0 then return end
        return {
            message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
        }
    end
    if context.skip_blind then
        if card.ability.extra.task_do == 'skip_blind' then
            extra = extra + card.ability.extra.xmult_mod
        end
        if card.ability.extra.task_dont == 'skip_blind' then
            extra = extra - card.ability.extra.xmult_reduction
        end
        card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
        if prev == card.ability.extra.xmult or extra == 0 then return end
        return {
            message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
        }
    end

    if context.buying_card then
        if context.card.ability.set == 'Joker' then
            if card.ability.extra.task_do == 'buy_joker' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'buy_joker' then
                extra = extra - card.ability.extra.xmult_reduction
            end
            card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
            if prev == card.ability.extra.xmult or extra == 0 then return end
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
            }
        elseif context.card.ability.set == 'Tarot' then
            if card.ability.extra.task_do == 'buy_tarot' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'buy_tarot' then
                extra = extra - card.ability.extra.xmult_reduction
            end
            card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
            if prev == card.ability.extra.xmult or extra == 0 then return end
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
            }
        elseif context.card.ability.set == 'Planet' then
            if card.ability.extra.task_do == 'buy_planet' then
                extra = extra + card.ability.extra.xmult_mod
            end
            if card.ability.extra.task_dont == 'buy_planet' then
                extra = extra - card.ability.extra.xmult_reduction
            end
            card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
            if prev == card.ability.extra.xmult or extra == 0 then return end
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}
            }
        end
    end

    if context.enhancing_card then
        if card.ability.extra.task_do == 'enhance' then
            extra = extra + card.ability.extra.xmult_mod
        end
        if card.ability.extra.task_dont == 'enhance' then
            extra = extra - card.ability.extra.xmult_reduction
        end
        card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
        if prev == card.ability.extra.xmult or extra == 0 then return end
        G.E_MANAGER:add_event(Event({
            func = function() card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}}); return true
            end}))
        return
    end

    if context.sealing_card then
        if card.ability.extra.task_do == 'seal' then
            extra = extra + card.ability.extra.xmult_mod
        end
        if card.ability.extra.task_dont == 'seal' then
            extra = extra - card.ability.extra.xmult_reduction
        end
        card.ability.extra.xmult = math.max(1, card.ability.extra.xmult + extra)
        if prev == card.ability.extra.xmult or extra == 0 then return end
        G.E_MANAGER:add_event(Event({
            func = function() card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}}}); return true
            end}))
        return
    end

    if context.end_of_round and context.cardarea == G.jokers then
        reset_kanban(card)
        return {
            message = localize('k_reset')
        }
    end
end

local set_sealRef = Card.set_seal
Card.set_seal = function(self, _seal, silent, immediate)
    set_sealRef(self, _seal, silent, immediate)
    if _seal then
        if G.jokers and (self.area == G.hand or self.area == G.play or self.area == G.deck) then
            for i=1, #G.jokers.cards do
                G.jokers.cards[i]:calculate_joker({sealing_card = true, cardarea = G.jokers, card = self})
            end
        end
    end
end

-------- end kanban board --------

-- blindfolded joker -- 

local blindfold = SMODS.Joker({
	key = "blindfold",
    config = {extra = {chips = 0, chip_mod = 60}},
	pos = {x = 0, y = 3},
	loc_txt = { 
        name = 'Blindfolded Joker',
        text = {
	"{C:attention}Boss Blind{} is randomized",
    "when selected, gains {C:chips}+#1#{} Chips",
    "when {C:attention}Boss Blind{} is defeated",
    "{C:inactive}(Currently {C:chips}+#2#{}{C:inactive} Chips)",
    "{C:inactive,s:0.8} Concept, Art: ABuffZucchini"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

blindfold .loc_vars = function(self, info_queue, card)
    return {
        vars = {
            card.ability.extra.chip_mod,
            card.ability.extra.chips
        }
    }
end

blindfold.calculate = function(self, card, context)
    if context.joker_main and context.cardarea == G.jokers then
        if card.ability.extra.chips > 0 then
            return {chips = card.ability.extra.chips}
        end
    end

    if context.end_of_round and context.cardarea == G.jokers and G.GAME.blind.boss and not context.blueprint then
        card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
        return {
            message = localize('k_upgrade_ex'),
            card = card,
            colour = G.C.CHIPS
        }
    end
end

local set_blindRef = G.FUNCS.select_blind
G.FUNCS.select_blind = function(e)
    if e.config.ref_table.boss then
        for i=1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.key == 'j_femtoLabsCollection_blindfold' then
                e.config.ref_table = G.P_BLINDS[get_new_boss()]
                local name = e.config.ref_table.loc_txt and e.config.ref_table.loc_txt.default.name or e.config.ref_table.name
                card_eval_status_text(G.jokers.cards[i], 'extra', nil, nil, nil, {message = name..' Jumpscare!', colour = G.C.FILTER})
            end
        end
    end
    set_blindRef(e)
end

-------- end blindfolded joker --------

-- frostbite -- 

local frostbite = SMODS.Joker({
	key = "frostbite",
    config = {extra = 10},
	pos = {x = 6, y = 3},
	loc_txt = { 
        name = 'Frostbite',
        text = {
	"{C:attention}#1#s{} permanently gain",
    "{C:mult}+#2#{} Mult when scored"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

frostbite.loc_vars = function(self, info_queue, card)
    return {
        vars = {
            localize{type = 'name_text', set = 'Enhanced', key = 'm_femtoLabsCollection_ice_card'},
            card.ability.extra
        }
    }
end

frostbite.calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play then
        if SMODS.get_enhancements(context.other_card, false)['m_femtoLabsCollection_ice_card'] then
            local other_card = context.other_card
            return {
                extra = {focus = other_card, func = function()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.8,
                        func = (function()
                            other_card:juice_up()
                            card_eval_status_text(other_card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.RED, instant = true})
                            other_card.ability.perma_mult = other_card.ability.perma_mult or 0
                            other_card.ability.perma_mult = other_card.ability.perma_mult + card.ability.extra
                            return true
                        end)}))
                end},
                card = card,
            }
        end
    end
end

-------- end frostbite --------

-- frigid storm -- 

local frigid = SMODS.Joker({
	key = "frigid",
    config = {extra = 30},
	pos = {x = 0, y = 4},
	loc_txt = { 
        name = 'Frigid Storm',
        text = {
	"{C:chips}+#1#{} Chips for each",
    "{C:attention}#2#{} in deck",
    "{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips)"
        }
    },
	rarity = 1,
	cost = 4,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

frigid.in_pool = function(self, args)
    if G.deck and G.deck.cards then
        for j = 1, #G.deck.cards do
            if SMODS.get_enhancements(G.deck.cards[j])['m_femtoLabsCollection_ice_card'] then
                return true
            end
        end
    end
end

frigid.loc_vars = function(self, info_queue, card)
    local ice_tally = 0
    if G.playing_cards then
        for k, v in pairs(G.playing_cards) do
            if SMODS.get_enhancements(v, false)['m_femtoLabsCollection_ice_card'] then ice_tally = ice_tally+1 end
        end
    end
    return {
        vars = {
            card.ability.extra,
            localize{type = 'name_text', set = 'Enhanced', key = 'm_femtoLabsCollection_ice_card'},
            card.ability.extra * ice_tally,
        }
    }
end

frigid.calculate = function(self, card, context)
    if context.joker_main and context.cardarea == G.jokers and card.ability.extra > 0 then
        local ice_tally = 0
        for k, v in pairs(G.playing_cards) do
            if SMODS.get_enhancements(v, false)['m_femtoLabsCollection_ice_card'] then ice_tally = ice_tally+1 end
        end
        return {chips = card.ability.extra * ice_tally}
    end
end

-------- end frigid storm --------

-- frightened joker -- 

local frightened = SMODS.Joker({
	key = "frightened",
    config = {extra = {discards = 3}},
	pos = {x = 1, y = 3},
	loc_txt = { 
        name = 'Frightened Joker',
        text = {
	"{C:red}+#1#{} Discards, disabled",
    "during a {C:attention}Boss Blind",
    "{C:inactive,s:0.8} Concept, Art: ABuffZucchini"
        }
    },
	rarity = 1,
	cost = 4,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

frightened.loc_vars = function(self, info_queue, card)
    return {
        vars = {
            card.ability.extra.discards
        }
    }
end

frightened.add_to_deck = function(self, card, from_debuff)
    card:juice_up(0.1, 0.1)
    G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discards
    ease_discard(card.ability.extra.discards)
end

frightened.remove_from_deck = function(self, card, from_debuff)
    if from_debuff then
        card:juice_up()
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
            play_sound('tarot2', 0.76, 0.4);return true end}))
        play_sound('tarot2', 1, 0.4)
    end
    G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discards
    ease_discard(-card.ability.extra.discards)
end

frightened.calculate = function(self, card, context)
    if context.blueprint then return end
    if context.setting_blind and context.cardarea == G.jokers then
        if context.blind.boss and not card.debuff then
            card:set_debuff(true)
        end
    end

    if context.end_of_round and card.debuff and context.cardarea == G.jokers then
        card:set_debuff(false)
    end
end

-------- end frightened joker --------

-- paint splatter -- 

local splatter = SMODS.Joker({
	key = "splatter",
    config = {extra = {chips = 5, mult = 2}},
	pos = {x = 1, y = 4},
	loc_txt = { 
        name = 'Paint Splatter',
        text = {
	"{C:attention}Wild Cards{} permanently",
    "gain {C:mult}+#1#{} Mult and {C:chips}+#2#",
    "chips when held in hand"
        }
    },
	rarity = 3,
	cost = 8,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

splatter.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS['m_wild']
    return {
        vars = {
            card.ability.extra.mult,
            card.ability.extra.chips
        }
    }
end

splatter.calculate = function(self, card, context)
    if context.individual and context.cardarea == G.hand and not context.end_of_round then
        if SMODS.get_enhancements(context.other_card)['m_wild'] then
            context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
            context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra.chips
            context.other_card.ability.perma_mult = context.other_card.ability.perma_mult or 0
            context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + card.ability.extra.mult
            return {
                extra = {message = localize('k_upgrade_ex'), colour = G.C.FILTER},
                colour = G.C.FILTER,
                card = card
            }
        end
    end
end

-------- end splatter --------

-- snowflake -- 

local snowflake = SMODS.Joker({
	key = "snowflake",
    config = {extra = {rank = 'Ace'}},
	pos = {x = 4, y = 4},
	loc_txt = { 
        name = 'Snowflake',
        text = {
	"If played hand is a",
    "single {C:attention}#1#{}, turn it into",
    "an {C:attention}Ice Card{} after scoring",
    "{s:0.8}Rank changes every round",
    "{C:inactive,s:0.8}Concept: ABuffZucchini"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

snowflake.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS['m_femtoLabsCollection_ice_card']
    return {
        vars = {
            localize(card.ability.extra.rank, 'ranks'), 
        }
    }
end

snowflake.set_ability = function(self, card)
    card.ability.extra.rank = pseudorandom_element(SMODS.Ranks, pseudoseed('flc_snowflake')).key
end

snowflake.calculate = function(self, card, context)
    if context.blueprint then return end
    if context.cardarea == G.jokers and context.final_scoring_step and #context.full_hand == 1 and context.full_hand[1].base.value == card.ability.extra.rank and not SMODS.get_enhancements(context.full_hand[1])['m_femtoLabsCollection_ice_card'] then
        return {
            func = function()
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
                    play_sound('tarot1')
                    return true end }))
                local percent = 1.15 - (1-0.999)/(1-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() context.full_hand[1]:flip();play_sound('card1', percent);context.full_hand[1]:juice_up(0.3, 0.3);return true end }))
                delay(0.2)
                context.full_hand[1]:set_ability(G.P_CENTERS.m_femtoLabsCollection_ice_card, nil, true)
                context.full_hand[1].ability.extra.calm_the_fuck_down = true
                local percent = 0.85 + (1-0.999)/(1-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() context.full_hand[1]:flip();play_sound('tarot2', percent, 0.6);context.full_hand[1]:juice_up(0.3, 0.3);return true end }))
            end
        }
    end

    if context.end_of_round and context.cardarea == G.jokers then
        card.ability.extra.rank = pseudorandom_element(SMODS.Ranks, pseudoseed('flc_snowflake')).key
        return {
            message = localize('k_reset')
        }
    end
end

-------- end snowflake --------

-- elephant in the room -- 

local elephant = SMODS.Joker({
	key = "elephant",
    config = {},
	pos = {x = 6, y = 4},
	loc_txt = { 
        name = 'Elephant In The Room',
        text = {
	"Retrigger {C:attention}last{} playing card",
    "once per {C:attention}Ivory Card{} held in hand",
    "{C:inactive,s:0.8}Concept, Art: ABuffZucchini"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

elephant.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS['m_femtoLabsCollection_ivory_card']
end


elephant.calculate = function(self, card, context)
    if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[#context.scoring_hand] then
        local quant = 0
        for i=1, #G.hand.cards do
            if SMODS.get_enhancements(G.hand.cards[i])['m_femtoLabsCollection_ivory_card'] then quant = quant + 1 end
        end
        return {
            message = localize('k_again_ex'),
            repetitions = quant,
            card = card
        }
    end
end

-------- end elephant in the room --------

-- hidden amulet -- 

local amulet = SMODS.Joker({
	key = "amulet",
    config = {},
	pos = {x = 5, y = 4},
	loc_txt = { 
        name = 'Ancient Amulet',
        text = {
	"{C:attention}Ivory Cards{} always score",
    "and retrigger cards",
    "one additional time",
        }
    },
	rarity = 3,
	cost = 8,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

amulet.loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS['m_femtoLabsCollection_ivory_card']
end
always_scoresRef = SMODS.always_scores
SMODS.always_scores = function(card)
    local ret = always_scoresRef(card)
    if SMODS.get_enhancements(card)['m_femtoLabsCollection_ivory_card'] and next(SMODS.find_card('j_femtoLabsCollection_amulet')) then
        ret = true
    end
    return ret
end
-------- end hidden amulet --------

-- magic curtains -- 

local curtains = SMODS.Joker({
	key = "curtains",
    config = {extra = {prob_success = 6}},
	pos = {x = 0, y = 5},
	loc_txt = { 
        name = 'Magic Curtains',
        text = {
	"{C:green}#1# in #2#{} cards are drawn {C:attention}face down",
    "{C:attention}face down{} cards in hand gain a",
    "random {C:attention}Enhancement{} at the end of round",
    "{C:inactive,s:0.8}Concept, Art: ABuffZucchini"
        }
    },
	rarity = 3,
	cost = 8,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

curtains.loc_vars = function(self, info_queue, card)
    return {vars = {''..(G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.prob_success}}
end

curtains.calculate = function(self, card, context)
    if context.blueprint then return end
    if context.end_of_round and context.individual and context.cardarea == G.hand then
        if context.other_card.facing == 'back' then
            local other_card = context.other_card
            context.other_card:set_ability(pseudorandom_element(G.P_CENTER_POOLS.Enhanced, pseudoseed('flc_curtains')).key, true, false)
            context.other_card:flip()
        end
    end
    if context.end_of_round and context.cardarea == G.jokers then
        return {
            message = 'Ta-da!',
            colour = G.C.FILTER,
            card = card,
            func = function()
                delay(0.9)
            end
        }
    end
end

stay_flippedRef = Blind.stay_flipped

Blind.stay_flipped = function(self, area, card)
    local ret = stay_flippedRef(self, area, card)

    if not ret and area == G.hand then
        for _, v in ipairs(SMODS.find_card('j_femtoLabsCollection_curtains')) do
            if pseudorandom('flc_curtains_flip_question_mark') < G.GAME.probabilities.normal/v.ability.extra.prob_success then
                ret = true
                break
            end
        end
    end

    return ret
end

-------- end magic curtains --------

-- dawn -- 

local dawn = SMODS.Joker({
	key = "dawn",
    config = {extra = {min = 0.2, max = 0.4, lastchips = 0}},
	pos = {x = 1, y = 5},
	loc_txt = { 
        name = 'Dawn',
        text = {
	"If hand scores between {C:attention}#1#%{} and",
    "{C:attention}#2#%{} of blind requirement, create",
    "a {V:1}Twilight Card",
    "{C:inactive}(Must have room)",
    "{C:inactive,s:0.8}Concept, Art: ABuffZucchini"
        }
    },
	rarity = 3,
	cost = 8,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

dawn.loc_vars = function(self, info_queue, card)
    return {
        vars = {
            card.ability.extra.min * 100,
            card.ability.extra.max * 100,
            colours = {
                flc_twilight_colour
            }
        }
    }    
end

dawn.calculate = function(self, card, context)
    if context.setting_blind and context.cardarea == G.jokers then
        card.ability.extra.lastchips = 0
    end
    if context.after and context.cardarea == G.jokers then
        return {
            func = function()
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.0,
                    func = (function()
                        if ((G.GAME.chips - card.ability.extra.lastchips) >= (G.GAME.blind.chips * card.ability.extra.min)) and ((G.GAME.chips - card.ability.extra.lastchips) <= (G.GAME.blind.chips * card.ability.extra.max)) and (G.consumeables.config.card_limit - #G.consumeables.cards) > 0 then
                            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                            G.E_MANAGER:add_event(Event({
                                trigger = 'before',
                                delay = 0.4,
                                func = (function()
                                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = '+1 Twilight', colour = flc_twilight_colour, instant = true})
                                        local card = SMODS.create_card({
                                            set = 'm_femtoLabsCollection_twilight',
                                            key_append = 'flc_dawn'
                                        })
                                        card:add_to_deck()
                                        G.consumeables:emplace(card)
                                        G.GAME.consumeable_buffer = 0
                                    return true
                                end)}))
                        end
                        card.ability.extra.lastchips = G.GAME.chips
                        return true
                    end)}))
            end
        }
    end
end

dawn.draw = function(self, card, layer)
    if (layer == 'card' or layer == 'both') then
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
end

-------- end dawn --------

-- buff zucchini -- 

local zucchini = SMODS.Joker({
	key = "zucchini",
    config = {extra = {slots = 2, mod = 1}},
	pos = {x = 2, y = 5},
	loc_txt = { 
        name = 'Buff Zucchini',
        text = {
	"{C:attention}+#1#{} card#2# available in shop",
    "Reduces by {C:red}#3#{} at",
    "the end of round",
    "{C:inactive,s:0.8}Concept: ABuffZucchini"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

zucchini.loc_vars = function(self, info_queue, card)
    return {
        vars = {
            card.ability.extra.slots,
            card.ability.extra.slots == 1 and '' or 's',
            card.ability.extra.mod,
        }
    }    
end

zucchini.add_to_deck = function(self, card, from_debuff) 
    change_shop_size(card.ability.extra.slots)
end

zucchini.remove_from_deck = function(self, card, from_debuff) 
    change_shop_size(-card.ability.extra.slots)
end

zucchini.calculate = function(self, card, context)
    if context.end_of_round and context.cardarea == G.jokers then
        card.ability.extra.slots = card.ability.extra.slots - card.ability.extra.mod
        change_shop_size(-card.ability.extra.mod)
    
        if card.ability.extra.slots <= 0 then
    
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                        func = function()
                                G.jokers:remove_card(card)
                                card:remove()
                                card = nil
                            return true; end})) 
                    return true
                end
            })) 
    
            return {
                message = localize('k_eaten_ex')
            }
        else
            return {
                message = localize{type='variable',key='a_chips_minus',vars={card.ability.extra.mod}},
            }
        end
    end
end

-------- end buff zucchini --------

-- hostage joker -- 

local hostage = SMODS.Joker({
	key = "hostage",
    config = {},
	pos = {x = 3, y = 5},
	loc_txt = { 
        name = 'Hostage Joker',
        text = {
	"Cannot win {C:attention}Blind{}",
    "until {C:attention}0{} hands left",
    "{C:inactive,s:0.8}Concept, Art: vitellary"
        }
    },
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

hostage.loc_vars = function(self, info_queue, card)
end

hostage.calculate = function(self, card, context)
end

-------- end hostage joker --------

-- scraggly -- 

local scraglerarity = SMODS.Rarity({
    key = "scragle_rarity",
    loc_txt = {
        name = 'J"ok"er !?'
    },
    badge_colour = HEX('A06864'),
})

scraglerarity.gradient = function(self, dt)
    self.badge_colour[1] = 0.5+0.4*(1- math.sin(G.TIMERS.REAL*5.9))
end

local scraggly = SMODS.Joker({
	key = "scraggly",
    config = {},
	pos = {x = 2, y = 4},
    soul_pos = {x = 3, y = 4},
    display_size = {w = 142, h = 95},
	loc_txt = { 
        name = 'Scraggly',
        text = {
	'{X:money,C:black,s:2}:)'
        }
    },
	rarity = "femtoLabsCollection_scragle_rarity",
	cost = 914,
	discovered = false,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	atlas = "j_flc_jokers"
})

scraggly.calculate = function(self, card, context)
end



-------- end scraggly --------