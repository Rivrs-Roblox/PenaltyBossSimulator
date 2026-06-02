local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Sound = require(Packages.Sound)
local DamageIndicator = require(StarterPlayer.StarterPlayerScripts.Client.Modules.DamageIndicator)
local AimVisuals = require(StarterPlayer.StarterPlayerScripts.Client.Modules.AimVisuals)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local InputController

local FightUIController = Knit.CreateController({
	Name = "FightUIController",

	_bossIntroGui = nil,
	_fightHud = nil,
	_dynamicBarGui = nil,

	-- Variables For DynamicBarGui
	_powerBar = nil,
	_powerPointer = nil,

	_damageIndicator = nil,

	-- 3D Aiming Properties
	_aimVisuals = nil,

	-- Intro Effect 3D
	_introEffectModel = nil,
	_introEffectConnection = nil,
})

-- #region Functions
function FightUIController:SetupGui()
	self._bossIntroGui = playerGui:WaitForChild("BossIntroGui")
	self._fightHud = playerGui:WaitForChild("FightHud")
	self._dynamicBarGui = playerGui:WaitForChild("DynamicBarGui")

	self._powerBar = self._dynamicBarGui:WaitForChild("DynamicBar")
	self._powerPointer = self._powerBar:WaitForChild("Pointer")

	self._countdownFrame = self._powerBar:WaitForChild("CountdownFrame")
	if self._countdownFrame then
		self._countdown = self._countdownFrame:WaitForChild("Countdown")
		if self._countdown then
			self._originalCountdownSize = self._countdown.Size
		end
	end
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

function FightUIController:Cleanup3DAiming()
	if self._aimVisuals then
		self._aimVisuals:Cleanup()
	end
end

function FightUIController:ShowFightUI(goalPos: Vector3, goalZone: Instance?)
	self:Cleanup3DAiming()

	if not self._powerBar then
		self:SetupGui()
	end

	-- Make both 3D Aim and 2D Power Bar visible at the same time
	self._powerBar.Visible = true
	self._dynamicBarGui.Enabled = true

	-- Restore countdownFrame parent back to the power bar
	if self._countdownFrame then
		self._countdownFrame.Parent = self._powerBar
	end

	-- Fade in GoalZone parts if provided
	self._currentGoalZone = goalZone
	if self._currentGoalZone then
		for _, part in ipairs(self._currentGoalZone:GetChildren()) do
			if part:IsA("BasePart") then
				part.Transparency = 1.0
				local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(part, tweenInfo, { Transparency = 0.5 }):Play()
			end
		end
	end

	-- Active pointer is the power pointer (moves automatically, colored orange/red)
	self._powerPointer.Position = UDim2.new(0.5, 0, 0.5, 0)
	self._powerPointer.Visible = true

	-- Start the 3D Aiming visuals
	if self._aimVisuals then
		self._aimVisuals:Show(goalPos, player.Character)
	end

	-- Start capturing inputs in InputController
	InputController:StartCapture(self._aimVisuals, self._powerPointer)
end

function FightUIController:LockFight()
	local savedDirection, savedPower = InputController:StopCapture()

	-- Lock 3D aim visuals
	if self._aimVisuals then
		self._aimVisuals:Lock()
	end

	-- Slow fadeout of 3D aiming visuals after 1 second
	task.delay(1, function()
		self:Cleanup3DAiming()
	end)

	savedDirection = savedDirection or 0.5
	savedPower = savedPower or 0.5

	return savedDirection, savedPower
end

function FightUIController:HideDynamicBar()
	InputController:StopCapture()

	self:Cleanup3DAiming()

	-- Fade out GoalZone parts if active
	if self._currentGoalZone then
		for _, part in ipairs(self._currentGoalZone:GetChildren()) do
			if part:IsA("BasePart") then
				local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(part, tweenInfo, { Transparency = 1.0 }):Play()
			end
		end
		self._currentGoalZone = nil
	end

	-- Make sure the countdownFrame is returned back to the powerBar when cleaning up
	if self._countdownFrame and self._countdownFrame.Parent ~= self._powerBar then
		self._countdownFrame.Parent = self._powerBar
	end

	self._dynamicBarGui.Enabled = false

	if self._countdownTween then
		self._countdownTween:Cancel()
		self._countdownTween:Destroy()
		self._countdownTween = nil
	end

	if self._countdownFrame then
		self._countdownFrame.Visible = false
	end
end

function FightUIController:UpdateCountdown(value: number)
	if not self._countdown or not self._countdownFrame then
		return
	end

	self._countdown.Text = "Auto kick in " .. tostring(value) .. "s"

	-- Cancel and destroy any active countdown tween to prevent memory leak and visual overlap
	if self._countdownTween then
		self._countdownTween:Cancel()
		self._countdownTween:Destroy()
		self._countdownTween = nil
	end

	if value > 0 then
		self._countdownFrame.Visible = true

		-- Pop scale micro-animation: scale from 1.6x down to 1.0x original size
		if self._originalCountdownSize then
			local orig = self._originalCountdownSize
			self._countdown.Size =
				UDim2.new(orig.X.Scale * 1.6, orig.X.Offset * 1.6, orig.Y.Scale * 1.6, orig.Y.Offset * 1.6)

			self._countdownTween = TweenService:Create(
				self._countdown,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = orig,
				}
			)
			self._countdownTween:Play()
		end
	else
		self._countdownFrame.Visible = false

		-- Reset size back to original immediately if hidden
		if self._originalCountdownSize then
			self._countdown.Size = self._originalCountdownSize
		end
	end
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
	InputController = Knit.GetController("InputController")
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
	self._aimVisuals = AimVisuals.new()

	print("FightUIController Started")
end
-- #endregion Knit Lifecycle

return FightUIController
