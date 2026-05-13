local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")
local DailyRewardsService = Knit.GetService("DailyRewardsService")

return table.freeze({
	[3575999163] = {
		["Name"] = "Daily Rewards - Skip All",
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

			for i = (data.LastRedeemedId == 0 and 1 or data.LastRedeemedId), 7 do
				DailyRewardsService:ClaimReward(Player, i, true)
			end
		end,
		["RestrictedRegionCanBuy"] = true,
	},
})
