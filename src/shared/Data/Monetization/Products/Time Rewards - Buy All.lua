local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local RewardsService = Knit.GetService("RewardsService")
local DataCacheService = Knit.GetService("DataCacheService")

return table.freeze({
    [3579243396] = {
        ["Name"] = "Time Rewards - Buy All",
        ["BeforeCheck"] = function(self, userId)
            local template = DataCacheService:GetFile("Template")
            
            if RewardsService:GetTimer(Players:GetPlayerByUserId(userId)) >= 2040 then
                return { status = false, message = template.Messages.Notifications.Cant_Buy }
            end

            return { status = true, message = "" }
        end,
        ["Purchased"] = function(self, userId)
            local DataCacheService = Knit.GetService("DataCacheService")
            local Rewards = DataCacheService:GetFile("Template").Rewards

            local Player = Players:GetPlayerByUserId(userId)
            local Timer = RewardsService:GetTimer(Players:GetPlayerByUserId(userId))

            for i = 1, 12 do
                if Timer < Rewards[i].Time then
                    RewardsService:ClaimReward(Player, i, true)
                end
            end

            RewardsService:SetTimer(Player, Rewards[12].Time)
        end,
        ["RestrictedRegionCanBuy"] = true,
    }
})