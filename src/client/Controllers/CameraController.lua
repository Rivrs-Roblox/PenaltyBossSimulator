local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local Helpers = ReplicatedStorage.Shared.Helpers
local CameraShaker = require(Helpers.Camera)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Controllers
local BallController

-- Constants
local BALL_CAMERA_TWEEN_TIME = 0.4

local CameraController = Knit.CreateController({
	Name = "CameraController",
	_cameraFollowConnection = nil,
	_cameraShaker = nil,
	_cameraEffectGui = nil,
	_cameraEffectStopped = false,
})

function CameraController:KnitInit()
	BallController = Knit.GetController("BallController")

	self._cameraShaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(Offset)
		camera.CFrame = camera.CFrame * Offset
	end)
	self._cameraShaker:Start()
end

function CameraController:StopCameraVisualEffect()
	self._cameraEffectStopped = true
end

function CameraController:StartCameraVisualEffect()
	if not self.__cameraEffectGui then
		self._cameraEffectGui = player.PlayerGui:WaitForChild("CameraEffect")
	end

	-- Hide all children first
	for _, child in ipairs(self._cameraEffectGui:GetChildren()) do
		if child:IsA("GuiObject") then
			child.Visible = false
		end
	end

	-- Start visual effect loop
	local children = self._cameraEffectGui:GetChildren()
	local index = 1
	self._cameraEffectStopped = false

	task.spawn(function()
		while not self._cameraEffectStopped do
			local child = children[index]
			if child and child:IsA("GuiObject") then
				child.Visible = true
				task.wait(0.05) -- Delay before hiding the current child
				child.Visible = false
			end

			index += 1
			if index > #children then
				index = 1
			end
		end

		-- Clean up all visuals when stopped
		for _, child in ipairs(children) do
			if child:IsA("GuiObject") then
				child.Visible = false
			end
		end
	end)
end

function CameraController:PlayShakePreset(preset: string)
	self._cameraShaker:Shake(CameraShaker.Presets[preset])
end

function CameraController:SetShootCamera(shootCamPos: Instance, goalArea: Instance)
	self:StopCameraFollow()

	if not shootCamPos or not goalArea then
		warn("[CameraController] ShootCameraPos or GoalArea not found")
		return
	end

	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable

	local targetCFrame = CFrame.new(shootCamPos.Position, goalArea.Position)
	TweenService:Create(camera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = targetCFrame,
	}):Play()
end

function CameraController:SetBallCamera(camPos: Vector3, overrideBallPos: Vector3?)
	self:StopCameraFollow()

	if not camPos then
		warn("[CameraController] Camera Pos not found")
		return
	end

	local ball = BallController:GetPlayerBallModel()
	if not ball then
		return
	end

	local ballPos = overrideBallPos or ball:GetPivot().Position

	camera.CameraType = Enum.CameraType.Scriptable

	local targetCFrame = CFrame.new(camPos, ballPos)
	TweenService
		:Create(camera, TweenInfo.new(BALL_CAMERA_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = targetCFrame,
		})
		:Play()
end

function CameraController:FollowBallCamera()
	self:StopCameraFollow()

	local ball = BallController:GetBallModel()
	if not ball then
		return
	end

	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable

	self._cameraFollowConnection = RunService.Heartbeat:Connect(function()
		local currentBall = BallController:GetBallModel()
		if not currentBall then
			self:StopCameraFollow()
			return
		end

		local ballPos = currentBall:GetPivot().Position
		local camPos = ballPos + Vector3.new(0, 3, -8)
		camera.CFrame = camera.CFrame:Lerp(CFrame.new(camPos, ballPos), 0.15)
	end)
end

function CameraController:StopCameraFollow()
	if self._cameraFollowConnection then
		self._cameraFollowConnection:Disconnect()
		self._cameraFollowConnection = nil
	end
end

function CameraController:CameraInFrontOfPlayer()
	self:StopCameraFollow()

	local character = player.Character
	if not character then
		return
	end

	camera.CameraType = Enum.CameraType.Scriptable

	local targetCFrame =
		CFrame.new(character.HumanoidRootPart.Position + Vector3.new(0, 2, 8), character.HumanoidRootPart.Position)
	TweenService:Create(camera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = targetCFrame,
	}):Play()
end

function CameraController:PlayBossEyeSequence(goalie: Model)
	self:StopCameraFollow()

	if not goalie or not goalie.PrimaryPart then
		return
	end

	camera.CameraType = Enum.CameraType.Scriptable

	local lookDir = goalie.PrimaryPart.CFrame.LookVector
	local rightDir = goalie.PrimaryPart.CFrame.RightVector
	local headPos = goalie.PrimaryPart.Position + Vector3.new(0, 2.4, 0)

	-- Eye focus points
	local eyeCamPosMiddle = headPos + lookDir * 4
	local eyeCamPosLeft = headPos + lookDir * 4 - rightDir * 5

	-- Look straight ahead (opposite to goalie's look direction) to avoid panning
	local lookAtLeft = eyeCamPosLeft - lookDir
	local lookAtHead = eyeCamPosMiddle - lookDir

	camera.CFrame = CFrame.new(eyeCamPosLeft, lookAtLeft)

	local tweenEye =
		TweenService:Create(camera, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			CFrame = CFrame.new(eyeCamPosMiddle, lookAtHead),
		})
	tweenEye:Play()
	tweenEye.Completed:Wait()
end

function CameraController:PlayBossZoomOutSequence(goalie: Model)
	if not goalie or not goalie.PrimaryPart then
		return
	end

	local lookDir = goalie.PrimaryPart.CFrame.LookVector
	local headPos = goalie.PrimaryPart.Position + Vector3.new(0, 1.5, 0)
	local fullBodyCamPos = headPos + lookDir * 8 + Vector3.new(0, 0.5, 0)

	local tweenZoomOut =
		TweenService:Create(camera, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(fullBodyCamPos, headPos),
		})
	tweenZoomOut:Play()
	tweenZoomOut.Completed:Wait()
end

function CameraController:ResetCamera()
	self:StopCameraFollow()

	camera.CameraType = Enum.CameraType.Custom

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			camera.CameraSubject = humanoid
		end
	end
end

return CameraController
