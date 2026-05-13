--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Sound = require(ReplicatedStorage.Packages.Sound)
local Zone = require(ReplicatedStorage.Shared.ZonePlus)
local Helpers = ReplicatedStorage.Shared.Helpers
local TweenBlur = require(Helpers.TweenBlur)
local CallUntilSuccess = require(Helpers.CallUntilSuccess)
local AddOutline = require(Helpers.AddOutline)
local Confetti = require(Helpers.Confetti)

-- Services
local ExclusivePackService = nil

-- Controllers
local NotificationController = nil
local DataCacheController = nil
local UIController = nil

local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

local exclusivePackAreas

-- Constants
local CurrentCamera = workspace.CurrentCamera
local OriginalCameraMin = Players.LocalPlayer.CameraMinZoomDistance

-- ExclusivePackController
local ExclusivePackController = Knit.CreateController({
	Name = "ExclusivePackController",

	Colors = {},
	Pets = {},
	Template = {},
	EggSettings = {},
})

--|| Functions ||--
function ExclusivePackController:BuyItem(id: number)
	local buyPromise, success, res = ExclusivePackService:BuyItem(id):await()

	if buyPromise == false then
		return
	end

	if typeof(res) == "table" then
		NotificationController:Notify(res)
		return
	end
end

function ExclusivePackController:ShowHatchedPetVisual(petName: string)
	task.wait(1)
	local function SetTransparency(Model, Value)
		for i, v in Model:GetDescendants() do
			if v:IsA("BasePart") then
				v.Transparency = Value
			end
		end
	end

	local PetPlacements = self.EggSettings.PetPlacements[1]

	TweenBlur(5, 0.2)

	CallUntilSuccess(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	end)

	UserInputService.MouseIconEnabled = false
	UIController:RemoveHUD({ ignoreTopFrame = false })
	UIController:JustHideFrame()

	--Players.LocalPlayer.CameraMinZoomDistance = 30

	task.spawn(function()
		local RenderStepName2 = "EggPetRender" .. 1 .. os.clock() .. math.random(1, 20)

		local BlurredBackground
		BlurredBackground = Instance.new("DepthOfFieldEffect")
		BlurredBackground.FarIntensity = 0
		BlurredBackground.Parent = Lighting

		Confetti(50)

		task.wait(0.3 / self.EggSettings.EggSpeed)

		local PetModel = ReplicatedStorage.Assets.Pets:FindFirstChild(petName, true)

		if not PetModel then
			warn("PetModel not found:", petName)
			return
		end
		PetModel = PetModel:Clone()

		PetModel:ScaleTo(PetModel:GetScale() / 2.5)
		for k, j in PetModel:GetDescendants() do
			pcall(function()
				j.Anchored = true
				j.CanCollide = false
			end)
		end

		AddOutline(PetModel)

		local PetNameTemplate = ReplicatedStorage.Assets.Prompts.PetName
		local PetName = PetNameTemplate:Clone() :: BillboardGui
		PetName.Parent = PetModel
		PetName.StudsOffset += Vector3.new(0, -3.5, 1)

		local Name = PetModel.Name

		local NameTL = PetName:WaitForChild("Name")
		local RarityTL = PetName:WaitForChild("Rarity")

		NameTL.Text = Name

		if string.find(Name, "Gold ") then
			NameTL.TextColor3 = self.Colors["Gold"]
		else
			NameTL.TextColor3 = self.Colors["Normal"]
		end

		RarityTL.Text = self.Pets[Name].Rarity
		RarityTL.TextColor3 = self.Colors[RarityTL.Text]

		PetModel.Parent = CurrentCamera

		local PositionValue2 = Instance.new("CFrameValue", PetModel)
		PositionValue2.Name = "PositionValue"
		PositionValue2.Value = CFrame.new(0, 0.3, -5)

		local RotationValue2 = Instance.new("CFrameValue", PetModel)
		RotationValue2.Name = "RotationValue"
		RotationValue2.Value = CFrame.Angles(0, 0, 0)

		local TransparencyValue2 = Instance.new("NumberValue", PetModel)
		TransparencyValue2.Name = "TransparencyValue"
		TransparencyValue2.Value = 1

		RunService:BindToRenderStep(RenderStepName2, Enum.RenderPriority.Last.Value, function()
			local TempPosition1 = CurrentCamera.CFrame
			local TempPosition2 = (PositionValue2.Value + PetPlacements[1]) * RotationValue2.Value
			local FinalPosition = TempPosition1 * TempPosition2

			PetModel:PivotTo(FinalPosition)
			SetTransparency(PetModel, TransparencyValue2.Value)
		end)

		local TransparencyTween3 = TweenService:Create(
			TransparencyValue2,
			TweenInfo.new(0.2 / self.EggSettings.EggSpeed, Enum.EasingStyle.Quint),
			{ Value = 0 }
		)
		TransparencyTween3:Play()
		TransparencyTween3.Completed:Connect(function()
			TransparencyTween3:Destroy()
		end)

		local RotationTween3 = TweenService:Create(
			RotationValue2,
			TweenInfo.new(1.3 / self.EggSettings.EggSpeed, Enum.EasingStyle.Quint),
			{ Value = CFrame.Angles(0, math.rad(PetModel:GetAttribute("EggRotation") or 0), 0) }
		)
		RotationTween3:Play()
		RotationTween3.Completed:Connect(function()
			RotationTween3:Destroy()
		end)

		task.wait(1.5 / self.EggSettings.EggSpeed)
		Sound:PlaySound("UI_Success")
		task.wait(2)

		local PositionTween2 = TweenService:Create(
			PositionValue2,
			TweenInfo.new(0.5 / self.EggSettings.EggSpeed, Enum.EasingStyle.Linear),
			{ Value = CFrame.new(0, 0.7, -5) }
		)
		PositionTween2:Play()

		task.wait(0.4 / self.EggSettings.EggSpeed)

		local PositionTween3 = TweenService:Create(
			PositionValue2,
			TweenInfo.new(0.7 / self.EggSettings.EggSpeed, Enum.EasingStyle.Linear),
			{ Value = CFrame.new(0, -10, -5) }
		)
		PositionTween3:Play()

		PositionTween3.Completed:Wait()
		PositionTween3.Completed:Connect(function()
			PositionTween3:Destroy()
		end)

		RunService:UnbindFromRenderStep(RenderStepName2)

		PetModel:Destroy()

		local BlurredBackgroundTween2 =
			TweenService:Create(BlurredBackground, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { FarIntensity = 0 })
		BlurredBackgroundTween2:Play()
		BlurredBackgroundTween2.Completed:Connect(function()
			BlurredBackgroundTween2:Destroy()
		end)

		task.wait(0.4)

		BlurredBackground:Destroy()

		UIController:ShowHUD()

		CallUntilSuccess(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		end)

		Players.LocalPlayer.CameraMinZoomDistance = OriginalCameraMin

		UserInputService.MouseIconEnabled = true

		TweenBlur(0, 0.2)
	end)
end

function ExclusivePackController:ResetExclusivePack()
	local resetPromise, success, res = ExclusivePackService:ResetExclusivePack():await()
	if resetPromise == false then
		return
	end

	if typeof(res) == "table" then
		NotificationController:Notify(res)
		return
	end
end

--|| Knit Lifecycle ||--
function ExclusivePackController:KnitInit()
	ExclusivePackService = Knit.GetService("ExclusivePackService")
	NotificationController = Knit.GetController("NotificationController")
	DataCacheController = Knit.GetController("DataCacheController")
	UIController = Knit.GetController("UIController")

	self.Colors = DataCacheController:GetFile("Colors")
	self.Pets = DataCacheController:GetFile("Pets")
	self.Template = DataCacheController:GetFile("Template")
	self.EggSettings = DataCacheController:GetFile("EggSettings")

	ExclusivePackService.ExclusiveChestOpened:Connect(function(petName)
		-- Handle exclusive chest opened event
		-- NotificationController:Notify({
		-- 	text = "You got " .. petName .. "!",
		-- 	type = "INFO",
		-- })

		self:ShowHatchedPetVisual(petName)
	end)

	task.delay(3, function()
		exclusivePackAreas = CollectionService:GetTagged("ExclusivePackArea")

		for _, exclusivePackArea in pairs(exclusivePackAreas) do
			local zone = Zone.new(exclusivePackArea)
			zone:setDetection("Centre")

			-- Handle player entering the zone
			zone.playerEntered:Connect(function(player)
				if player == Players.LocalPlayer then
					UIController:ShowFrame({ frame = FramesConstants.ExclusivePack })
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

	print("[STORE CONTROLLER] Controller loaded successfully.")
end

return ExclusivePackController
