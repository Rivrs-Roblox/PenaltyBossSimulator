local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")

return table.freeze({
    [3576018413] = {
        ["Name"] = "Wins Pack - Small",
        ["BeforeCheck"] = function(self, userId)
            return { status = true, message = "" }
        end,
        ["Purchased"] = function(self, userId)
            local Player = Players:GetPlayerByUserId(userId)
            local amount = DataService:GetWinsPackAmount(Player, "SMALL")

            DataService:ChangeValue(Player, "Wins", amount, true)
        end,
        ["RestrictedRegionCanBuy"] = true,
    }
})