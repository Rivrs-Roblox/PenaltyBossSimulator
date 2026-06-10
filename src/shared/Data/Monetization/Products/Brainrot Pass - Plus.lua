local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")
local SeasonService = Knit.GetService("SeasonService")
local DataCacheService = Knit.GetService("DataCacheService")

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local GetTableLength = require(Helpers.GetTableLength)

return table.freeze({
	[3344933718] = {
		["Name"] = "Brainrot Pass - Plus",
		["BeforeCheck"] = function(self, userId)
			local template = DataCacheService:GetFile("Template")
			local data = DataService:GetData(Players:GetPlayerByUserId(userId))

			if data.Season.Plus then
				return { status = false, message = "You already have Brainrot Pass Plus." }
			elseif
				not data.Season.Premium and GetTableLength(data.Inventory.Pets) + 38 > data.Inventory.Storage.Stored
			then
				return { status = false, message = template.Messages.Notifications.Not_Enough_Storage_Space }
			elseif GetTableLength(data.Inventory.Pets) + 30 > data.Inventory.Storage.Stored then
				return { status = false, message = template.Messages.Notifications.Not_Enough_Storage_Space }
			end

			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			local template = DataCacheService:GetFile("Template")
			local player = Players:GetPlayerByUserId(userId)
			local data = DataService:GetData(player)

			data.Season.Level = 30
			SeasonService.Client.LevelUpdated:Fire(player, data.Season.Level)

			local targetExp = 0

			for i = 1, data.Season.Level do
				targetExp += template.SeasonPass[i]
			end

			data.Season.Exp = targetExp
			SeasonService.Client.ExpUpdated:Fire(player, data.Season.Exp)

			data.SeasonPassCompleted += 1

			if not data.Season.Premium then
				data.Season.Premium = true
				SeasonService.Client.PremiumUpdated:Fire(player, data.Season.Premium)

				--local _, pet = EggsService:Hatch(player, 8, "BrainrotEgg", {}, true)
				-- SeasonService.Client.EggHatched:Fire(player, pet, "BrainrotEgg")

				--PetsService:AddPet(player, "Chill Guy")
			end

			data.Season.Plus = true

			-- local _, pet = EggsService:Hatch(player, 8, "BrainrotEgg", {}, true)
			-- SeasonService.Client.EggHatched:Fire(player, pet, "BrainrotEgg")

			-- local _, pet = EggsService:Hatch(player, 8, "BrainrotEgg", {}, true)
			-- SeasonService.Client.EggHatched:Fire(player, pet, "BrainrotEgg")

			-- local _, pet = EggsService:Hatch(player, 8, "BrainrotEgg", {}, true)
			-- SeasonService.Client.EggHatched:Fire(player, pet, "BrainrotEgg")

			-- local _, pet = EggsService:Hatch(player, 3, "BrainrotEgg", {}, true)
			-- SeasonService.Client.EggHatched:Fire(player, pet, "BrainrotEgg")

			-- local _, pet = EggsService:Hatch(player, 3, "BrainrotEgg", {}, true)
			-- SeasonService.Client.EggHatched:Fire(player, pet, "BrainrotEgg")

			-- BodyService:Buy(player, 23, true)
			-- PetsService:AddPet(player, "Gold Chill Guy")
			-- DataService:GiveBadge(player, "BrainrotPassPlus")
		end,
		["RestrictedRegionCanBuy"] = true,
	},
})
