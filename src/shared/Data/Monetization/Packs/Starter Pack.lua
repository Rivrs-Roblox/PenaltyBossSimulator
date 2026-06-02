local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Helpers = ReplicatedStorage.Shared.Helpers
local GetTableLength = require(Helpers.GetTableLength)

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")
local DataCacheService = Knit.GetService("DataCacheService")
local CharactersService = Knit.GetService("CharactersService")
local PetsService = Knit.GetService("PetsService")

return table.freeze({
	[3578761726] = {
		["Name"] = "Starter Pack",
		["BeforeCheck"] = function(self, userId)
			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			DataService:ChangeValue(Player, "Money2", 50_000, true)
			DataService:ChangeValue(Player, "Wins", 3_000, true)
			DataService:ChangeValue(Player, "Rebirth", 5, true)
			PetsService:AddPet(Player, "Fire Pony")

			CharactersService:Buy(Player, 35, true)
		end,
		["RestrictedRegionCanBuy"] = true,
	},
	[3600525897] = {
		["Name"] = "Pro Pack",
		["BeforeCheck"] = function(self, userId)
			local template = DataCacheService:GetFile("Template")
			local data = DataService:GetData(Players:GetPlayerByUserId(userId))
			if GetTableLength(data.Inventory.Pets) >= data.Inventory.Storage.Stored then
				return { status = false, message = template.Messages.Notifications.Not_Enough_Storage_Space }
			end

			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			DataService:ChangeValue(Players:GetPlayerByUserId(userId), "Money2", 250_000, true)
			DataService:ChangeValue(Players:GetPlayerByUserId(userId), "Wins", 8000, true)
			DataService:ChangeValue(Players:GetPlayerByUserId(userId), "Rebirth", 10, true)

			PetsService:AddPet(Players:GetPlayerByUserId(userId), "Cloud Whale")
		end,
		["RestrictedRegionCanBuy"] = true,
	},
	[3600526015] = {
		["Name"] = "Master Pack",
		["BeforeCheck"] = function(self, userId)
			local template = DataCacheService:GetFile("Template")
			local data = DataService:GetData(Players:GetPlayerByUserId(userId))
			if GetTableLength(data.Inventory.Pets) >= data.Inventory.Storage.Stored then
				return { status = false, message = template.Messages.Notifications.Not_Enough_Storage_Space }
			end

			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			DataService:ChangeValue(Players:GetPlayerByUserId(userId), "Money2", 1_000_000, true)
			DataService:ChangeValue(Players:GetPlayerByUserId(userId), "Wins", 20_000, true)
			DataService:ChangeValue(Players:GetPlayerByUserId(userId), "Rebirth", 20, true)

			PetsService:AddPet(Players:GetPlayerByUserId(userId), "Chinese Dragon")
		end,
		["RestrictedRegionCanBuy"] = true,
	},
})
