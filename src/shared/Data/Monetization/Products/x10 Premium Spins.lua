local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")

return table.freeze({
    [3576023388] = {
        ["Name"] = "x10 Premium Spins",
        ["BeforeCheck"] = function(self, userId)
            return { status = true, message = "" }
        end,
        ["Purchased"] = function(self, userId)
            local data = DataService:GetData(Players:GetPlayerByUserId(userId))
            data.Spins.Premium += 10

            self.Client.UpdateData:Fire(Players:GetPlayerByUserId(userId), data)
        end,
        ["RestrictedRegionCanBuy"] = false,
    }
})