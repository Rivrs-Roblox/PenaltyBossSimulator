-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local Sound = require(Packages.Sound)
local Confetti = require(ReplicatedStorage.Shared.Helpers.Confetti)

-- Player
local player = Players.LocalPlayer

local AssetFolder = ReplicatedStorage.Assets

local DataService
local ExitGiftService
local FightService

local NotificationController

local giftModelPool = {}

-- ExitGiftController
local ExitGiftController = Knit.CreateController({
	Name = "ExitGiftController",

	shakeTween = nil,
	giftModel = nil,
	giftPrompt = nil,
	IsInLobby = true,
	IsClaiming = false,
})

--|| Local Functions ||--
local function findGroundBelow(pos, maxDistance)
	local RaycastParams = RaycastParams.new()
	RaycastParams.FilterDescendantsInstances = { player.Character } -- ignore player
	RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	RaycastParams.IgnoreWater = false

	local origin = pos + Vector3.new(0, 1, 0) -- mulai sedikit di atas pivot
	local direction = Vector3.new(0, -1, 0) * maxDistance

	local result = workspace:Raycast(origin, direction, RaycastParams)
	if result and result.Position then
		return result.Position, result.Normal, result.Instance
	end
	return nil
end

local function getGiftModelFromPool()
	if #giftModelPool > 0 then
		return table.remove(giftModelPool)
	else
		local giftModel = AssetFolder:FindFirstChild("ExitGift")
		if giftModel then
			return giftModel:Clone()
		end
	end

	return nil
end

local function returnGiftModelToPool(giftModel)
	giftModel.Parent = nil
	table.insert(giftModelPool, giftModel)
end

--|| Functions ||--
function ExitGiftController:SpawnGiftModel()
	if not self.giftModel then
		local giftModel = getGiftModelFromPool()
		if giftModel then
			giftModel.Parent = workspace

			local primaryPart = giftModel.PrimaryPart
			if not primaryPart then
				primaryPart = giftModel:FindFirstChildWhichIsA("Part", true)
				if primaryPart then
					giftModel.PrimaryPart = primaryPart
				end
			end

			if not primaryPart then
				warn("[ExitGift] ExitGift model tidak punya PrimaryPart/BasePart")
				returnGiftModelToPool(giftModel)
				return
			end

			local oldPrompt = primaryPart:FindFirstChild("ProximityPrompt")
			if oldPrompt then
				oldPrompt:Destroy()
			end

			local prompt = Instance.new("ProximityPrompt")
			prompt.Name = "ExitGiftPrompt"
			prompt.ActionText = "Claim Gift"
			prompt.ObjectText = "Exit Gift"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.HoldDuration = 0
			prompt.MaxActivationDistance = 10
			prompt.RequiresLineOfSight = false
			prompt.Enabled = true
			prompt.Parent = primaryPart

			self.giftPrompt = prompt

			print("SpawnPrompt")

			self.giftModel = giftModel
		end
	end

	local success, playerPivot = pcall(function()
		return player.Character:GetPivot()
	end)

	local basePos = (success and playerPivot or CFrame.new(0, 0, -50)).Position

	-- cari ground sampai 50 studs bawah
	local groundPos = findGroundBelow(basePos, 50)

	if not groundPos then
		-- gagal raycast (mis. di udara) -> pakai fallback: posisi pivot tapi pakai Y 0 (world floor)
		groundPos = Vector3.new(basePos.X, 0, basePos.Z)
	end

	local targetCFrame = CFrame.new(groundPos)
	self.giftModel:PivotTo(targetCFrame)
end

function ExitGiftController:ShowFrame()
	if self._shown then
		return
	end

	self._shown = true

	local Info = TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0)
	local TweenFrame = TweenService:Create(
		Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").ExitGift,
		Info,
		{ ["Position"] = UDim2.fromScale(0.5, 0.4) }
	)

	Sound:PlaySound("MISC_Exit_Gift")

	TweenFrame:Play()
	TweenFrame.Completed:Connect(function()
		TweenFrame:Destroy()
	end)

	Confetti(50)

	local shakeInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 5, true, 0)

	local exitGiftFrame = Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").ExitGift

	if self.shakeTween then
		self.shakeTween:Cancel()
		self.shakeTween:Destroy()
		self.shakeTween = nil
	end

	-- Force reset rotation to 0 before starting the new shake tween
	exitGiftFrame.Rotation = 0

	local thisTween = TweenService:Create(exitGiftFrame, shakeInfo, { Rotation = 5 })
	self.shakeTween = thisTween

	thisTween:Play()

	thisTween.Completed:Connect(function(playbackState)
		-- 1. Ignore if the tween was cancelled (avoids duplicate trigger on Cancel())
		if playbackState ~= Enum.PlaybackState.Completed then
			return
		end

		task.wait(1)

		-- 2. Verify that this thread's tween is still the active tween (avoids overlapping race conditions)
		if self.shakeTween == thisTween then
			thisTween:Play()
		end
	end)
end

function ExitGiftController:HideFrame()
	if not self._shown then
		return
	end

	self._shown = false

	local exitGiftFrame = Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui").ExitGift

	if self.shakeTween then
		self.shakeTween:Cancel()
		self.shakeTween:Destroy()
		self.shakeTween = nil
	end

	-- Force reset rotation back to 0 on hide so it slides down straight and resets cleanly
	exitGiftFrame.Rotation = 0

	local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0)
	local TweenFrame = TweenService:Create(exitGiftFrame, Info, { ["Position"] = UDim2.fromScale(0.5, 1.35) })
	TweenFrame:Play()
	TweenFrame.Completed:Connect(function()
		TweenFrame:Destroy()
	end)
end

function ExitGiftController:KnitInit()
	DataService = Knit.GetService("DataService")
	ExitGiftService = Knit.GetService("ExitGiftService")
	FightService = Knit.GetService("FightService")
	NotificationController = Knit.GetController("NotificationController")
end

function ExitGiftController:KnitStart()
	local currentData = nil

	DataService:GetData():andThen(function(data)
		currentData = data
	end)

	if FightService.PlayerTeleported then
		FightService.PlayerTeleported:Connect(function()
			self.IsInLobby = true
		end)
	end

	if FightService.FightStarted then
		FightService.FightStarted:Connect(function()
			self.IsInLobby = false
		end)
	end

	GuiService.MenuOpened:Connect(function()
		print("menuOpened")
		if not currentData or currentData.ExitGiftClaimed then
			return
		end

		if not self.IsInLobby then
			return
		end
		print("Show")

		self:SpawnGiftModel()
		self:ShowFrame()
	end)

	ProximityPromptService.PromptTriggered:Connect(function(prompt, playerWhoTriggered)
		if prompt ~= self.giftPrompt then
			return
		end

		print("triggered")

		if playerWhoTriggered ~= nil and playerWhoTriggered ~= player then
			return
		end

		if self.IsClaiming then
			return
		end

		self.IsClaiming = true

		ExitGiftService:ClaimExitGift()
			:andThen(function(response)
				self.IsClaiming = false

				if response then
					NotificationController:Notify(response)
				end

				if response and response.type == "SUCCESS" then
					if currentData then
						currentData.ExitGiftClaimed = true
					end

					if self.giftPrompt then
						self.giftPrompt:Destroy()
						self.giftPrompt = nil
					end

					if self.giftModel then
						returnGiftModelToPool(self.giftModel)
						self.giftModel = nil
					end

					self:HideFrame()
				end
			end)
			:catch(function(err)
				self.IsClaiming = false
				warn("[ExitGift] Claim failed:", err)
			end)
	end)

	ExitGiftService.ExitGiftClaimed:Connect(function()
		if currentData then
			currentData.ExitGiftClaimed = true
		end
	end)

	print("[EXIT GIFT CONTROLLER] Controller loaded successfully.")
end

return ExitGiftController
