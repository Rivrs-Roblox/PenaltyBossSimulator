--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local Confetti = require(Helpers.Confetti)
local SetupArea = require(Helpers.SetupArea)

-- Controllers
local DataCacheController = nil
local NotificationController = nil
local StoreController = nil
local UIController = nil

-- Services
local SpinService = nil

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Contants
-- Constants
local FullSpins = 4
local SpinDuration = 5.5

local player = Players.LocalPlayer

-- SpinController
local SpinController = Knit.CreateController({
	Name = "SpinController",

	Template = {},
})

--|| Functions ||--
function SpinController:Spin(wheel: string)
	local Wheel =
		Players.LocalPlayer.PlayerGui:FindFirstChild("GameScreenGui").Spins.Popup.Container[`{wheel}`].WheelHolder.Wheel
	if not Wheel then
		return NotificationController:Notify({
			text = self.Template.Messages.Notifications.Wheel_Not_Found(wheel),
			type = "ERROR",
		})
	end

	local Rewards = self.Template.Spins[wheel]
	if not Rewards then
		return NotificationController:Notify({
			text = self.Template.Messages.Notifications.Wheel_Not_Found(wheel),
			type = "ERROR",
		})
	end

	local promise, targetRotation, notif = SpinService:Spin(wheel):await()
	if promise == false then
		return warn("[SPIN CONTROLLER] An internal error occured while performing server side spin.")
	end

	if type(targetRotation) == "table" then
		return NotificationController:Notify(targetRotation)
	end

	Sound:PlaySound("UI_Wheel_Spin")

	Wheel.Rotation = 0

	local finalRotation = (FullSpins * 360) + targetRotation
	local Info = TweenInfo.new(SpinDuration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)
	local Tween = TweenService:Create(Wheel, Info, {
		Rotation = finalRotation,
	})

	Tween:Play()
	Tween.Completed:Wait()
	Wheel.Rotation = targetRotation

	Confetti(50)
	NotificationController:Notify(notif)
end

function SpinController:Buy(name)
	StoreController:BuyItem({ name = name })
end

--|| Knit Lifecycle ||--
function SpinController:KnitInit()
	DataCacheController = Knit.GetController("DataCacheController")
	StoreController = Knit.GetController("StoreController")
	NotificationController = Knit.GetController("NotificationController")
	UIController = Knit.GetController("UIController")

	SpinService = Knit.GetService("SpinService")
	task.delay(3, function()
		SpinService.FreeSpin:Connect(function(amount)
			NotificationController:Notify({
				text = self.Template.Messages.Notifications.Free_Spin(amount or 1),
				type = "SUCCESS",
			})
		end)
	end)

	self.Template = DataCacheController:GetFile("Template")

	SetupArea("SpinArea", {
		onEnter = function(plr)
			if plr == player then
				UIController:ShowFrame({ frame = FramesConstants.Spins })
			end
		end,
		onExit = function(plr)
			if plr == player then
				UIController:HideFrame()
			end
		end,
	})

	print("[SPIN CONTROLLER] Controller loaded successfully.")
end

return SpinController
