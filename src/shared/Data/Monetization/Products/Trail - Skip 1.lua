local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")
local TrailsService = Knit.GetService("TrailsService")

return table.freeze({
	[3576508298] = {
		["Name"] = "Trail - Skip 1",
		["BeforeCheck"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			local data = DataService:GetData(Player)
			local Template = require(script.Parent.Parent.Parent.Template)

			local totalTrails = 0
			for _, trail in pairs(Template.Trails) do
				if trail.VIP then
					continue
				else
					totalTrails += 1
				end
			end

			-- Vérifier si le joueur a déjà toutes les auras
			if #data.Trails.Unlocked == totalTrails then
				return { status = false, message = "You've already unlocked all non-VIP trails." }
			end

			return { status = true, message = "" }
		end,
		["Purchased"] = function(self, userId)
			local Player = Players:GetPlayerByUserId(userId)
			local data = DataService:GetData(Player)
			local Template = require(script.Parent.Parent.Parent.Template)

			-- Trouver le dernier ID non-VIP débloqué
			local lastRedeemed = 0
			for _, ID in data.Trails.Unlocked do
				if ID > lastRedeemed and not Template.Trails[ID].VIP then
					lastRedeemed = ID
				end
			end

			-- Trouver le prochain ID non-VIP disponible
			local nextId = lastRedeemed + 1
			while Template.Trails[nextId] do
				if not Template.Trails[nextId].VIP then
					break
				end
				nextId += 1
			end

			TrailsService:Buy(Player, nextId, true)
		end,
	},
})
