local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
--local DataCacheController = Knit.GetController("DataCacheController")
local DataService = Knit.GetService("DataService")
local CoachesService = Knit.GetService("CoachesService")

return table.freeze({
	[3576048915] = {
		["Name"] = "Coach - Jos Morningho",
		["BeforeCheck"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			local data = DataService:GetData(Player)

			-- Vérifier si le joueur a déjà l'aura VIP
			for _, id in data.Coaches.Unlocked do
				if id == 1 then -- ID de votre Nature Aura (VIP)
					return { status = false, message = "You already owned this coach." }
				end
			end

			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			-- Donner l'aura VIP (Nature)
			CoachesService:Buy(Player, 1, true) -- ID 1 = Nature Aura
		end,
	},
})
