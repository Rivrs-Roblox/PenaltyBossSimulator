local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Ragdoll = require(StarterPlayer.StarterPlayerScripts.Client.Modules.Ragdoll)

-- Controllers
local DataCacheController

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

-- Templates
local goalieFolder = ReplicatedStorage.Assets.Enemies
local goalieTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Goalie")

local BOSS_INTRO_ANIMS = {
	"rbxassetid://139450355498585",
	"rbxassetid://103970452615958",
	"rbxassetid://109929343035851",
}

-- GoalieController
local GoalieController = Knit.CreateController({
	Name = "GoalieController",

	Template = {},

	-- Internal state
	_goalieModel = nil,
	_goalieAnimTrack = nil,
	_goalieAnims = {},
})

--#region Local Functions
local function getGoalieDataForWave(areaData: {}, bossIndex: number, wave: number): {}?
	bossIndex = tonumber(bossIndex) or 1
	wave = tonumber(wave) or 1

	local bossKey = "Boss " .. bossIndex
	local bossData = areaData[bossKey]
	if not bossData then
		-- Backwards compatibility fallbacks
		if bossIndex == 5 and areaData["Boss"] then
			bossData = areaData["Boss"]
		elseif areaData["MiniBoss " .. bossIndex] then
			bossData = areaData["MiniBoss " .. bossIndex]
		end
	end
	if not bossData then
		return nil
	end
	return bossData
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

-- #endregion

--#region Functions
function GoalieController:GetGoalieModel()
	return self._goalieModel
end

function GoalieController:GetGoaliePosition()
	if not self._goalieModel or not self._goalieModel.PrimaryPart then
		return Vector3.zero
	end
	return self._goalieModel.PrimaryPart.Position
end

function GoalieController:GetGoalieHipHeight()
	local humanoid = self._goalieModel:FindFirstChildOfClass("Humanoid")
	if humanoid then
		return humanoid.HipHeight
	end
	return 2.4
end

function GoalieController:SpawnGoalie(wave, area, goalieArea, bossIndex)
	-- Cleanup existing goalie
	self:CleanupGoalie()

	bossIndex = tonumber(bossIndex) or 1
	wave = tonumber(wave) or 1

	-- Clone goalie dari ReplicatedStorage
	local areaFolder = goalieFolder:FindFirstChild(area)
	if not areaFolder then
		warn("[GoalieController] No folder for area:", area)
		return
	end

	local goalieTemplate = areaFolder:FindFirstChild("Boss" .. bossIndex)

	-- Backwards compatibility: Fallback to old Boss template name if new one doesn't exist
	if not goalieTemplate then
		goalieTemplate = areaFolder:FindFirstChild("Boss") or areaFolder:FindFirstChild("MiniBoss " .. bossIndex)
	end

	if not goalieTemplate then
		warn(
			"[GoalieController] No template for Goalie (Wave "
				.. wave
				.. ", BossIndex "
				.. bossIndex
				.. ") in area: "
				.. area
		)
		return
	end

	local goalie = goalieTemplate:Clone()
	goalie.Name = "Goalie_Wave" .. wave

	-- Posisikan goalie di GoalieArea
	goalie.PrimaryPart.Anchored = true
	goalie:PivotTo(goalieArea.CFrame)

	goalie.Parent = workspace

	-- Ambil data goalie dari template
	local areaData = self.Template.Enemies[area]
	if not areaData then
		warn("[GoalieController] No enemy data for area:", area)
		return
	end

	local goalieData = getGoalieDataForWave(areaData, bossIndex, wave)
	if not goalieData then
		warn(
			"[GoalieController] No goalie data for area: " .. area .. ", BossIndex: " .. bossIndex .. ", Wave: " .. wave
		)
		return
	end

	-- Tambah BillboardGui untuk wave label
	local head = goalie:FindFirstChild("Head")
	if head then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "PowerLabel"
		billboard.Size = UDim2.new(4, 0, 1.5, 0)
		billboard.StudsOffset = Vector3.new(0, 2, 0)
		billboard.Adornee = head
		billboard.AlwaysOnTop = true

		local label = Instance.new("TextLabel")
		label.Name = "PowerText"
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = FormatNumber(goalieData.Power) .. " ⚽"
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeTransparency = 0
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = billboard

		billboard.Parent = head
	end

	self._goalieModel = goalie

	-- Play goalie idle animation
	self:PlayGoalieAnimation("Idle")
end

function GoalieController:CleanupGoalie()
	-- Stop goalie animation
	if self._goalieAnimTrack then
		self._goalieAnimTrack:Stop()
		self._goalieAnimTrack:Destroy()
		self._goalieAnimTrack = nil
	end

	if self._goalieModel then
		self._goalieModel:Destroy()
		self._goalieModel = nil
	end
end

--|| Goalie Animation Functions ||--

function GoalieController:PauseGoalieAnimation()
	if self._goalieAnimTrack then
		self._goalieAnimTrack:AdjustSpeed(0)
	end
end

function GoalieController:ResumeGoalieAnimation()
	if self._goalieAnimTrack then
		self._goalieAnimTrack:AdjustSpeed(1)
	end
end

function GoalieController:StopGoalieAnimation()
	if self._goalieAnimTrack then
		self._goalieAnimTrack:Stop()
		self._goalieAnimTrack:Destroy()
		self._goalieAnimTrack = nil
	end
end

function GoalieController:PlayGoalieAnimation(animName: string, speedMultiplier: number?)
	-- Stop previous goalie animation
	if self._goalieAnimTrack then
		self._goalieAnimTrack:Stop()
		self._goalieAnimTrack:Destroy()
		self._goalieAnimTrack = nil
	end

	local goalie = self._goalieModel
	if not goalie then
		return
	end

	local anim = self._goalieAnims[animName]
	if not anim then
		warn("[GoalieController] Animation '" .. animName .. "' not found in goalie")
		return
	end

	local animator = getAnimator(goalie)
	if not animator then
		return
	end

	self._goalieAnimTrack = animator:LoadAnimation(anim)
	self._goalieAnimTrack.Priority = Enum.AnimationPriority.Action

	-- Terapkan slow motion jika speedMultiplier diberikan
	if speedMultiplier then
		self._goalieAnimTrack:AdjustSpeed(speedMultiplier)
	end

	self._goalieAnimTrack:Play()
end

function GoalieController:PlayBossIntroAnimation(callback: () -> ())
	local animName = "BossIntro" .. math.random(1, #BOSS_INTRO_ANIMS)

	self:PlayGoalieAnimation(animName)

	if self._goalieAnimTrack then
		-- Animation Length might be 0 initially, use Stopped event
		local connection
		connection = self._goalieAnimTrack.Stopped:Connect(function()
			connection:Disconnect()
			self:PlayGoalieAnimation("Idle")
			if callback then
				callback()
			end
		end)
	else
		self:PlayGoalieAnimation("Idle")
		if callback then
			callback()
		end
	end
end

function GoalieController:PlayGoalieDefendAnimation(pointerPosition: number, result: string)
	-- Pilih animasi defend berdasarkan arah bola dan hasil
	local animName

	local goalie = self._goalieModel
	if not goalie or not goalie.PrimaryPart then
		return
	end

	local horizontalOffset = (pointerPosition - 0.5) * (50 - self:GetGoalieHipHeight())
	local leftDir = goalie.PrimaryPart.CFrame.RightVector * -1

	-- Tentukan arah tendangan dari posisi pointer
	local isLeft = pointerPosition < 0.4
	local isRight = pointerPosition > 0.6
	local isCenter = not isLeft and not isRight

	-- Pilih animasi defend berdasarkan result dan arah
	if result == "GoalBlast" or isCenter then
		animName = "Defend Idle"
	elseif result == "Goal" then
		-- -- Goalie salah tebak: defend ke arah berlawanan
		-- animName = if isLeft then "Defend Left" else "Defend Right"
		-- leftDir = -leftDir
		animName = if isLeft then "Defend Right" else "Defend Left"
		leftDir = leftDir * 0.5
	else
		-- Saved / Missed / GoalCorner: defend ke arah bola
		animName = if isLeft then "Defend Right" else "Defend Left"
	end

	-- Pindahkan posisi goalie ke goalieTargetPos (kecuali GoalBlast/Defend Front tengah)
	local shouldMove = result ~= "GoalBlast" and not isCenter

	local goalieTargetPos = goalie.PrimaryPart.Position + leftDir * horizontalOffset

	self:PlayGoalieAnimation(animName)

	if shouldMove then
		local currentCFrame = goalie.PrimaryPart.CFrame
		local targetCFrame = CFrame.new(goalieTargetPos) * (currentCFrame - currentCFrame.Position) -- Keep rotation

		TweenService:Create(goalie.PrimaryPart, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = targetCFrame,
		}):Play()
	end
end

--- Ragdoll goalie ke arah belakang (efek bola menabrak goalie dengan keras).
--- @param forwardDir Vector3 Arah tendangan bola (dari player ke gawang)
function GoalieController:RagdollGoalie(forwardDir: Vector3)
	local goalie = self._goalieModel
	if not goalie then
		return
	end

	-- unanchor all
	for _, part in goalie:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = true
		end
	end

	local ragdoll = Ragdoll.new(goalie)
	ragdoll:enableRagdoll()

	-- Beri velocity ke belakang (mental)
	local blastVelocity = forwardDir * 50
	for _, part in goalie:GetDescendants() do
		if part:IsA("BasePart") then
			part.AssemblyLinearVelocity = blastVelocity
		end
	end
end

function GoalieController:PreloadNecessaryAssets()
	task.spawn(function()
		local assetsToPreload = {}

		-- 2. Preload goalie animations
		local goalieAnimations = goalieTemplate:FindFirstChild("Animations")
		if goalieAnimations then
			for _, anim in goalieAnimations:GetChildren() do
				if anim:IsA("Animation") then
					self._goalieAnims[anim.Name] = anim
					table.insert(assetsToPreload, anim)
				end
			end
		end

		-- 3. Preload Boss Intro animations
		for i, animId in ipairs(BOSS_INTRO_ANIMS) do
			local anim = Instance.new("Animation")
			anim.AnimationId = animId
			anim.Name = "BossIntro" .. i
			self._goalieAnims[anim.Name] = anim
			table.insert(assetsToPreload, anim)
		end

		if #assetsToPreload > 0 then
			ContentProvider:PreloadAsync(assetsToPreload)
			print("[GoalieController] All assets loaded.")
		end
	end)
end

-- #endregion

-- #region Knit Lifecycle

function GoalieController:KnitInit()
	DataCacheController = Knit.GetController("DataCacheController")
end

function GoalieController:KnitStart()
	self.Template = DataCacheController:GetFile("Template")

	self:PreloadNecessaryAssets()
end
--	#endregion

return GoalieController
