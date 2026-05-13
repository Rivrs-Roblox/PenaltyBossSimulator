local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local BoostService = Knit.GetService("BoostService")

return table.freeze({
	[3580550330] = {
		["Name"] = "Boost Bundle",
		["BeforeCheck"] = function(self, userId)
			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			-- BoostService:AddBoost(Players:GetPlayerByUserId(userId), "1", 10)
			BoostService:AddBoost(Players:GetPlayerByUserId(userId), "2", 10)
			BoostService:AddBoost(Players:GetPlayerByUserId(userId), "3", 10)
		end,
		["RestrictedRegionCanBuy"] = true,
	},
})
