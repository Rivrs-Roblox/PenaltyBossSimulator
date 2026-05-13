local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")

return table.freeze({
    [986676901] = {
        ["Name"] = "Season Pass - Premium",
        ["Purchased"] = function(self, userId: number)

            local data = DataService:GetData(Players:GetPlayerByUserId(userId))

            self.Client.UpdateData:Fire(Players:GetPlayerByUserId(userId), data)
        end
    }
})