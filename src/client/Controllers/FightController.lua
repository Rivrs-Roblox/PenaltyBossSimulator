local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Promise = require(Packages.Promise)
local Sound = require(Packages.Sound)
local Signal = require(Packages.Signal)

-- Player
local player = Players.LocalPlayer

-- Services
local FightService
local DataService

-- Controllers
local UIController
local TeleportController
local AutoController
local NotificationController
local DataCacheController
local CharactersController
local GoalieController
local BallController
local CameraController
local TrailsController
local FightUIController
local EggsController
local TradeController
local ExitGiftController

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local TeleportEffectFrame = require(Helpers.TeleportEffectFrame)
local FormatNumber = require(Helpers.Numbers.FormatNumber)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local FightActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.FightActions)

local hideConnections = {}

local fightInstances = {
	-- ["Area01"] = { PenaltyZone = ... }
}

-- #region Constants

-- Penalty Kick Constants

local PLAYER_IDLE_ANIMATION_ID = "rbxassetid://132687400287514"
local RESULT_ANIMATION_IDS = {
	Win = {
		"rbxassetid://76106632238447",
		"rbxassetid://139656010469136",
	},
	Lose = {
		"rbxassetid://104772582542227",
		"rbxassetid://114904268403398",
	},
}
local AUTO_SHOOT_COUNTDOWN = 10
-- #endregion

-- FightController
local FightController = Knit.CreateController({
	Name = "FightController",
	IsFighting = false,
	IsKicking = false,
	KickPhase = "None",

	Template = {},
	ShootAnimationData = {},
	CurrentArea = nil,
	CurrentWave = 0,

	OnKickSignal = Signal.new(),

	-- Internal state
	_isOkayToStart = true,
	_currentBattleZone = nil, -- Reference ke battleZone Instance

	-- Animations
	_idleAnimTrack = nil,
	_idleAnim = nil,

	_shootAnimTrack = nil,
	_shootAnims = {},

	_resultAnims = {},
	_resultAnimTrack = nil,
})

--#region Local Functions

-- Translate "Area01" (enemiesData / fightInstances format) → "Zone1" (player data format)
local function toZoneName(areaName: string): string
	local n = tonumber(areaName:match("%d+"))
	return n and ("Zone" .. n) or areaName
end

local function getBestAutoWinTarget(data, enemiesData, bossProgress)
	local playerPower = data.Money2 or 0
	local unlockedAreas = data.Areas and data.Areas.Unlocked or { "Zone1" }

	local bestArea = "Area01"
	local bestBossIndex = 1
	local highestDefeatableBossPower = 0

	for areaName, areaData in pairs(enemiesData) do
		if areaName == "Tutorial" then
			continue
		end

		-- Check if player unlocked this area
		if not table.find(unlockedAreas, toZoneName(areaName)) then
			continue
		end

		-- Ensure we have a valid fightInstance
		local fightInstance = fightInstances[areaName]
		if not fightInstance then
			continue
		end

		-- Check progress in this area
		local progress = bossProgress and bossProgress[areaName] or 0
		local maxAllowedBoss = math.min(progress + 1, 5)

		-- Find the highest boss we can defeat in this area
		for bossIndex = 1, maxAllowedBoss do
			local bossKey = "Boss " .. bossIndex
			local bossData = areaData[bossKey]

			-- Backwards compatibility fallbacks
			if not bossData then
				if bossIndex == 5 and areaData["Boss"] then
					bossData = areaData["Boss"]
				elseif areaData["MiniBoss " .. bossIndex] then
					bossData = areaData["MiniBoss " .. bossIndex]
				end
			end

			if bossData then
				local goaliePower = bossData.Power or 0
				-- We want to find the highest boss power that is <= playerPower
				if playerPower >= goaliePower then
					if goaliePower > highestDefeatableBossPower then
						highestDefeatableBossPower = goaliePower
						bestArea = areaName
						bestBossIndex = bossIndex
					elseif goaliePower == highestDefeatableBossPower and areaName >= bestArea then
						-- tie-breaker: prefer higher area
						bestArea = areaName
						bestBossIndex = bossIndex
					end
				end
			end
		end
	end

	-- If the player's power is too low to defeat ANY boss in ANY unlocked area
	-- (e.g. immediately after a rebirth, player power is 0 or extremely low),
	-- we fall back to the very first boss of their highest unlocked area.
	if highestDefeatableBossPower == 0 then
		local highestUnlockedAreaNum = 1
		local highestUnlockedAreaName = "Area01"

		for _, zoneName in ipairs(unlockedAreas) do
			local n = tonumber(zoneName:match("%d+"))
			if n and n > highestUnlockedAreaNum then
				highestUnlockedAreaNum = n
				-- Format to AreaXX
				highestUnlockedAreaName = string.format("Area%02d", n)
			end
		end

		-- Ensure the highest unlocked area exists in enemiesData
		if enemiesData[highestUnlockedAreaName] and fightInstances[highestUnlockedAreaName] then
			bestArea = highestUnlockedAreaName
		else
			bestArea = "Area01"
		end
		bestBossIndex = 1
	end

	return bestArea, bestBossIndex
end

local function getAnimator(model: Instance): Animator?
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	return animator
end

local function hidePlayer(otherPlayer: Player)
	local character = otherPlayer.Character
	if not character then
		return
	end

	local titleGui = character:FindFirstChild("PlayerTitleGui")
	if titleGui then
		titleGui.Enabled = false
	end

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			-- Sembunyikan semua part visual
			descendant.LocalTransparencyModifier = 1
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
			descendant.Enabled = false -- Nonaktifkan lokal
		end
	end

	-- Disconnect previous if any
	local oldConnection = hideConnections[otherPlayer]
	if oldConnection then
		oldConnection:Disconnect()
		hideConnections[otherPlayer] = nil
	end

	local connection = character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			descendant.LocalTransparencyModifier = 1
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
			descendant.Enabled = false
		end
	end)

	hideConnections[otherPlayer] = connection
end

local function showPlayer(otherPlayer: Player)
	local character = otherPlayer.Character
	if not character then
		return
	end

	local titleGui = character:FindFirstChild("PlayerTitleGui")
	if titleGui then
		titleGui.Enabled = true
	end

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			descendant.LocalTransparencyModifier = 0
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
			if
				descendant:FindFirstAncestor("LowerTorso")
				or descendant:FindFirstAncestor("RightFoot")
				or descendant:FindFirstAncestor("Football")
			then
				continue -- skip efek special shoot
			end

			descendant.Enabled = true
		end
	end

	-- Disconnect listener
	local connection = hideConnections[otherPlayer]
	if connection then
		connection:Disconnect()
		hideConnections[otherPlayer] = nil
	end
end

-- #endregion

-- #region Player Functions
function FightController:PlayIdleAnimation()
	self:StopAnimations()

	local character = player.Character
	if not character then
		return
	end

	if not self._idleAnim then
		self._idleAnim = Instance.new("Animation")
		self._idleAnim.AnimationId = PLAYER_IDLE_ANIMATION_ID
	end

	local animator = getAnimator(character)
	if not animator then
		return
	end

	self._idleAnimTrack = animator:LoadAnimation(self._idleAnim)
	self._idleAnimTrack.Priority = Enum.AnimationPriority.Action
	self._idleAnimTrack.Looped = true
	self._idleAnimTrack:Play()
end

function FightController:PlayShootAnimation(shootAnimName: string)
	-- Stop idle terlebih dahulu
	if self._idleAnimTrack then
		self._idleAnimTrack:Stop()
		self._idleAnimTrack:Destroy()
		self._idleAnimTrack = nil
	end

	local character = player.Character
	if not character then
		return
	end

	local animData = self.ShootAnimationData[shootAnimName]

	if not animData then
		warn("Shoot animation data not found for: " .. shootAnimName)
		return
	end

	if not self._shootAnims[shootAnimName] then
		local animInstance = Instance.new("Animation")
		animInstance.AnimationId = animData.Id
		self._shootAnims[shootAnimName] = animInstance
	end

	local animator = getAnimator(character)
	if not animator then
		return
	end

	self._shootAnimTrack = animator:LoadAnimation(self._shootAnims[shootAnimName])
	self._shootAnimTrack.Priority = Enum.AnimationPriority.Action4
	self._shootAnimTrack.Looped = false
	self._shootAnimTrack:Play()

	-- Terapkan slow motion jika ada speed nya
	if animData.Speed then
		self._shootAnimTrack:AdjustSpeed(animData.Speed)
	end

	return self._shootAnimTrack
end

function FightController:StopAnimations()
	if self._idleAnimTrack then
		self._idleAnimTrack:Stop()
		self._idleAnimTrack:Destroy()
		self._idleAnimTrack = nil
	end

	if self._shootAnimTrack then
		self._shootAnimTrack:Stop()
		self._shootAnimTrack:Destroy()
		self._shootAnimTrack = nil
	end

	if self._resultAnimTrack then
		self._resultAnimTrack:Stop()
		self._resultAnimTrack:Destroy()
		self._resultAnimTrack = nil
	end
end

function FightController:PlayResultAnimation(resultType: string)
	self:StopAnimations()

	local character = player.Character
	if not character then
		return
	end

	local animId
	if resultType == "Win" then
		local anims = RESULT_ANIMATION_IDS.Win
		local randomId = math.random(1, #anims)
		animId = anims[randomId]
		if randomId == 1 then
			Sound:PlaySound("MISC_Siu")
		end
	else
		local anims = RESULT_ANIMATION_IDS.Lose
		animId = anims[math.random(1, #anims)]
	end

	if not self._resultAnims[animId] then
		local animInstance = Instance.new("Animation")
		animInstance.AnimationId = animId
		self._resultAnims[animId] = animInstance
	end

	local animator = getAnimator(character)
	if not animator then
		return
	end

	self._resultAnimTrack = animator:LoadAnimation(self._resultAnims[animId])
	self._resultAnimTrack.Priority = Enum.AnimationPriority.Action
	self._resultAnimTrack.Looped = false
	self._resultAnimTrack:Play()
end

-- #endregion

-- #region Fight Functions

--- Mendapatkan child part dari PenaltyZone berdasarkan nama.
function FightController:GetPenaltyZonePart(partName: string): Instance?
	local battleZone = self._currentBattleZone
	if not battleZone then
		return nil
	end

	return battleZone:FindFirstChild(partName)
end

-- GetZone dan GetPowerPenalty sekarang dihitung di server (FightService)
-- Client menerima Zone dan EffectivePower dari response EvaluateKick

function FightController:SetEnabledPlayerSpecialEffect(enabled: boolean)
	local character = player.Character
	if not character then
		return
	end

	local lowerTorso = character:FindFirstChild("LowerTorso")
	if lowerTorso and lowerTorso:FindFirstChild("Effects") then
		for _, effect in ipairs(lowerTorso.Effects:GetChildren()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = enabled
			end
		end
	end

	local rightFoot = character:FindFirstChild("RightFoot")
	if rightFoot then
		for _, effect in ipairs(rightFoot:GetChildren()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = enabled
			end
		end
	end
end

function FightController:PlaySpecialKickEffect()
	local ball = BallController:GetBallModel()
	FightUIController:DamageIndicator(ball, "SPECIAL KICK", Color3.fromRGB(255, 234, 0))
	Sound:PlaySound("MISC_Shoot_Penalty_Special")
	BallController:SetEnabledBallEffect(true, "SpecialEffects")
	CameraController:StartCameraVisualEffect()
	Sound:PlaySound("MISC_Ball_Flying")
end

function FightController:PlayKickEffect(zone: string, effectivePower: number)
	local color
	local info

	if zone == "Green" then
		color = Color3.fromRGB(0, 255, 0)
		info = "(Perfect)"
	elseif zone == "Orange" then
		color = Color3.fromRGB(255, 165, 0)
		info = "(-40% power)"
	else
		color = Color3.fromRGB(255, 0, 0)
		info = "(-70% power)"
	end

	local ball = BallController:GetBallModel()
	local text = FormatNumber(effectivePower) .. "⚽ " .. info
	FightUIController:DamageIndicator(ball, text, color)
	Sound:PlaySound("MISC_Shoot_Penalty")
end

function FightController:ProceedKickAnimation(savedDirection: number, savedPower: number, resultData: any)
	if not resultData or type(resultData) ~= "table" then
		warn("[FightController] Failed to evaluate kick on server")
		resultData = { Result = "Lost", PlayerPower = 0 }
	end

	local result = resultData.Result
	local isSpecialKick = resultData.IsSpecialKick

	CameraController:PlayShakePreset("Shoot")

	CharactersController:SetFootballTransparancy(player, 1)

	BallController:SpawnBall()

	if isSpecialKick then
		self:PlaySpecialKickEffect()
	else
		self:PlayKickEffect(resultData.Zone, resultData.EffectivePower)
	end

	-- Animate ball dengan callbacks berbasis posisi bola
	-- Mulai dengan slow-motion (0.65x speed)
	BallController:SetSpeedMultiplier(0.65)
	GoalieController:PlayGoalieAnimation("Idle", 0.2)

	local goalArea = self:GetPenaltyZonePart("GoalArea")

	BallController:AnimateBallKick(savedDirection, result, goalArea.Position, isSpecialKick, {
		onGoalieReact = function()
			-- Kembalikan speed ke normal
			BallController:SetSpeedMultiplier(1)
			GoalieController:PlayGoalieAnimation("Idle", 1)
			CameraController:StopCameraFollow()

			-- Play animasi defend goalie
			GoalieController:PlayGoalieDefendAnimation(savedDirection, result)
		end,
		onResult = function()
			CameraController:StopCameraVisualEffect()
			self:ShowKickResult(result)
		end,
		onArrived = function()
			if result ~= "Saved" and result ~= "Missed" then
				CameraController:PlayShakePreset("Goal")
			end
		end,
	})

	-- Camera: follow ball selama slow-mo (akan di-stop oleh onGoalieReact saat switch ke GoalCamera)
	CameraController:FollowBallCamera()
end

function FightController:StopPointer()
	if not self.IsKicking then
		return
	end

	self.IsKicking = false
	self.KickPhase = "None"

	-- Instantly hide the countdown text for immediate input feedback
	FightUIController:UpdateCountdown(0)

	-- Cancel the auto-shoot thread immediately (if not currently running this thread)
	if self._autoShootThread then
		if coroutine.running() ~= self._autoShootThread then
			task.cancel(self._autoShootThread)
		end
		self._autoShootThread = nil
	end

	self.OnKickSignal:Fire()

	-- Lock BOTH and retrieve them
	local savedDirection, savedPower = FightUIController:LockFight()

	local success, resultData = FightService:EvaluateKick(savedDirection, savedPower):await()
	if not success then
		return warn("[FightController] Failed to evaluate kick on server")
	end

	FightUIController:HidePenaltyProgress()

	local isSpecialKick = resultData.IsSpecialKick

	if isSpecialKick then
		BallController:SetEnabledPlayerBallEffect(true)
		self:SetEnabledPlayerSpecialEffect(true)
	end

	-- play sound berdasarkan zone dari server
	if resultData.Zone == "Green" then
		-- Sound:PlaySound("MISC_Applause")
	else
		-- Sound:PlaySound("MISC_Booing_Short")
		FightUIController:PlayDamageEffectScreen()
	end

	-- Pindahkan kamera ke BallCameraPos untuk cinematic view
	local ballCam = isSpecialKick and self:GetPenaltyZonePart("SpecialCameraPos")
		or self:GetPenaltyZonePart("BallCameraPos")

	if isSpecialKick then
		Sound:PlaySound("MISC_Camera_Move")
		CameraController:SetBallCamera(ballCam.Position, player.Character.PrimaryPart.Position)
	else
		CameraController:SetBallCamera(ballCam.Position)
	end

	local shootAnimName = if isSpecialKick then CharactersController:GetSpecialKickAnimation() else "Shoot"
	local animData = self.ShootAnimationData[shootAnimName]

	if not animData then
		warn("[FightController] Animation data not found for", shootAnimName)
		return
	end

	-- Play shoot animation dalam slow motion (cinematic)

	self:PlayShootAnimation(shootAnimName)

	if animData.Events then
		self:ScheduleAnimEvents(animData, {
			KickContact = function(eventInfo)
				-- Kembalikan kecepatan animasi ke normal setelah momen tendangan
				if self._shootAnimTrack then
					self._shootAnimTrack:AdjustSpeed(1)
				end

				BallController:SetEnabledPlayerBallEffect(false)

				self:ProceedKickAnimation(savedDirection, savedPower, resultData)
			end,
			Bump = function(eventInfo)
				Sound:PlaySound("MISC_Stomp")
				CameraController:PlayShakePreset("Hit")
			end,
			FastMove = function(eventInfo)
				Sound:PlaySound("MISC_Fast_Move")
			end,
			FastMove2 = function(eventInfo)
				Sound:PlaySound("MISC_Fast_Move2")
			end,
			SpinSlow = function(eventInfo)
				Sound:PlaySound("MISC_Spin_Slow")
			end,
			SpinSlow_2 = function(eventInfo)
				Sound:PlaySound("MISC_Spin_Slow")
			end,
			SpinFast = function(eventInfo)
				Sound:PlaySound("MISC_Spin_Fast")
			end,
			WhooshKick = function(eventInfo)
				Sound:PlaySound("MISC_Whoosh_Kick")
			end,
			Tap = function(eventInfo)
				Sound:PlaySound("MISC_Tap")
			end,
			Tap_2 = function(eventInfo)
				Sound:PlaySound("MISC_Tap")
			end,
		})
	else
		task.delay(0.5, function()
			self:ProceedKickAnimation(savedDirection, savedPower, resultData)
		end)
	end

	-- Hide dynamic bar
	FightUIController:HideDynamicBar()
end

function FightController:ScheduleAnimEvents(animData, callbacks)
	for eventName, eventInfo in pairs(animData.Events) do
		local realTime = eventInfo.Time / animData.Speed
		task.delay(realTime, function()
			-- Panggil callback kalau disediakan
			local cb = callbacks[eventName]
			if cb then
				cb(eventInfo)
			end
		end)
	end
end

function FightController:ShowKickResult(result: string)
	-- Determine if it's a goal variant
	local isGoal = (result == "Goal" or result == "GoalBlast" or result == "GoalCorner")

	FightUIController:PlayKickResultEffect(result)

	self.IsKicking = false
	self:SetEnabledPlayerSpecialEffect(false)

	task.delay(1.5, function()
		-- Terapkan evaluasi di server
		FightService:ApplyKickResult()

		if isGoal then
			-- Cleanup current goalie & ball
			GoalieController:CleanupGoalie()
			BallController:CleanupBall()

			-- Check if more waves
			if self.CurrentWave < 5 then
				self.CurrentWave += 1
				self:StartPenaltyRound(self.CurrentWave)
			end
			-- Jika wave 5, server akan handle cleared + EndFight
		else
			-- Saved atau Missed — player kalah
			GoalieController:CleanupGoalie()
			BallController:CleanupBall()
		end
	end)
end

function FightController:SetupPenaltyRound()
	-- Play idle animation saat menunggu kick
	self:PlayIdleAnimation()

	-- Set camera ke posisi shoot
	local shootCam = self:GetPenaltyZonePart("ShootCameraPos")
	local goalArea = self:GetPenaltyZonePart("GoalArea")
	CameraController:SetShootCamera(shootCam, goalArea)

	FightUIController:ShowPenaltyProgress(self.CurrentWave)

	-- Delay sebelum show dynamic bar
	Promise.delay(2):andThen(function()
		Sound:PlaySound("MISC_Whistle")

		if self.IsFighting then
			self.KickPhase = "Kicking"
			local goalZone = self:GetPenaltyZonePart("GoalZone")
			FightUIController:ShowFightUI(goalArea.Position, goalZone)
			self.IsKicking = true

			-- Cancel any existing auto-shoot thread (safety check)
			if self._autoShootThread then
				task.cancel(self._autoShootThread)
				self._autoShootThread = nil
			end

			-- Start 5 seconds auto-shoot countdown timer
			self._countdownValue = AUTO_SHOOT_COUNTDOWN
			FightUIController:UpdateCountdown(self._countdownValue)

			self._autoShootThread = task.spawn(function()
				while self._countdownValue > 0 do
					task.wait(1)
					if not self.IsKicking then
						break
					end
					self._countdownValue -= 1
					FightUIController:UpdateCountdown(self._countdownValue)
				end

				if self.IsKicking and self._countdownValue == 0 then
					self:StopPointer()
				end
			end)
		end
	end)
end

function FightController:PlayBossCinematicIntro(goalieModel: Model, onComplete: () -> ())
	-- Show Boss Name UI
	local bossName = "Boss " .. (self.BossIndex or 5)
	if self.IsTutorialFight then
		local bossData = self.Template.Enemies["Tutorial"]
		if bossData and bossData.Name then
			bossName = bossData.Name
		end
	elseif self.Template and self.Template.Enemies and self.Template.Enemies[self.CurrentArea] then
		local bossKey = "Boss " .. (self.BossIndex or 5)
		local bossData = self.Template.Enemies[self.CurrentArea][bossKey]
		if not bossData and self.BossIndex == 5 then
			bossData = self.Template.Enemies[self.CurrentArea]["Boss"]
		end
		if bossData and bossData.Name then
			bossName = bossData.Name
		end
	end

	FightUIController:SetupBossIntroGui()

	task.spawn(function()
		-- local ySize = Workspace:GetAttribute("Mata")
		FightUIController:TweenCinematicFrames(0.5, 8.3)

		GoalieController:StopGoalieAnimation()

		CameraController:PlayBossEyeSequence(goalieModel)

		task.wait(1)

		-- local ySizeAfter = Workspace:GetAttribute("MataAfter")
		FightUIController:TweenCinematicFrames(1.5, 7.7)

		CameraController:PlayBossZoomOutSequence(goalieModel)

		FightUIController:FadeInBossNameIntro(bossName)

		GoalieController:PlayBossIntroAnimation(function()
			FightUIController:FadeOutBossNameIntro()

			if onComplete then
				onComplete()
			end
		end)
	end)
end

function FightController:StartPenaltyRound(wave)
	self.CurrentWave = wave

	-- Spawn goalie
	local goalieArea = self:GetPenaltyZonePart("GoalieArea")
	GoalieController:SpawnGoalie(wave, self.CurrentArea, goalieArea, self.BossIndex, self.IsTutorialFight)

	CharactersController:SetFootballTransparancy(player, 0)

	if wave == 1 then
		-- Boss Cinematic Intro
		local goalieModel = GoalieController:GetGoalieModel()
		if goalieModel then
			self:PlayBossCinematicIntro(goalieModel, function()
				self:SetupPenaltyRound()
			end)
		else
			self:SetupPenaltyRound()
		end
	else
		self:SetupPenaltyRound()
	end
end

function FightController:UpdatePodiumLock(enemyPodium: Instance)
	local area = enemyPodium:GetAttribute("Area")
	local podiumType = enemyPodium:GetAttribute("Type")

	if not area or not podiumType then
		return
	end

	local bossIndex = tonumber(podiumType:match("%d+"))
	if not bossIndex then
		if podiumType == "Boss" then
			bossIndex = 5
		else
			bossIndex = 1
		end
	end

	local progress = self.BossProgress and self.BossProgress[area] or 0
	local isUnlocked = (bossIndex == 1) or (progress >= bossIndex - 1)

	task.spawn(function()
		local namePart = enemyPodium:WaitForChild("Name", 5)
		if not namePart then
			return
		end

		local billboard = namePart:WaitForChild("BillboardGui", 5)
		if not billboard then
			return
		end

		local lockElement = billboard:WaitForChild("Lock", 5)
		if lockElement then
			lockElement.Visible = not isUnlocked
		end
	end)
end

function FightController:UpdateAllPodiumLocks()
	local enemyPodiums = CollectionService:GetTagged("EnemyPodium")
	for _, enemyPodium in enemyPodiums do
		self:UpdatePodiumLock(enemyPodium)
	end
end

--|| Existing Functions ||--
function FightController:StartFight(area: string, bossIndex: number)
	if
		self.IsFighting
		or TeleportController.IsTeleporting
		or AutoController.IsAutoTraining
		or EggsController.Hatching
		or TradeController.IsTrading
	then
		if TeleportController.IsTeleporting then
			NotificationController:Notify({
				text = "Can't start a fight while teleporting." :: string,
				type = "ERROR",
				tag = "Fight",
			})
		end

		if AutoController.IsAutoTraining then
			NotificationController:Notify({
				text = "Can't start a fight while auto training." :: string,
				type = "ERROR",
				tag = "Fight",
			})
		end

		if EggsController.Hatching then
			NotificationController:Notify({
				text = "Can't start a fight while hatching eggs." :: string,
				type = "ERROR",
				tag = "Fight",
			})
		end

		if TradeController.IsTrading then
			NotificationController:Notify({
				text = "Can't start a fight while trading." :: string,
				type = "ERROR",
				tag = "Fight",
			})
		end

		return
	end

	bossIndex = tonumber(bossIndex) or 1

	-- Enforce sequential progression check
	local progress = self.BossProgress and self.BossProgress[area] or 0
	if bossIndex > 1 and progress < bossIndex - 1 then
		NotificationController:Notify({
			text = "You must defeat the previous boss first!",
			type = "ERROR",
			tag = "Fight",
		})
		return
	end

	self.IsFighting = true
	self._isOkayToStart = false

	local fightInstance = fightInstances[area]
	if not fightInstance then
		warn("[FightController] No fight instance found for area: ", area)
		self.IsFighting = false
		self._isOkayToStart = true
		return
	end

	self._currentBattleZone = fightInstance.PenaltyZone -- Simpan reference untuk spawn goalie
	Store:dispatch(FightActions.setFighting(true))

	local character = player.Character
	if not character then
		warn("[FightController] No character found for player")
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	end

	UIController:HideFrame()
	UIController:RemoveHUD({ ignoreTopFrame = true, hideSpinWheel = true, ignoreBottomFrame = true })
	ExitGiftController:HideFrame()

	TeleportEffectFrame("Close")

	task.wait(1)

	FightService:StartFight(fightInstance.PenaltyZone, bossIndex)
end

function FightController:StartAutoWinTask()
	task.spawn(function()
		while true do
			if AutoController.IsAutoWinning then
				if self.IsFighting then
					if self.IsKicking then
						self:StopPointer()
					end
				elseif self._isOkayToStart then
					local _, data = DataService:GetData():await()
					if not data then
						continue
					end

					local area, bossIndex = getBestAutoWinTarget(data, self.Template.Enemies, self.BossProgress)

					if area and bossIndex then
						self:StartFight(area, bossIndex)
					end
				end
			end

			task.wait(0.5)
		end
	end)
end

function FightController:PreloadNecessaryAssets()
	task.spawn(function()
		local assetsToPreload = {}

		-- 1. Preload sounds
		local necessarySounds = {
			"MISC_Shoot_Penalty_Special",
			"MISC_Shoot_Penalty",
			"MISC_Shoot_Training",
			"MISC_Whistle",
			"MISC_Booing",
			-- "MISC_Booing_Short",
			"MISC_Applause",
			"MISC_Goal",
			"MISC_Stomp",
			"MISC_Fast_Move",
			"MISC_Camera_Move",
			"MISC_Goalie_Hold",
			"MISC_Ball_Flying",
			"MISC_Spin_Slow",
			"MISC_Spin_Fast",
			"MISC_Fast_Move2",
			"MISC_Whoosh_Kick",
			"MISC_Tap",
		}
		for _, index in ipairs(necessarySounds) do
			local soundModule = Sound:GetOrCreateSound(index)
			if soundModule and soundModule.sound then
				print("Preloading sound: ", soundModule.sound)
				table.insert(assetsToPreload, soundModule.sound)
			end
		end

		-- 3. Preload player animations
		self._idleAnim = Instance.new("Animation")
		self._idleAnim.AnimationId = PLAYER_IDLE_ANIMATION_ID
		table.insert(assetsToPreload, self._idleAnim)

		for _, animId in RESULT_ANIMATION_IDS.Win do
			local animInstance = Instance.new("Animation")
			animInstance.AnimationId = animId
			self._resultAnims[animId] = animInstance
			table.insert(assetsToPreload, animInstance)
		end

		for _, animId in RESULT_ANIMATION_IDS.Lose do
			local animInstance = Instance.new("Animation")
			animInstance.AnimationId = animId
			self._resultAnims[animId] = animInstance
			table.insert(assetsToPreload, animInstance)
		end

		for animName, animData in self.ShootAnimationData do
			local animInstance = Instance.new("Animation")
			animInstance.AnimationId = animData.Id
			self._shootAnims[animName] = animInstance
			table.insert(assetsToPreload, animInstance)
		end

		if #assetsToPreload > 0 then
			ContentProvider:PreloadAsync(assetsToPreload)
			print("All assets loaded.")
		end
	end)
end

--#endregion

-- #region Knit Lifecycle

function FightController:KnitInit()
	FightService = Knit.GetService("FightService")
	DataService = Knit.GetService("DataService")

	UIController = Knit.GetController("UIController")
	TeleportController = Knit.GetController("TeleportController")
	AutoController = Knit.GetController("AutoController")
	NotificationController = Knit.GetController("NotificationController")
	DataCacheController = Knit.GetController("DataCacheController")
	CharactersController = Knit.GetController("CharactersController")
	GoalieController = Knit.GetController("GoalieController")
	BallController = Knit.GetController("BallController")
	CameraController = Knit.GetController("CameraController")
	TrailsController = Knit.GetController("TrailsController")
	FightUIController = Knit.GetController("FightUIController")
	EggsController = Knit.GetController("EggsController")
	TradeController = Knit.GetController("TradeController")
	ExitGiftController = Knit.GetController("ExitGiftController")
end

function FightController:KnitStart()
	self.Template = DataCacheController:GetFile("Template")
	self.ShootAnimationData = DataCacheController:GetFile("ShootAnimationData")

	-- Preload assets
	self:PreloadNecessaryAssets()

	FightService.FightStarted:Connect(function(fightArea, bossIndex, isTutorialFight)
		self.CurrentArea = fightArea
		self.BossIndex = bossIndex or 1
		self.IsTutorialFight = isTutorialFight
		self.CurrentWave = 0

		Sound:StopSound("MUSIC_Background")
		Sound:PlaySound("MUSIC_Fight")

		for _, otherPlayer in Players:GetPlayers() do
			if otherPlayer == player then
				continue
			end

			hidePlayer(otherPlayer)
		end

		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
		end

		TeleportEffectFrame("Open")

		-- Start first penalty round setelah teleport settle
		task.delay(0.5, function()
			if self.IsFighting then
				self:StartPenaltyRound(1)
			end
		end)
	end)

	FightService.FightEnded:Connect(function()
		if self.IsFighting then
			self.IsFighting = false
		end

		-- Cancel the auto-shoot thread immediately on fight end
		if self._autoShootThread then
			task.cancel(self._autoShootThread)
			self._autoShootThread = nil
		end

		-- Cleanup penalty kick state
		FightUIController:HideDynamicBar()
		GoalieController:CleanupGoalie()
		BallController:CleanupBall()
		self:StopAnimations()
		CameraController:ResetCamera()
		self.IsKicking = false
		self.IsTutorialFight = nil
		self.CurrentWave = 0
		self._currentBattleZone = nil
		Store:dispatch(FightActions.setFighting(false))

		Sound:StopSound("MUSIC_Fight")
		Sound:PlaySound("MUSIC_Background")

		TeleportEffectFrame("Close")

		Promise.delay(2):andThen(function()
			for _, otherPlayer in Players:GetPlayers() do
				if otherPlayer == player then
					continue
				end

				showPlayer(otherPlayer)
			end

			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				TrailsController:SyncMoveSpeed()
				humanoid.JumpPower = StarterPlayer.CharacterJumpPower
			end

			CharactersController:SetFootballTransparancy(player, 0)

			TeleportEffectFrame("Open")

			UIController:ShowHUD()

			self._isOkayToStart = true
		end)
	end)

	FightService.WaveUpdated:Connect(function(wave)
		if wave == "Cleared" then
			FightUIController:PlaySuccessText("ALL GOALIES BEATEN!")
			CameraController:CameraInFrontOfPlayer()
			self:PlayResultAnimation("Win")
		elseif wave == "Lost" then
			FightUIController:PlayFailedText("YOU LOST!")
			CameraController:CameraInFrontOfPlayer()
			self:PlayResultAnimation("Lose")
		end
	end)

	-- Setup other players visibility
	local function setupPlayer(otherPlayer)
		if otherPlayer == player then
			return
		end

		otherPlayer.CharacterAdded:Connect(function()
			if self.IsFighting then
				hidePlayer(otherPlayer)
			end
		end)
	end

	player.CharacterAdded:Connect(function(character)
		if self.IsFighting then
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
		end
	end)

	for _, otherPlayer in Players:GetPlayers() do
		setupPlayer(otherPlayer)
	end

	Players.PlayerAdded:Connect(setupPlayer)

	Players.PlayerRemoving:Connect(function(otherPlayer)
		local connection = hideConnections[otherPlayer]
		if connection then
			connection:Disconnect()
			hideConnections[otherPlayer] = nil
		end
	end)

	self.BossProgress = {}

	DataService.BossProgressUpdated:Connect(function(updatedProgress)
		self.BossProgress = updatedProgress
		self:UpdateAllPodiumLocks()
	end)

	local _, data = DataService:GetData():await()
	if data then
		self.BossProgress = data.BossProgress or {}
		self:UpdateAllPodiumLocks()
	end

	local function setupPenaltyZone(penaltyZone)
		local area = penaltyZone:GetAttribute("Area")

		if fightInstances[area] == nil then
			fightInstances[area] = {
				PenaltyZone = nil,
			}
		end

		fightInstances[area].PenaltyZone = penaltyZone

		if data.TutorialStep == 1 then
			if area == "Area01" then
				self:StartFight(area)
			end
		end
	end

	local penaltyZones = CollectionService:GetTagged("PenaltyZone")

	for _, penaltyZone in penaltyZones do
		setupPenaltyZone(penaltyZone)
	end

	CollectionService:GetInstanceAddedSignal("PenaltyZone"):Connect(setupPenaltyZone)

	-- Initialize ProximityPrompt for all EnemyPodiums
	local function setupPodium(enemyPodium)
		local area = enemyPodium:GetAttribute("Area")
		local podiumType = enemyPodium:GetAttribute("Type")

		local bossIndex = tonumber(podiumType:match("%d+"))
		if not bossIndex then
			if podiumType == "Boss" then
				bossIndex = 5
			else
				bossIndex = 1
			end
		end

		local enemyName = area .. " - " .. podiumType
		if self.Template and self.Template.Enemies and self.Template.Enemies[area] then
			local enemyData = self.Template.Enemies[area]["Boss " .. bossIndex]
			if enemyData and enemyData.Name then
				enemyName = enemyData.Name
			end
		end

		local base = enemyPodium:WaitForChild("Base", 10)
		if not base then
			warn("Base not found for enemy podium", enemyPodium)
			return
		end

		local function configurePrompt(model)
			if not model:IsA("Model") then
				return
			end

			local prompt = model:FindFirstChild("FightPrompt") or model:FindFirstChildOfClass("ProximityPrompt")
			if not prompt then
				prompt = Instance.new("ProximityPrompt")
				prompt.Name = "FightPrompt"
				prompt.ActionText = "Fight"
				prompt.HoldDuration = 0.5
				prompt.MaxActivationDistance = 10
				prompt.Parent = model
				prompt.Style = Enum.ProximityPromptStyle.Custom
			end

			prompt.ObjectText = enemyName

			if not prompt:GetAttribute("Connected") then
				prompt:SetAttribute("Connected", true)
				prompt.Triggered:Connect(function()
					local parsedBossIndex = tonumber(podiumType:match("%d+"))
					if not parsedBossIndex then
						if podiumType == "Boss" then
							parsedBossIndex = 5
						else
							parsedBossIndex = 1
						end
					end
					self:StartFight(area, parsedBossIndex)
				end)
			end
		end

		-- Setup for currently streamed-in models
		for _, child in ipairs(base:GetChildren()) do
			if child:IsA("Model") then
				configurePrompt(child)
			end
		end

		-- Setup for models that stream in later
		base.ChildAdded:Connect(function(child)
			if child:IsA("Model") then
				configurePrompt(child)
			end
		end)

		self:UpdatePodiumLock(enemyPodium)
	end

	local enemyPodiums = CollectionService:GetTagged("EnemyPodium")
	for _, enemyPodium in enemyPodiums do
		setupPodium(enemyPodium)
	end

	CollectionService:GetInstanceAddedSignal("EnemyPodium"):Connect(setupPodium)

	self:StartAutoWinTask()
end
--	#endregion

return FightController
