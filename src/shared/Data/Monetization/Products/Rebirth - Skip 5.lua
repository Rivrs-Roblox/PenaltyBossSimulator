local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local RebirthService = Knit.GetService("RebirthService")

return table.freeze({
    [3576017751] = {
        ["Name"] = "Rebirth - Skip 5",
        ["BeforeCheck"] = function(self, userId)
            return { status = true, message = "" }
        end,
        ["Purchased"] = function(self, userId)
            RebirthService:Skip(Players:GetPlayerByUserId(userId), 5)
        end,
        ["RestrictedRegionCanBuy"] = true,
    }
})