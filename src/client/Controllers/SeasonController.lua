--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Zone = require(ReplicatedStorage.Shared.ZonePlus)

-- Services
local SeasonService = nil

-- Controllers
local NotificationController = nil
local DataCacheController = nil
local UIController = nil

local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

local seasonAreas

-- SeasonController
local SeasonController = Knit.CreateController({
    Name = "SeasonController",
    Template = {}
})

--|| Functions ||--
function SeasonController:ClaimDailyQuest(id: string)
    local promise, res = SeasonService:ClaimDailyQuest(id):await()
    if promise == false then return warn("[SEASON CONTROLLER] An internal occured while claiming quest.") end

    NotificationController:Notify(res)
end

function SeasonController:ClaimReward(id: number)
    local promise, res = SeasonService:ClaimReward(id):await()
    if promise == false then return warn("[SEASON CONTROLLER] An internal occured while claiming reward.") end
    NotificationController:Notify(res)
end

function SeasonController:PremiumClaimReward(id: number)
    local promise, res = SeasonService:PremiumClaimReward(id):await()
    if promise == false then return warn("[SEASON CONTROLLER] An internal occured while claiming premium reward.") end
    NotificationController:Notify(res)
end

--|| Knit Lifecycle ||--
function SeasonController:KnitInit()
    SeasonService = Knit.GetService("SeasonService")
    SeasonService.QuestCompleted:Connect(function(exp)
        NotificationController:Notify({ text = `You received {exp} season pass XP`, type = "SUCCESS"})
    end)

    NotificationController = Knit.GetController("NotificationController")
    DataCacheController = Knit.GetController("DataCacheController")
    UIController = Knit.GetController("UIController")

    self.Template = DataCacheController:GetFile("Template")

    task.delay(3, function()
		seasonAreas = CollectionService:GetTagged("SeasonArea")

		for _, seasonArea in pairs(seasonAreas) do
			local zone = Zone.new(seasonArea)
			zone:setDetection("Centre")

			-- Handle player entering the zone
			zone.playerEntered:Connect(function(player)
				if player == Players.LocalPlayer then
					UIController:ShowFrame({ frame = FramesConstants.Season })
				end
			end)
		
			-- Handle player exiting the zone
			zone.playerExited:Connect(function(player)
				if player == Players.LocalPlayer then
					UIController:HideFrame()
				end
			end)
		end
	end)

    print("[SEASON CONTROLLER] Controller loaded successfully.")
end

return SeasonController