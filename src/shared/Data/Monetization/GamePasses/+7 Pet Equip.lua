local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")

return table.freeze({
	[1820652779] = {
		["Name"] = "+7 Pet Equip",
		["Purchased"] = function(self, userId: number)
			local data = DataService:GetData(Players:GetPlayerByUserId(userId))
			data.Inventory.Storage.Equipped += 7

			self.Client.UpdateData:Fire(Players:GetPlayerByUserId(userId), data)
		end,
	},
})
