local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.GetService("DataService")
local SeasonService = Knit.GetService("SeasonService")
local DataCacheService = Knit.GetService("DataCacheService")

return table.freeze({
    [3344929761] = {
        ["Name"] = "Season Pass - Skip 1",
        ["BeforeCheck"] = function(self, userId)
            local data = DataService:GetData(Players:GetPlayerByUserId(userId))

            if data.Season.Level == 30 then
                return { status = false, message = "Your season pass is already at max level." }
            end

            return { status = true, message = "" }
        end,
        ["Purchased"] = function(self, userId)
            local template = DataCacheService:GetFile("Template")
            local player = Players:GetPlayerByUserId(userId)
            local data = DataService:GetData(player)

            data.Season.Level += 1
            SeasonService.Client.LevelUpdated:Fire(player, data.Season.Level)

            local targetExp = 0

            for i = 1, data.Season.Level do
                targetExp += template.SeasonPass[i]
            end

            data.Season.Exp = targetExp
            SeasonService.Client.ExpUpdated:Fire(player, data.Season.Exp)
        end,
        ["RestrictedRegionCanBuy"] = true,
    }
})