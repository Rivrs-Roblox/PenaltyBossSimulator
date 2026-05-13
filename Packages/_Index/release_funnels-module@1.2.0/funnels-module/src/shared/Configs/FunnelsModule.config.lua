return table.freeze({
	["Onboarding"] = {
		First_Auto_On_Join = true,

		[1] = "Join the game",
		[2] = "Click 200 times",
		[3] = "Fight the first NPC",
		[4] = "Hatch an egg",
		[5] = "Completed tutorial",
	},

	["Progress"] = {
		[1] = {
			Tab_Name = "Progression",
			First_Auto_On_Join = true,

			[1] = "Join the game",
			[2] = "Completed first area",
			[3] = "Completed second area",
			[4] = "Completed third area",
			[5] = "Completed final area",
		},

		[2] = {
			Tab_Name = "Store",
			First_Auto_On_Join = false,

			[1] = "Open shop",
			[2] = "Click a item",
			[3] = "Item purchased",
		},
	},

	["Economy"] = {
		In_Game = {
			Coins = 0,
			Gems = 0,
		},

		Robux = {
			["100CoinsBundle"] = "Coins",
			["100GemsBundle"] = "Gems",
		},
	},
})
