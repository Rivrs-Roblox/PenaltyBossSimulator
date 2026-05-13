local Economy = require(script.Parent.Economy)

return table.freeze({
	["Rewards"] = {
		[1] = {
			Title = "+1000 " .. Economy.Money2,
			Icon = "Money2_NoStroke",
			Price = 1,

			RewardType = "Money2",
			Reward = 1000,
		},
		[2] = {
			Title = "+100 Wins",
			Icon = "Wins_NoStroke",
			Price = 5,

			RewardType = "Wins",
			Reward = 100,
		},
		[3] = {
			Title = "+10000 Wins",
			Icon = "Wins_NoStroke",
			Price = 10,

			RewardType = "Wins",
			Reward = 10000,
		},
	},
})
