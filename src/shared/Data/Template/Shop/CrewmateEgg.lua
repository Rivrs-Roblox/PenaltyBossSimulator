local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberWithComma = require(ReplicatedStorage.Shared.Helpers.Numbers.NumberWithComma)

return table.freeze({
	Description = "Get a chance to win these exclusive pets!",

	Pets = {
		{
            Name = "Crewmate",
            Chance = 50,
            Icon = "Crewmate",
            Text = `x{NumberWithComma(414)} Power`,
            Order = 1 },
		{
			Name = "Ghostmate",
			Chance = 30,
			Icon = "Ghostmate",
			Text = `x{NumberWithComma(690)} Power`,
			Order = 2,
		},
		{
			Name = "Engineer",
			Chance = 15,
			Icon = "Engineer",
			Text = `x{NumberWithComma(1472)} Power`,
			Order = 3,
		},
		{
			Name = "Guardian",
			Chance = 4,
			Icon = "Guardian",
			Text = `x{NumberWithComma(3220)} Power`,
			Order = 4,
		},
		{
			Name = "Impostor",
			Chance = 1,
			Icon = "Impostor",
			Text = `x{NumberWithComma(4600)} Power`,
			Order = 5,
		},
	},
})
