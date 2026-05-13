local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Settings = require(script.Parent.Settings)

local PET_ROOT_NAME = "__PetRoot"

local function getSetting(name: string, fallback)
	local value = Settings[name]
	if value == nil then
		return fallback
	end

	return value
end

local function isNaNCFrame(cf)
	if typeof(cf) ~= "CFrame" then
		return true
	end

	local pos = cf.Position
	return pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z
end

local function getPlayerFromKey(playerObj)
	if typeof(playerObj) == "Instance" and playerObj:IsA("Player") then
		return playerObj
	end

	if typeof(playerObj) == "Instance" and playerObj.Name then
		return Players:FindFirstChild(playerObj.Name)
	end

	if type(playerObj) == "string" then
		return Players:FindFirstChild(playerObj)
	end

	return nil
end

local function makeRaycastExcludeList(raycastExcludeModels, playerCharacter)
	local exclude = {}

	if type(raycastExcludeModels) == "table" then
		for _, model in ipairs(raycastExcludeModels) do
			if typeof(model) == "Instance" then
				table.insert(exclude, model)
			end
		end
	elseif typeof(raycastExcludeModels) == "Instance" then
		table.insert(exclude, raycastExcludeModels)
	end

	if playerCharacter then
		table.insert(exclude, playerCharacter)
	end

	return exclude
end

local function isValidPetGround(part: Instance?)
	if not part then
		return false
	end

	if not part:IsA("BasePart") then
		return false
	end

	if part:GetAttribute("IgnorePetRaycast") == true then
		return false
	end

	if part:GetAttribute("ForcePetGround") == true then
		return true
	end

	if part.CanCollide == false then
		return false
	end

	if part.Transparency >= 0.95 then
		return false
	end

	return true
end

local function setupBasePartPhysics(part: BasePart)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
end

local function getOrCreatePetRoot(petModel: Model)
	local root = petModel:FindFirstChild(PET_ROOT_NAME)

	if not root or not root:IsA("BasePart") then
		root = Instance.new("Part")
		root.Name = PET_ROOT_NAME
		root.Size = Vector3.new(0.2, 0.2, 0.2)
		root.Transparency = 1
		root.CFrame = petModel:GetPivot()
		root.Parent = petModel
	end

	setupBasePartPhysics(root)

	root.Transparency = 1
	root.CastShadow = false

	petModel.PrimaryPart = root

	return root
end

local function setupPetModelPhysics(petModel: Model)
	for _, obj in ipairs(petModel:GetDescendants()) do
		if obj:IsA("BasePart") then
			setupBasePartPhysics(obj)
		end
	end

	-- Penting:
	-- Jangan pakai MeshPart/BasePart visual sebagai PrimaryPart,
	-- karena beberapa pet punya local orientation bawaan 90,0,0.
	-- Pakai root invisible agar pivot/orientation utama model bersih.
	getOrCreatePetRoot(petModel)
end

local function getPetDataName(petData)
	if type(petData) == "table" then
		return petData.Name
	end

	return nil
end

local function toNumberOrFallback(value, fallback)
	local numberValue = tonumber(value)
	if numberValue == nil then
		return fallback
	end

	return numberValue
end

local function getPetRotationAttribute(petModel: Model, attributeName: string, fallback)
	local modelValue = petModel:GetAttribute(attributeName)
	if modelValue ~= nil then
		return toNumberOrFallback(modelValue, fallback)
	end

	if petModel.PrimaryPart then
		local primaryValue = petModel.PrimaryPart:GetAttribute(attributeName)
		if primaryValue ~= nil then
			return toNumberOrFallback(primaryValue, fallback)
		end
	end


	for _, obj in ipairs(petModel:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name ~= PET_ROOT_NAME then
			local partValue = obj:GetAttribute(attributeName)
			if partValue ~= nil then
				return toNumberOrFallback(partValue, fallback)
			end
		end
	end

	return fallback
end

local function getPetCorrectionRotation(petModel: Model)
	local xRotation = getPetRotationAttribute(petModel, "XRotation", 0)
	local rotationOffset = -(getPetRotationAttribute(petModel, "Rotation", 90))

	return CFrame.Angles(
		math.rad(xRotation),
		math.rad(rotationOffset),
		0
	)
end

local function getTargetFacingOrientation(targetPart: BasePart?)
	if not targetPart then
		return CFrame.new()
	end

	local connectedAxis = math.atan2(targetPart.CFrame.LookVector.X, targetPart.CFrame.LookVector.Z)
	connectedAxis = connectedAxis + math.rad(180)

	return CFrame.fromOrientation(0, connectedAxis, 0)
end


local function getPositionOffset(grid, info)
	local totalOffset
	local xOffset = 0
	local zOffset = 0

	if info.Farming == true then
		xOffset = math.cos(0)
	else
		local totalColumns = grid.TotalColumns > 0 and grid.TotalColumns or 1
		local totalRows = grid.TotalRows > 0 and grid.TotalRows or 1

		local xSpacing = getSetting("XSpacing", 2.5)
		local zSpacing = getSetting("ZSpacing", 2.5)
		local playerSpacing = getSetting("PlayerSpacing", 4)

		xOffset = ((grid.Column - (totalColumns + 1) / 2) * xSpacing)

		zOffset = (playerSpacing + -(-(grid.Row - (totalRows + 1) / 2) * zSpacing - (totalRows / 2) * zSpacing))
	end

	totalOffset = CFrame.new(xOffset, 0, zOffset)
	return totalOffset
end

local function getRaycastOffset(lastPosition, targetPart, raycastExcludeModels, playerCharacter)
	local origin = Vector3.new(lastPosition.Position.X, targetPart.Position.Y + 5, lastPosition.Position.Z)

	local direction = Vector3.new(0, -200, 0)
	local exclude = makeRaycastExcludeList(raycastExcludeModels, playerCharacter)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true

	for _ = 1, 10 do
		rayParams.FilterDescendantsInstances = exclude

		local result = Workspace:Raycast(origin, direction, rayParams)
		if not result or not result.Instance then
			break
		end

		if isValidPetGround(result.Instance) then
			return result.Position.Y
		end

		table.insert(exclude, result.Instance)
		origin = result.Position - Vector3.new(0, 0.05, 0)
	end

	return lastPosition.Position.Y
end


local function getAnimationOffset(timeElapsed, petMovement, higher)
	local speed = 10
	local maxHeight = 2.3
	local forwardAngle = math.rad(15)
	local backwardAngle = math.rad(15)

	if petMovement == "Fly" then
		speed = getSetting("FlySpeed", 2.3)
		maxHeight = getSetting("FlyMaxHeight", 1)
		forwardAngle = getSetting("FlyForwardAngle", math.rad(6))
		backwardAngle = getSetting("FlyBackwardAngle", math.rad(6))
	elseif petMovement == "Walk" then
		speed = getSetting("GroundSpeed", 10)
		maxHeight = getSetting("GroundMaxHeight", 2.3)
		forwardAngle = getSetting("GroundForwardAngle", math.rad(15))
		backwardAngle = getSetting("GroundBackwardAngle", math.rad(15))
	end

	local sinTime = math.sin(timeElapsed * speed)
	local newHeight = sinTime * maxHeight

	local newRotation
	if newHeight >= 0 then
		newRotation = sinTime * forwardAngle
	else
		newRotation = sinTime * backwardAngle
	end

	if petMovement == "Fly" then
		newHeight = newHeight + (if higher == nil then 4.3 else 0)
	elseif petMovement == "Walk" then
		newHeight = math.abs(newHeight)
	end

	local animationLeft = true
	if petMovement == "Walk" then
		if newHeight > getSetting("GroundHopMinHeight", 0.15) then
			animationLeft = true
		else
			animationLeft = false
			newRotation = 0
			newHeight = 0
		end
	end

	return {
		Rotation = CFrame.fromOrientation(newRotation, 0, 0),
		Height = newHeight,
		AnimationLeft = animationLeft,
	}
end

local function createPetModel(functions, grid, info, petData, petInstances, raycastExcludeModels, ownerName, id)
	local petModel = functions.GetPetModel(petData)
	if not petModel then
		return nil
	end

	petModel = petModel:Clone()
	grid.Model = petModel

	petModel.Name = ownerName .. "_" .. tostring(id)
	petModel:SetAttribute("Owner", ownerName)
	petModel:SetAttribute("Pet", petData.Name)

	setupPetModelPhysics(petModel)

	if not petModel.PrimaryPart then
		warn("[PETS UPDATE] Pet model has no BasePart:", petData.Name)
		petModel:Destroy()
		return nil
	end

	local tempPositionOffset = getPositionOffset(grid, info)
	tempPositionOffset = CFrame.new((info.Target.CFrame * tempPositionOffset).Position)
	tempPositionOffset = tempPositionOffset - Vector3.new(0, tempPositionOffset.Position.Y, 0)

	petModel:ScaleTo(petModel:GetScale() / 1.4)

	local initialOrientation = getTargetFacingOrientation(info.Target)
	local initialCorrectionRotation = getPetCorrectionRotation(petModel)

	petModel:PivotTo(tempPositionOffset * initialOrientation * initialCorrectionRotation)
	petModel.Parent = petInstances

	table.insert(raycastExcludeModels, petModel)

	return petModel
end

local function getCurrentTarget(player: Player?, info)
	if info.Target and info.Target.Parent then
		return info.Target
	end

	if not player then
		return nil
	end

	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if hrp then
		info.Target = hrp
		return hrp
	end

	return nil
end

local function removeFromExclude(raycastExcludeModels, model)
	local index = table.find(raycastExcludeModels, model)
	if index then
		table.remove(raycastExcludeModels, index)
	end
end

local function getSafeAlpha(speed, distance, deltaTime)
	if distance <= 0.001 then
		return 1
	end

	return math.clamp((speed / distance) * deltaTime, 0, 1)
end

local function getSafeAngleAlpha(functions, targetOrientation, lastOrientation, deltaTime)
	local angleDistance = 1

	if functions and functions.GetAngleDistance then
		angleDistance = functions.GetAngleDistance(targetOrientation, lastOrientation)
	end

	if angleDistance <= 0.001 then
		return 1
	end

	return math.clamp((250 / angleDistance) * deltaTime, 0, 1)
end

local function ensureLastInfoDefaults(lastInfo, currentModel, targetPart)
	if not lastInfo then
		return
	end

	if lastInfo.AnimationPosition == nil then
		lastInfo.AnimationPosition = CFrame.new(0, currentModel:GetExtentsSize().Y / 2, 0)
	end

	if lastInfo.AnimationRotation == nil then
		lastInfo.AnimationRotation = CFrame.new()
	end

	if lastInfo.AnimationHeight == nil then
		lastInfo.AnimationHeight = 0
	end

	if lastInfo.Orientation == nil then
		lastInfo.Orientation = getTargetFacingOrientation(targetPart)
	end

	if lastInfo.Raycast == nil then
		lastInfo.Raycast = CFrame.new(0, currentModel:GetPivot().Position.Y, 0)
	end
end

local function UpdatePets(
	deltaTime,
	functions,
	petsInSession,
	petsModule,
	petInstances,
	raycastExcludeModels,
	petsController
)
	local petsToMove = {
		Pets = {},
		CFrames = {},
	}

	for playerObj, gridData in pairs(petsInSession) do
		if functions.GetTableAmount(gridData) <= 0 then
			continue
		end

		local player = getPlayerFromKey(playerObj)
		if not player then
			continue
		end

		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local ownerName = player.Name

		for id, grid in pairs(gridData) do
			local info = grid.Information
			local lastInfo = grid.LastInformation
			local petData = grid.PetData

			if not info or not lastInfo or not petData or type(petData) ~= "table" then
				continue
			end

			local targetPart = getCurrentTarget(player, info)
			if not targetPart then
				continue
			end

			if lastInfo.Position ~= nil and isNaNCFrame(lastInfo.Position) then
				petsController:ReloadPets(player)
				continue
			end

			local petName = getPetDataName(petData)
			local petInfo = (petName and petsModule[petName]) or petData
			local petMovement = (petInfo and petInfo.Movement) or "Walk"

			local currentModel = grid.Model
			local shouldCreateModel = (
				not currentModel
				or currentModel == ""
				or type(currentModel) == "string"
				or not currentModel.Parent
			)

			if shouldCreateModel then
				local existingModel = petInstances:FindFirstChild(ownerName .. "_" .. tostring(id))
				if existingModel then
					removeFromExclude(raycastExcludeModels, existingModel)
					existingModel:Destroy()
				end

				currentModel = createPetModel(
					functions,
					grid,
					info,
					petData,
					petInstances,
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

			if not currentModel.PrimaryPart or currentModel.PrimaryPart.Name ~= PET_ROOT_NAME then
				setupPetModelPhysics(currentModel)
				if not currentModel.PrimaryPart then
					continue
				end
			end

			ensureLastInfoDefaults(lastInfo, currentModel, targetPart)

			table.insert(petsToMove.Pets, currentModel)

			--// Pet animation
			local animationTime = (petMovement == "Walk" and (grid.TimeElapsed or 0)) or os.clock()
			local animationInfo = getAnimationOffset(animationTime, petMovement, petInfo and petInfo.Higher)

			local animationPositionLerp = lastInfo.AnimationPosition
			local animationRotationLerp = lastInfo.AnimationRotation

			if animationInfo.AnimationLeft == true or info.Arrived == false then
				grid.TimeElapsed = (grid.TimeElapsed or 0) + deltaTime
			else
				grid.TimeElapsed = 0
			end

			if
				info.Arrived == false
				or animationInfo.AnimationLeft == true
				or (animationInfo.Height == 0 and lastInfo.AnimationHeight ~= 0)
				or petMovement == "Fly"
			then
				local animationHeightDistance = (
					Vector3.new(0, animationInfo.Height, 0)
					- Vector3.new(0, lastInfo.AnimationHeight or 0, 0)
				).Magnitude

				local animationSpeed = getSafeAlpha(100, animationHeightDistance, deltaTime)

				animationPositionLerp = lastInfo.AnimationPosition:Lerp(
					CFrame.new(0, animationInfo.Height + (currentModel:GetExtentsSize().Y / 2), 0),
					animationSpeed
				)

				animationRotationLerp = lastInfo.AnimationRotation:Lerp(animationInfo.Rotation, animationSpeed)
			end

			--// Pet position 
			if lastInfo.Position == nil then
				local pivot = currentModel:GetPivot().Position
				lastInfo.Position = CFrame.new(pivot.X, 0, pivot.Z)
			end

			local positionOffset = getPositionOffset(grid, info)
			positionOffset = CFrame.new((targetPart.CFrame * positionOffset).Position)
			positionOffset = positionOffset - Vector3.new(0, positionOffset.Position.Y, 0)

			local positionDistance = (positionOffset.Position - lastInfo.Position.Position).Magnitude

			
			local currentFlat = Vector3.new(lastInfo.Position.Position.X, 0, lastInfo.Position.Position.Z)
			local targetFlat = Vector3.new(positionOffset.Position.X, 0, positionOffset.Position.Z)

			local teleportDistance = getSetting("FollowTeleportDistance", 30)
			local targetTeleportDistance = getSetting("TargetTeleportDistance", 18)

			local previousTargetPosition = grid._LastTargetPosition
			local targetMovedDistance = 0
			if previousTargetPosition then
				local previousFlat = Vector3.new(previousTargetPosition.X, 0, previousTargetPosition.Z)
				targetMovedDistance = (previousFlat - targetFlat).Magnitude
			end

			local shouldSnapToTarget = grid._ForceSnap == true
				or (currentFlat - targetFlat).Magnitude > teleportDistance
				or targetMovedDistance > targetTeleportDistance

			grid._ForceSnap = false

			local playerSpeed = 20
			if humanoid then
				playerSpeed = humanoid.WalkSpeed
			elseif petData.Speed then
				playerSpeed = petData.Speed
			end

			local positionSpeed
			if playerSpeed ~= 0 then
				positionSpeed = getSafeAlpha(playerSpeed, positionDistance, deltaTime)
			else
				positionSpeed = getSafeAlpha(petData.Speed or 20, positionDistance, deltaTime)
			end

			local positionLerp
			if shouldSnapToTarget then
				positionLerp = positionOffset
			else
				positionLerp = lastInfo.Position:Lerp(positionOffset, positionSpeed)
			end

			local distanceCheck = (
				(positionLerp.Position - Vector3.new(0, positionLerp.Position.Y, 0))
				- positionOffset.Position
			).Magnitude

			local characterMoved = false
			if humanoid then
				characterMoved = humanoid.MoveDirection.Magnitude > 0
			end

			if shouldSnapToTarget then
				info.Arrived = true
			elseif characterMoved == true or distanceCheck > 0.001 then
				info.Arrived = false
			elseif distanceCheck <= 0.001 then
				info.Arrived = true
			end

			--// Raycast -
			local raycastHeight
			local raycastLerp

			if lastInfo.Raycast == nil then
				lastInfo.Raycast = CFrame.new(0, positionLerp.Position.Y, 0)
			end

			local absoluteTime = os.clock()

			if shouldSnapToTarget then
				lastInfo.RaycastHeight = getRaycastOffset(positionLerp, targetPart, raycastExcludeModels, character)
				lastInfo.NextRaycastTime = absoluteTime + 0.3
			elseif lastInfo.NextRaycastTime == nil or absoluteTime >= lastInfo.NextRaycastTime then
				lastInfo.NextRaycastTime = absoluteTime + 0.3
				lastInfo.RaycastHeight = getRaycastOffset(positionLerp, targetPart, raycastExcludeModels, character)
			end

			raycastHeight = lastInfo.RaycastHeight or targetPart.Position.Y

			local raycastDistance = (
				Vector3.new(0, raycastHeight, 0)
				- Vector3.new(0, lastInfo.Raycast.Position.Y, 0)
			).Magnitude

			if shouldSnapToTarget then
				raycastLerp = CFrame.new(0, raycastHeight, 0)
			else
				local raycastDistanceSpeed = (raycastDistance > 50 and 1000) or getSetting("RaycastSpeed", 35)
				local raycastLerpSpeed = getSafeAlpha(raycastDistanceSpeed, raycastDistance, deltaTime)
				raycastLerp = lastInfo.Raycast:Lerp(CFrame.new(0, raycastHeight, 0), raycastLerpSpeed)
			end

			--// Orientation 
			local petOrientation

			if distanceCheck <= 5 then
				petOrientation = getTargetFacingOrientation(targetPart)
			else
				local tempPosition1 = positionLerp.Position - Vector3.new(0, positionLerp.Position.Y, 0)
				local tempPosition2 = positionOffset.Position - Vector3.new(0, positionOffset.Position.Y, 0)

				petOrientation = CFrame.lookAt(tempPosition1, tempPosition2)
				petOrientation = petOrientation - petOrientation.Position
			end

			local orientationSpeed = if shouldSnapToTarget
				then 1
				else getSafeAngleAlpha(functions, petOrientation, lastInfo.Orientation, deltaTime)

			local orientationLerp = lastInfo.Orientation:Lerp(petOrientation, orientationSpeed)

			--// Final Rotation 
			local _, yOrientationLerp, _ = orientationLerp:ToOrientation()
			local xAnimationLerp, _, _ = animationRotationLerp:ToOrientation()

			local finalOrientation = CFrame.fromOrientation(xAnimationLerp, yOrientationLerp, 0)
			local correctionRotation = getPetCorrectionRotation(currentModel)

			local final = (positionLerp * raycastLerp * animationPositionLerp * finalOrientation)
				* correctionRotation

			table.insert(petsToMove.CFrames, final)

			--// Update cache.
			lastInfo.Position = positionLerp
			lastInfo.Raycast = raycastLerp
			lastInfo.Distance = distanceCheck
			lastInfo.AnimationPosition = animationPositionLerp
			lastInfo.AnimationRotation = animationRotationLerp
			lastInfo.AnimationHeight = animationInfo.Height
			lastInfo.AnimationLeft = animationInfo.AnimationLeft
			lastInfo.Orientation = orientationLerp

			grid._LastTargetPosition = positionOffset.Position
		end
	end

	for i, petModel in ipairs(petsToMove.Pets) do
		local finalCFrame = petsToMove.CFrames[i]
		if petModel and petModel.Parent and finalCFrame then
			petModel:PivotTo(finalCFrame)
		end
	end
end

return UpdatePets