-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Sound = require(Packages.Sound)
local Zone = require(ReplicatedStorage.Shared.ZonePlus)

-- Services
local TrainingService
local BallService

-- Controllers
local NotificationController
local AutoController
local CharactersController
local TrailsController
local FightController

-- Player
local player = Players.LocalPlayer
local playerGui = player:FindFirstChildOfClass("PlayerGui")

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

-- Signals
local AutoTrainingSignals = require(ReplicatedStorage.Shared.Signals.AutoTrainingSignals)
local TrainingSignals = require(ReplicatedStorage.Shared.Signals.TrainingSignals)

local trainingAreas = {}
local activePrompt
local currentTrainingArea
local trainingAnimationTrack
local cooldown = false
local hideConnections = {}
local humanoidJumpConnection
local animationSpeed = 1
local lastClickTime = 0

local animationCache = {
	[1] = Instance.new("Animation"),
	[2] = Instance.new("Animation"),
	[3] = Instance.new("Animation"),
	[4] = Instance.new("Animation"),
}

local HOLD_DURATION = 0.5
local COOLDOWN_TIME = 0.45
local TRAINING_1_ANIMATION_ID = "rbxassetid://90962989306225"
local TRAINING_2_ANIMATION_ID = "rbxassetid://90962989306225"
local TRAINING_3_ANIMATION_ID = "rbxassetid://90962989306225"
local TRAINING_4_ANIMATION_ID = "rbxassetid://90962989306225"
local ANIMATION_SPEED_DECAY = 0.5
local ANIMATION_SPEED_INCREASE = 0.25
local BEAM_SPEED = 2

animationCache[1].Name = "TrainingAnim1"
animationCache[1].AnimationId = TRAINING_1_ANIMATION_ID

animationCache[2].Name = "TrainingAnim2"
animationCache[2].AnimationId = TRAINING_2_ANIMATION_ID

animationCache[3].Name = "TrainingAnim3"
animationCache[3].AnimationId = TRAINING_3_ANIMATION_ID

animationCache[4].Name = "TrainingAnim4"
animationCache[4].AnimationId = TRAINING_4_ANIMATION_ID

-- TrainingController
local TrainingController = Knit.CreateController({
	Name = "TrainingController",
	IsTraining = false,
	IsAutoTrain = false,
})

--|| Local Functions ||--

local function playTrainingAnimation(index: number)
	if trainingAnimationTrack then
		trainingAnimationTrack:Stop()
		trainingAnimationTrack:Destroy()
		trainingAnimationTrack = nil
	end

	local anim = animationCache[index]
	if not anim then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Name = "TrainingAnimator"
		animator.Parent = humanoid
	end

	local tracks = animator:GetPlayingAnimationTracks()
	for _, track in ipairs(tracks) do
		if track.Name:find("TrainingAnim") then
			track:Stop()
			track:Destroy()
		end
	end

	trainingAnimationTrack = animator:LoadAnimation(anim)
	trainingAnimationTrack.Priority = Enum.AnimationPriority.Action
	trainingAnimationTrack:Play()
end

local function stopTrainingAnimation()
	if trainingAnimationTrack then
		trainingAnimationTrack:Stop()
		trainingAnimationTrack:Destroy()
		trainingAnimationTrack = nil
	end
end

local function startTrainingAreaVisual(trainingArea)
	print("StartAreaVisual")
	local index = trainingArea:GetAttribute("Index")

	TrainingService:StartTraining(trainingArea)

	if index == 1 then
		--local beam = trainingArea.Parent:FindFirstChild("Beam")
		--beam.TextureSpeed = BEAM_SPEED
	elseif index == 3 then
		for _, descendant in ipairs(trainingArea.Parent:GetDescendants()) do
			if descendant:IsA("MeshPart") then
				descendant.CanCollide = false
			end
		end
	else
		if index == 4 then
			for _, descendant in ipairs(trainingArea.Parent:GetDescendants()) do
				if descendant:IsA("MeshPart") then
					descendant.CanCollide = false
				end
			end
		end
	end
end

local function stopTrainingAreaVisual(trainingArea)
	if trainingArea == nil then
		print("Training area is nil")
		return
	end
	local index = trainingArea:GetAttribute("Index")

	TrainingService:StopTraining(trainingArea)

	if index == 1 then
		--local beam = trainingArea.Parent:FindFirstChild("Beam")
		--beam.TextureSpeed = 0
	elseif index == 3 then
		for _, descendant in ipairs(trainingArea.Parent:GetDescendants()) do
			if descendant:IsA("MeshPart") and not descendant:FindFirstAncestor("Boost") then
				descendant.CanCollide = true
			end
		end
	else
		if index == 4 then
			for _, descendant in ipairs(trainingArea.Parent:GetDescendants()) do
				if descendant:IsA("MeshPart") and not descendant:FindFirstAncestor("Boost") then
					descendant.CanCollide = true
				end
			end
		end
	end
end

local function increaseTrainingSpeed()
	local index = currentTrainingArea:GetAttribute("Index")
	local maxSpeed = if index == 1 then 3 else 6

	animationSpeed += ANIMATION_SPEED_INCREASE
	animationSpeed = math.clamp(animationSpeed, 1, maxSpeed)

	if trainingAnimationTrack then
		trainingAnimationTrack:AdjustSpeed(animationSpeed)
	else
		--playTrainingAnimation(index)
	end

	if index == 1 then
		--local beam = currentTrainingArea.Parent:FindFirstChild("Beam")
		--beam.TextureSpeed = BEAM_SPEED * animationSpeed
	end
end

local function decreaseTrainingSpeed()
	local index = currentTrainingArea:GetAttribute("Index")
	animationSpeed -= ANIMATION_SPEED_DECAY
	animationSpeed = math.clamp(animationSpeed, 1, 3)

	if trainingAnimationTrack then
		trainingAnimationTrack:AdjustSpeed(animationSpeed)
	else
		--playTrainingAnimation(index)
	end

	if index == 1 then
		--local beam = currentTrainingArea.Parent:FindFirstChild("Beam")
		--beam.TextureSpeed = BEAM_SPEED * animationSpeed
	end
end

local function requestTrainingBallShot()
	if not currentTrainingArea then
		return
	end

	if FightController and FightController.IsFighting then
		return
	end

	TrainingService:ShootTrainingBall(currentTrainingArea)
end

--|| Functions ||--
function TrainingController:StartTraining(trainingArea, isTransport)
	print(trainingArea:GetAttribute("Index"))
	if currentTrainingArea == trainingArea and self.IsTraining then
		return
	end

	currentTrainingArea = trainingArea

	-- disableMovement()
	-- hideOtherPlayers()

	self.IsTraining = true

	-- Deteksi lompat (lebih aman untuk mobile)
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	if humanoid then
		humanoidJumpConnection = humanoid.Jumping:Connect(function(isJumping)
			if isJumping and self.IsTraining then
				TrainingSignals.TrainingStopped:Fire(trainingArea)
				self:StopTraining(trainingArea)

				if AutoController.IsAutoTraining then
					AutoController:AutoTrain()
				end
			end
		end)
	end

	if activePrompt then
		activePrompt.Enabled = false
	end

	local pivot = trainingArea:FindFirstChild("Pivot")
	local character = player.Character

	if pivot and character then
		player:RequestStreamAroundAsync(pivot.Position)
		if isTransport then
			self.IsAutoTrain = true
			character:PivotTo(pivot.CFrame)
		end
	end

	local index = trainingArea:GetAttribute("Index")
	--playTrainingAnimation(index)
	startTrainingAreaVisual(trainingArea)

	-- Mulai loop training
	task.spawn(function()
		while self.IsTraining do
			TrainingService:Training(trainingArea)

			requestTrainingBallShot()
			task.wait(1.5)
		end
	end)

	TrainingSignals.TrainingStarted:Fire(trainingArea)
end

function TrainingController:StopTraining(trainingArea)
	--enableMovement()
	-- showOtherPlayers()

	TrainingSignals.TrainingStopped:Fire(trainingArea)
	self.IsTraining = false

	if humanoidJumpConnection then
		humanoidJumpConnection:Disconnect()
		humanoidJumpConnection = nil
	end

	if activePrompt then
		activePrompt.Enabled = true
		activePrompt = nil -- reset setelah dipakai
	end

	--stopTrainingAnimation()
	stopTrainingAreaVisual(trainingArea)

	if currentTrainingArea then
		currentTrainingArea = nil
	end

	animationSpeed = 1
end

function TrainingController:ClickTraining()
	if self.IsTraining then
		lastClickTime = os.clock()

		Sound:PlaySound("UI_Click")

		if currentTrainingArea and not cooldown then
			TrainingService:Training(currentTrainingArea)

			requestTrainingBallShot()
			cooldown = true

			increaseTrainingSpeed()

			task.delay(COOLDOWN_TIME, function()
				cooldown = false
			end)
		end
	end
end

--|| Knit Lifecycle ||--
function TrainingController:KnitStart()
	BallService = Knit.GetService("BallService")
	TrainingService = Knit.GetService("TrainingService")
	TrainingService.InsufficientPower:Connect(function(amount)
		NotificationController:Notify({
			tag = "Training",
			text = "You need " .. FormatNumber(amount) .. " more power!",
			type = "ERROR",
		})
	end)

	NotificationController = Knit.GetController("NotificationController")
	AutoController = Knit.GetController("AutoController")
	CharactersController = Knit.GetController("CharactersController")
	TrailsController = Knit.GetController("TrailsController")
	FightController = Knit.GetController("FightController")

	AutoTrainingSignals.AutoTrainingStopped:Connect(function()
		if currentTrainingArea then
			self:StopTraining(currentTrainingArea)
		end
	end)

	-- Animasi training mengikuti lifecycle bola dari BallService.
	-- Logic paksa hadap dan validasi training sekarang ada di TrainingService.
	BallService.BallWindupStarted:Connect(function()
		playTrainingAnimation(1)
	end)

	BallService.BallFinished:Connect(function()
		stopTrainingAnimation()
	end)

	task.spawn(function()
		local function setupArea(trainingArea)
			local zonePart = trainingArea:FindFirstChild("Zone") or trainingArea
			local zone = Zone.new(zonePart)
			zone:setDetection("Centre")
			-- MASUK ZONE
			zone.playerEntered:Connect(function(plr)
				if plr ~= player then
					return
				end

				TrainingService:CheckAvailability(trainingArea):andThen(function(value)
					if value then
						self:StartTraining(trainingArea)

						self.IsAutoTrain = false
					end
				end)
			end)

			--  KELUAR ZONE
			zone.playerExited:Connect(function(plr)
				if plr ~= player then
					return
				end
				TrainingSignals.TrainingStopped:Fire(trainingArea)

				if AutoController.IsAutoTraining and not self.IsAutoTrain then
					AutoController:AutoTrain()
				end
				self:StopTraining(currentTrainingArea)
			end)
			table.insert(trainingAreas, trainingArea)
		end

		for _, area in CollectionService:GetTagged("TrainingArea") do
			setupArea(area)
		end

		CollectionService:GetInstanceAddedSignal("TrainingArea"):Connect(setupArea)
	end)

	task.spawn(function()
		while true do
			if AutoController.IsAutoTraining then
				TrainingService:GetMostEffectiveArea():andThen(function(effectiveTrainingArea)
					for _, trainingArea in pairs(trainingAreas) do
						local area = trainingArea:GetAttribute("Area")

						if effectiveTrainingArea.area ~= area then
							continue
						end

						local index = trainingArea:GetAttribute("Index")

						if effectiveTrainingArea.index ~= index then
							continue
						end

						if currentTrainingArea then
							local currentArea = currentTrainingArea:GetAttribute("Area")
							local currentIndex = currentTrainingArea:GetAttribute("Index")

							if
								effectiveTrainingArea.area ~= currentArea
								or effectiveTrainingArea.index ~= currentIndex
							then
								self:StopTraining(currentTrainingArea)

								return
							end
						end

						--local proximityPrompt = trainingArea:FindFirstChildOfClass("ProximityPrompt")
						--activePrompt = proximityPrompt

						self:StartTraining(trainingArea, true)
						break
					end
				end)
			end

			task.wait(2)
		end
	end)

	-- Deteksi input tombol kiri mouse
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if UserInputService:GetFocusedTextBox() then
			return
		end

		if playerGui then
			local mousePosition = UserInputService:GetMouseLocation()
			local guiObjects = playerGui:GetGuiObjectsAtPosition(mousePosition.X, mousePosition.Y)

			for _, gui in ipairs(guiObjects) do
				-- Abaikan input jika menyentuh elemen UI yang aktif, KECUALI BillboardGui
				if
					(gui:IsA("TextButton") or gui:IsA("ImageButton") or gui:IsA("Frame"))
					and gui.Active
					and not gui:FindFirstAncestorOfClass("BillboardGui")
				then
					return -- Klik terjadi pada UI biasa, jangan proses tembakan
				end
			end
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then
			self:ClickTraining()
		end
	end)

	UserInputService.TouchTap:Connect(function(touchPositions, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if UserInputService:GetFocusedTextBox() then
			return
		end

		if playerGui then
			for _, touchPosition in ipairs(touchPositions) do
				local guiObjects = playerGui:GetGuiObjectsAtPosition(touchPosition.X, touchPosition.Y)

				for _, gui in ipairs(guiObjects) do
					if
						(gui:IsA("TextButton") or gui:IsA("ImageButton") or (gui:IsA("Frame") and gui.Active))
						and not gui:FindFirstAncestorOfClass("BillboardGui")
					then
						return -- Sentuhan terjadi pada UI biasa, abaikan
					end
				end
			end
		end

		self:ClickTraining()
	end)

	Players.PlayerRemoving:Connect(function(leavingPlayer)
		local conn = hideConnections[leavingPlayer]
		if conn then
			conn:Disconnect()
			hideConnections[leavingPlayer] = nil
		end
	end)

	task.spawn(function()
		while true do
			if self.IsTraining then
				local timeSinceLastClick = os.clock() - lastClickTime

				if timeSinceLastClick >= 1 then
					decreaseTrainingSpeed()
				end
			end

			task.wait(0.25)
		end
	end)

	-- UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	-- 	if gameProcessedEvent then
	-- 		return
	-- 	end

	-- 	if input.KeyCode == Enum.KeyCode.F then
	-- 		trainingAnimationTrack = nil
	-- 		print("Training animation track reset")
	-- 	elseif input.KeyCode == Enum.KeyCode.C then
	-- 		local character = player.Character
	-- 		if not character then
	-- 			return
	-- 		end

	-- 		local humanoid = character:FindFirstChildOfClass("Humanoid")
	-- 		if not humanoid then
	-- 			return
	-- 		end

	-- 		local animator = humanoid:FindFirstChildOfClass("Animator")
	-- 		if not animator then
	-- 			animator = Instance.new("Animator")
	-- 			animator.Name = "TrainingAnimator"
	-- 			animator.Parent = humanoid
	-- 		end

	-- 		local tracks = animator:GetPlayingAnimationTracks()
	-- 		for _, track in ipairs(tracks) do
	-- 			print("track name:", track.Name)
	-- 		end
	-- 	end
	-- end)
end

return TrainingController
