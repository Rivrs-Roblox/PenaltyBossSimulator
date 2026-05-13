--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local Tween = require(Helpers.Tween)
local SetInterval = require(Helpers.SetInterval)
local FormatNumber = require(Helpers.Numbers.FormatNumber)
local TweenBlur = require(Helpers.TweenBlur)
local CallUntilSuccess = require(Helpers.CallUntilSuccess)
local AddOutline = require(Helpers.AddOutline)
local Confetti = require(Helpers.Confetti)
local FindValue = require(Helpers.Table.FindValue)

-- Services
local EggsService = nil
local DataService = nil
local MonetizationService = nil
local RewardsService = nil
local TeleportationService = nil
local DailyRewardsService = nil
local FriendsService = nil
--local SeasonService = nil
local SpinService = nil
--local RedeemCandyService = nil

-- Controllers
local DataCacheController = nil
local NotificationController = nil
local UIController = nil
local MonetizationController = nil
local FightController = nil
local AutoController = nil

-- UI
local EggUI = ReplicatedStorage.Assets.UI.Egg:Clone()
local PetsContainer = EggUI.Container
local Holder = PetsContainer.Holder
local HolderTemplate = Holder:WaitForChild("PetTemplate")

-- Constants
local CurrentCamera = Workspace.CurrentCamera
local OriginalCameraMin = Players.LocalPlayer.CameraMinZoomDistance

-- EggsController
local EggsController = Knit.CreateController({
	Name = "EggsController",

	UI = {},
	Colors = {},
	Pets = {},
	Template = {},
	EggSettings = {},

	Hatching = false,

	Eggs = {},
	EggsModels = {},

	PlacementParts = {},

	Debounce = false,
	CurrentEgg = nil,
	AutoDelete = {},

	EUIScale = nil,
})

--|| Functions ||--
function EggsController:InitPlacementParts()
	for _, Egg in self.EggsModels do
		local Part = Instance.new("Part")
		Part.Anchored = true
		Part.CanCollide = false
		Part.CanQuery = false
		Part.Size = Vector3.new(1, 1, 1)
		Part.Position = Egg.Position
		Part.Transparency = 1
		Part.Parent = workspace:WaitForChild("Ignore")

		self.PlacementParts[Egg] = Part
	end
end

function EggsController:UpdateHolder()
	local Info = self.Eggs[self.CurrentEgg.Name]
	if not Info then
		return warn("[EGGS CONTROLLER] Egg has no data: " .. self.CurrentEgg.Name)
	end

	local Pets = Info.Pets
	for _, Child in Holder:GetChildren() do
		if Child:IsA("GuiButton") and Child ~= HolderTemplate then
			if not Pets[Child.Name] then
				Child:Destroy()
			end
		end
	end

	PetsContainer.Price.ImageLabel.Visible = true
	PetsContainer.Price.TextLabel.Position = UDim2.fromScale(0.7, 0.5)
	if typeof(Info.Price) == "number" then
		PetsContainer.Price.TextLabel.Text = FormatNumber(Info.Price)
	end
	if Info.Currency == "Robux" then
		PetsContainer.Price.ImageLabel.Visible = false
		PetsContainer.Price.TextLabel.Text =
			`{self.Template.Messages.Robux_Icon} {MonetizationController:GetPrice(Info.Price)}`
		PetsContainer.Price.TextLabel.Position = UDim2.fromScale(0.5, 0.5)
	end

	for Pet, Info in Pets do
		local Image = self.UI[Pet]
		if Image and not Holder:FindFirstChild(Pet) then
			local New = HolderTemplate:Clone()
			New.Name = Pet
			New.Visible = true
			New.Parent = Holder

			New:WaitForChild("PetViewport").Image = Image
			New:WaitForChild("Title").Text = `{Info.Chance}%`
			New.ImageColor3 = self.Colors[self.Pets[Pet].Rarity]
			New.LayoutOrder = -Info.Chance

			New.MouseButton1Click:Connect(function()
				local Index = table.find(self.AutoDelete, New.Name)
				if Index then
					table.remove(self.AutoDelete, Index)
				else
					table.insert(self.AutoDelete, New.Name)
				end

				New.Deleting.Visible = Index == nil
			end)

			New.Deleting.Visible = table.find(self.AutoDelete, New.Name) ~= nil
		end

		if not Image then
			warn("[EGGS CONTROLLER] Pet has no image: " .. Pet)
		end
	end
end

function EggsController:GetClosestEgg()
	local ClosestEgg = nil
	local ClosestDistance = math.huge

	for _, Egg in self.EggsModels do
		local Distance = Players.LocalPlayer:DistanceFromCharacter(Egg.Position)
		if Distance < ClosestDistance then
			ClosestEgg = Egg
			ClosestDistance = Distance
		end
	end

	return ClosestEgg, ClosestDistance
end

function EggsController:HookButtons()
	local Buttons = EggUI.Container.Buttons
	for _, Button in Buttons:GetChildren() do
		local number = tonumber((string.gsub(Button.Name, "%D", "")))
		if number ~= nil then
			Button.MouseButton1Click:Connect(function()
				local EggData = self.Eggs[self.CurrentEgg.Name]
				if EggData.Currency == "Wins" then
					if
						self.CurrentEgg ~= nil
						and self.Hatching == false
						and not FightController.IsFighting
						and not AutoController.IsAutoWinning
					then
						-- self.Hatching = true
						local dataPromise, data = DataService:GetData(Players.LocalPlayer):await()
						if dataPromise == false then
							return
						end

						if number == 3 and not FindValue(data.Gamepasses, "x3 Hatch") then
							MonetizationService:PromptPurchase("x3 Hatch", "GamePasses")
							self.Hatching = false
							return NotificationController:Notify({
								tag = "Eggs",
								text = self.Template.Messages.Notifications.Pass_Needed("x3 Hatch"),
								type = "ERROR",
							})
						end

						if number == 8 and not FindValue(data.Gamepasses, "x8 Hatch") then
							MonetizationService:PromptPurchase("x8 Hatch", "GamePasses")
							self.Hatching = false
							return NotificationController:Notify({
								tag = "Eggs",
								text = self.Template.Messages.Notifications.Pass_Needed("x8 Hatch"),
								type = "ERROR",
							})
						end

						local hatchPromise, success, res =
							EggsService:Hatch(number, self.CurrentEgg.Name, self.AutoDelete, false):await()
						if hatchPromise == false then
							self.Hatching = false
							return
						end

						if success == true then
							if #res == 0 then
								self.Hatching = false
								return NotificationController:Notify({
									tag = "Eggs",
									text = self.Template.Messages.Notifications.Unwanted_Pet_Obtained,
								})
							end
							self:Hatch(res)
						else
							self.Hatching = false
							NotificationController:Notify(res)
						end
					end
				elseif EggData.Currency == "Robux" then
					if number == 1 then
						local _, res = MonetizationService:PromptPurchase("x1 " .. EggData.Name, "Products"):await()
						if typeof(res) == "table" then
							NotificationController:Notify({
								tag = "Eggs",
								text = res.text,
								type = res.type,
							})
						end
					end

					if number == 3 then
						local _, res = MonetizationService:PromptPurchase("x3 " .. EggData.Name, "Products"):await()
						if typeof(res) == "table" then
							NotificationController:Notify({
								tag = "Eggs",
								text = res.text,
								type = res.type,
							})
						end
					end

					if number == 8 then
						local _, res = MonetizationService:PromptPurchase("x8 " .. EggData.Name, "Products"):await()
						if typeof(res) == "table" then
							NotificationController:Notify({
								tag = "Eggs",
								text = res.text,
								type = res.type,
							})
						end
					end
				end
			end)
		end
	end
end

function EggsController:Hatch(Pets: { string })
	if self.Hatching == true then
		return
	end
	self.Hatching = true
	local function SetTransparency(Model, Value)
		for i, v in Model:GetDescendants() do
			if v:IsA("BasePart") then
				v.Transparency = Value
			end
		end
	end

	local EggAmount = #Pets
	if not table.find({ 1, 3, 8 }, EggAmount) then
		warn("[EGGS CONTROLLER] Invalid Egg Amount: " .. EggAmount)
	end
	local EggPositions = self.EggSettings.EggPlacements[EggAmount]
	local PetPlacements = self.EggSettings.PetPlacements[EggAmount]

	TweenBlur(5, 0.2)

	CallUntilSuccess(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	end)

	UserInputService.MouseIconEnabled = false
	UIController:RemoveHUD({ ignoreTopFrame = false })
	UIController:JustHideFrame()

	--Players.LocalPlayer.CameraMinZoomDistance = 30
	Sound:PlaySound("UI_Egg_Hatch")
	for i, v in Pets do
		task.spawn(function()
			local RenderStepName1 = "EggRender" .. i .. os.clock() .. math.random(1, 20)
			local RenderStepName2 = "EggPetRender" .. i .. os.clock() .. math.random(1, 20)

			local EggModel = Workspace:FindFirstChild("Eggs"):FindFirstChild(self.CurrentEgg.Name, true)
			if EggModel:IsA("MeshPart") then
				EggModel = EggModel.Parent
			end

			EggModel = EggModel:Clone()

			for k, j in EggModel:GetDescendants() do
				if j:IsA("MeshPart") then
					j.Anchored = true
					j.CanCollide = false
				end
			end

			AddOutline(EggModel)
			EggModel.Parent = CurrentCamera

			local BlurredBackground
			if i == 1 then
				BlurredBackground = Instance.new("DepthOfFieldEffect")
				BlurredBackground.FarIntensity = 0
				BlurredBackground.Parent = Lighting

				local BlurredBackgroundTween1 = TweenService:Create(
					BlurredBackground,
					TweenInfo.new(0.5, Enum.EasingStyle.Quint),
					{ FarIntensity = 0.75 }
				)
				BlurredBackgroundTween1:Play()
				BlurredBackgroundTween1.Completed:Connect(function()
					BlurredBackgroundTween1:Destroy()
				end)
			end

			local PositionValue = Instance.new("CFrameValue", EggModel)
			PositionValue.Name = "PositionValue"
			PositionValue.Value = CFrame.new(0, -7, -5)

			local RotationValue = Instance.new("CFrameValue", EggModel)
			RotationValue.Name = "RotationValue"
			RotationValue.Value = CFrame.Angles(math.rad(-10), 0, 0)

			local SizeValue = Instance.new("Vector3Value", EggModel)
			SizeValue.Name = "SizeValue"
			SizeValue.Value = Vector3.new(2.085, 2.463, 2.085)

			local TransparencyValue = Instance.new("NumberValue", EggModel)
			TransparencyValue.Name = "TransparencyValue"
			TransparencyValue.Value = 0

			RunService:BindToRenderStep(RenderStepName1, Enum.RenderPriority.Last.Value, function()
				local TempPosition1 = CurrentCamera.CFrame
				local TempPosition2 = (PositionValue.Value + EggPositions[i]) * RotationValue.Value
				local FinalPosition = TempPosition1 * TempPosition2
				EggModel:PivotTo(FinalPosition * CFrame.Angles(0, math.rad(EggModel:GetAttribute("Offset") or 90), 0))

				local Scaler = (EggModel:GetExtentsSize() / SizeValue.Value).Magnitude
				EggModel:ScaleTo(EggModel:GetScale() / Scaler)
				SetTransparency(EggModel, TransparencyValue.Value)
			end)

			local PositionTween1 = TweenService:Create(
				PositionValue,
				TweenInfo.new(1 / self.EggSettings.EggSpeed, Enum.EasingStyle.Quint),
				{ Value = CFrame.new(0, 0, -4) }
			)
			PositionTween1:Play()
			PositionTween1.Completed:Connect(function()
				PositionTween1:Destroy()
			end)

			local RotationTween1 = TweenService:Create(
				RotationValue,
				TweenInfo.new(2 / self.EggSettings.EggSpeed, Enum.EasingStyle.Quint),
				{ Value = CFrame.Angles(math.rad(-10), math.rad(180), 0) }
			)
			RotationTween1:Play()
			RotationTween1.Completed:Connect(function()
				RotationTween1:Destroy()
			end)

			task.wait(0.7 / self.EggSettings.EggSpeed)

			for idx = 1, 3 do
				local RotationAngle
				if idx % 2 == 0 then
					RotationAngle = 35
				elseif idx == 3 then
					RotationAngle = 0
				else
					RotationAngle = -35
				end

				local RotationTween2 = TweenService:Create(
					RotationValue,
					TweenInfo.new(0.5 / self.EggSettings.EggSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
					{ Value = CFrame.Angles(math.rad(-10), math.rad(180), math.rad(RotationAngle)) }
				)

				RotationTween2:Play()

				task.spawn(function()
					task.wait(0.2 / self.EggSettings.EggSpeed)
					local SizeTween1 = TweenService:Create(
						SizeValue,
						TweenInfo.new(0.2 / self.EggSettings.EggSpeed, Enum.EasingStyle.Quint),
						{ Value = self.EggSettings.EggSizes[EggAmount][idx] }
					)

					SizeTween1:Play()
					SizeTween1.Completed:Connect(function()
						SizeTween1:Destroy()
					end)
				end)

				RotationTween2.Completed:Wait()
				RotationTween2.Completed:Connect(function()
					RotationTween2:Destroy()
				end)
			end

			local SizeTween2 = TweenService:Create(
				SizeValue,
				TweenInfo.new(0.5 / self.EggSettings.EggSpeed, Enum.EasingStyle.Quint),
				{ Value = Vector3.new(0.9, 1.063, 0.9) }
			)
			SizeTween2:Play()
			SizeTween2.Completed:Wait()
			SizeTween2.Completed:Connect(function()
				SizeTween2:Destroy()
			end)

			local SizeTween3 = TweenService:Create(
				SizeValue,
				TweenInfo.new(0.5 / self.EggSettings.EggSpeed, Enum.EasingStyle.Quint),
				{ Value = Vector3.new(2.085, 2.463, 2.085) }
			)
			SizeTween3:Play()
			SizeTween3.Completed:Connect(function()
				SizeTween3:Destroy()
			end)

			local TransparencyTween2 = TweenService:Create(
				TransparencyValue,
				TweenInfo.new(0.5 / self.EggSettings.EggSpeed, Enum.EasingStyle.Quint),
				{ Value = 1 }
			)
			TransparencyTween2:Play()
			TransparencyTween2.Completed:Connect(function()
				TransparencyTween2:Destroy()
			end)

			local ColorCorrection = Instance.new("ColorCorrectionEffect", Lighting)
			ColorCorrection.Enabled = false

			task.spawn(function()
				task.wait(0.1 / self.EggSettings.EggSpeed)
				if i == 1 then
					ColorCorrection.Enabled = true
					local FlashTween = TweenService:Create(
						ColorCorrection,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint),
						{ Brightness = 1 }
					)
					local FlashTween2 = TweenService:Create(
						ColorCorrection,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint),
						{ Brightness = 0.1 }
					)
					FlashTween:Play()
					FlashTween.Completed:Once(function()
						FlashTween2:Play()
						ColorCorrection:Destroy()
					end)
					FlashTween2.Completed:Connect(function()
						FlashTween2:Destroy()
					end)
				end
				EggModel:Destroy()
				RunService:UnbindFromRenderStep(RenderStepName1)
			end)

			if i == 1 then
				Confetti(50)
			end

			task.wait(0.3 / self.EggSettings.EggSpeed)

			local PetModel = ReplicatedStorage.Assets.Pets:FindFirstChild(v, true):Clone()

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
				local TempPosition2 = (PositionValue2.Value + PetPlacements[i]) * RotationValue2.Value
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

			if i == 1 then
				local BlurredBackgroundTween2 = TweenService:Create(
					BlurredBackground,
					TweenInfo.new(0.5, Enum.EasingStyle.Quint),
					{ FarIntensity = 0 }
				)
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

				self.Hatching = false
				UserInputService.MouseIconEnabled = true

				TweenBlur(0, 0.2)
			end
		end)
	end
end

function EggsController:UpdateUI()
	local Egg, Distance = self:GetClosestEgg()
	local ValidDistance = Distance < 10
	local Valid = ValidDistance
	if Valid and not self.Debounce and self.Hatching == false then
		self.Debounce = true
		self.CurrentEgg = Egg

		EggUI.Adornee = self.PlacementParts[Egg]

		self:UpdateHolder()

		Tween(self.EUIScale, { Scale = 1 }, 0.2)
	elseif not Valid or self.CurrentEgg ~= Egg or self.Hatching then
		self.Debounce = false
		Tween(self.EUIScale, { Scale = 0 }, 0.2)
		task.delay(0.2, function()
			EggUI.Adornee = nil
		end)
	end
end

--|| Knit Lifecycle ||--
function EggsController:KnitInit()
	EggsService = Knit.GetService("EggsService")
	DataService = Knit.GetService("DataService")
	MonetizationService = Knit.GetService("MonetizationService")
	RewardsService = Knit.GetService("RewardsService")
	DailyRewardsService = Knit.GetService("DailyRewardsService")
	FriendsService = Knit.GetService("FriendsService")
	--SeasonService = Knit.GetService("SeasonService")
	SpinService = Knit.GetService("SpinService")
	--RedeemCandyService = Knit.GetService("RedeemCandyService")

	DataCacheController = Knit.GetController("DataCacheController")
	UIController = Knit.GetController("UIController")
	NotificationController = Knit.GetController("NotificationController")
	MonetizationController = Knit.GetController("MonetizationController")
	FightController = Knit.GetController("FightController")
	AutoController = Knit.GetController("AutoController")

	self.Eggs = DataCacheController:GetFile("Eggs")
	self.UI = DataCacheController:GetFile("Images")
	self.Colors = DataCacheController:GetFile("Colors")
	self.Pets = DataCacheController:GetFile("Pets")
	self.Template = DataCacheController:GetFile("Template")
	self.EggSettings = DataCacheController:GetFile("EggSettings")

	task.delay(2, function()
		EggUI.Parent = Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui")
	end)

	task.delay(3, function()
		self.EggsModels = CollectionService:GetTagged("Egg")
		self:InitPlacementParts()
		self:HookButtons()
	end)

	self.EUIScale = Instance.new("UIScale", PetsContainer)
	self.EUIScale.Scale = 0

	HolderTemplate.Visible = false

	SetInterval(function()
		self:UpdateUI()
	end, 0.2)

	UserInputService.InputBegan:Connect(function(Input: InputObject)
		if
			self.CurrentEgg ~= nil
			and self.Hatching == false
			and not FightController.IsFighting
			and not AutoController.IsAutoWinning
		then
			local EggData = self.Eggs[self.CurrentEgg.Name]
			if EggData.Currency == "Wins" then
				if Input.KeyCode == Enum.KeyCode.E then
					local _, Distance = self:GetClosestEgg()
					local ValidDistance = Distance < 10
					if ValidDistance then
						-- self.Hatching = true

						local hatchPromise, success, res =
							EggsService:Hatch(1, self.CurrentEgg.Name, self.AutoDelete, false):await()
						if hatchPromise == false then
							self.Hatching = false
						end

						if success == true then
							if #res == 0 then
								self.Hatching = false
								return NotificationController:Notify({
									tag = "Eggs",
									text = self.Template.Messages.Notifications.Unwanted_Pet_Obtained,
								})
							end
							self:Hatch(res)
						else
							self.Hatching = false
							NotificationController:Notify({
								tag = "Eggs",
								text = res.text,
								type = res.type,
							})
						end
					end
				elseif Input.KeyCode == Enum.KeyCode.R then
					local Egg, Distance = self:GetClosestEgg()
					local ValidDistance = Distance < 10
					if ValidDistance then
						local dataPromise, data = DataService:GetData(Players.LocalPlayer):await()
						if dataPromise == false then
							return
						end

						if not FindValue(data.Gamepasses, "x3 Hatch") then
							MonetizationService:PromptPurchase("x3 Hatch", "GamePasses")
							return NotificationController:Notify({
								tag = "Eggs",
								text = self.Template.Messages.Notifications.Pass_Needed("x3 Hatch"),
								type = "ERROR",
							})
						end

						-- self.Hatching = true

						local hatchPromise, success, res =
							EggsService:Hatch(3, self.CurrentEgg.Name, self.AutoDelete, false):await()
						if hatchPromise == false then
							return
						end

						if success == true then
							if #res == 0 then
								self.Hatching = false
								return NotificationController:Notify({
									tag = "Eggs",
									text = self.Template.Messages.Notifications.Unwanted_Pet_Obtained,
								})
							end
							self:Hatch(res)
						else
							self.Hatching = false
							NotificationController:Notify({
								tag = "Eggs",
								text = res.text,
								type = res.type,
							})
						end
					end
				elseif Input.KeyCode == Enum.KeyCode.Y then
					local Egg, Distance = self:GetClosestEgg()
					local ValidDistance = Distance < 10
					if ValidDistance then
						local dataPromise, data = DataService:GetData(Players.LocalPlayer):await()
						if dataPromise == false then
							return
						end

						if not FindValue(data.Gamepasses, "x8 Hatch") then
							MonetizationService:PromptPurchase("x8 Hatch", "GamePasses")
							return NotificationController:Notify({
								tag = "Eggs",
								text = self.Template.Messages.Notifications.Pass_Needed("x8 Hatch"),
								type = "ERROR",
							})
						end

						-- self.Hatching = true

						local hatchPromise, success, res =
							EggsService:Hatch(8, self.CurrentEgg.Name, self.AutoDelete, false):await()
						if hatchPromise == false then
							return
						end

						if success == true then
							if #res == 0 then
								self.Hatching = false
								return NotificationController:Notify({
									tag = "Eggs",
									text = self.Template.Messages.Notifications.Unwanted_Pet_Obtained,
								})
							end
							self:Hatch(res)
						else
							self.Hatching = false
							NotificationController:Notify({
								tag = "Eggs",
								text = res.text,
								type = res.type,
							})
						end
					end
				end
			elseif EggData.Currency == "Robux" then
				local _, Distance = self:GetClosestEgg()
				local ValidDistance = Distance < 10
				if ValidDistance then
					if Input.KeyCode == Enum.KeyCode.E then
						local _, res = MonetizationService:PromptPurchase("x1 " .. EggData.Name, "Products"):await()
						if typeof(res) == "table" then
							NotificationController:Notify({
								tag = "Eggs",
								text = res.text,
								type = res.type,
							})
						end
					end

					if Input.KeyCode == Enum.KeyCode.R then
						local _, res = MonetizationService:PromptPurchase("x3 " .. EggData.Name, "Products"):await()
						if typeof(res) == "table" then
							NotificationController:Notify({
								tag = "Eggs",
								text = res.text,
								type = res.type,
							})
						end
					end

					if Input.KeyCode == Enum.KeyCode.Y then
						local _, res = MonetizationService:PromptPurchase("x8 " .. EggData.Name, "Products"):await()
						if typeof(res) == "table" then
							NotificationController:Notify({
								tag = "Eggs",
								text = res.text,
								type = res.type,
							})
						end
					end
				end
			end
		end
	end)

	local function Hatch(pets, egg)
		self.CurrentEgg = workspace:FindFirstChild(egg, true)
		repeat
			task.wait(1.5)
		until self.Hatching == false and not FightController.IsFighting and not AutoController.IsAutoWinning

		self:Hatch(pets)
	end

	MonetizationService.EggPurchased:Connect(Hatch)
	RewardsService.EggHatched:Connect(Hatch)
	DailyRewardsService.EggHatched:Connect(Hatch)
	FriendsService.EggHatched:Connect(Hatch)
	--SeasonService.EggHatched:Connect(Hatch)
	SpinService.EggHatched:Connect(Hatch)
	--RedeemCandyService.EggPurchased:Connect(Hatch)

	print("[EGGS CONTROLLER] Controller loaded successfully.")
end

return EggsController
