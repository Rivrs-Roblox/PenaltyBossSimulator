local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")

return table.freeze({
	[1819665805] = {
		["Name"] = "+25 Pet Storage",
		["Purchased"] = function(self, userId: number)
			local data = DataService:GetData(Players:GetPlayerByUserId(userId))
			data.Inventory.Storage.Stored += 25

			self.Client.UpdateData:Fire(Players:GetPlayerByUserId(userId), data)
		end,
	},
})
