-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local GuiService = game:GetService("GuiService")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

-- Player
local player = Players.LocalPlayer

-- Services
local OfflineFarmService

-- Controllers
local UIController

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local OfflineFarmActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.OfflineFarmActions)

local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- OfflineFarmController
local OfflineFarmController = Knit.CreateController({
	Name = "OfflineFarmController",
})

--|| Functions ||--

function OfflineFarmController:GetPowerEarned()
    OfflineFarmService:GetPowerEarned()
end

-- Knit Lifecycle
function OfflineFarmController:KnitStart()
    OfflineFarmService = Knit.GetService("OfflineFarmService")

    UIController = Knit.GetController("UIController")

    OfflineFarmService:CheckPowerEarned():andThen(function(powerEarned)
        if powerEarned > 1 then
            Store:dispatch(OfflineFarmActions.setPowerEarned(powerEarned))
            UIController:ShowFrame({ frame = FramesConstants.OfflineFarm })
        end
    end)

    GuiService.MenuOpened:Connect(function()
        UIController:ShowFrame({ frame = FramesConstants.OfflineNotification })
    end)
end

return OfflineFarmController