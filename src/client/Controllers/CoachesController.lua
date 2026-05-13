--[=[
    Owner: JustStop__
    Version: v1.1 (Synchronized Coach System)
]=]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

local COACH_WALK_ANIMATION_ID = "http://www.roblox.com/asset/?id=913402848"
local walkAnimationInstance = Instance.new("Animation")
walkAnimationInstance.Name = "CoachWalkAnim"
walkAnimationInstance.AnimationId = COACH_WALK_ANIMATION_ID

local COACH_TRAIN_ANIMATION_IDS = {
	"rbxassetid://96222316307137",
	"rbxassetid://79421168737236",
	"rbxassetid://122384469518064",
}

local coachTrainAnimationInstances = {}
for index, animationId in ipairs(COACH_TRAIN_ANIMATION_IDS) do
	local animation = Instance.new("Animation")
	animation.Name = "CoachTrainAnim" .. tostring(index)
	animation.AnimationId = animationId
	coachTrainAnimationInstances[index] = animation
end

local COACH_TRAIN_FRONT_RIGHT_OFFSET = 4.2
local COACH_TRAIN_FRONT_OFFSET = -3.0
local COACH_TRAIN_GRID_SIDE_SCALE = 0.45
local COACH_TRAIN_GRID_BACK_SCALE = 0.25
local COACH_TRAIN_ARRIVED_DISTANCE = 1.1
local COACH_TRAIN_ACTION_DURATION = 8
local COACH_TRAIN_REST_DURATION = 2
local COACH_TRAIN_MOVE_TIMEOUT = 3
local COACH_TRAIN_BACK_TIMEOUT = 3

local COACH_TRAIN_PLAYER_MOVING_SPEED = 1.25
local COACH_TRAIN_PLAYER_MOVE_DIRECTION_THRESHOLD = 0.05
local COACH_TRAIN_STILL_REQUIRED_DURATION = 0.35
local COACH_TRAIN_MOVING_WAIT_INTERVAL = 0.1

local Helpers = ReplicatedStorage.Shared.Helpers
local CoachGridFunctions = require(Helpers.Coaches.Grid)
local UpdateCoaches = require(Helpers.Coaches.Update)
local Filter = require(Helpers.Table.Filter)
local SetupArea = require(Helpers.SetupArea)
local TrainingSignals = require(ReplicatedStorage.Shared.Signals.TrainingSignals)

local DataCacheController, UIController, NotificationController
local CoachesService, DataService, SettingsService, TeleportService, CharactersService, FightService
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Player
local player = Players.LocalPlayer

local RaycastExcludeModels = {}
local coachAreas
local blockCoachAction = false

local Functions = {
	GetTableAmount = require(Helpers.Table.GetTableAmount),
	GetAngleDistance = require(Helpers.Math.GetAngleDistance),
	DeepCopy = require(Helpers.Table.DeepCopy),
	GetCoachModel = require(Helpers.Coaches.GetCoachModel),
}

local CoachesController = Knit.CreateController({
	Name = "CoachesController",
	CoachesInSession = {} :: table,
	CoachInstances = nil,
	CoachesTemplate = {},
	Colors = {},
	CoachAnimationTracks = {},
	CoachPreviousPositions = {},
	CoachTrainingTracks = {},
	CoachTrainingStates = {},
	CharacterRefreshConnections = {},
	IsLocalPlayerTraining = false,
	CurrentCoachTrainAnimationIndex = nil,
	TrainingSessionId = 0,
	LastLocalPlayerMoveTime = 0,
})

local function getCoachName(coachData)
	if type(coachData) == "table" then
		return coachData.Name
	end

	return nil
end

local function getAnimatorFromCoachModel(coachModel: Model): Animator?
	local humanoid = coachModel:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Name = "CoachAnimator"
			animator.Parent = humanoid
		end

		return animator
	end

	local animationController = coachModel:FindFirstChildOfClass("AnimationController")
	if not animationController then
		animationController = coachModel:FindFirstChildWhichIsA("AnimationController", true)
	end

	if animationController then
		local animator = animationController:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Name = "CoachAnimator"
			animator.Parent = animationController
		end

		return animator
	end

	return nil
end

local function isLocalPlayerCoach(coachModel: Model): boolean
	return coachModel:GetAttribute("Owner") == player.Name
end

function CoachesController:DestroyRenderedCoach(player: Player, index: string | number)
	local modelName = player.Name .. "_" .. tostring(index)

	for _, model in pairs(self.CoachInstances:GetChildren()) do
		if model.Name == modelName then
			local excludeIndex = table.find(RaycastExcludeModels, model)
			if excludeIndex then
				table.remove(RaycastExcludeModels, excludeIndex)
			end

			if self.CoachAnimationTracks[model] then
				self.CoachAnimationTracks[model]:Stop()
				self.CoachAnimationTracks[model]:Destroy()
				self.CoachAnimationTracks[model] = nil
			end

			if self.CoachTrainingTracks[model] then
				self.CoachTrainingTracks[model]:Stop()
				self.CoachTrainingTracks[model]:Destroy()
				self.CoachTrainingTracks[model] = nil
			end

			self.CoachTrainingStates[model] = nil
			self.CoachPreviousPositions[model] = nil
			model:Destroy()
		end
	end
end

--|| Functions ||--
function CoachesController:AddCoaches(player: Player, coachesDataFormat: table)
	coachesDataFormat = coachesDataFormat or {}

	if not self.CoachesInSession[player] then
		self.CoachesInSession[player] = {}
	end

	for index, newCoachData in pairs(coachesDataFormat) do
		local currentGrid = self.CoachesInSession[player][index]
		if currentGrid then
			local oldCoachName = getCoachName(currentGrid.CoachData or currentGrid.PetData)
			local newCoachName = getCoachName(newCoachData)

			if oldCoachName ~= nil and newCoachName ~= nil and oldCoachName ~= newCoachName then
				self:DestroyRenderedCoach(player, index)
				currentGrid.Model = ""
				currentGrid.CoachData = "None"
				currentGrid.PetData = "None"
			end
		end
	end

	local generatedCoaches = CoachGridFunctions.GetGrids(coachesDataFormat, self.CoachesInSession[player], player)
	for i, v in pairs(generatedCoaches) do
		if not self.CoachesInSession[player][i] then
			self.CoachesInSession[player][i] = v
		else
			self.CoachesInSession[player][i] = v
		end
	end

	for i, _ in pairs(self.CoachesInSession[player]) do
		if not generatedCoaches[i] then
			self.CoachesInSession[player][i] = nil
			self:DestroyRenderedCoach(player, i)
		end
	end

	self:RefreshPlayerTarget(player, false)
end

function CoachesController:HandleMove()
	RunService:BindToRenderStep("CoachesMovement", Enum.RenderPriority.Last.Value, function(Delta: number)
		local state = Store:getState()
		if state["SettingsReducer"] and state["SettingsReducer"].Pets_Visible == true then
			UpdateCoaches(
				Delta,
				Functions,
				self.CoachesInSession,
				self.CoachesTemplate,
				self.CoachInstances,
				RaycastExcludeModels,
				self
			)

			for _, coachModel in pairs(self.CoachInstances:GetChildren()) do
				if coachModel:IsA("Model") and coachModel.PrimaryPart then
					local humanoid = coachModel:FindFirstChildOfClass("Humanoid")
					if humanoid then
						local lastPos = coachModel:GetAttribute("PrevPos") or coachModel.PrimaryPart.Position
						local currentPos = coachModel.PrimaryPart.Position
						local velocity = (currentPos - lastPos).Magnitude / (Delta > 0 and Delta or 0.01)
						coachModel:SetAttribute("PrevPos", currentPos)

						local isMoving = velocity > 0.001

						local trainingState = self.CoachTrainingStates[coachModel]
						if trainingState and isLocalPlayerCoach(coachModel) then
							if trainingState.Phase == "Training" or trainingState.Phase == "Rest" then
								self:StopCoachWalkAnimation(coachModel)
								continue
							end
						end

						local track = self.CoachAnimationTracks[coachModel]

						if not track then
							local animator = humanoid:FindFirstChildOfClass("Animator")
								or Instance.new("Animator", humanoid)
							track = animator:LoadAnimation(walkAnimationInstance)
							track.Looped = true
							self.CoachAnimationTracks[coachModel] = track
						end

						if isMoving then
							if not track.IsPlaying then
								track:Play(0.2)
							end
							track:AdjustSpeed(velocity / 16)
						else
							if track.IsPlaying then
								track:Stop(0.3)
							end
						end
					end
				end
			end
		end
	end)
end

function CoachesController:StopCoachWalkAnimation(coachModel: Model)
	local walkTrack = self.CoachAnimationTracks[coachModel]
	if walkTrack and walkTrack.IsPlaying then
		walkTrack:Stop(0.2)
	end
end

function CoachesController:StopCoachTrainingAnimation(coachModel: Model)
	local trainingTrack = self.CoachTrainingTracks[coachModel]
	if trainingTrack then
		trainingTrack:Stop(0.2)
		trainingTrack:Destroy()
		self.CoachTrainingTracks[coachModel] = nil
	end
end

function CoachesController:PlayCoachTrainingAnimation(coachModel: Model, animationIndex: number?)
	if not coachModel or not coachModel.Parent then
		return nil
	end

	if not isLocalPlayerCoach(coachModel) then
		return nil
	end

	local selectedIndex = animationIndex or math.random(1, #coachTrainAnimationInstances)
	local animation = coachTrainAnimationInstances[selectedIndex]
	if not animation then
		warn("[COACHES CONTROLLER] Coach train animation missing for index:", selectedIndex)
		return nil
	end

	local animator = getAnimatorFromCoachModel(coachModel)
	if not animator then
		warn("[COACHES CONTROLLER] Coach model has no Humanoid/AnimationController:", coachModel.Name)
		return nil
	end

	self:StopCoachWalkAnimation(coachModel)
	self:StopCoachTrainingAnimation(coachModel)
	self:FaceCoachToLocalPlayer(coachModel, 1)

	local track = animator:LoadAnimation(animation)
	track.Name = "CoachTrainingTrack"
	track.Looped = false
	track.Priority = Enum.AnimationPriority.Action
	track:Play(0.12)

	self.CoachTrainingTracks[coachModel] = track
	self.CurrentCoachTrainAnimationIndex = selectedIndex

	return track
end

function CoachesController:GetRandomCoachTrainingAnimationIndex(previousIndex: number?): number?
	local animationCount = #coachTrainAnimationInstances
	if animationCount <= 0 then
		return nil
	end

	if animationCount == 1 then
		return 1
	end

	local selectedIndex = math.random(1, animationCount)
	if previousIndex ~= nil and selectedIndex == previousIndex then
		selectedIndex = (selectedIndex % animationCount) + 1
	end

	return selectedIndex
end

function CoachesController:PlayCoachTrainingAnimationsForDuration(coachModel: Model, sessionId: number, duration: number)
	local startTime = os.clock()
	local lastAnimationIndex = nil

	while self:IsCoachTrainingRoutineAlive(coachModel, sessionId) do
		if self:IsLocalPlayerMovingForCoachTraining() then
			break
		end

		local elapsed = os.clock() - startTime
		local remaining = duration - elapsed
		if remaining <= 0 then
			break
		end

		self:FaceCoachToLocalPlayer(coachModel, 1)

		local selectedIndex = self:GetRandomCoachTrainingAnimationIndex(lastAnimationIndex)
		if selectedIndex == nil then
			warn("[COACHES CONTROLLER] No coach train animation is configured.")
			task.wait(math.min(remaining, 0.25))
			continue
		end

		lastAnimationIndex = selectedIndex
		local track = self:PlayCoachTrainingAnimation(coachModel, selectedIndex)

		local playDuration = 1
		if track and track.Length and track.Length > 0 then
			playDuration = track.Length
		end

		local animationStartTime = os.clock()
		while self:IsCoachTrainingRoutineAlive(coachModel, sessionId) do
			if self:IsLocalPlayerMovingForCoachTraining() then
				break
			end

			local totalElapsed = os.clock() - startTime
			local animationElapsed = os.clock() - animationStartTime

			if totalElapsed >= duration then
				break
			end

			if track and not track.IsPlaying then
				break
			end

			if animationElapsed >= playDuration then
				break
			end

			self:FaceCoachToLocalPlayer(coachModel, 0.1)
			task.wait(0.05)
		end

		self:StopCoachTrainingAnimation(coachModel)
	end

	self:StopCoachTrainingAnimation(coachModel)
end


function CoachesController:GetCoachTrainingFrontOffset(grid): CFrame
	local totalColumns = grid.TotalColumns > 0 and grid.TotalColumns or 1
	local totalRows = grid.TotalRows > 0 and grid.TotalRows or 1

	local gridX = ((grid.Column - (totalColumns + 1) / 2) * 1.5) * COACH_TRAIN_GRID_SIDE_SCALE
	local gridZ = ((grid.Row - (totalRows + 1) / 2) * 1.0) * COACH_TRAIN_GRID_BACK_SCALE

	return CFrame.new(
		COACH_TRAIN_FRONT_RIGHT_OFFSET + gridX,
		0,
		COACH_TRAIN_FRONT_OFFSET + gridZ
	)
end

function CoachesController:GetCoachTrainingTargetOffset(grid, _info, coachModel: Model): CFrame?
	local trainingState = self.CoachTrainingStates[coachModel]
	if not trainingState then
		return nil
	end

	if not self.IsLocalPlayerTraining then
		return nil
	end

	if not isLocalPlayerCoach(coachModel) then
		return nil
	end

	if trainingState.TargetMode == "Front" then
		if self:IsLocalPlayerMovingForCoachTraining() then
			trainingState.TargetMode = "Back"
			trainingState.Phase = "FollowingPlayer"
			trainingState.IsArrived = false
			self:StopCoachTrainingAnimation(coachModel)
			return nil
		end

		return self:GetCoachTrainingFrontOffset(grid)
	end

	return nil
end

function CoachesController:OnCoachTrainingMovementUpdated(coachModel: Model, distanceXZ: number)
	local trainingState = self.CoachTrainingStates[coachModel]
	if not trainingState then
		return
	end

	trainingState.Distance = distanceXZ
	trainingState.IsArrived = distanceXZ <= COACH_TRAIN_ARRIVED_DISTANCE
end

function CoachesController:FaceCoachToLocalPlayer(coachModel: Model, deltaTime: number?)
	if not coachModel or not coachModel.Parent or not coachModel.PrimaryPart then
		return false
	end

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return false
	end

	local currentPivot = coachModel:GetPivot()
	local currentPosition = currentPivot.Position
	local targetPosition = Vector3.new(rootPart.Position.X, currentPosition.Y, rootPart.Position.Z)

	if (targetPosition - currentPosition).Magnitude <= 0.05 then
		return false
	end

	local targetCFrame = CFrame.lookAt(currentPosition, targetPosition)
	local alpha = math.clamp((deltaTime or 1) * 10, 0, 1)
	coachModel:PivotTo(currentPivot:Lerp(targetCFrame, alpha))

	return true
end

function CoachesController:FaceCoachForTrainingIfNeeded(coachModel: Model, deltaTime: number)
	local trainingState = self.CoachTrainingStates[coachModel]
	if not trainingState then
		return false
	end

	if trainingState.Phase ~= "Training" then
		return false
	end

	return self:FaceCoachToLocalPlayer(coachModel, deltaTime)
end

function CoachesController:IsLocalPlayerMovingForCoachTraining(): boolean
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart then
		return false
	end

	local velocity = rootPart.AssemblyLinearVelocity
	local horizontalSpeed = Vector2.new(velocity.X, velocity.Z).Magnitude
	local isMoving = humanoid.MoveDirection.Magnitude > COACH_TRAIN_PLAYER_MOVE_DIRECTION_THRESHOLD
		or horizontalSpeed > COACH_TRAIN_PLAYER_MOVING_SPEED

	if isMoving then
		self.LastLocalPlayerMoveTime = os.clock()
	end

	return isMoving
end

function CoachesController:HasLocalPlayerBeenStillForCoachTraining(): boolean
	self:IsLocalPlayerMovingForCoachTraining()
	return os.clock() - (self.LastLocalPlayerMoveTime or 0) >= COACH_TRAIN_STILL_REQUIRED_DURATION
end

function CoachesController:SetCoachToFollowPlayerDuringTraining(coachModel: Model)
	local trainingState = self.CoachTrainingStates[coachModel]
	if not trainingState then
		return
	end

	trainingState.TargetMode = "Back"
	trainingState.Phase = "FollowingPlayer"
	trainingState.IsArrived = false
	self:StopCoachTrainingAnimation(coachModel)
end

function CoachesController:WaitUntilLocalPlayerStillForTraining(coachModel: Model, sessionId: number): boolean
	while self:IsCoachTrainingRoutineAlive(coachModel, sessionId) do
		if self:HasLocalPlayerBeenStillForCoachTraining() then
			return true
		end

		self:SetCoachToFollowPlayerDuringTraining(coachModel)
		task.wait(COACH_TRAIN_MOVING_WAIT_INTERVAL)
	end

	return false
end

function CoachesController:IsCoachTrainingRoutineAlive(coachModel: Model, sessionId: number): boolean
	local trainingState = self.CoachTrainingStates[coachModel]
	return self.IsLocalPlayerTraining
		and trainingState ~= nil
		and trainingState.SessionId == sessionId
		and coachModel ~= nil
		and coachModel.Parent ~= nil
end

function CoachesController:WaitForCoachTrainingArrival(
	coachModel: Model,
	sessionId: number,
	timeout: number,
	breakWhenPlayerMoves: boolean?
): boolean
	local startTime = os.clock()

	while self:IsCoachTrainingRoutineAlive(coachModel, sessionId) do
		if breakWhenPlayerMoves and self:IsLocalPlayerMovingForCoachTraining() then
			self:SetCoachToFollowPlayerDuringTraining(coachModel)
			return false
		end

		local trainingState = self.CoachTrainingStates[coachModel]
		if trainingState and trainingState.IsArrived then
			return true
		end

		if os.clock() - startTime >= timeout then
			return false
		end

		task.wait(0.05)
	end

	return false
end

function CoachesController:StartCoachTrainingRoutine(coachModel: Model)
	if not coachModel or not coachModel.Parent then
		return
	end

	if not isLocalPlayerCoach(coachModel) then
		return
	end

	local existingState = self.CoachTrainingStates[coachModel]
	if existingState and existingState.SessionId == self.TrainingSessionId then
		return
	end

	local sessionId = self.TrainingSessionId
	self.CoachTrainingStates[coachModel] = {
		SessionId = sessionId,
		TargetMode = "Back",
		Phase = "FollowingPlayer",
		IsArrived = false,
		Distance = math.huge,
	}

	task.spawn(function()
		while self:IsCoachTrainingRoutineAlive(coachModel, sessionId) do
			local trainingState = self.CoachTrainingStates[coachModel]
			if not trainingState then
				break
			end

			if not self:WaitUntilLocalPlayerStillForTraining(coachModel, sessionId) then
				break
			end

			if not self:IsCoachTrainingRoutineAlive(coachModel, sessionId) then
				break
			end

			self:StopCoachTrainingAnimation(coachModel)
			trainingState.TargetMode = "Front"
			trainingState.Phase = "MovingFront"
			trainingState.IsArrived = false

			local arrivedFront = self:WaitForCoachTrainingArrival(
				coachModel,
				sessionId,
				COACH_TRAIN_MOVE_TIMEOUT,
				true
			)

			if not self:IsCoachTrainingRoutineAlive(coachModel, sessionId) then
				break
			end

			if not arrivedFront or not self:HasLocalPlayerBeenStillForCoachTraining() then
				self:SetCoachToFollowPlayerDuringTraining(coachModel)
				continue
			end

			trainingState.Phase = "Training"
			trainingState.TargetMode = "Front"
			self:FaceCoachToLocalPlayer(coachModel, 1)
			self:PlayCoachTrainingAnimationsForDuration(
				coachModel,
				sessionId,
				COACH_TRAIN_ACTION_DURATION
			)

			if not self:IsCoachTrainingRoutineAlive(coachModel, sessionId) then
				break
			end

			if self:IsLocalPlayerMovingForCoachTraining() then
				self:SetCoachToFollowPlayerDuringTraining(coachModel)
				continue
			end

			trainingState.TargetMode = "Back"
			trainingState.Phase = "MovingBack"
			trainingState.IsArrived = false
			self:WaitForCoachTrainingArrival(coachModel, sessionId, COACH_TRAIN_BACK_TIMEOUT, false)

			if not self:IsCoachTrainingRoutineAlive(coachModel, sessionId) then
				break
			end

			trainingState.Phase = "Rest"
			trainingState.TargetMode = "Back"
			task.wait(COACH_TRAIN_REST_DURATION)
		end

		self:StopCoachTrainingAnimation(coachModel)

		local currentState = self.CoachTrainingStates[coachModel]
		if currentState and currentState.SessionId == sessionId then
			self.CoachTrainingStates[coachModel] = nil
		end
	end)
end
function CoachesController:PlayLocalCoachTrainingAnimations()
	if self.IsLocalPlayerTraining then
		return
	end

	self.IsLocalPlayerTraining = true
	self.TrainingSessionId += 1
	self.CurrentCoachTrainAnimationIndex = nil
	self.LastLocalPlayerMoveTime = os.clock()

	for _, coachModel in pairs(self.CoachInstances:GetChildren()) do
		if coachModel:IsA("Model") and isLocalPlayerCoach(coachModel) then
			self:StartCoachTrainingRoutine(coachModel)
		end
	end
end

function CoachesController:StopLocalCoachTrainingAnimations()
	if not self.IsLocalPlayerTraining then
		return
	end

	self.IsLocalPlayerTraining = false
	self.TrainingSessionId += 1
	self.CurrentCoachTrainAnimationIndex = nil

	for coachModel, _ in pairs(self.CoachTrainingTracks) do
		self:StopCoachTrainingAnimation(coachModel)
	end

	for coachModel, _ in pairs(self.CoachTrainingStates) do
		self.CoachTrainingStates[coachModel] = nil
	end
end

function CoachesController:BuyCoach(id: number)
	if blockCoachAction then
		NotificationController:Notify({ tag = "Coach", text = "Processing...", type = "ERROR" })
		return
	end

	blockCoachAction = true
	return CoachesService:Buy(id)
		:andThen(function(result)
			if result then
				NotificationController:Notify({ tag = "Coach", text = result.text, type = result.type })
			end
			blockCoachAction = false
			return result
		end)
		:catch(function(err)
			warn(err)
			blockCoachAction = false
		end)
end

function CoachesController:EquipCoach(id: number)
	if blockCoachAction then
		NotificationController:Notify({ tag = "Coach", text = "Processing...", type = "ERROR" })
		return
	end

	blockCoachAction = true
	return CoachesService:Equip(id)
		:andThen(function(result)
			if result then
				NotificationController:Notify({ tag = "Coach", text = result.text, type = result.type })
			end
			blockCoachAction = false
			return result
		end)
		:catch(function(err)
			warn(err)
			blockCoachAction = false
		end)
end

function CoachesController:UnequipCoach(id: number)
	if blockCoachAction then
		NotificationController:Notify({ tag = "Coach", text = "Processing...", type = "ERROR" })
		return
	end

	blockCoachAction = true
	return CoachesService:Unequip()
		:andThen(function(result)
			if result then
				NotificationController:Notify({ tag = "Coach", text = result.text, type = result.type })
			end
			blockCoachAction = false
			return result
		end)
		:catch(function(err)
			warn(err)
			blockCoachAction = false
		end)
end

function CoachesController:PlayerRemove(player: Player)
	if self.CoachesInSession[player] then
		local foundCoaches = Filter(self.CoachInstances:GetChildren(), function(coachModel: Model)
			return coachModel:GetAttribute("Owner") == player.Name
		end) :: { Model }

		for _, coachModel in pairs(foundCoaches) do
			local excludeIndex = table.find(RaycastExcludeModels, coachModel)
			if excludeIndex then
				table.remove(RaycastExcludeModels, excludeIndex)
			end

			if self.CoachAnimationTracks[coachModel] then
				self.CoachAnimationTracks[coachModel]:Stop()
				self.CoachAnimationTracks[coachModel]:Destroy()
				self.CoachAnimationTracks[coachModel] = nil
			end

			if self.CoachTrainingTracks[coachModel] then
				self.CoachTrainingTracks[coachModel]:Stop()
				self.CoachTrainingTracks[coachModel]:Destroy()
				self.CoachTrainingTracks[coachModel] = nil
			end

			self.CoachTrainingStates[coachModel] = nil
			self.CoachPreviousPositions[coachModel] = nil
			coachModel:Destroy()
		end

		for Index = #RaycastExcludeModels, 1, -1 do
			local Model = RaycastExcludeModels[Index]
			if Model and Model:GetAttribute("Owner") == player.Name then
				table.remove(RaycastExcludeModels, Index)
			end
		end
		self.CoachesInSession[player] = nil
	end
end

function CoachesController:GetPlayerRootPart(targetPlayer: Player, shouldWait: boolean?): BasePart?
	local character = targetPlayer.Character
	if (not character or not character.Parent) and shouldWait then
		character = targetPlayer.CharacterAdded:Wait()
	end

	if not character or not character.Parent then
		return nil
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart and shouldWait then
		rootPart = character:WaitForChild("HumanoidRootPart", 5)
	end

	if rootPart and rootPart:IsA("BasePart") then
		return rootPart
	end

	return nil
end

function CoachesController:RefreshPlayerTarget(targetPlayer: Player, shouldWait: boolean?)
	local grids = self.CoachesInSession[targetPlayer]
	if not grids then
		return
	end

	local hrp = self:GetPlayerRootPart(targetPlayer, shouldWait)
	if not hrp then
		return
	end

	for _, grid in pairs(grids) do
		if grid.Information then
			grid.Information.Target = hrp
		end

		
		grid._LastMoveToPosition = nil
		grid._LastMoveToTime = nil
	end
end

function CoachesController:ConnectPlayerCharacterRefresh(targetPlayer: Player)
	if self.CharacterRefreshConnections[targetPlayer] then
		return
	end

	self.CharacterRefreshConnections[targetPlayer] = targetPlayer.CharacterAdded:Connect(function(character: Model)
		task.spawn(function()
			character:WaitForChild("HumanoidRootPart", 5)
			task.wait()

			self:RefreshPlayerTarget(targetPlayer, false)
		end)
	end)
end

function CoachesController:DisconnectPlayerCharacterRefresh(targetPlayer: Player)
	local connection = self.CharacterRefreshConnections[targetPlayer]
	if connection then
		connection:Disconnect()
		self.CharacterRefreshConnections[targetPlayer] = nil
	end
end

function CoachesController:ReloadCoaches(player: Player)
	self:PlayerRemove(player)
	local success, coaches = CoachesService:GetCoaches(player):await()
	if success and coaches then
		local _, data = DataService:GetData(player):await()
		if data and data.Settings.Pets_Visible == true then
			self:AddCoaches(player, coaches)
			return true
		end
	end
	return false
end

--|| Knit Lifecycle ||--
function CoachesController:KnitInit()
	self.CoachInstances = Instance.new("Model")
	self.CoachInstances.Parent = workspace
	self.CoachInstances.Name = "Coaches"

	DataCacheController = Knit.GetController("DataCacheController")
	UIController = Knit.GetController("UIController")
	NotificationController = Knit.GetController("NotificationController")

	CoachesService = Knit.GetService("CoachesService")
	SettingsService = Knit.GetService("SettingsService")
	DataService = Knit.GetService("DataService")
	TeleportService = Knit.GetService("TeleportService")
	CharactersService = Knit.GetService("CharactersService")
	FightService = Knit.GetService("FightService")

	local templateData = DataCacheController:GetFile("Template")
	if templateData and templateData.Coaches then
		self.CoachesTemplate = templateData.Coaches
	else
		self.CoachesTemplate = DataCacheController:GetFile("Coaches")
	end
	self.Colors = DataCacheController:GetFile("Colors")

	self:HandleMove()

	for _, targetPlayer in pairs(Players:GetPlayers()) do
		self:ConnectPlayerCharacterRefresh(targetPlayer)
	end

	task.spawn(function()
		for _, Player in pairs(Players:GetPlayers()) do
			local _ = Player.Character or Player.CharacterAdded:Wait()
			local __, coachesData = CoachesService:GetCoaches(Player):await()
			local ___, Data = DataService:GetData(Players.LocalPlayer):await()
			if Data and Data.Settings and Data.Settings.Pets_Visible == true then
				self:AddCoaches(Player, coachesData)
				self:RefreshPlayerTarget(Player, false)
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(leavingPlayer: Player)
		self:PlayerRemove(leavingPlayer)
		self:DisconnectPlayerCharacterRefresh(leavingPlayer)
	end)

	Players.PlayerAdded:Connect(function(joinedPlayer: Player)
		self:ConnectPlayerCharacterRefresh(joinedPlayer)

		task.spawn(function()
			local _ = joinedPlayer.Character or joinedPlayer.CharacterAdded:Wait()
			local __, coachesData = CoachesService:GetCoaches(joinedPlayer):await()
			local ___, Data = DataService:GetData(Players.LocalPlayer):await()

			if Data and Data.Settings and Data.Settings.Pets_Visible == true then
				self:AddCoaches(joinedPlayer, coachesData)
				self:RefreshPlayerTarget(joinedPlayer, false)
			end
		end)
	end)

	self.CoachInstances.ChildAdded:Connect(function(coachModel: Model)
		if self.IsLocalPlayerTraining and isLocalPlayerCoach(coachModel) then
			task.defer(function()
				self:StartCoachTrainingRoutine(coachModel)
			end)
		end

		local coachNameUI = ReplicatedStorage.Assets.Prompts.PetName:Clone()
		coachNameUI.Parent = coachModel

		local NameTL = coachNameUI:WaitForChild("Name")
		local RarityTL = coachNameUI:WaitForChild("Rarity")

		local coachAttributeName = coachModel:GetAttribute("Coach") or coachModel:GetAttribute("Pet")
		local currentCoachData = nil

		for _, coachData in pairs(self.CoachesTemplate) do
			if coachData.Name == coachAttributeName then
				currentCoachData = coachData
				break
			end
		end

		if currentCoachData then
			NameTL.Text = currentCoachData.DisplayName or currentCoachData.Name
			NameTL.TextColor3 = self.Colors["Normal"] or Color3.fromRGB(255, 255, 255)

			if currentCoachData.VIP then
				RarityTL.Text = "VIP Coach"
				RarityTL.TextColor3 = self.Colors["Legendary"] or Color3.fromRGB(255, 215, 0)
			else
				RarityTL.Text = "Coach"
				RarityTL.TextColor3 = self.Colors["Common"] or Color3.fromRGB(200, 200, 200)
			end
		else
			NameTL.Text = coachAttributeName or "Unknown"
		end
	end)

	CoachesService.PlayerCoachesUpdated:Connect(function(updatedPlayer: Player, coachesData)
		local ___, Data = DataService:GetData(Players.LocalPlayer):await()
		if Data and Data.Settings and Data.Settings.Pets_Visible == true then
			self:AddCoaches(updatedPlayer, coachesData)
			self:RefreshPlayerTarget(updatedPlayer, false)
		end
	end)

	TeleportService.PlayerTeleported:Connect(function(teleportedPlayer, coachesData, pets)
		local ___, Data = DataService:GetData(Players.LocalPlayer):await()
		if Data and Data.Settings and Data.Settings.Pets_Visible == true then
			self:AddCoaches(teleportedPlayer, {})
			self:AddCoaches(teleportedPlayer, coachesData)
			self:RefreshPlayerTarget(teleportedPlayer, false)
		end
	end)

	SettingsService.SettingsUpdated:Connect(function(settings: table)
		if settings.Pets_Visible == false then
			for _, p in pairs(Players:GetPlayers()) do
				self:PlayerRemove(p)
			end
		else
			for _, Player in pairs(Players:GetPlayers()) do
				local _ = Player.Character or Player.CharacterAdded:Wait()
				local __, coachesData = CoachesService:GetCoaches(Player):await()
				self:AddCoaches(Player, coachesData)
			end
		end
	end)

	CharactersService.CharactersUpdated:Connect(function()
		task.spawn(function()
			local localPlayer = Players.LocalPlayer
			local dataSuccess, data = DataService:GetData(localPlayer):await()
			if not dataSuccess or not data or data.Settings.Pets_Visible ~= true then
				return
			end

			self:RefreshPlayerTarget(localPlayer, true)
		end)
	end)

	TrainingSignals.TrainingStarted:Connect(function()
		self:PlayLocalCoachTrainingAnimations()
	end)

	TrainingSignals.TrainingStopped:Connect(function()
		self:StopLocalCoachTrainingAnimations()
	end)

	print("[COACHES CONTROLLER] Controller loaded successfully.")
end

function CoachesController:KnitStart()
	SetupArea("CoachesArea", {
		onEnter = function(plr)
			if plr == player then
				UIController:ShowFrame({ frame = FramesConstants.Coach })
			end
		end,
		onExit = function(plr)
			if plr == player then
				UIController:HideFrame()
			end
		end,
	})
end

return CoachesController
