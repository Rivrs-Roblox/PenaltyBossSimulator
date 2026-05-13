local Gamepasses = require(script.Gamepasses)
local OPPets = require(script.OPPets)
local Wins = require(script.Wins)
local Boosts = require(script.Boosts)
local StarterPacks = require(script.StarterPacks)
local ExclusiveChest = require(script.ExclusiveChest)
local BrainrotEgg = require(script.BrainrotEgg)
local CrewmateEgg = require(script.CrewmateEgg)
local Featured = require(script.Featured)

return table.freeze({
	Featured = table.clone(Featured),
	Starter_Bundle = {
		Price = 249,
	},
	Shop_Egg = {
		Name = "Dominus Egg",
		Price_1 = 149,
		Price_3 = 359,
		Price_8 = 829,
	},

	Gamepasses = table.clone(Gamepasses),
	OPPets = table.clone(OPPets),
	Wins = table.clone(Wins),
	Boosts = table.clone(Boosts),
	StarterPacks = table.clone(StarterPacks),
	ExclusiveChest = table.clone(ExclusiveChest),
	BrainrotEgg = table.clone(BrainrotEgg),
	CrewmateEgg = table.clone(CrewmateEgg),
})
