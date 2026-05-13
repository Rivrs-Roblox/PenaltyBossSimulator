-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

-- Player
local player = Players.LocalPlayer

local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

local BoostEventActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.BoostEventActions)

-- BoostEventController
local BoostEventController = Knit.CreateController({
	Name = "BoostEventController",
})

--|| Local Functions ||--

--|| Functions ||--
function BoostEventController:DisplayCountdown(seconds)
	-- Update UI countdown
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds % 60
	local formattedTime = string.format("%02d:%02d", minutes, remainingSeconds)
	Store:dispatch(BoostEventActions.setBoostEventCountdown(formattedTime))
end

function BoostEventController:ShowBoost(boostData)
	Store:dispatch(BoostEventActions.setCurrentBoostEvent(boostData))
end

function BoostEventController:HideBoost()
	Store:dispatch(BoostEventActions.setCurrentBoostEvent(nil))
end

function BoostEventController:KnitStart()
	local BoostEventService = Knit.GetService("BoostEventService")

	BoostEventService.BoostStarted:Connect(function(boostData)
		self:ShowBoost(boostData)
	end)

	BoostEventService.BoostEnded:Connect(function()
		self:HideBoost()
	end)

	BoostEventService.UpdateCountdown:Connect(function(seconds)
		self:DisplayCountdown(seconds)
	end)
end

return BoostEventController
