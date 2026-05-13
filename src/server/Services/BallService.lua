local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Sound = require(Packages.Sound)

--// CONFIG
local BALL_LIFETIME = 2
local CURVE_HEIGHT = 12
local SHOOT_COOLDOWN = 1.15

local START_FORWARD_OFFSET = 2.0
local START_RIGHT_OFFSET = 0.5
local START_HEIGHT_OFFSET = 0.2

local BallService = Knit.CreateService({
	Name = "BallService",
	Client = {
		-- Dipakai client hanya sebagai info lifecycle bola, bukan untuk logic training/facing.
		BallWindupStarted = Knit.CreateSignal(),
		BallShoot = Knit.CreateSignal(),
		BallFinished = Knit.CreateSignal(),
	},
})

BallService.LastShootTime = {}

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

local function getBallSpawnPosition(character, root, targetPosition)
	local basePos = root.Position

	local rightFoot = getRightFoot(character)
	if rightFoot and rightFoot:IsA("BasePart") then
		basePos = Vector3.new(basePos.X, rightFoot.Position.Y + 0.2, basePos.Z)
	end

	-- horizontal
	local flatDirection = Vector3.new(targetPosition.X - root.Position.X, 0, targetPosition.Z - root.Position.Z)

	-- fallback kalau target terlalu dekat / vector 0
	if flatDirection.Magnitude < 0.001 then
		flatDirection = root.CFrame.LookVector
		flatDirection = Vector3.new(flatDirection.X, 0, flatDirection.Z)
	end

	if flatDirection.Magnitude < 0.001 then
		flatDirection = Vector3.new(0, 0, -1)
	end

	flatDirection = flatDirection.Unit

	-- offset kanan
	local rightDirection = flatDirection:Cross(Vector3.yAxis)
	if rightDirection.Magnitude < 0.001 then
		rightDirection = Vector3.xAxis
	else
		rightDirection = rightDirection.Unit
	end

	local spawnPos = basePos
		+ (flatDirection * START_FORWARD_OFFSET)
		+ (rightDirection * START_RIGHT_OFFSET)
		+ Vector3.new(0, START_HEIGHT_OFFSET, 0)

	return spawnPos
end

local function setFootballTransparancy(player: Player, transparancy: number)
	local character = player.Character
	if not character then
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local football = hrp:FindFirstChild("Football")
		if football then
			local ballRoot = football:FindFirstChild("BallRoot")
			local meshPart = ballRoot and ballRoot:FindFirstChildOfClass("MeshPart")
			if meshPart then
				meshPart.Transparency = transparancy
			end
		end
	end
end

function BallService:ResetPlayer(player: Player)
	self.LastShootTime[player] = nil
end

function BallService:ShootBall(player: Player, target)
	-- Cegah duplikasi shoot dari spam click / loop training.
	local now = os.clock()
	if self.LastShootTime[player] and (now - self.LastShootTime[player]) < SHOOT_COOLDOWN then
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

	-- BallService hanya mengurus lifecycle bola.
	-- Paksa hadap target dipindahkan ke TrainingService.
	self.Client.BallWindupStarted:Fire(player)

	local ballTemplate = ReplicatedStorage:FindFirstChild("BallModel")
	if not ballTemplate then
		warn("BallModel tidak ditemukan di ReplicatedStorage!")
		setFootballTransparancy(player, 0)
		self.Client.BallFinished:Fire(player)
		return false
	end

	task.delay(0.3, function()
		if not character.Parent or not root.Parent then
			setFootballTransparancy(player, 0)
			self.Client.BallFinished:Fire(player)
			return
		end

		local ball = ballTemplate:Clone()

		Sound:PlaySound("MISC_Shoot_Training", character)
		-- self.Client.BallShoot:Fire(player)
		setFootballTransparancy(player, 1)

		local spawnPos = getBallSpawnPosition(character, root, targetPosition)

		setObjectCFrame(ball, CFrame.lookAt(spawnPos, targetPosition))
		ball.Parent = workspace

		local start = getObjectPosition(ball)

		local midPoint = (start + targetPosition) / 2
		midPoint += Vector3.new(math.random(-5, 5), CURVE_HEIGHT, math.random(-5, 5))

		local t = 0
		local speed = 2
		local finished = false

		local function finishShot()
			if finished then
				return
			end

			finished = true
			setFootballTransparancy(player, 0)
			self.Client.BallFinished:Fire(player)
		end

		local connection
		connection = RunService.Heartbeat:Connect(function(dt)
			if not ball or not ball.Parent then
				if connection then
					connection:Disconnect()
				end
				finishShot()
				return
			end

			t = math.clamp(t + dt * speed, 0, 1)
			local smoothT = t * t * (3 - 2 * t)

			local a = start:Lerp(midPoint, smoothT)
			local b = midPoint:Lerp(targetPosition, smoothT)
			local pos = a:Lerp(b, smoothT)

			setObjectCFrame(ball, CFrame.new(pos) * CFrame.Angles(t * 20, t * 20, 0))

			if t >= 1 then
				connection:Disconnect()
				ball:Destroy()
				finishShot()
			end
		end)

		task.delay(BALL_LIFETIME + 1, function()
			if connection then
				connection:Disconnect()
			end

			if ball and ball.Parent then
				ball:Destroy()
			end

			finishShot()
		end)
	end)

	return true
end

function BallService:KnitStart()
	Players.PlayerRemoving:Connect(function(player)
		self.LastShootTime[player] = nil
	end)
end

return BallService
