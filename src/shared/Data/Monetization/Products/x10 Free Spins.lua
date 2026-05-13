local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")

return table.freeze({
    [3576023573] = {
        ["Name"] = "x10 Free Spins",
        ["BeforeCheck"] = function(self, userId)
            return { status = true, message = "" }
        end,
        ["Purchased"] = function(self, userId)
            local data = DataService:GetData(Players:GetPlayerByUserId(userId))
            data.Spins.Free += 10

            self.Client.UpdateData:Fire(Players:GetPlayerByUserId(userId), data)
        end,
        ["RestrictedRegionCanBuy"] = false,
    }
})