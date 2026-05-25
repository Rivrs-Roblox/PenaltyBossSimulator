local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Sound = require(Packages.Sound)
local DamageIndicator = require(StarterPlayer.StarterPlayerScripts.Client.Modules.DamageIndicator)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local POINTER_SPEED = 1.5 -- Kecepatan pointer (full left to right per second)

local FightUIController = Knit.CreateController({
	Name = "FightUIController",

	_bossIntroGui = nil,
	_fightHud = nil,
	_dynamicBarGui = nil,

	-- Variables For DynamicBarGui
	_pointer = nil,
	_pointerConnection = nil,
	_pointerPosition = 0.5,
	_pointerDirection = 1,

	_damageIndicator = nil,

	-- Intro Effect 3D
	_introEffectModel = nil,
	_introEffectConnection = nil,
})

-- #region Local Functions
local function localTestFunction()
	print("Local Test Function called")
end
-- #endregion Local Functions

-- #region Functions
function FightUIController:SetupGui()
	self._bossIntroGui = playerGui:WaitForChild("BossIntroGui")
	self._fightHud = playerGui:WaitForChild("FightHud")
	self._dynamicBarGui = playerGui:WaitForChild("DynamicBarGui")
	self._pointer = self._dynamicBarGui:WaitForChild("DynamicBar"):WaitForChild("Pointer")
end

function FightUIController:DamageIndicator(ballModel: Model, text: string, color: Color3)
	if not ballModel or not text or not color then
		return
	end

	local camera = workspace.CurrentCamera
	local targetPos = ballModel and ballModel.PrimaryPart.Position or Vector3.zero
	local vector = camera:WorldToViewportPoint(targetPos)
	local viewportPoint = Vector2.new(vector.X, vector.Y)

	self._damageIndicator:Create(text, viewportPoint, self._fightHud, color)
end

function FightUIController:ShowDynamicBar()
	-- Safety: Clean up existing connection if any
	if self._pointerConnection then
		self._pointerConnection:Disconnect()
		self._pointerConnection = nil
	end

	if not self._pointer or not self._dynamicBarGui then
		warn("[FightUIController] UI not setup for ShowDynamicBar")
		return
	end

	-- Reset pointer ke tengah
	self._pointerPosition = 0.5
	self._pointerDirection = 1

	-- Update pointer visual position
	self._pointer.Position = UDim2.new(self._pointerPosition, 0, 0.5, 0)

	-- Show GUI
	self._dynamicBarGui.Enabled = true

	-- Mulai animasi pointer
	self._pointerConnection = RunService.RenderStepped:Connect(function(dt)
		-- Update posisi pointer
		self._pointerPosition += self._pointerDirection * POINTER_SPEED * dt

		-- Bounce di ujung
		if self._pointerPosition >= 1 then
			self._pointerPosition = 1
			self._pointerDirection = -1
		elseif self._pointerPosition <= 0 then
			self._pointerPosition = 0
			self._pointerDirection = 1
		end

		-- Update visual (pointer posisi di dalam DynamicBar)
		self._pointer.Position = UDim2.new(self._pointerPosition, 0, 0.5, 0)
	end)
end

function FightUIController:StopPointer()
	if self._pointerConnection then
		self._pointerConnection:Disconnect()
		self._pointerConnection = nil
	end

	local savedPosition = self._pointerPosition

	-- Flash pointer untuk feedback visual
	if self._pointer then
		local originalColor = self._pointer.BackgroundColor3
		TweenService:Create(self._pointer, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			BackgroundColor3 = Color3.fromRGB(255, 255, 0),
		}):Play()

		task.delay(0.3, function()
			if self._pointer then
				TweenService:Create(self._pointer, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					BackgroundColor3 = originalColor,
				}):Play()
			end
		end)
	end

	return savedPosition
end

function FightUIController:HideDynamicBar()
	-- Stop pointer animation
	if self._pointerConnection then
		self._pointerConnection:Disconnect()
		self._pointerConnection = nil
	end

	-- Hide GUI
	self._dynamicBarGui.Enabled = false
end

function FightUIController:PlayDamageEffectScreen()
	if self._fightHud:FindFirstChild("DamageScreen") then
		self._fightHud.DamageScreen.Visible = true

		task.delay(0.5, function()
			self._fightHud.DamageScreen.Visible = false
		end)
	end
end

function FightUIController:PlaySuccessText(message: string)
	if self._fightHud:FindFirstChild("Succeed") then
		self._fightHud.Succeed.Text = message
		self._fightHud.Succeed.Visible = true

		task.delay(2, function()
			self._fightHud.Succeed.Visible = false
		end)
	end
end

function FightUIController:PlayFailedText(message: string)
	if self._fightHud:FindFirstChild("Failed") then
		self._fightHud.Failed.Text = message
		self._fightHud.Failed.Visible = true

		task.delay(2, function()
			self._fightHud.Failed.Visible = false
		end)
	end
end

function FightUIController:PlayKickResultEffect(result: string)
	local textResult
	local soundName

	-- Map result to text and sound
	if result == "Goal" then
		textResult = self._fightHud:FindFirstChild("Succeed")
		if textResult then
			textResult.Text = "GOAL!"
		end
		soundName = "MISC_Applause_Big"
	elseif result == "GoalBlast" then
		textResult = self._fightHud:FindFirstChild("Succeed")
		if textResult then
			textResult.Text = "BLASTED IN!"
		end
		soundName = "MISC_Applause_Big"
	elseif result == "GoalCorner" then
		textResult = self._fightHud:FindFirstChild("Succeed")
		if textResult then
			textResult.Text = "CORNER GOAL!"
		end
		soundName = "MISC_Applause_Big"
	elseif result == "Saved" then
		textResult = self._fightHud:FindFirstChild("Failed")
		if textResult then
			textResult.Text = "Failed!"
		end
		soundName = "MISC_Booing"
	elseif result == "Missed" then
		textResult = self._fightHud:FindFirstChild("Failed")
		if textResult then
			textResult.Text = "Missed!"
		end
		soundName = "MISC_Booing"
	end

	if soundName then
		Sound:PlaySound(soundName)
	end

	if textResult then
		textResult.Visible = true
		-- Animasi text scale
		textResult.Size = UDim2.new(0.4, 0, 0.08, 0)
		TweenService:Create(textResult, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0.6, 0, 0.12, 0),
		}):Play()

		task.delay(1.5, function()
			textResult.Visible = false
		end)
	end
end

function FightUIController:ShowPenaltyProgress(round: number)
	local penaltyProgress = self._fightHud:FindFirstChild("PenaltyProgress")
	if not penaltyProgress then
		return
	end

	local goals = penaltyProgress:FindFirstChild("Goals")
	if not goals then
		return
	end

	local questText = penaltyProgress:FindFirstChild("QuestText")
	if not questText then
		return
	end

	for i = 1, (round - 1) do
		local goal = goals:FindFirstChild(tostring(i))
		if goal then
			if goal:FindFirstChild("Success") then
				goal.Success.Visible = true
			end
		end
	end

	questText.Text = "Score 5 penalties in a row! (" .. (round - 1) .. "/5)"

	penaltyProgress.Visible = true
end

function FightUIController:HidePenaltyProgress()
	local penaltyProgress = self._fightHud:FindFirstChild("PenaltyProgress")
	if not penaltyProgress then
		return
	end

	penaltyProgress.Visible = false

	local goals = penaltyProgress:FindFirstChild("Goals")
	if not goals then
		return
	end

	local questText = penaltyProgress:FindFirstChild("QuestText")
	if not questText then
		return
	end

	for i = 1, 5 do
		local goal = goals:FindFirstChild(tostring(i))
		if goal then
			if goal:FindFirstChild("Success") then
				goal.Success.Visible = false
			end
			if goal:FindFirstChild("Fail") then
				goal.Fail.Visible = false
			end
		end
	end

	questText.Text = "Score 5 penalties in a row! (0/5)"
end

-- #endregion

-- #region Boss Intro Functions
function FightUIController:SetupBossIntroGui()
	if not self._bossIntroGui then
		self._bossIntroGui = playerGui:WaitForChild("BossIntroGui")
	end

	-- 3D Intro Effect Setup
	if not self._introEffectModel then
		local original = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("IntroEffect")
		self._introEffectModel = original:Clone()
		self._introEffectModel.Parent = workspace.CurrentCamera
	end

	-- Lock to Camera
	if self._introEffectConnection then
		self._introEffectConnection:Disconnect()
	end

	self._introEffectConnection = RunService.RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		if self._introEffectModel and self._introEffectModel.PrimaryPart then
			-- Pola Gacha: Gunakan CFrame kamera sebagai base, lalu kalikan dengan offset lokal
			-- Jarak -5 berarti 5 unit di DEPAN kamera (Sumbu Z negatif adalah arah depan di Roblox)
			local offset = CFrame.new(0, 0, -1)

			-- Jika model kamu terbalik, tambahkan rotasi 180 derajat seperti di Gacha
			local rotation = CFrame.Angles(0, math.rad(180), 0)

			local targetCFrame = camera.CFrame * offset * rotation
			self._introEffectModel:PivotTo(targetCFrame)
		end
	end)

	if self._bossIntroGui and self._bossIntroGui.BossName then
		self._bossIntroGui.BossName.TextTransparency = 1
		if self._bossIntroGui.BossName.UIStroke then
			self._bossIntroGui.BossName.UIStroke.Transparency = 1
		end
		self._bossIntroGui.Enabled = true
	end
end

function FightUIController:TweenCinematicFrames(duration: number, ySize: number)
	if not self._introEffectModel then
		return
	end

	local bar1 = self._introEffectModel:FindFirstChild("Bar1")
	local bar2 = self._introEffectModel:FindFirstChild("Bar2")

	if bar1 and bar2 then
		TweenService:Create(bar1, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(bar1.Size.X, ySize, bar1.Size.Z),
		}):Play()

		TweenService:Create(bar2, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(bar2.Size.X, ySize, bar2.Size.Z),
		}):Play()
	end

	-- Matikan UI frames jika masih ada
	for _, cinematicFrame in self._bossIntroGui:GetChildren() do
		if cinematicFrame:IsA("Frame") then
			cinematicFrame.Visible = false
		end
	end
end

function FightUIController:FadeInBossNameIntro(name: string)
	if not self._bossIntroGui or not self._bossIntroGui:FindFirstChild("BossName") then
		return
	end

	self._bossIntroGui.BossName.Text = name

	local tweenInfo = TweenInfo.new(0.5)
	TweenService:Create(self._bossIntroGui.BossName, tweenInfo, { TextTransparency = 0 }):Play()
	if self._bossIntroGui.BossName.UIStroke then
		TweenService:Create(self._bossIntroGui.BossName.UIStroke, tweenInfo, { Transparency = 0 }):Play()
	end
end

function FightUIController:FadeOutBossNameIntro()
	if not self._bossIntroGui or not self._bossIntroGui.BossName then
		return
	end

	local tweenInfo = TweenInfo.new(0.5)
	local fadeOut = TweenService:Create(self._bossIntroGui.BossName, tweenInfo, { TextTransparency = 1 })
	if self._bossIntroGui.BossName.UIStroke then
		TweenService:Create(self._bossIntroGui.BossName.UIStroke, tweenInfo, { Transparency = 1 }):Play()
	end

	fadeOut:Play()

	-- Cleanup 3D Effects
	if self._introEffectConnection then
		self._introEffectConnection:Disconnect()
		self._introEffectConnection = nil
	end

	if self._introEffectModel then
		self._introEffectModel:Destroy()
		self._introEffectModel = nil
	end

	fadeOut.Completed:Wait()

	self._bossIntroGui.Enabled = false
end
-- #endregion

-- #region Knit Lifecycle
function FightUIController:KnitInit()
	print("FightUIController Initialized")
end

function FightUIController:KnitStart()
	if player.Character then
		self:SetupGui()
	end

	player.CharacterAdded:Connect(function()
		self:SetupGui()
	end)

	self._damageIndicator = DamageIndicator.new()

	print("FightUIController Started")
end
-- #endregion Knit Lifecycle

return FightUIController
