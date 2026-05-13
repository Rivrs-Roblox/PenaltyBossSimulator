local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberWithComma = require(ReplicatedStorage.Shared.Helpers.Numbers.NumberWithComma)

return table.freeze({
	Description = "Get a chance to win these exclusive pets!",

	Pets = {
		{ Name = "Lirili", Chance = 50, Icon = "Lirili", Text = `x{NumberWithComma(45)} Power`, Order = 1 },
		{
			Name = "Udindindun",
			Chance = 35,
			Icon = "Udindindun",
			Text = `x{NumberWithComma(75)} Power`,
			Order = 2,
		},
		{
			Name = "Patapim",
			Chance = 12,
			Icon = "Patapim",
			Text = `Always has 120% of your best pet\'s power`,
			Order = 3,
			Secret = true,
		},
		{
			Name = "Tralalero",
			Chance = 3,
			Icon = "Tralalero",
			Text = `Always has 200% of your best pet\'s power`,
			Order = 4,
			Secret = true,
		},
		{
			Name = "Tung Tung Sahur",
			Chance = 1,
			Icon = "Tung Tung Sahur",
			Text = `Always has 300% of your best pet\'s power`,
			Order = 5,
			Secret = true,
		},
	},
})
