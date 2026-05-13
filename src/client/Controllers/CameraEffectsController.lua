local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

--remote events
local shakeCameraEvent = ReplicatedStorage.RemoteEvents:WaitForChild("ShakeCameraEvent")

local CameraEffectsController = Knit.CreateController({
	Name = "CameraEffectsController",
})

function CameraEffectsController:ShakeCamera(intensity, duration, fadeInTime, fadeOutTime)
	local cam = workspace.CurrentCamera
	local startTime = tick()

	fadeInTime = fadeInTime or 0.1
	fadeOutTime = fadeOutTime or 0.3

	local connection
	connection = RunService.RenderStepped:Connect(function()
		local now = tick()
		local elapsed = now - startTime
		local remaining = duration - elapsed

		if elapsed >= duration then
			connection:Disconnect()
			return
		end

		-- Hitung scale berdasarkan waktu (fade in & fade out)
		local scale = 1
		if elapsed < fadeInTime then
			scale = elapsed / fadeInTime
		elseif remaining < fadeOutTime then
			scale = remaining / fadeOutTime
		end

		local currentIntensity = intensity * scale

		local offset = Vector3.new(
			(math.random() - 0.5) * 2 * currentIntensity,
			(math.random() - 0.5) * 2 * currentIntensity,
			(math.random() - 0.5) * 2 * currentIntensity
		)

		-- Ambil posisi kamera saat ini (mengikuti karakter)
		local baseCFrame = cam.CFrame
		cam.CFrame = baseCFrame * CFrame.new(offset)
	end)
end

function CameraEffectsController:KnitStart()
	-- Connect the remote event to the ShakeCamera function
	shakeCameraEvent.OnClientEvent:Connect(function(intensity, duration, fadeInTime, fadeOutTime)
		self:ShakeCamera(intensity, duration, fadeInTime, fadeOutTime)
	end)
end

return CameraEffectsController
