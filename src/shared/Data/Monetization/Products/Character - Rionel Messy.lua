local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
--local DataCacheController = Knit.GetController("DataCacheController")
local DataService = Knit.GetService("DataService")
local CharactersService = Knit.GetService("CharactersService")

return table.freeze({
	[3575628514] = {
		["Name"] = "Character - Rionel Messy",
		["BeforeCheck"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			local data = DataService:GetData(Player)

			-- Vérifier si le joueur a déjà l'aura VIP
			for _, id in data.Characters.Unlocked do
				if id == 32 then -- ID de votre Nature Aura (VIP)
					return { status = false, message = "You already owned this character." }
				end
			end

			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			-- Donner l'aura VIP (Nature)
			CharactersService:Buy(Player, 32, true) -- ID 1 = Nature Aura
		end,
	},
})
