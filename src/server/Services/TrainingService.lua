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

local TrainingAreas
local TrainingAreasData
local PlayersInTraining = {}

local FACE_DURATION = 1
local FACE_RESPONSIVENESS = 50
local FACE_MAX_TORQUE = 400000

local TrainingService = Knit.CreateService({
	Name = "TrainingService",
	Client = {
		InsufficientPower = Knit.CreateSignal(),
	},
})

--|| Client Functions ||--
function TrainingService.Client:Training(player: Player, trainingArea)
	self.Server:Training(player, trainingArea)
end

function TrainingService.Client:StartTraining(player: Player, trainingArea)
	self.Server:StartTraining(player, trainingArea)
end

function TrainingService.Client:StopTraining(player: Player, trainingArea)
	self.Server:StopTraining(player, trainingArea)
end

function TrainingService.Client:GetMostEffectiveArea(player: Player)
	return self.Server:GetMostEffectiveArea(player)
end

function TrainingService.Client:CheckAvailability(player: Player, trainingArea)
	return self.Server:CheckAvailability(player, trainingArea)
end

function TrainingService.Client:ShootTrainingBall(player: Player, trainingArea)
	return self.Server:ShootTrainingBall(player, trainingArea)
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

local function isPlayerFighting(player: Player): boolean
	return FightService ~= nil and FightService.Sessions ~= nil and FightService.Sessions[player] ~= nil
end

function TrainingService:IsPlayerInTrainingArea(player: Player, trainingArea): boolean
	local areaPlayers = PlayersInTraining[trainingArea]
	return areaPlayers ~= nil and areaPlayers[player] == true
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

function TrainingService:ShootTrainingBall(player: Player, trainingArea)
	if typeof(trainingArea) ~= "Instance" then
		return false
	end

	if not self:IsPlayerInTrainingArea(player, trainingArea) then
		return false
	end

	local target = trainingArea:FindFirstChild("Target")

	-- Paksa hadap sekarang tanggung jawab TrainingService, bukan BallService.
	-- Kalau player sedang fight, FacePlayerToTrainingTarget akan return false dan tidak mengubah rotasi.
	self:FacePlayerToTrainingTarget(player, target)

	return BallService:ShootBall(player, target)
end

function TrainingService:Training(player: Player, trainingArea)
	if PlayersInTraining == nil then
		return warn("PlayersInTraining table is not initialized.")
	end

	if PlayersInTraining[trainingArea] == nil then
		return warn("Training area not found: ", trainingArea.Name)
	end

	if PlayersInTraining[trainingArea][player] == nil then
		return warn("Player is not in training area: ", player.Name)
	end

	local area = trainingArea:GetAttribute("Area")
	local index = trainingArea:GetAttribute("Index")
	local areaData = TrainingAreasData[area][index]
	local playerData = DataService:GetData(player)

	if areaData.VIP then
		if not FindValue(playerData.Gamepasses, "VIP") then
			MonetizationService:PromptPurchase(player, "VIP", "GamePasses")
			return
		end
	end

	if playerData.Money2 >= areaData.PowerRequirement then
		local powerGet = areaData.PowerPerSecond
		-- if BoostEventService.CurrentBoost and BoostEventService.CurrentBoost.type == "Money2" then
		-- 	powerGet = powerGet * BoostEventService.CurrentBoost.multiplier
		-- end
		
		
		--SeasonService:Increase(player, "MONEY_2 Daily", 1)
		--SeasonService:Increase(player, "MONEY_2 Weekly", 1)
		DataService:ChangeValue(player, "Money2", powerGet, false)
	else
		self.Client.InsufficientPower:Fire(player, areaData.PowerRequirement - playerData.Money2)
	end
end

function TrainingService:StartTraining(player: Player, trainingArea)
	-- Masukkan ke PlayersInTraining jika belum ada
	if not PlayersInTraining[trainingArea] then
		PlayersInTraining[trainingArea] = {}

		local index = trainingArea:GetAttribute("Index")
		if index == 4 then
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
end

function TrainingService:StopTraining(player: Player, trainingArea)
	if BallService then
		BallService:ResetPlayer(player)
	end

	local areaPlayers = PlayersInTraining[trainingArea]
	if areaPlayers then
		areaPlayers[player] = nil

		-- Hapus entri jika sudah kosong
		if next(areaPlayers) == nil then
			PlayersInTraining[trainingArea] = nil

			local index = trainingArea:GetAttribute("Index")
			if index == 4 then
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
	local area = trainingArea:GetAttribute("Area")
	local index = trainingArea:GetAttribute("Index")
	local areaData = TrainingAreasData[area][index]
	local playerData = DataService:GetData(player)

	if areaData.VIP then
		if not FindValue(playerData.Gamepasses, "VIP") then
			MonetizationService:PromptPurchase(player, "VIP", "GamePasses")
			return false
		end
	end

	if playerData.Money2 < areaData.PowerRequirement then
		self.Client.InsufficientPower:Fire(player, areaData.PowerRequirement - playerData.Money2)
		return false
	end

	return true
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
