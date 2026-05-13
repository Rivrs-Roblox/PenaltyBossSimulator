local Players = game:GetService("Players")

local Settings = require(script.Parent.Settings)

local function GetSetting(name: string, fallback)
	local value = Settings[name]
	if value == nil then
		return fallback
	end

	return value
end

local function IsNaNCFrame(cf)
	if typeof(cf) ~= "CFrame" then
		return true
	end

	local pos = cf.Position
	return pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z
end

local function GetPositionOffset(grid, info)
	if info.Farming == true then
		return CFrame.new(0, 0, 0)
	end

	local rightOffset = GetSetting("FollowRightOffset", 2.8)
	local backOffset = GetSetting("FollowBackOffset", 2.4)

	local sideScale = GetSetting("FollowGridSideScale", 0.8)
	local backScale = GetSetting("FollowGridBackScale", 0.6)

	local totalColumns = grid.TotalColumns > 0 and grid.TotalColumns or 1
	local totalRows = grid.TotalRows > 0 and grid.TotalRows or 1

	local gridX = ((grid.Column - (totalColumns + 1) / 2) * Settings.XSpacing) * sideScale
	local gridZ = ((grid.Row - (totalRows + 1) / 2) * Settings.ZSpacing) * backScale

	
	return CFrame.new(
		rightOffset + gridX,
		0,
		backOffset + gridZ
	)
end

local function GetPlayerFromKey(playerObj)
	if typeof(playerObj) == "Instance" and playerObj:IsA("Player") then
		return playerObj
	end

	if typeof(playerObj) == "Instance" and playerObj.Name then
		return Players:FindFirstChild(playerObj.Name)
	end

	return nil
end

local function IsTargetPartValidForPlayer(player: Player?, targetPart: Instance?): boolean
	if not targetPart or not targetPart:IsA("BasePart") then
		return false
	end

	if not targetPart.Parent or not targetPart:IsDescendantOf(workspace) then
		return false
	end

	if not player then
		return true
	end

	local character = player.Character
	if not character or not character.Parent then
		return false
	end

	return targetPart.Parent == character
end

local function ResolveActiveTarget(player: Player?, info: table): BasePart?
	if IsTargetPartValidForPlayer(player, info.Target) then
		return info.Target
	end

	if not player then
		return nil
	end

	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		info.Target = humanoidRootPart
		return humanoidRootPart
	end

	return nil
end

local COACH_COLLISION_GROUP = "Coaches"

local function SetBasePartCollisionGroup(part)
	local success, err = pcall(function()
		part.CollisionGroup = COACH_COLLISION_GROUP
	end)

	if not success then
		warn(`[COACH UPDATE] Failed to set collision group for {part:GetFullName()}: {err}`)
	end
end

local function SetupCoachModelPhysics(coachModel)
	for _, obj in ipairs(coachModel:GetDescendants()) do
		if obj:IsA("BasePart") then
			SetBasePartCollisionGroup(obj)
			obj.Anchored = false
			obj.CanCollide = false
			obj.CanQuery = false
		end
	end

	coachModel.DescendantAdded:Connect(function(obj)
		if obj:IsA("BasePart") then
			SetBasePartCollisionGroup(obj)
			obj.Anchored = false
			obj.CanCollide = false
			obj.CanQuery = false
		end
	end)

	local humanoid = coachModel:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.AutoRotate = true
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	end
end

local function CreateCoachModel(functions, grid, info, coachData, coachInstances, raycastExcludeModels, ownerName, id)
	local coachModel = functions.GetCoachModel(coachData)
	if not coachModel then
		return nil
	end

	coachModel = coachModel:Clone()
	coachModel.Name = ownerName .. "_" .. tostring(id)
	coachModel:SetAttribute("Owner", ownerName)
	coachModel:SetAttribute("Coach", coachData.Name)

	local spawnOffset = GetPositionOffset(grid, info)
	local spawnCFrame = info.Target.CFrame * spawnOffset
	local spawnPosition = spawnCFrame.Position

	coachModel:PivotTo(CFrame.new(spawnPosition.X, spawnPosition.Y, spawnPosition.Z))
	coachModel.Parent = coachInstances

	SetupCoachModelPhysics(coachModel)
	table.insert(raycastExcludeModels, coachModel)

	return coachModel
end

local function FaceSameDirectionAsPlayer(currentModel, targetPart, deltaTime)
	if not currentModel.PrimaryPart or not targetPart then
		return
	end

	local currentPivot = currentModel:GetPivot()
	local currentPosition = currentPivot.Position

	local lookVector = targetPart.CFrame.LookVector
	if lookVector.Magnitude <= 0 then
		return
	end

	local targetFacingCFrame = CFrame.lookAt(
		currentPosition,
		currentPosition + lookVector
	)

	local alpha = math.clamp(deltaTime * 8, 0, 1)
	currentModel:PivotTo(currentPivot:Lerp(targetFacingCFrame, alpha))
end

local function UpdateCoaches(deltaTime, functions, coachesInSession, coachesTemplate, coachInstances, raycastExcludeModels, coachesController)
	for playerObj, gridData in pairs(coachesInSession) do
		if functions.GetTableAmount(gridData) <= 0 then
			continue
		end

		local player = GetPlayerFromKey(playerObj)
		local ownerName = player and player.Name or tostring(playerObj)

		for id, grid in pairs(gridData) do
			local info = grid.Information
			local lastInfo = grid.LastInformation
			local coachData = grid.CoachData or grid.PetData

			if not info or not coachData then
				continue
			end

			local activeTarget = ResolveActiveTarget(player, info)
			if not activeTarget then
				continue
			end

			if lastInfo and lastInfo.Position ~= nil and IsNaNCFrame(lastInfo.Position) then
				if player then
					coachesController:ReloadCoaches(player)
				end
				continue
			end

			local currentModel = grid.Model
			local shouldCreateModel = (
				not currentModel
				or currentModel == ""
				or type(currentModel) == "string"
				or not currentModel.Parent
			)

			if shouldCreateModel then
				local existingModel = coachInstances:FindFirstChild(ownerName .. "_" .. tostring(id))
				if existingModel then
					existingModel:Destroy()
				end

				currentModel = CreateCoachModel(
					functions,
					grid,
					info,
					coachData,
					coachInstances,
					raycastExcludeModels,
					ownerName,
					id
				)

				if not currentModel then
					grid.Model = ""
					continue
				end

				grid.Model = currentModel
			end

			if not currentModel.PrimaryPart then
				continue
			end

			local coachHumanoid = currentModel:FindFirstChildOfClass("Humanoid")
			if not coachHumanoid then
				continue
			end

			local positionOffset = GetPositionOffset(grid, info)
			if coachesController and coachesController.GetCoachTrainingTargetOffset then
				local trainingOffset = coachesController:GetCoachTrainingTargetOffset(grid, info, currentModel)
				if trainingOffset then
					positionOffset = trainingOffset
				end
			end

			local targetCFrame = info.Target.CFrame * positionOffset
			local targetPosition = targetCFrame.Position
			local currentPosition = currentModel.PrimaryPart.Position

			local distanceXZ = Vector2.new(
				currentPosition.X - targetPosition.X,
				currentPosition.Z - targetPosition.Z
			).Magnitude

			if coachesController and coachesController.OnCoachTrainingMovementUpdated then
				coachesController:OnCoachTrainingMovementUpdated(currentModel, distanceXZ, targetPosition)
			end

			local teleportDistance = GetSetting("FollowTeleportDistance", 30)
			local runDistance = GetSetting("FollowRunDistance", 8)
			local moveDistance = GetSetting("FollowMoveDistance", 1.6)
			local arrivedDistance = GetSetting("FollowArrivedDistance", 1.1)

			local playerHumanoid = info.Target.Parent and info.Target.Parent:FindFirstChildOfClass("Humanoid")
			local coachSpeed = coachData.Speed and (coachData.Speed * 16) or 18
			local baseSpeed = playerHumanoid and playerHumanoid.WalkSpeed or coachSpeed

			if distanceXZ > teleportDistance then
				currentModel:PivotTo(CFrame.lookAt(
					targetPosition,
					targetPosition + info.Target.CFrame.LookVector
				))

				info.Arrived = false
				grid._LastMoveToPosition = nil
				grid._LastMoveToTime = nil
			elseif distanceXZ > moveDistance then
				local targetSpeed = distanceXZ > runDistance and (baseSpeed * 1.4) or baseSpeed
				coachHumanoid.WalkSpeed = coachHumanoid.WalkSpeed + (targetSpeed - coachHumanoid.WalkSpeed) * 0.15

				local now = os.clock()
				local lastMoveToPosition = grid._LastMoveToPosition
				local lastMoveToTime = grid._LastMoveToTime or 0

				local shouldRefreshMoveTo = false

				if not lastMoveToPosition then
					shouldRefreshMoveTo = true
				elseif (lastMoveToPosition - targetPosition).Magnitude > GetSetting("FollowMoveToRefreshDistance", 0.2) then
					shouldRefreshMoveTo = true
				elseif now - lastMoveToTime > GetSetting("FollowMoveToRefreshTime", 0.1) then
					shouldRefreshMoveTo = true
				end

				if shouldRefreshMoveTo then
					coachHumanoid:MoveTo(targetPosition)
					grid._LastMoveToPosition = targetPosition
					grid._LastMoveToTime = now
				end

				info.Arrived = false
			else
				coachHumanoid.WalkSpeed = coachHumanoid.WalkSpeed + (0 - coachHumanoid.WalkSpeed) * 0.25

				if distanceXZ <= arrivedDistance then
					info.Arrived = true
				end

				if coachHumanoid.WalkSpeed < 0.5 then
					coachHumanoid:MoveTo(currentPosition)

					local handledTrainingFacing = false
					if coachesController and coachesController.FaceCoachForTrainingIfNeeded then
						handledTrainingFacing = coachesController:FaceCoachForTrainingIfNeeded(currentModel, deltaTime)
					end

					if not handledTrainingFacing then
						FaceSameDirectionAsPlayer(currentModel, info.Target, deltaTime)
					end
				end
			end

			if lastInfo then
				lastInfo.Position = CFrame.new(currentModel.PrimaryPart.Position)
			end
		end
	end
end

return UpdateCoaches