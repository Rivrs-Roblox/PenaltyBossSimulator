local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")

return table.freeze({
	[1820790650] = {
		["Name"] = "+2 Pet Equip",
		["Purchased"] = function(self, userId: number)
			local data = DataService:GetData(Players:GetPlayerByUserId(userId))
			data.Inventory.Storage.Equipped += 2

			self.Client.UpdateData:Fire(Players:GetPlayerByUserId(userId), data)
		end,
	},
})
