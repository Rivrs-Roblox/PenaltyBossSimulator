--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Zone = require(ReplicatedStorage.Shared.ZonePlus)


local Helpers = ReplicatedStorage.Shared.Helpers
local SetupArea = require(Helpers.SetupArea)

-- Player
local player = Players.LocalPlayer

-- Services
local GoldMachineService = nil

-- Controllers
local NotificationController = nil
local UIController = nil

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

local goldMachineAreas

-- GoldMachineController
local GoldMachineController = Knit.CreateController({
    Name = "GoldMachineController",
})

--|| Functions ||--
function GoldMachineController:AddOrRemovePet(params: table)
    local p, r = GoldMachineService:AddOrRemovePet(params):await()
    if p == false then return warn("[GOLD MACHINE CONTROLLER] An internal error occured while adding or removing pet.") end

    if r ~= nil then NotificationController:Notify(r) end
end

function GoldMachineController:Craft()
    local p, r = GoldMachineService:Craft():await()
    if p == false then return warn("[GOLD MACHINE CONTROLLER] An internal error occured while crafting pet.") end

    if r ~= nil then NotificationController:Notify(r) end
end

--|| Knit Lifecycle ||--
function GoldMachineController:KnitStart()
    GoldMachineService = Knit.GetService("GoldMachineService")
    NotificationController = Knit.GetController("NotificationController")
    UIController = Knit.GetController("UIController")

    -- task.delay(3, function()
    --     goldMachineAreas = CollectionService:GetTagged("GoldMachineArea")

    --     for _, goldMachineArea in pairs(goldMachineAreas) do
    --         local zone = Zone.new(goldMachineArea)
    --         zone:setDetection("Centre")

    --         -- Handle player entering the zone
    --         zone.playerEntered:Connect(function(player)
    --             if player == Players.LocalPlayer then
    --                 UIController:ShowFrame({ frame = FramesConstants.GoldPets })
    --             end
    --         end)
        
    --         -- Handle player exiting the zone
    --         zone.playerExited:Connect(function(player)
    --             if player == Players.LocalPlayer then
    --                 UIController:HideFrame()
    --             end
    --         end)
    --     end

    -- end)

    SetupArea("GoldMachineArea", {
		onEnter = function(plr)
			if plr == player then
				UIController:ShowFrame({ frame = FramesConstants.GoldPets })
			end
		end,
		onExit = function(plr)
			if plr == player then
				UIController:HideFrame()
			end
		end,
	})
    
    print("[GOLD MACHINE CONTROLLER] CONTROLLER loaded successfully.")
end

return GoldMachineController