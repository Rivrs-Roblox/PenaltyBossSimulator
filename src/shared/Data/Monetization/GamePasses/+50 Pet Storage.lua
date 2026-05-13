local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")

return table.freeze({
	[1817696973] = {
		["Name"] = "+50 Pet Storage",
		["Purchased"] = function(self, userId: number)
			local data = DataService:GetData(Players:GetPlayerByUserId(userId))
			data.Inventory.Storage.Stored += 50

			self.Client.UpdateData:Fire(Players:GetPlayerByUserId(userId), data)
		end,
	},
})
