
function flc_trigger_back_setting_blind_effect(blind) -- mod stupid games, make stupid hacks
	if G.GAME.selected_back.effect.config.volatile then

		for i=1, 5 do
			G.deck.config.card_limit = G.deck.config.card_limit - 1
			draw_card(G.deck,G.play, 20 * i,'up', nil)
		end

		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
			play_sound('tarot1')
			for i=1, #G.play.cards do
				local percent = 1.1 - (i-0.999)/(#G.play.cards-0.998)*0.3
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() G.play.cards[i]:flip();play_sound('card1', percent);G.play.cards[i]:juice_up(0.3, 0.3);return true end }))
			end
			delay(0.1)
			for i=1, #G.play.cards do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                    local card = G.play.cards[i]

					if pseudorandom('flc_go_my_enhancements') < 0.2 then
						card:set_ability(pseudorandom_element(G.P_CENTER_POOLS["Enhanced"], pseudoseed('flc_vol_enhpool')))
					else
						card:set_ability(G.P_CENTERS['c_base'])
					end

					local edition_rate = 1
					local edition = poll_edition('flc_deck_incedit'..G.GAME.round_resets.ante, edition_rate, true)
					card:set_edition(edition)
					local seal_rate = 4
					local seal_poll = pseudorandom(pseudoseed('flc_deck_incseal'..G.GAME.round_resets.ante))
					if seal_poll > 1 - 0.02*seal_rate then
						card:set_seal(pseudorandom_element(G.P_CENTER_POOLS['Seal'], pseudoseed('flc_vol_sealpool')).key)
					else
						card:set_seal(false)
					end

					--local rank_suffix = pseudorandom_element({'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'}, pseudoseed('flc_vol_rank'))

					local rank = pseudorandom_element(SMODS.Ranks, pseudoseed('flc_vol_rank')).key

					--local suit_prefix = pseudorandom_element({'S','H','D','C'}, pseudoseed('flc_vol_suit'))..'_'

					local suit = pseudorandom_element(SMODS.Suits, pseudoseed('flc_vol_rank')).key

					assert(SMODS.change_base(card, suit, rank))

                    --card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                return true end }))
            end  
			for i=1, #G.play.cards do
				local percent = 0.9 + (i-0.999)/(#G.play.cards-0.998)*0.3
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() G.play.cards[i]:flip();play_sound('tarot2', percent, 0.6);G.play.cards[i]:juice_up(0.3, 0.3);return true end }))
			end
			delay(1.4)
			for i=1, #G.play.cards do
				G.deck.config.card_limit = G.deck.config.card_limit + 1
				draw_card(G.play,G.deck, 20 * i,'up', nil)
			end
		return true end}))
	elseif G.GAME.selected_back.effect.config.hue and G.GAME.selected_back.effect.config.next_discards ~= 0 then
		G.GAME.blind.discards_sub = (G.GAME.blind.discards_sub or 0) - G.GAME.selected_back.effect.config.next_discards
		if G.deck and G.deck.cards[1] then G.deck.cards[1]:juice_up() end
		ease_discard(G.GAME.selected_back.effect.config.next_discards)
		G.GAME.selected_back.effect.config.next_discards = 0
	end
end

-- region volatile deck -----------------------

local volatiledeck = SMODS.Back({
    name = "Volatile Deck",
    key = "flc_volatile",
	config = {volatile = true},
	pos = {x = 1, y = 0},
	loc_txt = {
        name = "Volatile Deck",
        text = {
            "When {C:attention}Blind{} is selected,",
			"{C:attention}5 cards{} in the deck",
			"are {C:red}randomized{}"
        }
    },
    atlas= "b_flc_decks"
})

function volatile_apply(self)
	if self.effect.config.volatile then
		G.GAME.starting_params.flc_volatile = true
	end
end

-- endregion volatile deck-----------------------

-- region slate deck -----------------------

local slatedeck = SMODS.Back({
    name = "Slate Deck",
    key = "flc_slatedeck",
	config = {slate = true},
	pos = {x = 0, y = 0},
	loc_txt = {
        name = "Slate Deck",
        text = {
            "{C:attention}-2{} Joker slots",
			"Newly created cards may",
			"be {C:attention}Sealed {T:m_stone}Stone Cards"
        }
    },
    atlas= "b_flc_decks"
})
slatedeck.apply = function(self, back)
	G.GAME.starting_params.flc_slatedeck = true
	G.GAME.starting_params.joker_slots = 3
end

local createRef = SMODS.create_card

function SMODS.create_card(t)

	local ret = createRef(t)

	-- foil deck part

	if G.GAME.starting_params.flc_foildeck and ret.ability.set == 'Joker' then
		ret:set_edition({foil = true}, true)
	end

	-- slate deck

	if (t.set == 'Base' or t.set == 'Enhanced') and G.GAME.starting_params.flc_slatedeck then
		if pseudorandom('flc_slatedeck2') < 0.5 then
			local silent = not not ret.seal
			ret:set_ability(G.P_CENTERS['m_stone'])
			--ret:set_edition(nil, true)
			ret:set_seal(pseudorandom_element(G.P_CENTER_POOLS['Seal'], pseudoseed('flc_vol_sealpool')).key, silent)
		end
	end

	return ret
end

local copyRef = copy_card

function copy_card(other, new_card, card_scale, playing_card, strip_edition)
	local ret = copyRef(other, new_card, card_scale, playing_card, strip_edition)
	if G.GAME.starting_params.flc_foildeck and ret.ability.set == 'Joker' then
		ret:set_edition({foil = true}, not ret.edition)
	end
	if (other.ability.type == 'Base' or other.ability.type == 'Enhanced') and G.GAME.starting_params.flc_slatedeck then
		if pseudorandom('flc_slatedeck3') < 0.5 then
			local silent = not not ret.seal
			ret:set_ability(G.P_CENTERS['m_stone'])
			--ret:set_edition(nil, true)
			ret:set_seal(pseudorandom_element(G.P_CENTER_POOLS['Seal'], pseudoseed('flc_vol_sealpool')).key, silent)
		end
	end
	return ret
end

-- endregion slate deck-----------------------

-- region slate deck -----------------------

local spiraldeck = SMODS.Back({
    name = "Spiral Deck",
    key = "flc_spiraldeck",
	config = {spiral = true},
	pos = {x = 2, y = 0},
	loc_txt = {
        name = "Spiral Deck",
        text = {
            "{C:attention}Shop Rerolls{} refresh",
			"{C:attention}Booster Packs{} instead",
			"of the {C:attention}Card Shop{},",
			"but {C:attention}cost more"
        }
    },
    atlas= "b_flc_decks"
})

spiraldeck.apply = function(self, back)
	G.GAME.starting_params.flc_spiraldeck = true
	G.GAME.starting_params.reroll_cost = 8
end

local refreshRef = G.FUNCS.reroll_shop

G.FUNCS.reroll_shop = function(e)
	if G.GAME.starting_params.flc_spiraldeck then --run my own shit
		stop_use()
		G.CONTROLLER.locks.shop_reroll = true
		if G.CONTROLLER:save_cardarea_focus('shop_booster') then G.CONTROLLER.interrupt.focus = true end
		if G.GAME.current_round.reroll_cost > 0 then 
		  inc_career_stat('c_shop_dollars_spent', G.GAME.current_round.reroll_cost)
		  inc_career_stat('c_shop_rerolls', 1)
		  ease_dollars(-G.GAME.current_round.reroll_cost)
		end
		G.E_MANAGER:add_event(Event({
			trigger = 'immediate',
			func = function()
			  local final_free = G.GAME.current_round.free_rerolls > 0
			  G.GAME.current_round.free_rerolls = math.max(G.GAME.current_round.free_rerolls - 1, 0)
			  G.GAME.round_scores.times_rerolled.amt = G.GAME.round_scores.times_rerolled.amt + 1
	
			  --stupid hack to make the reroll scale twice as fast
			  calculate_reroll_cost(final_free)
			  calculate_reroll_cost(final_free)
			  for i = #G.shop_booster.cards,1, -1 do
				local c = G.shop_booster:remove_card(G.shop_booster.cards[i])
				c:remove()
				c = nil
			  end
	
			  --save_run()
	
			  play_sound('coin2')
			  play_sound('other1')
			  
			  for i = 1, 2 - #G.shop_booster.cards do

				G.GAME.current_round.used_packs = {}
				if not G.GAME.current_round.used_packs[i] then
					G.GAME.current_round.used_packs[i] = get_pack('shop_pack').key
				end

				local card = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
				G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.used_packs[i]], {bypass_discovery_center = true, bypass_discovery_ui = true})
				create_shop_card_ui(card, 'Booster', G.shop_booster)
				card.ability.booster_pos = i
				card:start_materialize()
				G.shop_booster:emplace(card)
				card:juice_up()
			  end
			  return true
			end
		  }))
		  G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.3,
			func = function()
			G.E_MANAGER:add_event(Event({
			  func = function()
				G.CONTROLLER.interrupt.focus = false
				G.CONTROLLER.locks.shop_reroll = false
				G.CONTROLLER:recall_cardarea_focus('shop_booster')
				for i = 1, #G.jokers.cards do
				  G.jokers.cards[i]:calculate_joker({reroll_shop = true})
				end
				return true
			  end
			}))
			return true
		  end
		}))
		G.E_MANAGER:add_event(Event({ func = function() save_run(); return true end}))
	else
		refreshRef(e) --otherwise run the actual function
	end
end

-- endregion volatile deck-----------------------

-- region foil deck -----------------------

local foildeck = SMODS.Back({
    name = "Foil Deck",
    key = "foil",
	config = {foild = true},
	pos = {x = 3, y = 0},
	loc_txt = {
        name = "Foil Deck",
        text = {
            "Every {C:attention}Joker{} is and",
			"can only be {C:dark_edition,T:e_foil}Foil{}",
			"{C:attention}-1{} Joker slot"
        }
    },
    atlas= "b_flc_decks"
})

foildeck.apply = function(self, back)
	G.GAME.starting_params.flc_foildeck = true
	G.GAME.starting_params.joker_slots = 4
end

editionRef = Card.set_edition

function Card.set_edition(self, edition, immediate, silent)

	if not G.GAME.starting_params.flc_foildeck then return editionRef(self, edition, immediate, silent) end

	local mod_edition = edition

	if self.ability.set == 'Joker' then mod_edition = {foil = true} end

	if not (self.edition and self.edition.foil) then editionRef(self, mod_edition, immediate, silent) end
end


-- endregion foil deck-----------------------

-- region hue deck -----------------------

local huedeck = SMODS.Back({
    name = "Hue Deck",
    key = "hue",
	config = {hue = true, next_discards = 0},
	pos = {x = 4, y = 0},
	loc_txt = {
        name = "Hue Deck",
        text = {
            "{C:attention}Skipping{} a blind gives",
			"{C:attention}+2{} discards next round"
        }
    },
    atlas= "b_flc_decks"
})

huedeck.apply = function(self, back)
	G.GAME.starting_params.flc_huedeck = true
end

local skipRef = G.FUNCS.skip_blind
G.FUNCS.skip_blind = function(e)
	skipRef(e)
	if G.GAME.selected_back.effect.config.hue and G.GAME.selected_back.effect.config.next_discards then
		G.GAME.selected_back.effect.config.next_discards = G.GAME.selected_back.effect.config.next_discards + 2
	end
end

-- endregion hue deck -----------------------

-- region pyrite deck -----------------------

local pyrite = SMODS.Back({
    name = "Pyrite Deck",
    key = "pyrite",
	config = {pyrite = true},
	pos = {x = 5, y = 0},
	loc_txt = {
        name = "Pyrite Deck",
        text = {
            "Starting cards are {C:attention,T:m_gold}Gold Cards{}",
			"Earn no {C:attention}Interest{}, hands",
			"lose {C:attention}$2{} per {C:attention}card played{} when",
			"played with more than {C:attention}$0"
        }
    },
    atlas= "b_flc_decks"
})

pyrite.apply = function(self, back)
	G.GAME.starting_params.flc_pyritedeck = true
	G.GAME.modifiers.no_interest = true
end

card_from_controlRef = card_from_control

function card_from_control(control)
	card_from_controlRef(control)
	if G.GAME.starting_params.flc_pyritedeck then
		for _, card in ipairs(G.playing_cards) do
			card:set_ability(G.P_CENTERS.m_gold, true, false)
		end
	end
end

press_playRef = Blind.press_play
function Blind.press_play(self)
	if G.GAME.starting_params.flc_pyritedeck then
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
			if G.GAME.dollars > 0 then
				for i = 1, #G.play.cards do
					G.E_MANAGER:add_event(Event({func = function() G.play.cards[i]:juice_up(); return true end })) 
					ease_dollars(-2)
					delay(0.23)
				end
			end
			return true end })) 
	end
	return press_playRef(self)
end

-- endregion pyrite deck -----------------------

-- region gradient deck -----------------------

local gradient = SMODS.Back({
    name = "Gradient Deck",
    key = "gradient",
	config = {gradient = true},
	pos = {x = 6, y = 0},
	loc_txt = {
        name = "Gradient Deck",
        text = {
            "All {C:attention}Booster Packs{} contain",
			"{C:attention}+1{} extra card",
        }
    },
    atlas= "b_flc_decks"
})

gradient.apply = function(self, back)
	G.GAME.starting_params.flc_gradientdeck = true
end

-- endregion gradient deck -----------------------

-- region mural deck -----------------------

local mural = SMODS.Back({
    name = "Mural Deck",
    key = "mural",
	config = {mural = true, voucher = 'v_femtoLabsCollection_duskshopper', consumables = {'c_femtoLabsCollection_presence'}},
	pos = {x = 0, y = 1},
	loc_txt = {
        name = "Mural Deck",
        text = {
            "Start with {C:attention,T:v_femtoLabsCollection_duskshopper}Homecoming{}",
 			"and a {C:attention,T:c_femtoLabsCollection_presence}Presence{} card",
        }
    },
    atlas= "b_flc_decks"
})


mural.apply = function(self, back)
	G.GAME.starting_params.flc_muraldeck = true
end

-- endregion mural deck -----------------------

sendDebugMessage("[FLC] Decks loaded")

----------------------------------------------
------------MOD CODE END----------------------