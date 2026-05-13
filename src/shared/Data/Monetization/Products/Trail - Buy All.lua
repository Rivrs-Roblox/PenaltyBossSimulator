local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
--local DataCacheController = Knit.GetController("DataCacheController")
local DataService = Knit.GetService("DataService")
local TrailsService = Knit.GetService("TrailsService")

return table.freeze({
	[3576507991] = {
		["Name"] = "Trail - Buy All",
		["BeforeCheck"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			local data = DataService:GetData(Player)
			local Template = require(script.Parent.Parent.Parent.Template)

			-- Compter le nombre total d'auras non-VIP
			local totalNonVIPTrails = 0
			local unlockedNonVIPTrails = 0

			for id, trail in pairs(Template.Trails) do
				if not trail.VIP then
					totalNonVIPTrails += 1
					if table.find(data.Trails.Unlocked, id) then
						unlockedNonVIPTrails += 1
					end
				end
			end

			-- Vérifier si le joueur a déjà toutes les auras non-VIP
			if unlockedNonVIPTrails >= totalNonVIPTrails then
				return { status = false, message = "You've already unlocked all non-VIP trails." }
			end

			return { status = true, message = "" }
		end,

		["Purchased"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			local Template = require(script.Parent.Parent.Parent.Template)

			-- Donner toutes les auras non-VIP
			for id, trail in pairs(Template.Trails) do
				if not trail.VIP then
					TrailsService:Buy(Player, id, true)
				end
			end
		end,
	},
})
