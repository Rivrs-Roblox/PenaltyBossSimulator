--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local FightService = nil

local NPCAnimController = Knit.CreateController({
	Name = "NPCAnimController",
})

-- CONFIG
local MAX_ACTIVE_JUMP_NPCS_PER_AREA = 30

local ENVIRONMENTS_FOLDER_NAME = "Environments"
local NPCS_MODEL_NAME = "NPCAnim"

local WAIT_FOLDER_TIMEOUT = 10

local BASE_JUMP_HEIGHT = 1.5
local JUMP_HEIGHT_VARIATION = 0.4

local BASE_UP_DURATION = 0.28
local BASE_DOWN_DURATION = 0.32
local JUMP_DURATION_VARIATION = 0.25

local START_OFFSET_STEP = 0.18
local START_OFFSET_RANDOM = 0.35

local REST_TIME_MIN = 0.15
local REST_TIME_MAX = 0.45

local FORCE_ANCHOR_DURING_JUMP = true
local DISABLE_COLLISION_DURING_JUMP = false
local RESET_TO_ORIGIN_ON_STOP = true

local RandomGenerator = Random.new()

-- AREA / NPC MODEL

local function toFolderName(fightArea: string): string
	local text = tostring(fightArea)
	local number = tonumber(text:match("%d+"))

	if not number then
		return text
	end

	return string.format("Area%02d", number)
end

local function getNPCAnimModel(folderName: string): Model?
	local areaFolder = workspace:WaitForChild(folderName, WAIT_FOLDER_TIMEOUT)
	if not areaFolder then
		warn("[NPCAnimController] Area folder tidak ditemukan:", folderName)
		return nil
	end

	local environmentsFolder = areaFolder:WaitForChild(ENVIRONMENTS_FOLDER_NAME, WAIT_FOLDER_TIMEOUT)
	if not environmentsFolder then
		warn("[NPCAnimController] Environments tidak ditemukan di:", folderName)
		return nil
	end

	local npcAnimModel = environmentsFolder:WaitForChild(NPCS_MODEL_NAME, WAIT_FOLDER_TIMEOUT)
	if not npcAnimModel then
		warn("[NPCAnimController] NPCAnim tidak ditemukan di:", environmentsFolder:GetFullName())
		return nil
	end

	if not npcAnimModel:IsA("Model") then
		warn("[NPCAnimController] NPCAnim harus berupa Model, bukan:", npcAnimModel.ClassName)
		return nil
	end

	return npcAnimModel
end

local function getNPCModels(folderName: string): { Model }
	local npcAnimModel = getNPCAnimModel(folderName)
	if not npcAnimModel then
		return {}
	end

	local children = npcAnimModel:GetChildren()
	local models = {}

	for _, child in ipairs(children) do
		if child:IsA("Model") then
			table.insert(models, child)
		end
	end

	print("[NPCAnimController] NPCAnim model:", npcAnimModel:GetFullName())
	print("[NPCAnimController] Total child:", #children)
	print("[NPCAnimController] Total NPC model:", #models)

	return models
end

-- MODEL STATE

local function prepareModelForJump(model: Model)
	local originalPartStates = {}

	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			originalPartStates[descendant] = {
				Anchored = descendant.Anchored,
				CanCollide = descendant.CanCollide,
			}

			if FORCE_ANCHOR_DURING_JUMP then
				descendant.Anchored = true
			end

			if DISABLE_COLLISION_DURING_JUMP then
				descendant.CanCollide = false
			end
		end
	end

	return originalPartStates
end

local function restoreModelAfterJump(originalPartStates)
	for part, state in pairs(originalPartStates) do
		if part and part.Parent then
			part.Anchored = state.Anchored
			part.CanCollide = state.CanCollide
		end
	end
end

-- TWEEN JUMP

local function getRandomVariation(baseValue: number, variation: number): number
	local multiplier = RandomGenerator:NextNumber(1 - variation, 1 + variation)
	return baseValue * multiplier
end

local function waitWithStopCheck(seconds: number, state): boolean
	local endTime = os.clock() + seconds

	while os.clock() < endTime do
		if state.Stopped then
			return false
		end

		task.wait(0.03)
	end

	return not state.Stopped
end

local function cleanupJumpState(state, shouldReset: boolean)
	if state.Cleaned then
		return
	end

	state.Cleaned = true
	state.Stopped = true

	if state.CurrentTween then
		pcall(function()
			state.CurrentTween:Cancel()
		end)

		state.CurrentTween = nil
	end

	if state.Connection then
		state.Connection:Disconnect()
		state.Connection = nil
	end

	if shouldReset and state.Model and state.Model.Parent then
		pcall(function()
			state.Model:PivotTo(state.OriginPivot)
		end)
	end

	if state.OriginalPartStates then
		restoreModelAfterJump(state.OriginalPartStates)
		state.OriginalPartStates = nil
	end

	if state.PivotValue then
		state.PivotValue:Destroy()
		state.PivotValue = nil
	end
end

local function createJumpTween(state, targetPivot: CFrame, duration: number, easingDirection: Enum.EasingDirection): Tween
	local tweenInfo = TweenInfo.new(
		duration,
		Enum.EasingStyle.Sine,
		easingDirection,
		0,
		false,
		0
	)

	return TweenService:Create(state.PivotValue, tweenInfo, {
		Value = targetPivot,
	})
end

local function playTween(state, targetPivot: CFrame, duration: number, easingDirection: Enum.EasingDirection): boolean
	if state.Stopped or not state.Model or not state.Model.Parent then
		return false
	end

	state.CurrentTween = createJumpTween(state, targetPivot, duration, easingDirection)
	state.CurrentTween:Play()

	local playbackState = state.CurrentTween.Completed:Wait()

	if state.Stopped or not state.Model or not state.Model.Parent then
		return false
	end

	return playbackState == Enum.PlaybackState.Completed
end

local function startJumpLoop(model: Model, index: number)
	local originPivot = model:GetPivot()
	local originalPartStates = prepareModelForJump(model)

	local pivotValue = Instance.new("CFrameValue")
	pivotValue.Name = "_NPCJumpPivotValue"
	pivotValue.Value = originPivot
	pivotValue.Parent = model

	local state = {
		Model = model,
		OriginPivot = originPivot,
		PivotValue = pivotValue,
		Connection = nil,
		CurrentTween = nil,
		Stopped = false,
		Cleaned = false,
		OriginalPartStates = originalPartStates,
	}

	state.Connection = pivotValue:GetPropertyChangedSignal("Value"):Connect(function()
		if state.Stopped then
			return
		end

		if not model.Parent then
			cleanupJumpState(state, false)
			return
		end

		model:PivotTo(pivotValue.Value)
	end)

	task.spawn(function()
		local startDelay = ((index - 1) * START_OFFSET_STEP) + RandomGenerator:NextNumber(0, START_OFFSET_RANDOM)

		if not waitWithStopCheck(startDelay, state) then
			cleanupJumpState(state, RESET_TO_ORIGIN_ON_STOP)
			return
		end

		while not state.Stopped and model.Parent do
			local jumpHeight = getRandomVariation(BASE_JUMP_HEIGHT, JUMP_HEIGHT_VARIATION)
			local upDuration = getRandomVariation(BASE_UP_DURATION, JUMP_DURATION_VARIATION)
			local downDuration = getRandomVariation(BASE_DOWN_DURATION, JUMP_DURATION_VARIATION)

			local upPivot = originPivot + Vector3.new(0, jumpHeight, 0)

			if not playTween(state, upPivot, upDuration, Enum.EasingDirection.Out) then
				break
			end

			if not playTween(state, originPivot, downDuration, Enum.EasingDirection.In) then
				break
			end

			local restTime = RandomGenerator:NextNumber(REST_TIME_MIN, REST_TIME_MAX)
			if not waitWithStopCheck(restTime, state) then
				break
			end
		end

		cleanupJumpState(state, RESET_TO_ORIGIN_ON_STOP)
	end)

	return state
end

-- SELECTION

local function shuffleModels(models: { Model }): { Model }
	local shuffled = {}

	for _, model in ipairs(models) do
		table.insert(shuffled, model)
	end

	for i = #shuffled, 2, -1 do
		local j = RandomGenerator:NextInteger(1, i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end

	return shuffled
end

local function chooseActiveNPCModels(models: { Model }): { Model }
	if #models <= MAX_ACTIVE_JUMP_NPCS_PER_AREA then
		return models
	end

	local shuffled = shuffleModels(models)
	local selected = {}

	for i = 1, MAX_ACTIVE_JUMP_NPCS_PER_AREA do
		table.insert(selected, shuffled[i])
	end

	return selected
end

-- KNIT LIFECYCLE

function NPCAnimController:KnitStart()
	FightService = Knit.GetService("FightService")

	local activeJumpStates = {}
	local currentAreaFolder: string? = nil
	local sessionToken = 0

	local function stopActiveJumpers()
		sessionToken += 1

		for _, state in ipairs(activeJumpStates) do
			cleanupJumpState(state, RESET_TO_ORIGIN_ON_STOP)
		end

		table.clear(activeJumpStates)
	end

	local function startAreaJump(folderName: string)
		stopActiveJumpers()

		currentAreaFolder = folderName
		local myToken = sessionToken

		task.spawn(function()
			print("[NPCAnimController] Start NPC jump area:", folderName)

			local allNPCModels = getNPCModels(folderName)

			if myToken ~= sessionToken then
				return
			end

			if #allNPCModels <= 0 then
				warn("[NPCAnimController] Tidak ada NPC model di area:", folderName)
				return
			end

			local selectedNPCModels = chooseActiveNPCModels(allNPCModels)

			for index, model in ipairs(selectedNPCModels) do
				if myToken ~= sessionToken then
					return
				end

				if model.Parent then
					local state = startJumpLoop(model, index)
					table.insert(activeJumpStates, state)
				end
			end
		end)
	end

	FightService.FightStarted:Connect(function(fightArea: string)
		local folderName = toFolderName(fightArea)
		startAreaJump(folderName)
	end)

	FightService.FightEnded:Connect(function()
		stopActiveJumpers()
		currentAreaFolder = nil
	end)

	print("[NPCAnimController] Controller loaded successfully.")
end

return NPCAnimController