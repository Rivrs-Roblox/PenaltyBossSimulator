local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")

return table.freeze({
    [3576018594] = {
        ["Name"] = "Wins Pack - Regular",
        ["BeforeCheck"] = function(self, userId)
            return { status = true, message = "" }
        end,
        ["Purchased"] = function(self, userId)
            local Player = Players:GetPlayerByUserId(userId)
            local amount = DataService:GetWinsPackAmount(Player, "REGULAR")

            DataService:ChangeValue(Player, "Wins", amount, true)
        end,
        ["RestrictedRegionCanBuy"] = true,
    }
})