local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")

return table.freeze({
    [3576018872] = {
        ["Name"] = "Wins Pack - Huge",
        ["BeforeCheck"] = function(self, userId)
            return { status = true, message = "" }
        end,
        ["Purchased"] = function(self, userId)
            local Player = Players:GetPlayerByUserId(userId)
            local amount = DataService:GetWinsPackAmount(Player, "HUGE")

            DataService:ChangeValue(Player, "Wins", amount, true)
        end,
        ["RestrictedRegionCanBuy"] = true,
    }
})