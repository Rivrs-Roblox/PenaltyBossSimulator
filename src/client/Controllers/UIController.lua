--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

--Services
local DataService = nil

--Controllers
local DataCacheController = nil
local NotificationController = nil
local FightController = nil
local TradeController = nil

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.UIActions)
local NotificationActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.NotificationActions)
local AllRewardsActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.AllRewardsActions)

-- Helpers
local FormatNumber = require(ReplicatedStorage.Shared.Helpers.Numbers.FormatNumber)

---Cache
local TopFrameSizeInit = false
local TopFrameSize = nil

local BottomFrameSizeInit = false
local BottomFrameSize = nil
local isUIShown = false
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

local blockBuyArea = false

-- UIController
local UIController = Knit.CreateController({
	Name = "UIController",
	Template = {},
	Images = {},
	ActiveTweens = {
		impactTweens = {},
		displaySizeTweens = {},
	},
})
--|| Local Functions ||--
local function IsPlayerOnMobile()
	return UserInputService.TouchEnabled
end

--|| Functions ||--
function UIController:RemoveHUD(params: {})
	setmetatable(params, { __index = { ignoreTopFrame = true, ignoreBottomFrame = true } })
	local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0)

	task.delay(0.2, function()
		isUIShown = false
	end)
	local LeftTween = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.LeftFrame,
		Info,
		{ ["Position"] = UDim2.fromScale(-0.165, 0.5) }
	)
	local RightTween = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.RightFrame,
		Info,
		{ ["Position"] = UDim2.fromScale(1.584, 0.5) }
	)
	local TopFrame = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.TopFrame,
		Info,
		{ ["Position"] = UDim2.fromScale(0, -1.075) }
	)
	local BottomFrame = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.BottomFrame,
		Info,
		{ ["Position"] = UDim2.fromScale(0.5, 1.25) }
	)

	LeftTween:Play()
	RightTween:Play()
	if params.ignoreBottomFrame == false then
		BottomFrame:Play()
	end
	if params.ignoreTopFrame == false then
		TopFrame:Play()
	end
end

function UIController:ShowHUD()
	local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0)

	task.delay(0.2, function()
		isUIShown = true
	end)
	local LeftTween = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.LeftFrame,
		Info,
		{ ["Position"] = if IsPlayerOnMobile() then UDim2.fromScale(0.01, 0.42) else UDim2.fromScale(0.01, 0.42) }
	)
	local RightTween = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.RightFrame,
		Info,
		{ ["Position"] = if IsPlayerOnMobile() then UDim2.fromScale(0.99, 0.42) else UDim2.fromScale(0.99, 0.42) }
	)
	local TopFrame = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.TopFrame,
		Info,
		{ ["Position"] = UDim2.fromScale(0.5, 0) }
	)
	local BottomFrame = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.BottomFrame,
		Info,
		{ ["Position"] = UDim2.fromScale(0.5, 0.99) }
	)

	if not FightController.IsFighting then
		LeftTween:Play()
		RightTween:Play()
	end

	BottomFrame:Play()
	TopFrame:Play()
end

function UIController:HideBottomFrame()
	local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0)
	local BottomFrame = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.BottomFrame,
		Info,
		{ ["Position"] = UDim2.fromScale(0.5, 1.25) }
	)
	BottomFrame:Play()
	BottomFrame.Completed:Connect(function()
		BottomFrame:Destroy()
	end)
end

function UIController:ShowBottomFrame()
	local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0)

	local BottomFrame = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.BottomFrame,
		Info,
		{ ["Position"] = if IsPlayerOnMobile() then UDim2.fromScale(0.5, 0.85) else UDim2.fromScale(0.5, 0.895) }
	)
	BottomFrame:Play()
	BottomFrame.Completed:Connect(function()
		BottomFrame:Destroy()
	end)
end

function UIController:HideFrame()
	self:ShowHUD()
	--:ResetCamera()
	Store:dispatch(UIActions.resetCurrentUI())
end

function UIController:JustHideFrame()
	Store:dispatch(UIActions.resetCurrentUI())
end

function UIController:ShowFrame(params: {})
	setmetatable(params, { __index = { frame = nil } })

	if FightController.IsFighting and params.frame ~= "Battle" then
		return
	end

	if TradeController.IsTrading then
		return
	end

	if params.frame == nil then
		return print("Frame", params.frame, "is NULL")
	end

	

	if params.frame ~= "Battle" then
		self:RemoveHUD({ ignoreTopFrame = true })
		--print("Frame Battle Detected")
	end

	if params.frame == "DailyRewards" then
		--Store:dispatch(AllRewardsActions.setAllRewards("DailyRewards"))
		Store:dispatch(UIActions.setCurrentUI("DailyRewards"))
		return
	end

	if params.frame == "Aura" or params.frame == "Trails" then
		task.wait(0.3)
		--CameraController:SetCameraPreviewDance()
	end
	Store:dispatch(UIActions.setCurrentUI(params.frame))

	if params.frame == "Store" then
		Store:dispatch(NotificationActions.setNotification("Store", nil))
	end
end

function UIController:ShowNewClickUnlock()
	local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0)

	local NewClickFrameTween = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.NewClickFrame,
		Info,
		{ ["Position"] = UDim2.fromScale(0.08, 0.70) }
	)

	NewClickFrameTween:Play()

	task.delay(15, function()
		NewClickFrameTween = TweenService:Create(
			Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.NewClickFrame,
			Info,
			{ ["Position"] = UDim2.fromScale(-0.3, 0.70) }
		)
		NewClickFrameTween:Play()
	end)
end

function UIController:InitTopFrameSize(size)
	if not TopFrameSizeInit then
		TopFrameSize = size
		TopFrameSizeInit = true
	end
end

function UIController:InitBottomFrameSize(size)
	if not BottomFrameSizeInit then
		BottomFrameSize = size
		BottomFrameSizeInit = true
	end
end

function UIController:HideNewClickFrame()
	local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0)
	local NewClickFrameTween = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.NewClickFrame,
		Info,
		{ ["Position"] = UDim2.fromScale(-0.3, 0.70) }
	)
	NewClickFrameTween:Play()
end

function UIController:IsCurrentFrame(name)
	return Store:getState()["UIReducer"].CurrentUI == name
end

function UIController:MakeImpactRectangleClickButton()
	-- Cancel and destroy any existing impact tweens
	for _, tween in pairs(self.ActiveTweens.impactTweens) do
		if tween.Instance then
			tween:Cancel()
			tween:Destroy()
		end
	end
	-- Clear the tweens table
	table.clear(self.ActiveTweens.impactTweens)

	local BottomFrame = Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.BottomFrame
	local ImpactFrame = Instance.new("Frame", Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui"))
	ImpactFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	ImpactFrame.BackgroundColor3 = Color3.fromRGB(136, 206, 250)
	ImpactFrame.BackgroundTransparency = 0.7
	ImpactFrame.Size = BottomFrame.Size - UDim2.fromScale(0, 0.14)
	ImpactFrame.Position = BottomFrame.Position - UDim2.fromScale(0.01, 0)

	local UICorner = Instance.new("UICorner", ImpactFrame)
	UICorner.CornerRadius = UDim.new(0.25, 0)

	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint", ImpactFrame)
	UIAspectRatioConstraint.AspectRatio = 1

	local TweenInf = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0)
	local TweenImpact = TweenService:Create(
		ImpactFrame,
		TweenInf,
		{ Size = BottomFrame.Size + UDim2.fromScale(0.08, 0.08), BackgroundTransparency = 1 }
	)

	self.ActiveTweens.impactTweens[1] = TweenImpact

	TweenImpact:Play()
	TweenImpact.Completed:Connect(function()
		ImpactFrame:Destroy()
	end)
end

function UIController:TweenTopDisplaySize(currency)
	-- Cancel and destroy any existing display size tweens
	for _, tween in pairs(self.ActiveTweens.displaySizeTweens) do
		if tween.Instance then
			tween:Cancel()
			tween:Destroy()
		end
	end
	-- Clear the tweens table
	table.clear(self.ActiveTweens.displaySizeTweens)

	local TopFrame = Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.TopFrame
	local FrameToTween = TopFrame:FindFirstChild(currency)

	self:InitTopFrameSize(FrameToTween.Size)

	local TweenInf2 = TweenInfo.new(0.14, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
	local TweenInf1 = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

	local TweenSizeUp =
		TweenService:Create(FrameToTween, TweenInf1, { Size = TopFrameSize + UDim2.fromScale(0.15, 0.15) })

	local TweenSizeDown = TweenService:Create(FrameToTween, TweenInf2, { Size = TopFrameSize })

	self.ActiveTweens.displaySizeTweens[1] = TweenSizeUp
	self.ActiveTweens.displaySizeTweens[2] = TweenSizeDown

	TweenSizeDown.Completed:Connect(function()
		TweenSizeDown:Destroy()
	end)

	TweenSizeUp:Play()
	TweenSizeUp.Completed:Connect(function()
		TweenSizeDown:Play()
		TweenSizeUp:Destroy()
	end)
end

function UIController:ChangeShopCanvaPosition(number: number)
	local ShopScrollFrame =
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").Store.Content.Container.ShopScroll
	local Info = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0)
	local TweenCanva = TweenService:Create(ShopScrollFrame, Info, {
		["CanvasPosition"] = Vector2.new(
			math.abs((ShopScrollFrame.CanvasSize.Y.Offset - ShopScrollFrame.AbsoluteSize.Y) * number),
			0
		),
	})
	TweenCanva:Play()
end

function UIController:TweenBottomButtomSize()
	local BottomFrame = Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").HUD.BottomFrame
	local BottomButtom = BottomFrame.Click

	self:InitBottomFrameSize(BottomButtom.Size)

	local TweenInf2 = TweenInfo.new(0.14, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
	local TweenInf1 = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
	local TweenSizeUp =
		TweenService:Create(BottomButtom, TweenInf1, { Size = BottomFrameSize + UDim2.fromScale(0.15, 0.15) })

	local TweenSizeDown = TweenService:Create(BottomButtom, TweenInf2, { Size = BottomFrameSize })
	TweenSizeUp:Play()
	TweenSizeUp.Completed:Connect(function()
		UIController:MakeImpactRectangleClickButton()
		TweenSizeDown:Play()
	end)
end

function UIController:BuyArea(area)
	if blockBuyArea then
		NotificationController:Notify({
			tag = "BuyArea",
			text = "Please wait while your purchase is being processed",
			type = "ERROR",
		})
		return
	end

	blockBuyArea = true

	DataService:GetData(Players.LocalPlayer):andThen(function(data)
		local unlockedZones = data.Areas and data.Areas.Unlocked or { "Zone1" }
		local lastUnlocked = unlockedZones[#unlockedZones]
		local lastUnlockedNumber = tonumber(string.match(lastUnlocked, "%d+"))
		local zoneNumber = tonumber(string.match(area.Id, "%d+"))

		if (zoneNumber - 1) ~= lastUnlockedNumber then
			NotificationController:Notify({
				tag = "BuyArea",
				text = "You must unlock previous zone first!",
				type = "ERROR",
			})
			blockBuyArea = false
			return
		end

		-- Check if player has beaten all bosses in the previous zone
		local prevAreaId = string.format("Area%02d", lastUnlockedNumber)
		local enemies = self.Template and self.Template.Enemies
		local areaEnemies = enemies and enemies[prevAreaId]

		if areaEnemies then
			local maxBossCount = 0
			for enemyKey, _ in pairs(areaEnemies) do
				local bIndex = tonumber(string.match(enemyKey, "Boss%s+(%d+)"))
					or tonumber(string.match(enemyKey, "MiniBoss%s+(%d+)"))
				if bIndex and bIndex > maxBossCount then
					maxBossCount = bIndex
				elseif enemyKey == "Boss" and 5 > maxBossCount then
					maxBossCount = 5
				end
			end

			local progress = data.BossProgress and data.BossProgress[prevAreaId] or 0
			if progress < maxBossCount then
				NotificationController:Notify({
					tag = "BuyArea",
					text = "You must beat all bosses in the previous zone first!",
					type = "ERROR",
				})
				blockBuyArea = false
				return
			end
		end

		if data.Wins >= area.Price then
			DataService:AddArea(area.Id)
			NotificationController:Notify({
				tag = "BuyArea",
				text = "You unlocked " .. area.Name .. "!",
				type = "SUCCESS",
			})
			blockBuyArea = false
		else
			NotificationController:Notify({
				tag = "BuyArea",
				text = "You need " .. FormatNumber(area.Price - data.Wins) .. " more Wins!",
				type = "ERROR",
			})
			blockBuyArea = false
		end
	end)
end

--|| Knit Lifecycle ||--
function UIController:KnitInit()
	DataService = Knit.GetService("DataService")
end

function UIController:KnitStart()
	--CameraController = Knit.GetController("CameraController")
	DataCacheController = Knit.GetController("DataCacheController")
	NotificationController = Knit.GetController("NotificationController")
	FightController = Knit.GetController("FightController")
	TradeController = Knit.GetController("TradeController")

	self.Images = DataCacheController:GetFile("Images")
	self.Template = DataCacheController:GetFile("Template")

	task.delay(60 * 6, function()
		repeat
			task.wait()
		until isUIShown and not FightController.IsFighting
		UIController:ShowFrame({ frame = FramesConstants.StarterPack })
		self.ShowHUD()
	end)

	-- task.delay(60 * 12, function()
	-- 	repeat
	-- 		task.wait()
	-- 	until isUIShown and not FightController.IsFighting
	-- 	UIController:ShowFrame({ frame = FramesConstants.ExclusivePack })
	-- 	self.ShowHUD()
	-- end)

	print("[TELEPORT CONTROLLER] Controller loaded successfully.")
end

return UIController
