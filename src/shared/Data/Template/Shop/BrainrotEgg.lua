local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberWithComma = require(ReplicatedStorage.Shared.Helpers.Numbers.NumberWithComma)

return table.freeze({
	Description = "Get a chance to win these exclusive pets!",

	Pets = {
		{
            Name = "Ambalabu",
            Chance = 50,
            Icon = "Ambalabu",
            Text = `x{NumberWithComma(450)} Power`,
            Order = 1 },
		{
			Name = "Chimpanzini",
			Chance = 30,
			Icon = "Chimpanzini",
			Text = `x{NumberWithComma(750)} Power`,
			Order = 2,
		},
		{
			Name = "Saturno",
			Chance = 15,
			Icon = "Saturno",
			Text = `x{NumberWithComma(1600)} Power`,
			Order = 3,
		},
		{
			Name = "Assassino",
			Chance = 4,
			Icon = "Assassino",
			Text = `x{NumberWithComma(3500)} Power`,
			Order = 4,
		},
		{
			Name = "Bombombini",
			Chance = 1,
			Icon = "Bombombini",
			Text = `x{NumberWithComma(5000)} Power`,
			Order = 5,
		},
	},
})
