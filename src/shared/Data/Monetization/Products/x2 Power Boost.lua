local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local BoostService = Knit.GetService("BoostService")

return table.freeze({
	[3580550090] = {
		["Name"] = "x2 Power Boost",
		["BeforeCheck"] = function(self, userId)
			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			BoostService:AddBoost(Players:GetPlayerByUserId(userId), "2", 1)
		end,
		["RestrictedRegionCanBuy"] = true,
	},
})
