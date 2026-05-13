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
local RainbowMachineService = nil

-- Controllers
local NotificationController = nil
local UIController = nil

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

local rainbowMachineAreas

-- RainbowMachineController
local RainbowMachineController = Knit.CreateController({
	Name = "RainbowMachineController",
})

--|| Functions ||--
function RainbowMachineController:AddOrRemovePet(params: table)
	local p, r = RainbowMachineService:AddOrRemovePet(params):await()
	if p == false then
		return warn("[RAINBOW MACHINE CONTROLLER] An internal error occured while adding or removing pet.")
	end

	if r ~= nil then
		NotificationController:Notify(r)
	end
end

function RainbowMachineController:Craft()
	local p, r = RainbowMachineService:Craft():await()
	if p == false then
		return warn("[RAINBOW MACHINE CONTROLLER] An internal error occured while crafting pet.")
	end
	if r ~= nil then
		NotificationController:Notify(r)
	end
end

--|| Knit Lifecycle ||--
function RainbowMachineController:KnitInit()
	RainbowMachineService = Knit.GetService("RainbowMachineService")

	NotificationController = Knit.GetController("NotificationController")

	UIController = Knit.GetController("UIController")

	-- task.delay(3, function()
	-- 	rainbowMachineAreas = CollectionService:GetTagged("RainbowMachineArea")

	-- 	for _, RainbowMachineArea in pairs(rainbowMachineAreas) do
	-- 		local zone = Zone.new(RainbowMachineArea)
	-- 		zone:setDetection("Centre")

	-- 		-- Handle player entering the zone
	-- 		zone.playerEntered:Connect(function(player)
	-- 			if player == Players.LocalPlayer then
	-- 				UIController:ShowFrame({ frame = FramesConstants.RainbowPets })
	-- 			end
	-- 		end)

	-- 		-- Handle player exiting the zone
	-- 		zone.playerExited:Connect(function(player)
	-- 			if player == Players.LocalPlayer then
	-- 				UIController:HideFrame()
	-- 			end
	-- 		end)
	-- 	end
	-- end)

	SetupArea("RainbowMachineArea", {
		onEnter = function(plr)
			if plr == player then
				UIController:ShowFrame({ frame = FramesConstants.RainbowPets })
			end
		end,
		onExit = function(plr)
			if plr == player then
				UIController:HideFrame()
			end
		end,
	})

	print("[RAINBOW MACHINE CONTROLLER] CONTROLLER loaded successfully.")
end

return RainbowMachineController
