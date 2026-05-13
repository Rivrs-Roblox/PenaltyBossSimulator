local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberWithComma = require(ReplicatedStorage.Shared.Helpers.Numbers.NumberWithComma)

return table.freeze({
	Renews_In = "SOON",

	Pet_1 = {
		Name = "Lunar Moth",
		Icon = "Lunar Moth UI",
		Text = `x{NumberWithComma(8000)}`,
		Price = 290,
	},

	Pet_2 = {
		Name = "White Tiger",
		Icon = "White Tiger UI",
		Text = `x{NumberWithComma(17000)}`,
		Price = 450,
	},

	Pet_3 = {
		Name = "Demonic Paon",
		Icon = "Demonic Paon UI",
		Text = `x{NumberWithComma(30000)}`,
		Price = 760,
	},

	Pet_4 = {
		Name = "Golden Ram",
		Icon = "Golden Ram",
		Text = `x{NumberWithComma(870000)}`,
		Price = 1890,
	},

	Pet_5 = {
		Name = "Sun Lion",
		Icon = "Sun Lion",
		Text = `x{NumberWithComma(3250000)}`,
		Price = 2350,
	},
})
