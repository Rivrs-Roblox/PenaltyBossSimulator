local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
--local DataCacheController = Knit.GetController("DataCacheController")
local DataService = Knit.GetService("DataService")
local CoachesService = Knit.GetService("CoachesService")

return table.freeze({
	[3576056523] = {
		["Name"] = "Coach - Saar Alex Ferguyon",
		["BeforeCheck"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			local data = DataService:GetData(Player)

			-- Vérifier si le joueur a déjà l'aura VIP
			for _, id in data.Coaches.Unlocked do
				if id == 2 then -- ID de votre Nature Aura (VIP)
					return { status = false, message = "You already owned this coach." }
				end
			end

			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			-- Donner l'aura VIP (Nature)
			CoachesService:Buy(Player, 2, true) -- ID 1 = Nature Aura
		end,
	},
})
