-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local TeleportService = nil

-- Controllers
local DataCacheController = nil
local UIController = nil
local NotificationController = nil
local TrainingController = nil
local FightController = nil

-- TeleportController
local TeleportController = Knit.CreateController({
	Name = "TeleportController",
	Template = {},
	IsTeleporting = false,
})

--|| Functions ||--

function TeleportController:TeleportEffectFrame(_Params)
	local TweenGUI = Players.LocalPlayer.PlayerGui:WaitForChild("Transition")
	local Image = TweenGUI:WaitForChild("Image")
	local BlackScreen = TweenGUI:WaitForChild("BlackScreen")
	local GoalSize = nil
	local StartSize = nil
	local IsBlackScreen = nil

	if _Params == "Open" then
		StartSize = UDim2.fromScale(1, 1)
		GoalSize = UDim2.fromScale(30, 30)
		IsBlackScreen = false
	elseif _Params == "Close" then
		StartSize = UDim2.fromScale(30, 30)
		GoalSize = UDim2.fromScale(1, 1)
		IsBlackScreen = true
	else
		return
	end

	if Image then
		Image.Size = StartSize
		Image.Visible = true
		BlackScreen.Visible = false

		local TweenFrame =
			TweenService:Create(Image, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = GoalSize,
			})

		TweenFrame:Play()

		TweenFrame.Completed:Wait()

		Image.Visible = false

		if IsBlackScreen then
			BlackScreen.Visible = true
		end
	end
end

-- Request teleportation to a zone
function TeleportController:RequestTeleport(player: Player, id: string)
	if TrainingController.IsTraining then
		NotificationController:Notify({
			tag = "Teleport",
			text = "You can't teleport while training." :: string,
			type = "ERROR",
		})

		return
	end

	if FightController.IsFighting then
		NotificationController:Notify({
			tag = "Teleport",
			text = "You can't teleport while fighting." :: string,
			type = "ERROR",
		})

		return
	end

	if self.IsTeleporting then
		NotificationController:Notify({
			tag = "Teleport",
			text = "Please wait while teleport is being processed",
			type = "ERROR",
		})
		return
	end

	self.IsTeleporting = true
	UIController:HideFrame()
	UIController:RemoveHUD({ ignoreTopFrame = false })

	self:TeleportEffectFrame("Close")

	return TeleportService:TeleportRequest(player, id):andThen(function()
		task.wait(1)

		self:TeleportEffectFrame("Open")

		self.IsTeleporting = false

		UIController:ShowHUD()
	end)
end

--|| Knit Lifecycle ||--
function TeleportController:KnitInit()
	TeleportService = Knit.GetService("TeleportService")
end

function TeleportController:KnitStart()
	DataCacheController = Knit.GetController("DataCacheController")
	UIController = Knit.GetController("UIController")
	NotificationController = Knit.GetController("NotificationController")
	TrainingController = Knit.GetController("TrainingController")
	FightController = Knit.GetController("FightController")

	self.Template = DataCacheController:GetFile("Template")

	print("[TELEPORT CONTROLLER] Controller started successfully.")
end

return TeleportController
