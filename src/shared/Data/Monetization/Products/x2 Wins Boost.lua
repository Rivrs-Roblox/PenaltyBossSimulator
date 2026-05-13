local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local BoostService = Knit.GetService("BoostService")

return table.freeze({
	[3580550247] = {
		["Name"] = "x2 Wins Boost",
		["BeforeCheck"] = function(self, userId)
			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			BoostService:AddBoost(Players:GetPlayerByUserId(userId), "3", 1)
		end,
		["RestrictedRegionCanBuy"] = true,
	},
})
