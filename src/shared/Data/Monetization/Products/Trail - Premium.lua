local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
--local DataCacheController = Knit.GetController("DataCacheController")
local DataService = Knit.GetService("DataService")
local TrailsService = Knit.GetService("TrailsService")

return table.freeze({
	[3576508095] = {
		["Name"] = "Trail - Premium",
		["BeforeCheck"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			local data = DataService:GetData(Player)

			-- Vérifier si le joueur a déjà l'aura VIP
			for _, id in data.Trails.Unlocked do
				if id == 1 then -- ID de votre Nature Trail (VIP)
					return { status = false, message = "You already owned this trail." }
				end
			end

			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			-- Donner l'aura VIP (Nature)
			TrailsService:Buy(Player, 1, true) -- ID 1 = Nature Trail
		end,
	},
})
