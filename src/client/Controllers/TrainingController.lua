-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Sound = require(Packages.Sound)
local Zone = require(ReplicatedStorage.Shared.ZonePlus)

-- Services
local TrainingService
local BallService
local DataService

-- Controllers
local NotificationController
local AutoController
local CharactersController
local TrailsController
local FightController
local DataCacheController

-- Player
local player = Players.LocalPlayer
local playerGui = player:FindFirstChildOfClass("PlayerGui")

-- Signals
local AutoTrainingSignals = require(ReplicatedStorage.Shared.Signals.AutoTrainingSignals)
local TrainingSignals = require(ReplicatedStorage.Shared.Signals.TrainingSignals)

-- Data
local TrainingAnimationData = require(ReplicatedStorage.Shared.Data.TrainingAnimationData)
local TrainingAreasData
local EnemiesData
local ImagesData

local trainingAreas = {}
local bossProgress = {}
local activePrompt
local currentTrainingArea
local trainingAnimationTrack
local cooldown = false
local hideConnections = {}
local humanoidJumpConnection
local animationSpeed = 1
local lastClickTime = 0
local trainingStartRequestId = 0
local pendingTrainingArea
local localTrainingAreas = {}

local animationCache = {}
local preloadedTrainingAnimations = {}
local goalPulseCache = setmetatable({}, { __mode = "k" })
local currentTrainingShotId
local lastGoalPulseShotId
local isTrainingProjectileActive = false

local HOLD_DURATION = 0.5
local COOLDOWN_TIME = 0.45
local ANIMATION_SPEED_DECAY = 0.5
local ANIMATION_SPEED_INCREASE = 0.25
local BEAM_SPEED = 2
local VIP_TRAINING_INDEX = 6
local TRAINING_START_RETRY_ATTEMPTS = 5
local TRAINING_START_RETRY_INTERVAL = 0.12
local DISABLE_COLLISION_TRAINING_INDEXES = {
	[3] = true,
	[4] = true,
	[5] = true,
}
local TRAINING_BILLBOARD_ICON_NAMES = {
	"PowerImage",
	"PowerIcon",
	"Money2Icon",
	"RequirementIcon",
	"CurrencyIcon",
	"Icon",
	"Power",
	"Money2",
}

-- TrainingController
local TrainingController = Knit.CreateController({
	Name = "TrainingController",
	IsTraining = false,
	IsAutoTrain = false,
})

--|| Local Functions ||--

local function getTrainingAreaIndex(trainingArea): number
	local index = trainingArea and trainingArea:GetAttribute("Index")
	return tonumber(index) or TrainingAnimationData.Default.Index or 1
end

local function getTrainingAnimationData(index: number)
	return TrainingAnimationData.Areas[index] or TrainingAnimationData.Default
end

local function zoneNameToAreaId(zoneName: string?): string?
	if typeof(zoneName) ~= "string" then
		return nil
	end

	local zoneNumber = tonumber(zoneName:match("%d+"))
	if not zoneNumber then
		return nil
	end

	return string.format("Area%02d", zoneNumber)
end

local function getTrainingAreaTemplateData(trainingArea: Instance?)
	if not trainingArea or not TrainingAreasData then
		return nil
	end

	local area = trainingArea:GetAttribute("Area")
	local index = trainingArea:GetAttribute("Index")

	if typeof(area) ~= "string" or index == nil then
		return nil
	end

	return TrainingAreasData[area] and TrainingAreasData[area][index]
end

local function getRequiredBossIndex(trainingArea: Instance?): number?
	if not trainingArea then
		return nil
	end

	local index = tonumber(trainingArea:GetAttribute("Index"))
	if not index or index <= 1 then
		return nil
	end

	local areaData = getTrainingAreaTemplateData(trainingArea)
	if (areaData and areaData.VIP) or index == VIP_TRAINING_INDEX then
		return nil
	end

	return index
end

local function isVipTrainingArea(trainingArea: Instance?): boolean
	if not trainingArea then
		return false
	end

	local areaData = getTrainingAreaTemplateData(trainingArea)
	if areaData and areaData.VIP then
		return true
	end

	return tonumber(trainingArea:GetAttribute("Index")) == VIP_TRAINING_INDEX
end

local function getBossData(areaId: string?, bossIndex: number?)
	if not areaId or typeof(bossIndex) ~= "number" then
		return nil
	end

	local areaEnemies = EnemiesData and EnemiesData[areaId]
	if not areaEnemies then
		return nil
	end

	local bossData = areaEnemies["Boss " .. bossIndex] or areaEnemies["MiniBoss " .. bossIndex]
	if bossData then
		return bossData
	end

	if bossIndex == 5 then
		return areaEnemies.Boss
	end

	return nil
end

local function getBossDisplayName(areaId: string?, bossIndex: number?): string
	local bossData = getBossData(areaId, bossIndex)
	if bossData and bossData.Name then
		return bossData.Name
	end

	return "Boss " .. tostring(bossIndex)
end

local function getTrainingBillboard(trainingArea: Instance?)
	local parent = trainingArea and trainingArea.Parent
	local requirement = parent and parent:FindFirstChild("Requirement")

	return requirement and requirement:FindFirstChild("BillboardGui")
end

local function getRequiredText(trainingArea: Instance?)
	local billboard = getTrainingBillboard(trainingArea)
	return billboard and billboard:FindFirstChild("RequiredText")
end

local function findNamedIcon(root: Instance?)
	if not root then
		return nil
	end

	for _, iconName in ipairs(TRAINING_BILLBOARD_ICON_NAMES) do
		local icon = root:FindFirstChild(iconName, true)
		if icon and (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) then
			return icon
		end
	end

	return nil
end

local function isBillboardIconCandidate(instance: Instance): boolean
	if not (instance:IsA("ImageLabel") or instance:IsA("ImageButton")) then
		return false
	end

	local lowerName = string.lower(instance.Name)
	return lowerName ~= "background" and lowerName ~= "bg" and lowerName ~= "back"
end

local function findAnyIconCandidate(root: Instance?)
	if not root then
		return nil
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		if isBillboardIconCandidate(descendant) then
			return descendant
		end
	end

	return nil
end

local function getTrainingBillboardIcon(trainingArea: Instance?)
	local billboard = getTrainingBillboard(trainingArea)
	local requiredText = billboard and billboard:FindFirstChild("RequiredText", true)
	local icon = findNamedIcon(requiredText and requiredText.Parent)
	if icon then
		return icon
	end

	icon = findAnyIconCandidate(requiredText and requiredText.Parent)
	if icon then
		return icon
	end

	icon = findNamedIcon(billboard)
	if icon then
		return icon
	end

	local plusText = billboard and billboard:FindFirstChild("PlusText", true)
	icon = findNamedIcon(plusText and plusText.Parent)
	if icon then
		return icon
	end

	icon = findAnyIconCandidate(plusText and plusText.Parent)
	if icon then
		return icon
	end

	if billboard then
		for _, descendant in ipairs(billboard:GetDescendants()) do
			if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				local lowerName = string.lower(descendant.Name)
				if lowerName:find("icon") or lowerName:find("power") or lowerName:find("money") then
					return descendant
				end
			end
		end
	end

	return findAnyIconCandidate(billboard)
end

local function setTrainingBillboardIcon(trainingArea: Instance?, isUnlocked: boolean)
	local icon = getTrainingBillboardIcon(trainingArea)
	if not icon or not ImagesData then
		return
	end

	icon.Image = if isUnlocked then ImagesData.Money2 else ImagesData.Lock
end

local function updateTrainingAreaRequirementText(trainingArea: Instance?)
	if isVipTrainingArea(trainingArea) then
		return
	end

	local requiredText = getRequiredText(trainingArea)
	if not requiredText then
		return
	end

	local requiredBossIndex = getRequiredBossIndex(trainingArea)
	if not requiredBossIndex then
		requiredText.Visible = false
		setTrainingBillboardIcon(trainingArea, true)
		return
	end

	local areaId = zoneNameToAreaId(trainingArea:GetAttribute("Area"))
	local progress = areaId and bossProgress[areaId] or 0

	if progress >= requiredBossIndex then
		requiredText.Visible = false
		setTrainingBillboardIcon(trainingArea, true)
	else
		requiredText.Text = `Defeat {getBossDisplayName(areaId, requiredBossIndex)} !!`
		requiredText.Visible = true
		setTrainingBillboardIcon(trainingArea, false)
	end
end

local function updateAllTrainingAreaRequirementTexts()
	for _, trainingArea in ipairs(trainingAreas) do
		updateTrainingAreaRequirementText(trainingArea)
	end
end

local function getCurrentTrainingAnimationData()
	return getTrainingAnimationData(getTrainingAreaIndex(currentTrainingArea))
end

local function getMaxAnimationSpeed(animData): number
	return tonumber(animData and animData.MaxSpeedMultiplier)
		or tonumber(TrainingAnimationData.Default.MaxSpeedMultiplier)
		or 3
end

local function getPlaybackSpeed(animData, speedMultiplier: number): number
	local baseSpeed = tonumber(animData and animData.Speed) or tonumber(TrainingAnimationData.Default.Speed) or 1

	return math.max(0.01, baseSpeed * speedMultiplier)
end

local function getOrCreateAnimation(animationId: string, index: number)
	if animationCache[animationId] then
		return animationCache[animationId]
	end

	local anim = Instance.new("Animation")
	anim.Name = `TrainingAnim{index}`
	anim.AnimationId = animationId
	animationCache[animationId] = anim

	return anim
end

local function preloadTrainingAnimation(index: number)
	local animData = getTrainingAnimationData(index)
	local animationId = animData.Id or TrainingAnimationData.Default.Id

	if not animationId or animationId == "" or preloadedTrainingAnimations[animationId] then
		return
	end

	local anim = getOrCreateAnimation(animationId, index)
	local success = pcall(function()
		ContentProvider:PreloadAsync({ anim })
	end)

	if success then
		preloadedTrainingAnimations[animationId] = true
	end
end

local function getCharacterFootball()
	local character = player.Character
	if not character then
		return nil
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return nil
	end

	return hrp:FindFirstChild("Football")
end

local function setBasePartVisible(part: BasePart, visible: boolean)
	if part:GetAttribute("TrainingOriginalTransparency") == nil then
		part:SetAttribute("TrainingOriginalTransparency", part.Transparency)
	end

	if visible then
		local originalTransparency = part:GetAttribute("TrainingOriginalTransparency")
		if typeof(originalTransparency) ~= "number" then
			originalTransparency = 0
		end

		part.Transparency = originalTransparency
	else
		part.Transparency = 1
	end
end

local function isBallVfx(descendant: Instance): boolean
	return descendant:IsA("ParticleEmitter")
		or descendant:IsA("Trail")
		or descendant:IsA("Beam")
		or descendant:IsA("Fire")
		or descendant:IsA("Smoke")
		or descendant:IsA("Sparkles")
		or descendant:IsA("PointLight")
		or descendant:IsA("SpotLight")
		or descendant:IsA("SurfaceLight")
		or descendant:IsA("Highlight")
end

local function disableBallVfx(root: Instance)
	for _, descendant in ipairs(root:GetDescendants()) do
		if isBallVfx(descendant) then
			pcall(function()
				descendant.Enabled = false
			end)
		end
	end
end

local TARGET_IMPACT_VFX_NAMES = {
	"TrainingImpactVFX",
	"ImpactEffects",
	"ExplodeEffects",
	"SpecialEffects",
	"HoldEffects",
	"VFX",
	"Effects",
}

local DEFAULT_IMPACT_EMIT_COUNT = 25
local IMPACT_VFX_DURATION = 0.3
local IMPACT_VFX_CLEANUP_DELAY = 2.5
local GOAL_PULSE_CONFIG = {
	ScaleMultiplier = 1.25,
	GrowTime = 0.15,
	ShrinkTime = 0.14,
	GrowEasingStyle = Enum.EasingStyle.Back,
	GrowEasingDirection = Enum.EasingDirection.Out,
	ShrinkEasingStyle = Enum.EasingStyle.Quad,
	ShrinkEasingDirection = Enum.EasingDirection.In,
}

local function hasVfx(root: Instance): boolean
	if isBallVfx(root) then
		return true
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		if isBallVfx(descendant) then
			return true
		end
	end

	return false
end

local function findTargetImpactVfxTemplate(target: Instance?)
	if not target then
		return nil
	end

	for _, effectName in ipairs(TARGET_IMPACT_VFX_NAMES) do
		local effect = target:FindFirstChild(effectName)
		if effect and hasVfx(effect) then
			return effect
		end
	end

	for _, child in ipairs(target:GetChildren()) do
		if child:GetAttribute("TrainingImpactVFX") == true and hasVfx(child) then
			return child
		end
	end

	for _, child in ipairs(target:GetChildren()) do
		if hasVfx(child) then
			return child
		end
	end

	return nil
end

local function prepareImpactBasePart(part: BasePart)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
end

local function getSelfAndDescendants(root: Instance)
	local objects = { root }

	for _, descendant in ipairs(root:GetDescendants()) do
		table.insert(objects, descendant)
	end

	return objects
end

local function weldPartToBase(part: BasePart, basePart: BasePart)
	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = part
	weld.Part1 = basePart
	weld.Parent = part
end

local function attachVfxTemplateToAnchor(template: Instance, anchor: BasePart, cf: CFrame)
	local effectRoot: Instance = anchor

	if isBallVfx(template) then
		local attachment = anchor:FindFirstChild("TrainingVFXAttachment")
		if not attachment then
			attachment = Instance.new("Attachment")
			attachment.Name = "TrainingVFXAttachment"
			attachment.Parent = anchor
		end

		local clone = template:Clone()
		if clone:IsA("ParticleEmitter") then
			clone.Parent = attachment
		else
			clone.Parent = anchor
		end
		effectRoot = clone
	elseif template:IsA("Attachment") then
		local clone = template:Clone()
		clone.Parent = anchor
		effectRoot = clone
	elseif template:IsA("Model") then
		local clone = template:Clone()
		clone:PivotTo(cf)
		clone.Parent = workspace

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("BasePart") then
				weldPartToBase(descendant, anchor)
			end
		end

		effectRoot = clone
	elseif template:IsA("BasePart") then
		local clone = template:Clone()
		clone.CFrame = cf
		clone.Parent = workspace
		weldPartToBase(clone, anchor)
		effectRoot = clone
	else
		local attachment = Instance.new("Attachment")
		attachment.Name = template.Name
		attachment.Parent = anchor

		for _, child in ipairs(template:GetChildren()) do
			local childClone = child:Clone()

			if childClone:IsA("ParticleEmitter") then
				childClone.Parent = attachment
			elseif childClone:IsA("Attachment") then
				childClone.Parent = anchor
			elseif childClone:IsA("Model") then
				childClone:PivotTo(cf)
				childClone.Parent = workspace

				for _, descendant in ipairs(childClone:GetDescendants()) do
					if descendant:IsA("BasePart") then
						weldPartToBase(descendant, anchor)
					end
				end
			elseif childClone:IsA("BasePart") then
				childClone.CFrame = cf
				childClone.Parent = workspace
				weldPartToBase(childClone, anchor)
			else
				childClone.Parent = attachment
			end
		end
	end

	return effectRoot
end

local function triggerImpactVfx(root: Instance, duration: number, defaultEmitCount: number)
	for _, descendant in ipairs(getSelfAndDescendants(root)) do
		if descendant:IsA("ParticleEmitter") then
			local emitCount = descendant:GetAttribute("EmitCount")
			if typeof(emitCount) ~= "number" then
				emitCount = defaultEmitCount
			end

			local emitDelay = descendant:GetAttribute("EmitDelay")
			if typeof(emitDelay) == "number" and emitDelay > 0 then
				task.delay(emitDelay, function()
					if descendant and descendant.Parent then
						descendant:Emit(emitCount)
					end
				end)
			else
				descendant:Emit(emitCount)
			end

			descendant.Enabled = true
			task.delay(duration, function()
				if descendant and descendant.Parent then
					descendant.Enabled = false
				end
			end)
		elseif descendant:IsA("Trail") or descendant:IsA("Beam") then
			descendant.Enabled = true
			task.delay(duration, function()
				if descendant and descendant.Parent then
					descendant.Enabled = false
				end
			end)
		elseif descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("Sparkles") then
			descendant.Enabled = true
			task.delay(duration, function()
				if descendant and descendant.Parent then
					descendant.Enabled = false
				end
			end)
		elseif descendant:IsA("PointLight") or descendant:IsA("SpotLight") or descendant:IsA("SurfaceLight") then
			descendant.Enabled = true
			task.delay(duration, function()
				if descendant and descendant.Parent then
					descendant.Enabled = false
				end
			end)
		end
	end
end

local function findGoalModelFromTrainingArea(trainingArea: Instance?): Model?
	if not trainingArea then
		return nil
	end

	local trainingAreaParent = trainingArea and trainingArea.Parent
	if not trainingAreaParent then
		return nil
	end

	local assets = trainingAreaParent:FindFirstChild("Assets")
	if not assets then
		return nil
	end

	local goal = assets:FindFirstChild("Goal")
	if goal and goal:IsA("Model") then
		return goal
	end

	return nil
end

local function cleanupGoalPulse(pulse, skipDestroyingConnection: boolean?)
	if not pulse then
		return
	end

	pulse.GrowTween:Cancel()
	pulse.ShrinkTween:Cancel()
	pulse.ChangedConnection:Disconnect()
	pulse.GrowCompletedConnection:Disconnect()
	pulse.ShrinkCompletedConnection:Disconnect()

	if not skipDestroyingConnection and pulse.DestroyingConnection then
		pulse.DestroyingConnection:Disconnect()
	end

	if pulse.ScaleValue and pulse.ScaleValue.Parent then
		pulse.ScaleValue:Destroy()
	end
end

local function getOrCreateGoalPulse(goal: Model)
	local cached = goalPulseCache[goal]
	if cached then
		return cached
	end

	local scaleValue = Instance.new("NumberValue")
	scaleValue.Name = "TrainingGoalPulseScale"
	scaleValue.Value = goal:GetScale()
	scaleValue.Parent = goal

	local originalScale = scaleValue.Value
	local pulseScale = originalScale * GOAL_PULSE_CONFIG.ScaleMultiplier
	local growTween = TweenService:Create(scaleValue, TweenInfo.new(
		GOAL_PULSE_CONFIG.GrowTime,
		GOAL_PULSE_CONFIG.GrowEasingStyle,
		GOAL_PULSE_CONFIG.GrowEasingDirection
	), {
		Value = pulseScale,
	})
	local shrinkTween = TweenService:Create(scaleValue, TweenInfo.new(
		GOAL_PULSE_CONFIG.ShrinkTime,
		GOAL_PULSE_CONFIG.ShrinkEasingStyle,
		GOAL_PULSE_CONFIG.ShrinkEasingDirection
	), {
		Value = originalScale,
	})

	local changedConnection = scaleValue.Changed:Connect(function(value: number)
		if goal and goal.Parent then
			goal:ScaleTo(value)
		end
	end)

	local growCompletedConnection = growTween.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed and goal and goal.Parent then
			shrinkTween:Play()
		end
	end)

	local shrinkCompletedConnection = shrinkTween.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed and goal and goal.Parent then
			scaleValue.Value = originalScale
		end
	end)

	cached = {
		ScaleValue = scaleValue,
		OriginalScale = originalScale,
		GrowTween = growTween,
		ShrinkTween = shrinkTween,
		ChangedConnection = changedConnection,
		GrowCompletedConnection = growCompletedConnection,
		ShrinkCompletedConnection = shrinkCompletedConnection,
	}

	cached.DestroyingConnection = goal.Destroying:Once(function()
		local pulse = goalPulseCache[goal]
		if pulse == cached then
			cleanupGoalPulse(pulse, true)
			goalPulseCache[goal] = nil
		end
	end)

	goalPulseCache[goal] = cached
	return cached
end

local function playTrainingGoalPulse(trainingArea: Instance?)
	local goal = findGoalModelFromTrainingArea(trainingArea)
	if not goal then
		return
	end

	local pulse = getOrCreateGoalPulse(goal)
	pulse.GrowTween:Cancel()
	pulse.ShrinkTween:Cancel()
	pulse.ScaleValue.Value = pulse.OriginalScale
	pulse.GrowTween:Play()
end

local function playTargetImpactVfx(target: Instance?, impactPosition: Vector3)
	local template = findTargetImpactVfxTemplate(target)
	if not template then
		return
	end

	local duration = template:GetAttribute("Duration")
	if typeof(duration) ~= "number" then
		duration = IMPACT_VFX_DURATION
	end

	local cleanupDelay = template:GetAttribute("CleanupDelay")
	if typeof(cleanupDelay) ~= "number" then
		cleanupDelay = IMPACT_VFX_CLEANUP_DELAY
	end

	local emitCount = template:GetAttribute("EmitCount")
	if typeof(emitCount) ~= "number" then
		emitCount = DEFAULT_IMPACT_EMIT_COUNT
	end

	local anchor = Instance.new("Part")
	anchor.Name = "TrainingImpactVFXAnchor"
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Transparency = 1
	anchor.CFrame = CFrame.new(impactPosition)
	prepareImpactBasePart(anchor)
	anchor.Parent = workspace

	local effectRoot = attachVfxTemplateToAnchor(template, anchor, CFrame.new(impactPosition))
	triggerImpactVfx(effectRoot, duration, emitCount)

	Debris:AddItem(anchor, cleanupDelay)

	if effectRoot ~= anchor and (effectRoot:IsA("Model") or effectRoot:IsA("BasePart")) then
		Debris:AddItem(effectRoot, cleanupDelay)
	end
end

local function setCharacterBallVisual(visible: boolean)
	local football = getCharacterFootball()
	if not football then
		return
	end

	-- VFX bola karakter sengaja selalu dimatikan.
	disableBallVfx(football)

	for _, descendant in ipairs(football:GetDescendants()) do
		if descendant:IsA("BasePart") then
			setBasePartVisible(descendant, visible)
		end
	end
end

local function isSameTrainingShot(shotInfo): boolean
	if typeof(shotInfo) ~= "table" then
		return true
	end

	if typeof(shotInfo.PlayerUserId) == "number" and shotInfo.PlayerUserId ~= player.UserId then
		return false
	end

	if currentTrainingShotId == nil then
		return true
	end

	return shotInfo.ShotId == currentTrainingShotId
end

local function isCurrentTrainingTarget(target: Instance?): boolean
	if typeof(target) ~= "Instance" or not currentTrainingArea then
		return false
	end

	local currentTarget = currentTrainingArea:FindFirstChild("Target")
	if not currentTarget then
		return false
	end

	return target == currentTarget or target:IsDescendantOf(currentTarget) or currentTarget:IsDescendantOf(target)
end

local function shouldPlayGoalPulseForImpact(target: Instance?, shotInfo): boolean
	if not currentTrainingArea or not isTrainingProjectileActive then
		return false
	end

	if currentTrainingShotId == nil or typeof(shotInfo) ~= "table" then
		return false
	end

	if not isSameTrainingShot(shotInfo) or not isCurrentTrainingTarget(target) then
		return false
	end

	if typeof(shotInfo) == "table" and lastGoalPulseShotId == shotInfo.ShotId then
		return false
	end

	return true
end

local function playTrainingAnimation(shotInfo)
	if trainingAnimationTrack then
		trainingAnimationTrack:Stop()
		trainingAnimationTrack:Destroy()
		trainingAnimationTrack = nil
	end

	local index = getTrainingAreaIndex(currentTrainingArea)
	local animData = getTrainingAnimationData(index)
	local animationId = animData.Id
	local playbackSpeed = getPlaybackSpeed(animData, animationSpeed)

	if typeof(shotInfo) == "table" then
		index = tonumber(shotInfo.TrainingIndex) or index
		animationId = shotInfo.AnimationId or animationId
		playbackSpeed = tonumber(shotInfo.PlaybackSpeed) or playbackSpeed
		currentTrainingShotId = shotInfo.ShotId
		lastGoalPulseShotId = nil

		if typeof(shotInfo.SpeedMultiplier) == "number" then
			animationSpeed =
				math.clamp(shotInfo.SpeedMultiplier, 1, getMaxAnimationSpeed(getTrainingAnimationData(index)))
		end
	else
		currentTrainingShotId = nil
		lastGoalPulseShotId = nil
	end

	if not animationId or animationId == "" then
		warn(`Training animation Id belum diatur untuk area index {index}`)
		return
	end

	local anim = getOrCreateAnimation(animationId, index)
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
	trainingAnimationTrack:Play(0, 1, playbackSpeed)
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

	if index == 1 then
		--local beam = trainingArea.Parent:FindFirstChild("Beam")
		--beam.TextureSpeed = BEAM_SPEED
	elseif DISABLE_COLLISION_TRAINING_INDEXES[index] then
		for _, descendant in ipairs(trainingArea.Parent:GetDescendants()) do
			if descendant:IsA("MeshPart") then
				descendant.CanCollide = false
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
	elseif DISABLE_COLLISION_TRAINING_INDEXES[index] then
		for _, descendant in ipairs(trainingArea.Parent:GetDescendants()) do
			if descendant:IsA("MeshPart") and not descendant:FindFirstAncestor("Boost") then
				descendant.CanCollide = true
			end
		end
	end
end

local function increaseTrainingSpeed()
	if not currentTrainingArea then
		return
	end

	local index = getTrainingAreaIndex(currentTrainingArea)
	local animData = getTrainingAnimationData(index)
	local maxSpeed = getMaxAnimationSpeed(animData)

	animationSpeed += ANIMATION_SPEED_INCREASE
	animationSpeed = math.clamp(animationSpeed, 1, maxSpeed)

	if index == 1 then
		--local beam = currentTrainingArea.Parent:FindFirstChild("Beam")
		--beam.TextureSpeed = BEAM_SPEED * animationSpeed
	end
end

local function decreaseTrainingSpeed()
	if not currentTrainingArea then
		return
	end

	local index = getTrainingAreaIndex(currentTrainingArea)
	local animData = getTrainingAnimationData(index)
	local maxSpeed = getMaxAnimationSpeed(animData)

	animationSpeed -= ANIMATION_SPEED_DECAY
	animationSpeed = math.clamp(animationSpeed, 1, maxSpeed)

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

	TrainingService:ShootTrainingBall(currentTrainingArea, animationSpeed)
end

--|| Functions ||--
function TrainingController:StartTraining(trainingArea, isTransport)
	print(trainingArea:GetAttribute("Index"))
	if currentTrainingArea == trainingArea and self.IsTraining then
		return
	end

	trainingStartRequestId += 1
	local requestId = trainingStartRequestId
	pendingTrainingArea = trainingArea

	local pivot = trainingArea:FindFirstChild("Pivot")
	local character = player.Character

	if pivot and character then
		player:RequestStreamAroundAsync(pivot.Position)
		if isTransport then
			self.IsAutoTrain = true
			character:PivotTo(pivot.CFrame)
		end
	end

	local function canRetryStart()
		return requestId == trainingStartRequestId
			and pendingTrainingArea == trainingArea
			and (isTransport or localTrainingAreas[trainingArea] == true)
	end

	local function activateTraining()
		pendingTrainingArea = nil
		currentTrainingArea = trainingArea

		-- disableMovement()
		-- hideOtherPlayers()

		self.IsTraining = true

		-- Deteksi lompat (lebih aman untuk mobile)
		local currentCharacter = player.Character
		local humanoid = currentCharacter and currentCharacter:FindFirstChild("Humanoid")
		if humanoid then
			if humanoidJumpConnection then
				humanoidJumpConnection:Disconnect()
			end

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

		--playTrainingAnimation(index)
		startTrainingAreaVisual(trainingArea)

		-- Mulai loop training
		task.spawn(function()
			preloadTrainingAnimation(getTrainingAreaIndex(trainingArea))

			while self.IsTraining and currentTrainingArea == trainingArea do
				TrainingService:Training(trainingArea)
				requestTrainingBallShot()
				task.wait(1.5)
			end
		end)

		TrainingSignals.TrainingStarted:Fire(trainingArea)
	end

	local function requestStart(attempt: number)
		TrainingService:StartTraining(trainingArea):andThen(function(result)
			if requestId ~= trainingStartRequestId then
				return
			end

			local canStart = result == true or (typeof(result) == "table" and result.Success == true)
			if canStart then
				activateTraining()
				return
			end

			local reason = typeof(result) == "table" and result.Reason or nil
			if reason == "Outside" and attempt < TRAINING_START_RETRY_ATTEMPTS and canRetryStart() then
				task.delay(TRAINING_START_RETRY_INTERVAL, function()
					if canRetryStart() then
						requestStart(attempt + 1)
					end
				end)
				return
			end

			pendingTrainingArea = nil
			if isTransport then
				self.IsAutoTrain = false
			end
		end)
	end

	requestStart(1)
end

function TrainingController:StopTraining(trainingArea)
	--enableMovement()
	-- showOtherPlayers()

	if trainingArea ~= nil and currentTrainingArea ~= nil and currentTrainingArea ~= trainingArea then
		TrainingService:StopTraining(trainingArea)
		return
	end

	if trainingArea == nil or pendingTrainingArea == nil or pendingTrainingArea == trainingArea then
		trainingStartRequestId += 1
		pendingTrainingArea = nil
	end

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

	stopTrainingAnimation()
	currentTrainingShotId = nil
	lastGoalPulseShotId = nil

	if not isTrainingProjectileActive then
		setCharacterBallVisual(true)
	end

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

			increaseTrainingSpeed()
			requestTrainingBallShot()
			cooldown = true

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
	DataService = Knit.GetService("DataService")

	DataCacheController = Knit.GetController("DataCacheController")
	local templateData = DataCacheController:GetFile("Template")
	TrainingAreasData = templateData.TrainingAreas
	EnemiesData = templateData.Enemies
	ImagesData = DataCacheController:GetFile("Images")

	NotificationController = Knit.GetController("NotificationController")
	AutoController = Knit.GetController("AutoController")
	CharactersController = Knit.GetController("CharactersController")
	TrailsController = Knit.GetController("TrailsController")
	FightController = Knit.GetController("FightController")

	TrainingService.TrainingAreaLocked:Connect(function(bossName)
		NotificationController:Notify({
			tag = "Training",
			text = "Required: Defeat " .. tostring(bossName) .. " first!",
			type = "ERROR",
		})
	end)

	DataService.BossProgressUpdated:Connect(function(updatedProgress)
		bossProgress = updatedProgress or {}
		updateAllTrainingAreaRequirementTexts()
	end)

	DataService:GetData():andThen(function(data)
		bossProgress = data and data.BossProgress or {}
		updateAllTrainingAreaRequirementTexts()
	end)

	AutoTrainingSignals.AutoTrainingStopped:Connect(function()
		if currentTrainingArea then
			self:StopTraining(currentTrainingArea)
		end
	end)

	BallService.BallWindupStarted:Connect(function(shotInfo)
		isTrainingProjectileActive = false
		playTrainingAnimation(shotInfo)
		setCharacterBallVisual(true)
	end)

	BallService.BallShoot:Connect(function(shotInfo)
		if not isSameTrainingShot(shotInfo) then
			return
		end

		isTrainingProjectileActive = true
		setCharacterBallVisual(false)
	end)

	BallService.BallImpact:Connect(function(target, impactPosition, shotInfo)
		if typeof(impactPosition) ~= "Vector3" then
			return
		end

		if not shouldPlayGoalPulseForImpact(target, shotInfo) then
			return
		end

		if typeof(shotInfo) == "table" then
			lastGoalPulseShotId = shotInfo.ShotId
		end

		playTrainingGoalPulse(currentTrainingArea)
		-- playTargetImpactVfx(target, impactPosition)
	end)

	BallService.BallFinished:Connect(function(shotInfo)
		if not isSameTrainingShot(shotInfo) then
			return
		end

		stopTrainingAnimation()
		currentTrainingShotId = nil
		lastGoalPulseShotId = nil
		isTrainingProjectileActive = false

		local restoreDelay = 0
		if typeof(shotInfo) == "table" and typeof(shotInfo.RestoreCharacterBallDelay) == "number" then
			restoreDelay = math.max(0, shotInfo.RestoreCharacterBallDelay)
		end

		if restoreDelay > 0 then
			task.delay(restoreDelay, function()
				if currentTrainingShotId == nil and not isTrainingProjectileActive then
					setCharacterBallVisual(true)
				end
			end)
		else
			setCharacterBallVisual(true)
		end
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

				localTrainingAreas[trainingArea] = true
				self.IsAutoTrain = false
				self:StartTraining(trainingArea)
			end)

			--  KELUAR ZONE
			zone.playerExited:Connect(function(plr)
				if plr ~= player then
					return
				end
				localTrainingAreas[trainingArea] = nil
				TrainingSignals.TrainingStopped:Fire(trainingArea)

				if AutoController.IsAutoTraining and not self.IsAutoTrain then
					AutoController:AutoTrain()
				end
				self:StopTraining(trainingArea)
			end)
			table.insert(trainingAreas, trainingArea)
			updateTrainingAreaRequirementText(trainingArea)
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
					if not effectiveTrainingArea then
						return
					end

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
