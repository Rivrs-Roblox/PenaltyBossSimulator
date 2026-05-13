local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Helpers = ReplicatedStorage.Shared.Helpers
local GetTableLength = require(Helpers.GetTableLength)

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")
local PetsService = Knit.GetService("PetsService")
local DataCacheService = Knit.GetService("DataCacheService")

return table.freeze({
	[3583693758] = {
		["Name"] = "Lunar Moth",
		["BeforeCheck"] = function(self, userId)
			local template = DataCacheService:GetFile("Template")
			local data = DataService:GetData(Players:GetPlayerByUserId(userId))
			if GetTableLength(data.Inventory.Pets) >= data.Inventory.Storage.Stored then
				return { status = false, message = template.Messages.Notifications.Not_Enough_Storage_Space }
			end

			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			PetsService:AddPet(Players:GetPlayerByUserId(userId), "Lunar Moth")
		end,
		["RestrictedRegionCanBuy"] = true,
	},
})
