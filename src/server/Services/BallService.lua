local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Sound = require(Packages.Sound)

--// CONFIG
local DEFAULT_BALL_LIFETIME = 2
local DEFAULT_CURVE_HEIGHT = 12
local DEFAULT_HORIZONTAL_CURVE = 5
local DEFAULT_SHOOT_COOLDOWN = 1.15
local DEFAULT_WINDUP_TIME = 0.3
local CHARACTER_BALL_RESTORE_DELAY = 0.12
local IMPACT_VFX_DURATION = 0.1
local IMPACT_VFX_CLEANUP_DELAY = 2.5
local DEFAULT_IMPACT_EMIT_COUNT = 25

local TARGET_IMPACT_VFX_NAMES = {
	"TrainingImpactVFX",
	"ImpactEffects",
	"ExplodeEffects",
	"SpecialEffects",
	"HoldEffects",
	"VFX",
	"Effects",
}

local BALL_EFFECT_ROOT_NAMES = {
	"TrainingEffects",
	"TrainingVFX",
	"Effects",
	"Efek",
	"Effect",
	"VFX",
}

local BALL_KICK_VFX_NAMES = {}

local KICK_VFX_DURATION = 1
local KICK_VFX_CLEANUP_DELAY = 1.75
local DEFAULT_KICK_EMIT_COUNT = 20

local DEFAULT_START_FORWARD_OFFSET = 2.0
local DEFAULT_START_RIGHT_OFFSET = 0.5
local DEFAULT_START_HEIGHT_OFFSET = 0.2

local BallService = Knit.CreateService({
	Name = "BallService",
	Client = {
		BallWindupStarted = Knit.CreateSignal(),
		BallShoot = Knit.CreateSignal(),
		BallImpact = Knit.CreateSignal(),
		BallFinished = Knit.CreateSignal(),
	},
})

BallService.LastShootTime = {}
BallService.ActiveShots = {}
BallService.ActiveShotInfos = {}
BallService.ActiveShotPhases = {}
BallService.ShotCounters = {}

local function getRightFoot(character)
	return character:FindFirstChild("RightFoot") -- R15
		or character:FindFirstChild("Right Leg") -- R6
		or character:FindFirstChild("RightLowerLeg") -- fallback R15
end

local function getObjectPosition(obj)
	if obj:IsA("Model") then
		return obj:GetPivot().Position
	elseif obj:IsA("BasePart") then
		return obj.Position
	end

	return Vector3.zero
end

local function setObjectCFrame(obj, cf)
	if obj:IsA("Model") then
		obj:PivotTo(cf)
	elseif obj:IsA("BasePart") then
		obj.CFrame = cf
	end
end

local function getNumber(value, fallback)
	if typeof(value) == "number" then
		return value
	end

	return fallback
end

local function getTargetPosition(target, root)
	if target then
		if target:IsA("BasePart") then
			return target.Position
		elseif target:IsA("Model") then
			return target:GetPivot().Position
		elseif target:IsA("Attachment") then
			return target.WorldPosition
		end
	end

	return root.Position + root.CFrame.LookVector * 50
end

local function getBallSpawnPosition(character, root, targetPosition, shotConfig)
	local startForwardOffset = getNumber(shotConfig.StartForwardOffset, DEFAULT_START_FORWARD_OFFSET)
	local startRightOffset = getNumber(shotConfig.StartRightOffset, DEFAULT_START_RIGHT_OFFSET)
	local startHeightOffset = getNumber(shotConfig.StartHeightOffset, DEFAULT_START_HEIGHT_OFFSET)

	local basePos = root.Position

	local rightFoot = getRightFoot(character)
	if rightFoot and rightFoot:IsA("BasePart") then
		basePos = Vector3.new(basePos.X, rightFoot.Position.Y + 0.2, basePos.Z)
	end

	local flatDirection = Vector3.new(targetPosition.X - root.Position.X, 0, targetPosition.Z - root.Position.Z)

	if flatDirection.Magnitude < 0.001 then
		flatDirection = root.CFrame.LookVector
		flatDirection = Vector3.new(flatDirection.X, 0, flatDirection.Z)
	end

	if flatDirection.Magnitude < 0.001 then
		flatDirection = Vector3.new(0, 0, -1)
	end

	flatDirection = flatDirection.Unit

	local rightDirection = flatDirection:Cross(Vector3.yAxis)
	if rightDirection.Magnitude < 0.001 then
		rightDirection = Vector3.xAxis
	else
		rightDirection = rightDirection.Unit
	end

	local spawnPos = basePos
		+ (flatDirection * startForwardOffset)
		+ (rightDirection * startRightOffset)
		+ Vector3.new(0, startHeightOffset, 0)

	return spawnPos
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

local function removeBallVfx(root: Instance)
	for _, descendant in ipairs(root:GetDescendants()) do
		if isBallVfx(descendant) then
			descendant:Destroy()
		end
	end
end

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

local function findChildByNames(parent: Instance?, names)
	if not parent then
		return nil
	end

	for _, name in ipairs(names) do
		local child = parent:FindFirstChild(name)
		if child then
			return child
		end
	end

	local lowerNameMap = {}
	for _, name in ipairs(names) do
		lowerNameMap[string.lower(tostring(name))] = true
	end

	for _, child in ipairs(parent:GetChildren()) do
		if lowerNameMap[string.lower(child.Name)] then
			return child
		end
	end

	return nil
end

local function findFirstVfxChild(parent: Instance?)
	if not parent then
		return nil
	end

	for _, child in ipairs(parent:GetChildren()) do
		if hasVfx(child) then
			return child
		end
	end

	return nil
end

local function findBallKickVfxTemplate(ballTemplate: Instance?, zoneId: any)
	if not ballTemplate then
		return nil
	end

	local effectsRoot = findChildByNames(ballTemplate, BALL_EFFECT_ROOT_NAMES)
	if not effectsRoot then
		return nil
	end

	local zoneNames = {}
	if zoneId ~= nil then
		table.insert(zoneNames, tostring(zoneId))
	end
	table.insert(zoneNames, "Default")

	local zoneFolder = findChildByNames(effectsRoot, zoneNames)
	if not zoneFolder then
		return nil
	end

	-- Struktur yang disarankan:
	-- BallModel
	--   Effects / Efek
	--     Zone1
	--       KickEffects / asset VFX
	local namedKickEffect = findChildByNames(zoneFolder, BALL_KICK_VFX_NAMES)
	if namedKickEffect and hasVfx(namedKickEffect) then
		return namedKickEffect
	end

	local firstVfxChild = findFirstVfxChild(zoneFolder)
	if firstVfxChild then
		return firstVfxChild
	end

	if hasVfx(zoneFolder) then
		return zoneFolder
	end

	return nil
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

local function getFirstBasePart(root: Instance): BasePart?
	if root:IsA("BasePart") then
		return root
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("BasePart") then
			return descendant
		end
	end

	return nil
end

local function findKickTrailAttachment(ball: Instance, name: string): Attachment?
	local attachment = ball:FindFirstChild(name)
	if attachment and attachment:IsA("Attachment") then
		return attachment
	end

	local ballPart = getFirstBasePart(ball)
	if ballPart then
		attachment = ballPart:FindFirstChild(name)
		if attachment and attachment:IsA("Attachment") then
			return attachment
		end
	end

	return nil
end

local function bindKickTrailAttachments(effectRoot: Instance, ball: Instance)
	local attachment0 = findKickTrailAttachment(ball, "A0")
	local attachment1 = findKickTrailAttachment(ball, "A1")
	if not attachment0 or not attachment1 then
		return
	end

	for _, descendant in ipairs(getSelfAndDescendants(effectRoot)) do
		if descendant:IsA("Trail") then
			descendant.Attachment0 = attachment0
			descendant.Attachment1 = attachment1
		end
	end
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

		effectRoot = anchor
	end

	return effectRoot
end

local triggerImpactVfx

local function getKickVfxConfig(template: Instance)
	local duration = template:GetAttribute("Duration")
	if typeof(duration) ~= "number" then
		duration = KICK_VFX_DURATION
	end

	local cleanupDelay = template:GetAttribute("CleanupDelay")
	if typeof(cleanupDelay) ~= "number" then
		cleanupDelay = KICK_VFX_CLEANUP_DELAY
	end

	local emitCount = template:GetAttribute("EmitCount")
	if typeof(emitCount) ~= "number" then
		emitCount = DEFAULT_KICK_EMIT_COUNT
	end

	return duration, cleanupDelay, emitCount
end

local function attachKickVfxAnchor(anchor: BasePart, basePart: BasePart, parent: Instance, cf: CFrame)
	for _, child in ipairs(anchor:GetChildren()) do
		if child:IsA("WeldConstraint") then
			child:Destroy()
		end
	end

	anchor.CFrame = cf
	anchor.Parent = parent
	weldPartToBase(anchor, basePart)
end

local function createKickVfxAnchor(
	ballTemplate: Instance?,
	zoneId: any,
	basePart: BasePart,
	parent: Instance,
	cf: CFrame
)
	local template = findBallKickVfxTemplate(ballTemplate, zoneId)
	if not template then
		return
	end

	local duration, cleanupDelay, emitCount = getKickVfxConfig(template)
	local anchor = Instance.new("Part")
	anchor.Name = "TrainingKickVFXAnchor"
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Transparency = 1
	attachKickVfxAnchor(anchor, basePart, parent, cf)

	local effectRoot = attachVfxTemplateToAnchor(template, anchor, cf)
	bindKickTrailAttachments(effectRoot, parent)
	triggerImpactVfx(effectRoot, duration, emitCount)

	Debris:AddItem(anchor, cleanupDelay)

	if effectRoot ~= anchor and (effectRoot:IsA("Model") or effectRoot:IsA("BasePart")) then
		Debris:AddItem(effectRoot, cleanupDelay)
	end

	return anchor
end

local function getCharacterFootball(character: Model): Instance?
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end

	return root:FindFirstChild("Football")
end

local function playKickCharacterBallVfx(ballTemplate: Instance?, zoneId: any, character: Model?)
	if not character then
		return
	end

	local football = getCharacterFootball(character)
	if not football then
		return
	end

	local ballPart = getFirstBasePart(football)
	if not ballPart then
		return
	end

	local ballCFrame = if football:IsA("Model") then football:GetPivot() else ballPart.CFrame
	return createKickVfxAnchor(ballTemplate, zoneId, ballPart, football, ballCFrame)
end

local function moveKickVfxToBall(anchor: BasePart?, ball: Instance?)
	if not anchor or not anchor.Parent or not ball then
		return false
	end

	local ballPart = getFirstBasePart(ball)
	if not ballPart then
		return false
	end

	local ballCFrame = if ball:IsA("Model") then ball:GetPivot() else ballPart.CFrame
	attachKickVfxAnchor(anchor, ballPart, ball, ballCFrame)
	bindKickTrailAttachments(anchor, ball)
	return true
end

local function playKickBallVfx(ballTemplate: Instance?, zoneId: any, ball: Instance?)
	if not ball then
		return
	end

	local ballPart = getFirstBasePart(ball)
	if not ballPart then
		return
	end

	local ballCFrame = if ball:IsA("Model") then ball:GetPivot() else ballPart.CFrame
	return createKickVfxAnchor(ballTemplate, zoneId, ballPart, ball, ballCFrame)
end

function triggerImpactVfx(root: Instance, duration: number, defaultEmitCount: number)
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

local function fireBallImpactToClients(service, target: Instance?, impactPosition: Vector3, shotInfo)
	for _, clientPlayer in ipairs(Players:GetPlayers()) do
		service.Client.BallImpact:Fire(clientPlayer, target, impactPosition, shotInfo)
	end
end

local function prepareProjectileBall(ball: Instance)
	removeBallVfx(ball)

	-- Training ball digerakkan manual oleh Heartbeat, jadi physics/collision tidak boleh ikut memotong gerak.
	-- Ini penting untuk area tertentu yang punya collider/mesh dekat target, terutama index 2.
	for _, descendant in ipairs(ball:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
		end
	end

	if ball:IsA("BasePart") then
		ball.Anchored = true
		ball.CanCollide = false
		ball.CanTouch = false
		ball.CanQuery = false
		ball.Massless = true
	end
end

local function hideProjectileBall(ball: Instance?)
	if not ball then
		return
	end

	if ball:IsA("BasePart") then
		ball.Transparency = 1
	end

	for _, descendant in ipairs(ball:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Transparency = 1
		elseif isBallVfx(descendant) then
			pcall(function()
				descendant.Enabled = false
			end)
		end
	end
end

local function cloneShotInfoWithRestoreDelay(shotInfo)
	local result = {}

	if typeof(shotInfo) == "table" then
		for key, value in pairs(shotInfo) do
			result[key] = value
		end
	end

	result.RestoreCharacterBallDelay = CHARACTER_BALL_RESTORE_DELAY
	return result
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

local function setCharacterFootballVisual(player: Player, visible: boolean)
	local character = player.Character
	if not character then
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local football = hrp:FindFirstChild("Football")
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

local function makeClientShotInfo(shotId: number, shotConfig)
	shotConfig = shotConfig or {}
	local projectileLifetime = tonumber(shotConfig.ProjectileLifetime)
		or tonumber(shotConfig.BallLifetime)
		or DEFAULT_BALL_LIFETIME

	return {
		ShotId = shotId,
		PlayerUserId = shotConfig.PlayerUserId,
		TrainingIndex = shotConfig.TrainingIndex,
		TrainingZone = shotConfig.TrainingZone,
		AnimationId = shotConfig.AnimationId,
		BaseSpeed = shotConfig.BaseSpeed,
		SpeedMultiplier = shotConfig.SpeedMultiplier,
		PlaybackSpeed = shotConfig.PlaybackSpeed,
		KickContactTime = shotConfig.KickContactTime,
		WindupTime = shotConfig.WindupTime,
		CooldownTime = shotConfig.CooldownTime,
		ProjectileLifetime = projectileLifetime,
		BallLifetime = projectileLifetime,
	}
end

function BallService:ResetPlayer(player: Player)
	local activeShotInfo = self.ActiveShotInfos[player]
	local activePhase = self.ActiveShotPhases[player]

	self.LastShootTime[player] = nil

	if activePhase == "projectile" then
		return
	end

	setCharacterFootballVisual(player, true)

	self.ActiveShots[player] = nil
	self.ActiveShotInfos[player] = nil
	self.ActiveShotPhases[player] = nil
	self.ShotCounters[player] = (self.ShotCounters[player] or 0) + 1

	if activeShotInfo then
		self.Client.BallFinished:Fire(player, activeShotInfo)
	end
end

function BallService:ShootBall(player: Player, target, shotConfig)
	shotConfig = shotConfig or {}

	if self.ActiveShots[player] ~= nil then
		return false
	end

	local now = os.clock()
	local cooldown = tonumber(shotConfig.CooldownTime) or DEFAULT_SHOOT_COOLDOWN
	if self.LastShootTime[player] and (now - self.LastShootTime[player]) < cooldown then
		return false
	end
	self.LastShootTime[player] = now

	local character = player.Character
	if not character then
		return false
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end

	local targetPosition = getTargetPosition(target, root)
	local windupTime = tonumber(shotConfig.WindupTime) or DEFAULT_WINDUP_TIME
	windupTime = math.max(0, windupTime)

	local projectileLifetime = tonumber(shotConfig.ProjectileLifetime)
		or tonumber(shotConfig.BallLifetime)
		or DEFAULT_BALL_LIFETIME
	projectileLifetime = math.max(0.05, projectileLifetime)

	local curveHeight = tonumber(shotConfig.CurveHeight) or DEFAULT_CURVE_HEIGHT
	local horizontalCurve = tonumber(shotConfig.HorizontalCurve) or DEFAULT_HORIZONTAL_CURVE

	self.ShotCounters[player] = (self.ShotCounters[player] or 0) + 1
	local shotId = self.ShotCounters[player]
	self.ActiveShots[player] = shotId
	self.ActiveShotPhases[player] = "windup"

	local clientShotInfo = makeClientShotInfo(shotId, {
		PlayerUserId = player.UserId,
		TrainingIndex = shotConfig.TrainingIndex,
		TrainingZone = shotConfig.TrainingZone,
		AnimationId = shotConfig.AnimationId,
		BaseSpeed = shotConfig.BaseSpeed,
		SpeedMultiplier = shotConfig.SpeedMultiplier,
		PlaybackSpeed = shotConfig.PlaybackSpeed,
		KickContactTime = shotConfig.KickContactTime,
		WindupTime = windupTime,
		CooldownTime = shotConfig.CooldownTime,
		ProjectileLifetime = projectileLifetime,
		BallLifetime = projectileLifetime,
	})
	self.ActiveShotInfos[player] = clientShotInfo

	setCharacterFootballVisual(player, true)
	self.Client.BallWindupStarted:Fire(player, clientShotInfo)
	local kickVfxAnchor: BasePart?

	local ballTemplate = ReplicatedStorage:FindFirstChild("BallModel")
	if not ballTemplate then
		warn("BallModel tidak ditemukan di ReplicatedStorage!")
		self.ActiveShots[player] = nil
		self.ActiveShotInfos[player] = nil
		self.ActiveShotPhases[player] = nil
		setCharacterFootballVisual(player, true)
		self.Client.BallFinished:Fire(player, clientShotInfo)
		return false
	end

	task.delay(math.max(0, windupTime - 0.7), function()
		if self.ActiveShots[player] ~= shotId then
			return
		end

		if character.Parent then
			kickVfxAnchor = playKickCharacterBallVfx(ballTemplate, shotConfig.TrainingZone, character)
		end
	end)

	task.delay(windupTime, function()
		if self.ActiveShots[player] ~= shotId then
			return
		end

		if not character.Parent or not root.Parent then
			if self.ActiveShots[player] == shotId then
				self.ActiveShots[player] = nil
				self.ActiveShotInfos[player] = nil
				self.ActiveShotPhases[player] = nil
			end

			setCharacterFootballVisual(player, true)
			self.Client.BallFinished:Fire(player, clientShotInfo)
			return
		end

		local ball = ballTemplate:Clone()
		prepareProjectileBall(ball)
		ball:SetAttribute("TrainingProjectile", true)
		ball:SetAttribute("TrainingShotId", shotId)
		ball:SetAttribute("TrainingIndex", tonumber(shotConfig.TrainingIndex) or 0)
		if shotConfig.TrainingZone ~= nil then
			ball:SetAttribute("TrainingZone", tostring(shotConfig.TrainingZone))
		end
		ball:SetAttribute("ProjectileLifetime", projectileLifetime)

		local spawnPos = getBallSpawnPosition(character, root, targetPosition, shotConfig)
		setObjectCFrame(ball, CFrame.lookAt(spawnPos, targetPosition))
		ball.Parent = workspace
		if not moveKickVfxToBall(kickVfxAnchor, ball) then
			playKickBallVfx(ballTemplate, shotConfig.TrainingZone, ball)
		end

		self.ActiveShotPhases[player] = "projectile"
		setCharacterFootballVisual(player, false)
		Sound:PlaySound("MISC_Shoot_Training", root)
		self.Client.BallShoot:Fire(player, clientShotInfo)

		local start = getObjectPosition(ball)
		local midPoint = (start + targetPosition) / 2
		local horizontalDirection = Vector3.new(targetPosition.X - start.X, 0, targetPosition.Z - start.Z)
		local horizontalOffset = Vector3.zero

		if horizontalDirection.Magnitude > 0.001 then
			horizontalOffset = Vector3.yAxis:Cross(horizontalDirection.Unit) * horizontalCurve
		end

		midPoint += horizontalOffset + Vector3.yAxis * curveHeight

		local elapsed = 0
		local finished = false
		local impactPlayed = false
		local connection

		local function finishShot(shouldDestroyBall: boolean)
			if finished then
				return
			end

			finished = true

			if connection then
				connection:Disconnect()
				connection = nil
			end

			-- if shouldDestroyBall then
			-- 	playTargetImpactVfx(target, targetPosition)
			-- end

			if ball and ball.Parent then
				hideProjectileBall(ball)
			end

			if shouldDestroyBall and ball and ball.Parent then
				task.defer(function()
					if ball and ball.Parent then
						ball:Destroy()
					end
				end)
			end

			if self.ActiveShots[player] == shotId then
				self.ActiveShots[player] = nil
				self.ActiveShotInfos[player] = nil
				self.ActiveShotPhases[player] = nil

				local finishedShotInfo = cloneShotInfoWithRestoreDelay(clientShotInfo)
				self.Client.BallFinished:Fire(player, finishedShotInfo)

				task.delay(CHARACTER_BALL_RESTORE_DELAY, function()
					if self.ActiveShots[player] == nil then
						setCharacterFootballVisual(player, true)
					end
				end)
			end
		end

		connection = RunService.Heartbeat:Connect(function(dt)
			if self.ActiveShots[player] ~= shotId then
				if connection then
					connection:Disconnect()
					connection = nil
				end

				if ball and ball.Parent then
					hideProjectileBall(ball)
					ball:Destroy()
				end

				return
			end

			if not ball or not ball.Parent then
				finishShot(false)
				return
			end

			elapsed += dt
			local t = math.clamp(elapsed / projectileLifetime, 0, 1)
			local smoothT = t * t * (3 - 2 * t)

			local a = start:Lerp(midPoint, smoothT)
			local b = midPoint:Lerp(targetPosition, smoothT)
			local pos = a:Lerp(b, smoothT)

			setObjectCFrame(ball, CFrame.new(pos) * CFrame.Angles(t * 20, t * 20, 0))

			if not impactPlayed and elapsed >= projectileLifetime * 0.75 then
				impactPlayed = true
				-- Sound:PlaySound("MISC_Training_Goal", target)
				fireBallImpactToClients(self, target, targetPosition, clientShotInfo)
			end

			if elapsed >= projectileLifetime then
				finishShot(true)
			end
		end)

		task.delay(projectileLifetime + 1, function()
			finishShot(true)
		end)
	end)

	return true
end

function BallService:KnitStart()
	Players.PlayerRemoving:Connect(function(player)
		self.LastShootTime[player] = nil
		self.ActiveShots[player] = nil
		self.ActiveShotInfos[player] = nil
		self.ActiveShotPhases[player] = nil
		self.ShotCounters[player] = nil
	end)
end

return BallService
