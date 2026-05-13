local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Helpers = ReplicatedStorage.Shared.Helpers
local GetTableLength = require(Helpers.GetTableLength)

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")
local ExclusivePackService = Knit.GetService("ExclusivePackService")

return table.freeze({
	[3312373850] = {
		["Name"] = "Exclusive Pack - Tier 2",
		["BeforeCheck"] = function(self, userId)
			local data = DataService:GetData(Players:GetPlayerByUserId(userId))
			local exclusivePack = data.ExclusivePack
			if exclusivePack[6].Claimed == true then
				return { status = false, message = "You already claimed this item." }
			end

			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			ExclusivePackService:ClaimItem(Players:GetPlayerByUserId(userId), 6)
		end,
		["RestrictedRegionCanBuy"] = true,
	},
})
