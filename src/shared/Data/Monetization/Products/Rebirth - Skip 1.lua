local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local RebirthService = Knit.GetService("RebirthService")

return table.freeze({
    [3576017442] = {
        ["Name"] = "Rebirth - Skip 1",
        ["BeforeCheck"] = function(self, userId)
            return { status = true, message = "" }
        end,
        ["Purchased"] = function(self, userId)
            RebirthService:Skip(Players:GetPlayerByUserId(userId), 1)
        end,
        ["RestrictedRegionCanBuy"] = true,
    }
})