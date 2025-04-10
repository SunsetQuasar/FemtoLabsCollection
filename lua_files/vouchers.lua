local duskshopper = SMODS.Voucher({
    key = "duskshopper",
    loc_txt = {
        name = "Dusk Shopper",
        text = {
            "{V:1}Twilight{} cards may",
            "appear in the {C:attention}Shop"
        }
    },
    atlas = 'v_flc_vouchers', 
    pos = { x = 0, y = 0 },
    discovered = true
})

duskshopper.loc_vars = function(self, loc_vars, card)
    return {
        vars = {
            colours = {
                flc_twilight_colour
            }
        }
    }
end

duskshopper.redeem = function(self, card)
    G.GAME['m_femtolabscollection_twilight_rate'] = 2
end

local duskbooster = SMODS.Voucher({
    key = "duskbooster",
    loc_txt = {
        name = "Dusk Booster",
        text = {
            "{V:1}Nightfall Packs{} may contain",
            "{C:dark_edition}Negative {V:1}Twilight{} cards"
        }
    },
    atlas = 'v_flc_vouchers', 
    requires = {'v_femtoLabsCollection_duskshopper'},
    pos = { x = 1, y = 0 },
    discovered = true
})

duskbooster.loc_vars = function(self, loc_vars, card)
    return {
        vars = {
            colours = {
                flc_twilight_colour
            }
        }
    }
end

duskbooster.redeem = function(self, card)
    G.GAME['m_femtolabscollection_twilight_negatives'] = true
end