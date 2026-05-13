local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")

return table.freeze({
	[1819281901] = {
		["Name"] = "+4 Pet Equip",
		["Purchased"] = function(self, userId: number)
			local data = DataService:GetData(Players:GetPlayerByUserId(userId))
			data.Inventory.Storage.Equipped += 4

			self.Client.UpdateData:Fire(Players:GetPlayerByUserId(userId), data)
		end,
	},
})
