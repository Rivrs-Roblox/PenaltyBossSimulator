-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")

-- Knit Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataService
local MonetizationService
--local SeasonService
local DataCacheService
local BallService
local FightService

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FindValue = require(Helpers.Table.FindValue)
local FormatNumber = require(Helpers.Numbers.FormatNumber)

-- Data
local TrainingAnimationData = require(ReplicatedStorage.Shared.Data.TrainingAnimationData)

local TrainingAreas
local TrainingAreasData
local PlayersInTraining = {}

local FACE_DURATION = 1
local FACE_RESPONSIVENESS = 50
local FACE_MAX_TORQUE = 400000
local VIP_TRAINING_INDEX = 6
local TRAINING_AREA_POSITION_PADDING = 3

local TrainingService = Knit.CreateService({
	Name = "TrainingService",
	Client = {
		InsufficientPower = Knit.CreateSignal(),
	},
})

--|| Client Functions ||--
function TrainingService.Client:Training(player: Player, trainingArea)
	return self.Server:Training(player, trainingArea)
end

function TrainingService.Client:StartTraining(player: Player, trainingArea)
	return self.Server:StartTraining(player, trainingArea)
end

function TrainingService.Client:StopTraining(player: Player, trainingArea)
	return self.Server:StopTraining(player, trainingArea)
end

function TrainingService.Client:GetMostEffectiveArea(player: Player)
	return self.Server:GetMostEffectiveArea(player)
end

function TrainingService.Client:CheckAvailability(player: Player, trainingArea)
	return self.Server:CheckAvailability(player, trainingArea)
end

function TrainingService.Client:ShootTrainingBall(player: Player, trainingArea, speedMultiplier)
	return self.Server:ShootTrainingBall(player, trainingArea, speedMultiplier)
end

--|| Functions ||--

local function getTargetPosition(target)
	if target then
		if target:IsA("BasePart") then
			return target.Position
		elseif target:IsA("Model") then
			return target:GetPivot().Position
		elseif target:IsA("Attachment") then
			return target.WorldPosition
		end
	end

	return nil
end

local function getPlayerRoot(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function getTrainingZoneInstance(trainingArea): Instance?
	if typeof(trainingArea) ~= "Instance" then
		return nil
	end

	local zone = trainingArea:FindFirstChild("Zone")
	if zone and (zone:IsA("BasePart") or zone:IsA("Model")) then
		return zone
	end

	if trainingArea:IsA("BasePart") or trainingArea:IsA("Model") then
		return trainingArea
	end

	return nil
end

local function isPositionInsideBounds(position: Vector3, boundsCFrame: CFrame, boundsSize: Vector3, padding: number): boolean
	local localPosition = boundsCFrame:PointToObjectSpace(position)
	local halfSize = (boundsSize * 0.5) + Vector3.new(padding, padding, padding)

	return math.abs(localPosition.X) <= halfSize.X
		and math.abs(localPosition.Y) <= halfSize.Y
		and math.abs(localPosition.Z) <= halfSize.Z
end

local function isPlayerPhysicallyInTrainingArea(player: Player, trainingArea): boolean
	local root = getPlayerRoot(player)
	if not root then
		return false
	end

	local zone = getTrainingZoneInstance(trainingArea)
	if not zone then
		return false
	end

	if zone:IsA("BasePart") then
		return isPositionInsideBounds(root.Position, zone.CFrame, zone.Size, TRAINING_AREA_POSITION_PADDING)
	elseif zone:IsA("Model") then
		local boundsCFrame, boundsSize = zone:GetBoundingBox()
		return isPositionInsideBounds(root.Position, boundsCFrame, boundsSize, TRAINING_AREA_POSITION_PADDING)
	end

	return false
end

local function isPlayerFighting(player: Player): boolean
	return FightService ~= nil and FightService.Sessions ~= nil and FightService.Sessions[player] ~= nil
end

local function isPlayerRegisteredForTraining(player: Player, trainingArea): boolean
	if typeof(trainingArea) ~= "Instance" then
		return false
	end

	local areaPlayers = PlayersInTraining[trainingArea]
	return areaPlayers ~= nil and areaPlayers[player] == true
end

local function getTrainingAreaData(trainingArea)
	if typeof(trainingArea) ~= "Instance" then
		return nil
	end

	local area = trainingArea:GetAttribute("Area")
	local index = trainingArea:GetAttribute("Index")

	if TrainingAreasData == nil or TrainingAreasData[area] == nil then
		return nil
	end

	return TrainingAreasData[area][index]
end

local function canPlayerUseTrainingArea(player: Player, trainingArea, shouldNotify: boolean): boolean
	local areaData = getTrainingAreaData(trainingArea)
	if not areaData then
		return false
	end

	local playerData = DataService:GetData(player)
	if not playerData then
		return false
	end

	if areaData.VIP and not FindValue(playerData.Gamepasses, "VIP") then
		if shouldNotify then
			MonetizationService:PromptPurchase(player, "VIP", "GamePasses")
		end
		return false
	end

	if playerData.Money2 < areaData.PowerRequirement then
		if shouldNotify then
			TrainingService.Client.InsufficientPower:Fire(player, areaData.PowerRequirement - playerData.Money2)
		end
		return false
	end

	return true
end

local function getTrainingAnimationData(index: number)
	return TrainingAnimationData.Areas[index] or TrainingAnimationData.Default
end

local function getKickContactTime(animData): number
	local events = animData and animData.Events
	local kickContact = events and events.KickContact
	local time = kickContact and kickContact.Time

	if typeof(time) == "number" then
		return time
	end

	local defaultEvents = TrainingAnimationData.Default.Events
	local defaultKickContact = defaultEvents and defaultEvents.KickContact
	return (defaultKickContact and defaultKickContact.Time) or 0.3
end

local function getAnimationBaseSpeed(animData): number
	local speed = animData and animData.Speed
	if typeof(speed) == "number" and speed > 0 then
		return speed
	end

	return TrainingAnimationData.Default.Speed or 1
end

local function getMaxSpeedMultiplier(animData): number
	return tonumber(animData and animData.MaxSpeedMultiplier)
		or tonumber(TrainingAnimationData.Default.MaxSpeedMultiplier)
		or 3
end

local function getBallData(animData)
	local defaultBallData = TrainingAnimationData.Default.Ball or {}
	return (animData and animData.Ball) or defaultBallData, defaultBallData
end

local function getBallNumber(animData, key: string, fallback: number): number
	local ballData, defaultBallData = getBallData(animData)
	local value = ballData and ballData[key]
	if typeof(value) == "number" then
		return value
	end

	local defaultValue = defaultBallData and defaultBallData[key]
	if typeof(defaultValue) == "number" then
		return defaultValue
	end

	return fallback
end

local function buildTrainingShotConfig(trainingArea, requestedSpeedMultiplier)
	local index = tonumber(trainingArea:GetAttribute("Index")) or TrainingAnimationData.Default.Index or 1
	local animData = getTrainingAnimationData(index)

	local speedMultiplier = tonumber(requestedSpeedMultiplier) or 1
	speedMultiplier = math.clamp(speedMultiplier, 1, getMaxSpeedMultiplier(animData))

	local baseSpeed = getAnimationBaseSpeed(animData)
	local playbackSpeed = math.max(0.01, baseSpeed * speedMultiplier)
	local kickContactTime = getKickContactTime(animData)
	local windupTime = kickContactTime / playbackSpeed

	local projectileLifetime = getBallNumber(animData, "Lifetime", 2)
	local curveHeight = getBallNumber(animData, "CurveHeight", 12)
	local horizontalCurve = getBallNumber(animData, "HorizontalCurve", 5)
	local startForwardOffset = getBallNumber(animData, "StartForwardOffset", 2.0)
	local startRightOffset = getBallNumber(animData, "StartRightOffset", 0.5)
	local startHeightOffset = getBallNumber(animData, "StartHeightOffset", 0.2)

	local minimumCooldown = tonumber(animData.MinimumShootCooldown)
		or tonumber(TrainingAnimationData.Default.MinimumShootCooldown)
		or 1.15
	local cooldownPadding = tonumber(animData.CooldownPadding)
		or tonumber(TrainingAnimationData.Default.CooldownPadding)
		or 0.15

	return {
		TrainingIndex = index,
		TrainingZone = trainingArea:GetAttribute("Area"),
		AnimationId = animData.Id or TrainingAnimationData.Default.Id,
		BaseSpeed = baseSpeed,
		SpeedMultiplier = speedMultiplier,
		PlaybackSpeed = playbackSpeed,
		KickContactTime = kickContactTime,
		WindupTime = windupTime,
		ProjectileLifetime = projectileLifetime,
		BallLifetime = projectileLifetime, -- backward compatibility untuk client/patch lama
		CurveHeight = curveHeight,
		HorizontalCurve = horizontalCurve,
		StartForwardOffset = startForwardOffset,
		StartRightOffset = startRightOffset,
		StartHeightOffset = startHeightOffset,
		CooldownTime = math.max(minimumCooldown, windupTime + projectileLifetime + cooldownPadding),
	}
end

function TrainingService:IsPlayerInTrainingArea(player: Player, trainingArea): boolean
	return isPlayerRegisteredForTraining(player, trainingArea)
		and isPlayerPhysicallyInTrainingArea(player, trainingArea)
end

function TrainingService:FacePlayerToTrainingTarget(player: Player, target)
	-- Guard utama: kalau server mencatat player sedang fight, jangan paksa hadap.
	-- Ini mencegah orientasi fight/penalty diganggu oleh sisa request training.
	if isPlayerFighting(player) then
		return false
	end

	local character = player.Character
	if not character then
		return false
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end

	local targetPosition = getTargetPosition(target)
	if not targetPosition then
		return false
	end

	local flatDirection = Vector3.new(targetPosition.X - root.Position.X, 0, targetPosition.Z - root.Position.Z)
	if flatDirection.Magnitude < 0.001 then
		return false
	end

	local attachment = root:FindFirstChild("TrainingFaceAttachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "TrainingFaceAttachment"
		attachment.Parent = root
	end

	local oldAlign = root:FindFirstChild("TrainingFaceAlign")
	if oldAlign then
		oldAlign:Destroy()
	end

	local lookCFrame = CFrame.lookAt(root.Position, root.Position + flatDirection.Unit)

	local align = Instance.new("AlignOrientation")
	align.Name = "TrainingFaceAlign"
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.Attachment0 = attachment
	align.CFrame = lookCFrame
	align.MaxTorque = FACE_MAX_TORQUE
	align.Responsiveness = FACE_RESPONSIVENESS
	align.Parent = root

	task.delay(FACE_DURATION, function()
		if align and align.Parent then
			align:Destroy()
		end
	end)

	return true
end

function TrainingService:ShootTrainingBall(player: Player, trainingArea, speedMultiplier)
	if typeof(trainingArea) ~= "Instance" then
		return false
	end

	if not isPlayerRegisteredForTraining(player, trainingArea) then
		return false
	end

	if not isPlayerPhysicallyInTrainingArea(player, trainingArea) then
		self:StopTraining(player, trainingArea)
		return false
	end

	local target = trainingArea:FindFirstChild("Target")
	local shotConfig = buildTrainingShotConfig(trainingArea, speedMultiplier)

	-- Paksa hadap sekarang tanggung jawab TrainingService, bukan BallService.
	-- Kalau player sedang fight, FacePlayerToTrainingTarget akan return false dan tidak mengubah rotasi.
	self:FacePlayerToTrainingTarget(player, target)

	return BallService:ShootBall(player, target, shotConfig)
end

function TrainingService:Training(player: Player, trainingArea)
	if PlayersInTraining == nil then
		return warn("PlayersInTraining table is not initialized.")
	end

	if typeof(trainingArea) ~= "Instance" then
		return false
	end

	if PlayersInTraining[trainingArea] == nil then
		return false
	end

	if PlayersInTraining[trainingArea][player] == nil then
		return false
	end

	if not isPlayerPhysicallyInTrainingArea(player, trainingArea) then
		self:StopTraining(player, trainingArea)
		return false
	end

	local areaData = getTrainingAreaData(trainingArea)
	if not areaData then
		return false
	end

	local playerData = DataService:GetData(player)

	if not canPlayerUseTrainingArea(player, trainingArea, true) then
		return false
	end

	if playerData.Money2 >= areaData.PowerRequirement then
		local powerGet = areaData.PowerPerSecond
		-- if BoostEventService.CurrentBoost and BoostEventService.CurrentBoost.type == "Money2" then
		-- 	powerGet = powerGet * BoostEventService.CurrentBoost.multiplier
		-- end

		--SeasonService:Increase(player, "MONEY_2 Daily", 1)
		--SeasonService:Increase(player, "MONEY_2 Weekly", 1)
		DataService:ChangeValue(player, "Money2", powerGet, false)
		return true
	else
		self.Client.InsufficientPower:Fire(player, areaData.PowerRequirement - playerData.Money2)
		return false
	end
end

function TrainingService:StartTraining(player: Player, trainingArea)
	if typeof(trainingArea) ~= "Instance" then
		return {
			Success = false,
			Reason = "Invalid",
		}
	end

	if not canPlayerUseTrainingArea(player, trainingArea, true) then
		return {
			Success = false,
			Reason = "Unavailable",
		}
	end

	if not isPlayerPhysicallyInTrainingArea(player, trainingArea) then
		return {
			Success = false,
			Reason = "Outside",
		}
	end

	-- Masukkan ke PlayersInTraining jika belum ada
	if not PlayersInTraining[trainingArea] then
		PlayersInTraining[trainingArea] = {}

		local index = trainingArea:GetAttribute("Index")
		if index == VIP_TRAINING_INDEX then
			for _, descendant in ipairs(trainingArea.Parent:GetDescendants()) do
				if descendant:IsA("MeshPart") then
					if descendant.Name == "Handle" or descendant.Name == "Weight" then
						descendant.Transparency = 1
					end
				end
			end
		end
	end

	PlayersInTraining[trainingArea][player] = true
	return {
		Success = true,
		Reason = "Started",
	}
end

function TrainingService:StopTraining(player: Player, trainingArea)
	if BallService then
		BallService:ResetPlayer(player)
	end

	if typeof(trainingArea) ~= "Instance" then
		return false
	end

	local areaPlayers = PlayersInTraining[trainingArea]
	if areaPlayers then
		areaPlayers[player] = nil

		-- Hapus entri jika sudah kosong
		if next(areaPlayers) == nil then
			PlayersInTraining[trainingArea] = nil

			local index = trainingArea:GetAttribute("Index")
			if index == VIP_TRAINING_INDEX then
				for _, descendant in ipairs(trainingArea.Parent:GetDescendants()) do
					if descendant:IsA("MeshPart") then
						if descendant.Name == "Handle" or descendant.Name == "Weight" then
							descendant.Transparency = 0
						end
					end
				end
			end
		end
	end

	return true
end

function TrainingService:GetMostEffectiveArea(player: Player)
	local playerData = DataService:GetData(player)
	local playerPower = playerData.Money2
	local unlockedAreas = playerData.Areas.Unlocked

	local effectiveTrainingArea = nil

	for zoneName, zoneData in pairs(TrainingAreasData) do
		if table.find(unlockedAreas, zoneName) ~= nil then
			for level, data in pairs(zoneData) do
				if data.VIP then
					if not FindValue(playerData.Gamepasses, "VIP") then
						continue
					end
				end

				if playerPower >= data.PowerRequirement then
					if effectiveTrainingArea ~= nil then
						-- Bandingkan powerPerSecond untuk mencari area terbaik
						if data.PowerPerSecond > effectiveTrainingArea.powerPerSecond then
							effectiveTrainingArea =
								{ area = zoneName, index = level, powerPerSecond = data.PowerPerSecond }
						end
					else
						effectiveTrainingArea = { area = zoneName, index = level, powerPerSecond = data.PowerPerSecond }
					end
				end
			end
		end
	end

	return effectiveTrainingArea
end

function TrainingService:CheckAvailability(player: Player, trainingArea)
	return canPlayerUseTrainingArea(player, trainingArea, true)
end

-- KNIT START
function TrainingService:KnitStart()
	DataService = Knit.GetService("DataService")
	MonetizationService = Knit.GetService("MonetizationService")
	--SeasonService = Knit.GetService("SeasonService")
	DataCacheService = Knit.GetService("DataCacheService")
	BallService = Knit.GetService("BallService")
	FightService = Knit.GetService("FightService")

	TrainingAreasData = DataCacheService:GetFile("Template").TrainingAreas

	TrainingAreas = CollectionService:GetTagged("TrainingArea")

	for _, trainingArea in ipairs(TrainingAreas) do
		local area = trainingArea:GetAttribute("Area")
		local index = trainingArea:GetAttribute("Index")

		if TrainingAreasData[area][index].VIP then
			continue
		end

		local BillboardGui = trainingArea.Parent.Requirement.BillboardGui

		local requiredText = BillboardGui:FindFirstChild("RequiredText")
		if requiredText then
			requiredText.Text = `{FormatNumber(TrainingAreasData[area][index].PowerRequirement)} Required`
		end

		--requiredText.Text = `{FormatNumber(TrainingAreasData[area][index].PowerRequirement)} Required`
	end
end

return TrainingService
