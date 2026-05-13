local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")
local DailyRewardsService = Knit.GetService("DailyRewardsService")

return table.freeze({
	[3576015914] = {
		["Name"] = "Daily Rewards - Skip 1",
		["BeforeCheck"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			local data = DataService:GetData(Player)

			if data.LastRedeemedId == 7 then
				return { status = false, message = "You have already collected all daily rewards." }
			end

			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			local data = DataService:GetData(Player)

			DailyRewardsService:ClaimReward(Player, data.LastRedeemedId + 1, true)
		end,
		["RestrictedRegionCanBuy"] = true,
	},
})
