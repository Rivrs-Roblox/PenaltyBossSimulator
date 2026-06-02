local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local InputController = Knit.CreateController({
	Name = "InputController",

	_pointerConnection = nil,
	_touchConnections = nil,

	_aimTouchInput = nil,
	_lastTouchX = nil,
	_touchStartPos = nil,

	_isCapturing = false,
	_aimDirectionValue = 0.5,
	_pointerPosition = 0.5,
	_pointerDirection = 1,
	_activeAimVisuals = nil,
	_activePowerPointer = nil,

	-- UI References
	_controlFrame = nil,
	_joystickFrame = nil,
	_joystickKnob = nil,
	_gamepadFrame = nil,
	_gamepadJoystickFrame = nil,
	_gamepadJoystickKnob = nil,
})

local FightController

local POINTER_SPEED = 1.5 -- Kecepatan pointer (full left to right per second)
local AIM_STEER_SPEED = 0.8 -- Steer speed: 0.8 units per second

local function isPlayerOnMobile()
	return UserInputService.TouchEnabled
end

function InputController:KnitInit()
	FightController = Knit.GetController("FightController")
end

function InputController:KnitStart()
	self:SetupShootConnections()

	task.spawn(function()
		self:SetupControlUI()
	end)
end

function InputController:SetupControlUI()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local dynamicBarGui = playerGui:WaitForChild("DynamicBarGui")

	self._controlFrame = dynamicBarGui:WaitForChild("Control")
	self._joystickFrame = self._controlFrame:WaitForChild("Mobile"):WaitForChild("Left")
	self._joystickKnob = self._joystickFrame:WaitForChild("Joystick")

	self._gamepadFrame = self._controlFrame:WaitForChild("Gamepad", 5)
	if self._gamepadFrame then
		self._gamepadJoystickFrame = self._gamepadFrame:FindFirstChild("Left") or self._gamepadFrame
		self._gamepadJoystickKnob = self._gamepadJoystickFrame and self._gamepadJoystickFrame:FindFirstChild("Joystick")
	end

	UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
		self:UpdateControlVisibility(lastInputType)
	end)

	self:UpdateControlVisibility(UserInputService:GetLastInputType())
end

function InputController:UpdateControlVisibility(inputType)
	if not self._controlFrame then
		return
	end
	local isMobile = isPlayerOnMobile()
	local isGamepad = inputType == Enum.UserInputType.Gamepad1
		or inputType == Enum.UserInputType.Gamepad2
		or inputType == Enum.UserInputType.Gamepad3
		or inputType == Enum.UserInputType.Gamepad4
	local isPC = not isMobile and not isGamepad

	if self._controlFrame:FindFirstChild("Mobile") then
		self._controlFrame.Mobile.Visible = isMobile and not isGamepad
	end
	if self._controlFrame:FindFirstChild("PC") then
		self._controlFrame.PC.Visible = isPC
	end
	if self._gamepadFrame then
		self._gamepadFrame.Visible = isGamepad
	end
end

function InputController:SetupShootConnections()
	-- Input: Mouse1 / Keypresses to shoot
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if not FightController or not FightController.IsKicking then
			return
		end

		if UserInputService:GetFocusedTextBox() then
			return
		end

		-- Handle PC/Console shoot inputs
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.KeyCode == Enum.KeyCode.ButtonR2
			or input.KeyCode == Enum.KeyCode.Space
		then
			FightController:StopPointer()
		end

		-- Handle mobile touch inputs (drag on left half is for aim, tap on right half is to shoot)
		if input.UserInputType == Enum.UserInputType.Touch then
			local viewportSize = workspace.CurrentCamera.ViewportSize
			if input.Position.X >= viewportSize.X / 2 then
				FightController:StopPointer()
			end
		end
	end)

	UserInputService.TouchTap:Connect(function(touchPositions, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if not FightController or not FightController.IsKicking then
			return
		end

		if UserInputService:GetFocusedTextBox() then
			return
		end

		local touchPos = touchPositions[1]
		if touchPos then
			local viewportSize = workspace.CurrentCamera.ViewportSize
			if touchPos.X >= viewportSize.X / 2 then
				FightController:StopPointer()
			end
		end
	end)
end

function InputController:StartCapture(aimVisuals, powerPointer)
	self:StopCapture()

	self._isCapturing = true
	self._aimDirectionValue = 0.5
	self._pointerPosition = 0.5
	self._pointerDirection = 1
	self._activeAimVisuals = aimVisuals
	self._activePowerPointer = powerPointer

	if self._controlFrame then
		self._controlFrame.Visible = true
		self:UpdateControlVisibility(UserInputService:GetLastInputType())
	end

	if self._joystickKnob then
		self._joystickKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
	end
	if self._gamepadJoystickKnob then
		self._gamepadJoystickKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
	end

	-- Track mobile swiping
	self._aimTouchInput = nil
	self._lastTouchX = nil
	self._touchStartPos = nil

	-- Setup input connections for mobile dragging
	local touchBeganConn, touchChangedConn, touchEndedConn

	touchBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end
		if input.UserInputType == Enum.UserInputType.Touch then
			local viewportSize = workspace.CurrentCamera.ViewportSize
			if input.Position.X < viewportSize.X / 2 then
				self._aimTouchInput = input
				self._lastTouchX = input.Position.X
				self._touchStartPos = input.Position
			end
		end
	end)

	touchChangedConn = UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
		if input == self._aimTouchInput then
			local viewportSize = workspace.CurrentCamera.ViewportSize
			local diffX = input.Position.X - self._lastTouchX
			self._lastTouchX = input.Position.X

			local sensitivity = 1.5
			self._aimDirectionValue =
				math.clamp(self._aimDirectionValue + (diffX / (viewportSize.X / 2)) * sensitivity, 0, 1)

			-- Move visual joystick knob based on drag displacement
			local joystickFrame = self._joystickFrame
			local joystickKnob = self._joystickKnob
			if joystickFrame and joystickKnob and self._touchStartPos then
				local totalDrag = input.Position - self._touchStartPos
				local maxKnobOffsetX = math.max((joystickFrame.AbsoluteSize.X - joystickKnob.AbsoluteSize.X) / 2, 30)
				local maxKnobOffsetY = math.max((joystickFrame.AbsoluteSize.Y - joystickKnob.AbsoluteSize.Y) / 2, 30)

				local joystickOffsetX = math.clamp(totalDrag.X, -maxKnobOffsetX, maxKnobOffsetX)
				local joystickOffsetY = math.clamp(totalDrag.Y, -maxKnobOffsetY, maxKnobOffsetY)

				joystickKnob.Position = UDim2.new(0.5, joystickOffsetX, 0.5, joystickOffsetY)
			end
		end
	end)

	touchEndedConn = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		if input == self._aimTouchInput then
			self._aimTouchInput = nil
			self._lastTouchX = nil
			self._touchStartPos = nil

			-- Tween visual joystick knob back to the center
			local joystickKnob = self._joystickKnob
			if joystickKnob then
				local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(joystickKnob, tweenInfo, {
					Position = UDim2.new(0.5, 0, 0.5, 0),
				}):Play()
			end
		end
	end)

	self._touchConnections = { touchBeganConn, touchChangedConn, touchEndedConn }

	-- Start the single loop that updates BOTH the 2D power bar and the 3D aim target
	self._pointerConnection = RunService.RenderStepped:Connect(function(dt)
		if not self._isCapturing then
			return
		end

		-- 1. Automatic sweeping of the 2D power pointer
		self._pointerPosition += self._pointerDirection * POINTER_SPEED * dt

		if self._pointerPosition >= 1 then
			self._pointerPosition = 1
			self._pointerDirection = -1
		elseif self._pointerPosition <= 0 then
			self._pointerPosition = 0
			self._pointerDirection = 1
		end

		if self._activePowerPointer then
			self._activePowerPointer.Position = UDim2.new(self._pointerPosition, 0, 0.5, 0)
		end

		-- 2. Manual steering of the 3D aim target via A and D keys on PC or Gamepad Thumbsticks
		local steerInput = 0

		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			steerInput = -1
		elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
			steerInput = 1
		end

		-- Read gamepad thumbsticks state
		local gamepadSteerX = 0
		local gamepadSteerY = 0
		local success, gamepadState = pcall(function()
			return UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
		end)

		if success and gamepadState then
			for _, state in ipairs(gamepadState) do
				if state.KeyCode == Enum.KeyCode.Thumbstick1 or state.KeyCode == Enum.KeyCode.Thumbstick2 then
					if math.abs(state.Position.X) > 0.1 then -- Deadzone
						gamepadSteerX = state.Position.X
					end
					if state.KeyCode == Enum.KeyCode.Thumbstick1 then
						gamepadSteerY = state.Position.Y
					end
				end
			end
		end

		if math.abs(gamepadSteerX) > 0.1 then
			steerInput = gamepadSteerX
		end

		if math.abs(steerInput) > 0.05 then
			self._aimDirectionValue = math.clamp(self._aimDirectionValue + steerInput * AIM_STEER_SPEED * dt, 0, 1)
		end

		-- Update visual gamepad joystick knob position
		local gamepadJoystickFrame = self._gamepadJoystickFrame
		local gamepadJoystickKnob = self._gamepadJoystickKnob
		if gamepadJoystickFrame and gamepadJoystickKnob then
			local maxKnobOffsetX =
				math.max((gamepadJoystickFrame.AbsoluteSize.X - gamepadJoystickKnob.AbsoluteSize.X) / 2, 30)
			local maxKnobOffsetY =
				math.max((gamepadJoystickFrame.AbsoluteSize.Y - gamepadJoystickKnob.AbsoluteSize.Y) / 2, 30)

			local targetOffsetX = gamepadSteerX * maxKnobOffsetX
			local targetOffsetY = -gamepadSteerY * maxKnobOffsetY -- Invert Y because screen space Y is positive downwards

			gamepadJoystickKnob.Position = UDim2.new(0.5, targetOffsetX, 0.5, targetOffsetY)
		end

		-- 3. Update the 3D aiming visuals with the manual aim direction
		if self._activeAimVisuals then
			self._activeAimVisuals:Update(self._aimDirectionValue, dt)
		end
	end)
end

function InputController:StopCapture()
	self._isCapturing = false
	self._activeAimVisuals = nil
	self._activePowerPointer = nil

	if self._controlFrame then
		self._controlFrame.Visible = false
	end

	if self._pointerConnection then
		self._pointerConnection:Disconnect()
		self._pointerConnection = nil
	end

	if self._touchConnections then
		for _, conn in ipairs(self._touchConnections) do
			if conn then
				conn:Disconnect()
			end
		end
		self._touchConnections = nil
	end

	self._aimTouchInput = nil
	self._lastTouchX = nil
	self._touchStartPos = nil

	-- Return visual joysticks to the center
	local joystickKnob = self._joystickKnob
	if joystickKnob then
		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(joystickKnob, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0),
		}):Play()
	end

	local gamepadJoystickKnob = self._gamepadJoystickKnob
	if gamepadJoystickKnob then
		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(gamepadJoystickKnob, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.5, 0),
		}):Play()
	end

	return self._aimDirectionValue or 0.5, self._pointerPosition or 0.5
end

return InputController
