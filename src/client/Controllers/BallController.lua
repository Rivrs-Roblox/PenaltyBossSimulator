local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Sound = require(Packages.Sound)

-- Controllers
local GoalieController
local CameraController

-- Templates
local ballTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Balls"):WaitForChild("Football")

-- Constants
local BALL_SPEED = 46
local GOALIE_REACT_DISTANCE = 12
local RESULT_SHOW_DISTANCE = 3
local BALL_SPIN_SPEED = 38
local BIG_HIP_THRESHOLD = 3.5

local player = Players.LocalPlayer

local BallController = Knit.CreateController({
	Name = "BallController",

	-- Internal state
	_ballModel = nil,
	_ballMoveConnection = nil,
	_ballSpeed = BALL_SPEED,
	_ballSpeedMultiplier = 1,
})

local function getPlayerBall()
	local character = player.Character
	if not character then
		return nil
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	if not humanoidRootPart then
		return nil
	end

	local ball = humanoidRootPart:FindFirstChild("Football")
	if not ball then
		return nil
	end

	return ball
end

function BallController:KnitInit()
	GoalieController = Knit.GetController("GoalieController")
	CameraController = Knit.GetController("CameraController")
end

function BallController:GetBallModel()
	return self._ballModel
end

function BallController:GetPlayerBallModel()
	return getPlayerBall()
end

-- Player ball which is in the character
function BallController:SetEnabledPlayerBallEffect(enabled: boolean)
	local ball = getPlayerBall()
	if not ball then
		return
	end

	for _, part in ipairs(ball:GetDescendants()) do
		if part:IsA("ParticleEmitter") or part:IsA("Trail") then
			part.Enabled = enabled
		end
	end
end

-- Ball which is in the air/Projectile
function BallController:SetEnabledBallEffect(enabled: boolean, effectName: string)
	local ball = self._ballModel
	if not ball then
		return
	end

	local effects = ball:FindFirstChild(effectName, true)
	if not effects then
		return
	end

	for _, child in ipairs(effects:GetChildren()) do
		if child:IsA("ParticleEmitter") or child:IsA("Trail") then
			child.Enabled = enabled
		end
	end
end

function BallController:PlayExplosionEffect()
	Sound:PlaySound("MISC_Explosion")
	CameraController:PlayShakePreset("Explosion")
	self:SetEnabledBallEffect(true, "ExplodeEffects")

	local goalie = GoalieController:GetGoalieModel()
	local ball = self._ballModel
	if goalie and goalie.PrimaryPart and ball and ball.PrimaryPart then
		local blastDir = (goalie.PrimaryPart.Position - ball.PrimaryPart.Position).Unit
		-- Tambahkan sedikit dorongan ke atas agar terbang natural
		blastDir = (blastDir + Vector3.new(0, 0.5, 0)).Unit
		GoalieController:RagdollGoalie(blastDir)
	end

	task.delay(1, function()
		self:SetEnabledBallEffect(false, "ExplodeEffects")
	end)
end

function BallController:SetSpeedMultiplier(mult: number)
	self._ballSpeedMultiplier = mult
end

function BallController:SpawnBall(ballPos: Vector3)
	self:CleanupBall()

	if not ballPos then
		local ball = getPlayerBall()
		if not ball then
			return warn("Ball not found")
		end

		ballPos = ball.PrimaryPart.Position
	end

	local ball = ballTemplate:Clone()
	ball.Name = "PenaltyBall"
	ball:PivotTo(CFrame.new(ballPos))

	ball.Parent = workspace
	self._ballModel = ball
end

function BallController:CleanupBall()
	self:StopBallMovement()
	if self._ballModel then
		self._ballModel:Destroy()
		self._ballModel = nil
	end
end

function BallController:ReleaseBallPhysics()
	local ball = self._ballModel
	if not ball then
		return
	end

	if ball.PrimaryPart then
		ball.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 5)
		ball.PrimaryPart.Anchored = false
	end
end

function BallController:WeldBallToGoalie()
	local ball = self._ballModel
	local goalie = GoalieController:GetGoalieModel()
	if not ball or not goalie then
		return
	end

	local ballPart = ball.PrimaryPart
	if not ballPart then
		return
	end

	local handNames = { "Left Hand", "LeftHand", "LeftLowerArm", "Left Arm" }
	local handPart
	for _, name in handNames do
		handPart = goalie:FindFirstChild(name)
		if handPart and handPart:IsA("BasePart") then
			break
		end
		handPart = nil
	end

	if not handPart then
		handPart = goalie.PrimaryPart
	end

	if not handPart then
		return
	end

	ballPart.CFrame = handPart.CFrame
	ballPart.Anchored = false

	local weld = Instance.new("WeldConstraint")
	weld.Name = "GoalieCatchWeld"
	weld.Part0 = handPart
	weld.Part1 = ballPart
	weld.Parent = ballPart
end

function BallController:StopBallMovement()
	if self._ballMoveConnection then
		self._ballMoveConnection:Disconnect()
		self._ballMoveConnection = nil
	end
end

function BallController:MoveBallTo(targetPos: Vector3, callbacks: {}?, shootDirection: string?)
	self:StopBallMovement()

	local ball = self._ballModel
	if not ball then
		return
	end

	local movePart
	local effects
	movePart = ball.PrimaryPart
	effects = ball.SpecialEffects

	if not movePart or not effects then
		warn("Ball part or effects not found")
		return
	end

	local goalieReacted = false
	local ballHitGoalie = false
	local resultShown = false
	local spinAngle = 0
	callbacks = callbacks or {}

	self._ballMoveConnection = RunService.Heartbeat:Connect(function(dt)
		if not self._ballModel or not movePart or not movePart.Parent then
			self:StopBallMovement()
			return
		end

		local currentPos = movePart.Position
		local direction = (targetPos - currentPos)
		local distanceToTarget = direction.Magnitude

		local distanceToGoalie = math.abs(GoalieController:GetGoaliePosition().Z - currentPos.Z) or math.huge

		if not goalieReacted and distanceToGoalie <= GOALIE_REACT_DISTANCE then
			goalieReacted = true
			if callbacks.onGoalieReact then
				callbacks.onGoalieReact()
			end
		end

		if not ballHitGoalie and distanceToGoalie < 2 then
			ballHitGoalie = true
			if callbacks.onBallHitGoalie then
				callbacks.onBallHitGoalie()
			end
		end

		if not resultShown and distanceToTarget <= RESULT_SHOW_DISTANCE then
			resultShown = true
			if callbacks.onResult then
				callbacks.onResult()
			end
		end

		if distanceToTarget < 0.5 then
			self:StopBallMovement()

			if not resultShown and callbacks.onResult then
				callbacks.onResult()
			end

			if callbacks.onArrived then
				callbacks.onArrived()
			end
			return
		end

		local speedMul = self._ballSpeedMultiplier
		local moveDistance = self._ballSpeed * speedMul * dt
		local moveVector = direction.Unit * math.min(moveDistance, distanceToTarget)
		spinAngle += BALL_SPIN_SPEED * speedMul * dt
		local tilt = if shootDirection and shootDirection == "Left"
			then CFrame.Angles(0, 0, math.rad(45))
			else CFrame.Angles(0, 0, math.rad(-45))

		movePart.CFrame = CFrame.new(currentPos + moveVector) * tilt * CFrame.Angles(spinAngle, 0, 0)
		effects.CFrame = CFrame.new(currentPos + moveVector) * CFrame.Angles(math.rad(-90), 0, 0)
	end)
end

function BallController:AnimateBallKick(
	pointerPosition: number,
	result: string,
	goalPos: Vector3,
	isSpecialKick: boolean,
	callbacks: {}?,
	isGoalCornerBlasted: boolean?
)
	local ball = self._ballModel
	if not ball then
		return
	end

	local goaliePos = GoalieController:GetGoaliePosition()
	local goalieHipHeight = GoalieController:GetGoalieHipHeight()

	local ballPos = ball:GetPivot().Position
	local forwardDir = (goalPos - ballPos).Unit
	local rightDir = forwardDir:Cross(Vector3.new(0, 1, 0)).Unit

	local shootDirection = if pointerPosition < 0.5 then "Left" else "Right"

	if result == "Goal" then
		local horizontalOffset = (pointerPosition - 0.5) * 50
		local randomVerticalOffset = Vector3.new(0, math.random(-4, 4), 0)
		local targetPos = goalPos + rightDir * horizontalOffset + forwardDir * 1.2 + randomVerticalOffset

		local wrappedCallbacks = {
			onGoalieReact = callbacks and callbacks.onGoalieReact,
			onResult = callbacks and callbacks.onResult,
			onArrived = function()
				if callbacks and callbacks.onArrived then
					callbacks.onArrived()
				end

				Sound:PlaySound("MISC_Goal")
				if isSpecialKick then
					self:SetEnabledBallEffect(false, "SpecialEffects")
					self:PlayExplosionEffect()
				end
				self:ReleaseBallPhysics()
			end,
		}

		self:MoveBallTo(targetPos, wrappedCallbacks, shootDirection)
	elseif result == "GoalBlast" then
		local targetPos = goaliePos + Vector3.new(0, 0, 5)

		local wrappedCallbacks = {
			onGoalieReact = callbacks and callbacks.onGoalieReact,
			onResult = function()
				task.delay(2, function()
					if callbacks and callbacks.onResult then
						callbacks.onResult()
					end
				end)
			end,
			onBallHitGoalie = function()
				self._ballSpeed = 0

				local delay = 1
				if isSpecialKick then
					Sound:PlaySound("MISC_Goalie_Hold")
					CameraController:PlayShakePreset("GoalieDefendSpecial")
					self:SetEnabledBallEffect(false, "SpecialEffects")
					delay = 2.5
				else
					CameraController:PlayShakePreset("GoalieDefend")
				end

				self:SetEnabledBallEffect(true, "HoldEffects")

				task.delay(delay, function()
					Sound:PlaySound("MISC_Goal")

					self:SetEnabledBallEffect(false, "HoldEffects")
					if isSpecialKick then
						self:PlayExplosionEffect()
					else
						GoalieController:RagdollGoalie(forwardDir)
					end

					self._ballSpeed = BALL_SPEED
				end)
			end,
			onArrived = function()
				if callbacks and callbacks.onArrived then
					callbacks.onArrived()
				end

				self:ReleaseBallPhysics()
			end,
		}

		self:MoveBallTo(targetPos, wrappedCallbacks, shootDirection)
	elseif result == "GoalCorner" then
		local cornerOffset = if pointerPosition < 0.5 then -25 else 25
		local targetPos = goalPos + rightDir * cornerOffset + Vector3.new(0, 5, 0)

		local isBlasted = if isGoalCornerBlasted ~= nil then isGoalCornerBlasted else true

		local wrappedCallbacks = {
			onGoalieReact = callbacks and callbacks.onGoalieReact,
			onResult = callbacks and callbacks.onResult,
			onArrived = function()
				if not (goalieHipHeight >= BIG_HIP_THRESHOLD) or not isBlasted then
					if callbacks and callbacks.onArrived then
						callbacks.onArrived()
					end

					Sound:PlaySound("MISC_Goal")
					if isSpecialKick then
						self:SetEnabledBallEffect(false, "SpecialEffects")
						self:PlayExplosionEffect()
					end
					self:ReleaseBallPhysics()
				else
					self:ReleaseBallPhysics()
				end
			end,
			onBallHitGoalie = function()
				if goalieHipHeight >= BIG_HIP_THRESHOLD and isBlasted then
					self._ballSpeed = 0
					GoalieController:PauseGoalieAnimation()

					local delay = 1
					if isSpecialKick then
						Sound:PlaySound("MISC_Goalie_Hold")
						CameraController:PlayShakePreset("GoalieDefendSpecial")
						self:SetEnabledBallEffect(false, "SpecialEffects")
						delay = 2.5
					else
						CameraController:PlayShakePreset("GoalieDefend")
					end

					self:SetEnabledBallEffect(true, "HoldEffects")

					task.delay(delay, function()
						Sound:PlaySound("MISC_Goal")

						self:SetEnabledBallEffect(false, "HoldEffects")
						GoalieController:ResumeGoalieAnimation()
						if isSpecialKick then
							self:PlayExplosionEffect()
						else
							GoalieController:RagdollGoalie(forwardDir)
						end

						self._ballSpeed = BALL_SPEED
					end)
				end
			end,
		}

		self:MoveBallTo(targetPos, wrappedCallbacks, shootDirection)
	elseif result == "Saved" then
		local savedGoalieModel = GoalieController:GetGoalieModel()
		if not savedGoalieModel or not savedGoalieModel.PrimaryPart then
			return
		end
		local leftDir = savedGoalieModel.PrimaryPart.CFrame.RightVector * -1
		local goalieTargetPos

		if pointerPosition >= 0.4 and pointerPosition <= 0.6 then
			goalieTargetPos = goaliePos
		else
			local horizontalOffset = (pointerPosition - 0.5) * 54
			local extraOffset = if pointerPosition < 0.5 then -4 else 4
			goalieTargetPos = goaliePos + leftDir * (horizontalOffset + extraOffset)
		end

		local targetPos = goalieTargetPos

		local wrappedCallbacks = {
			onGoalieReact = callbacks and callbacks.onGoalieReact,
			onResult = callbacks and callbacks.onResult,
			onArrived = function()
				if callbacks and callbacks.onArrived then
					callbacks.onArrived()
				end

				self:WeldBallToGoalie()
			end,
		}

		self:MoveBallTo(targetPos, wrappedCallbacks, shootDirection)
	elseif result == "Missed" then
		local wideOffset = if pointerPosition < 0.5 then -46 else 46
		local targetPos = goalPos + rightDir * wideOffset + Vector3.new(0, 3, 0) + forwardDir * 8

		local wrappedCallbacks = {
			onGoalieReact = callbacks and callbacks.onGoalieReact,
			onResult = callbacks and callbacks.onResult,
			onArrived = function()
				if callbacks and callbacks.onArrived then
					callbacks.onArrived()
				end

				self:ReleaseBallPhysics()
			end,
		}

		self:MoveBallTo(targetPos, wrappedCallbacks, shootDirection)
	end
end

return BallController
