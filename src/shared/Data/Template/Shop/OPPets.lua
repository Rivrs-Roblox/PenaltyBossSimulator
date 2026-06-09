local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberWithComma = require(ReplicatedStorage.Shared.Helpers.Numbers.NumberWithComma)

return table.freeze({
	Renews_In = "SOON",

	Pet_1 = {
		Name = "Lunar Moth",
		Icon = "Lunar Moth UI",
		Text = "x18.9",
		Price = 149,
	},

	Pet_2 = {
		Name = "White Tiger",
		Icon = "White Tiger UI",
		Text = "x27.9",
		Price = 249,
	},

	Pet_3 = {
		Name = "Demonic Paon",
		Icon = "Demonic Paon UI",
		Text = "x65.1",
		Price = 399,
	},

	Pet_4 = {
		Name = "Golden Ram",
		Icon = "Golden Ram",
		Text = "x180.6",
		Price = 599,
	},

	Pet_5 = {
		Name = "Sun Lion",
		Icon = "Sun Lion",
		Text = `x{NumberWithComma(3250000)}`,
		Price = 2350,
	},
})
