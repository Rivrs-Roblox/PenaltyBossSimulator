--[=[
    Volume Slider Component
    Visual follows Applications/newSettings, functionality remains from Applications/Settings
]=]

-- Game services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

local activeSliderOwner = nil

local function makeToggleButton(params)
	local enabled = params.enabled == true
	local zIndex = params.zIndexBase or 5

	local strokeColor = if enabled then Color3.fromHex("26cf13") else Color3.fromHex("8f0000")
	local gradientA = if enabled then Color3.fromHex("1dd42c") else Color3.fromHex("ff362f")
	local gradientB = if enabled then Color3.fromHex("21681e") else Color3.fromHex("8d1414")
	local text = if enabled then "On" else "Off"

	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.9, 0.5),
		Size = UDim2.fromScale(0.15, 0.6),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		AutoButtonColor = true,
		LayoutOrder = 3,
		ZIndex = zIndex,
		[Roact.Event.MouseButton1Click] = params.onActivated,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		UIStroke = Roact.createElement("UIStroke", {
			Color = strokeColor,
			Thickness = 2,
		}),

		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, gradientA),
				ColorSequenceKeypoint.new(1, gradientB),
			}),
			Rotation = 90,
		}),

		ButtonText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.85, 0.55),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = Color3.fromHex("fafafa"),
			TextScaled = true,
			TextWrapped = true,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			ZIndex = zIndex + 1,
		}),
	})
end

return function(params: {})
	setmetatable(params, {
		__index = {
			Name = "" :: string,
			Icon = "rbxassetid://126045313881885" :: string,
			Value = 100 :: number,
			OnChange = function(value) end,
			Enabled = nil,
			OnToggle = function(enabled) end,
			hooks = nil,
			Order = 0 :: number,
			ZIndexBase = 3 :: number,
		},
	})

	local hooks = params.hooks
	local useState = hooks.useState
	local useEffect = hooks.useEffect

	local startValue = math.clamp(params.Value or 0, 0, 100)
	local startEnabled = if params.Enabled ~= nil then params.Enabled else startValue > 0

	local _, setIsDragging = useState(false)
	local currentValue, setCurrentValue = useState(startValue)
	local isEnabled, setIsEnabled = useState(startEnabled)
	local activeInputRef = hooks.useValue(nil)
	local activeSliderFrameRef = hooks.useValue(nil)
	local isMouseDraggingRef = hooks.useValue(false)
	local isEnabledRef = hooks.useValue(isEnabled)
	local onChangeRef = hooks.useValue(params.OnChange)
	local sliderOwnerRef = hooks.useValue({})

	isEnabledRef.value = isEnabled
	onChangeRef.value = params.OnChange

	useEffect(function()
		local newValue = math.clamp(params.Value or 0, 0, 100)
		setCurrentValue(newValue)
		setIsEnabled(if params.Enabled ~= nil then params.Enabled else newValue > 0)
	end, { params.Value, params.Enabled })

	local function updateValue(input, frame)
		if not isEnabledRef.value then
			return
		end

		local inputX = input.Position.X - frame.AbsolutePosition.X
		local relativeX = math.clamp(inputX / frame.AbsoluteSize.X, 0, 1)
		local newValue = math.floor(relativeX * 100 + 0.5)

		setCurrentValue(newValue)
		onChangeRef.value(newValue)
	end

	local function stopDragging()
		if activeSliderOwner == sliderOwnerRef.value then
			activeSliderOwner = nil
		end

		activeInputRef.value = nil
		activeSliderFrameRef.value = nil
		isMouseDraggingRef.value = false
		setIsDragging(false)
	end

	local progress = math.clamp((currentValue or 0) / 100, 0, 1)
	local zIndex = params.ZIndexBase
	local touchTargetHeight = if UserInputService.TouchEnabled then 0.92 else 0.42
	local sliderInputEvents = {
		[Roact.Event.InputBegan] = function(obj, input)
			if not isEnabledRef.value then
				return
			end

			if activeSliderOwner ~= nil and activeSliderOwner ~= sliderOwnerRef.value then
				return
			end

			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				activeSliderOwner = sliderOwnerRef.value
				activeInputRef.value = input
				activeSliderFrameRef.value = obj
				isMouseDraggingRef.value = input.UserInputType == Enum.UserInputType.MouseButton1
				setIsDragging(true)
				updateValue(input, obj)
			end
		end,
	}
	local function withSliderInputEvents(props)
		for event, handler in pairs(sliderInputEvents) do
			props[event] = handler
		end

		return props
	end

	useEffect(function()
		local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			local sliderFrame = activeSliderFrameRef.value
			if sliderFrame == nil then
				return
			end

			if input == activeInputRef.value or (isMouseDraggingRef.value and input.UserInputType == Enum.UserInputType.MouseMovement) then
				updateValue(input, sliderFrame)
			end
		end)

		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			local sliderFrame = activeSliderFrameRef.value
			if sliderFrame == nil then
				return
			end

			if input == activeInputRef.value or (isMouseDraggingRef.value and input.UserInputType == Enum.UserInputType.MouseButton1) then
				updateValue(input, sliderFrame)
				stopDragging()
			end
		end)

		return function()
			if activeSliderOwner == sliderOwnerRef.value then
				activeSliderOwner = nil
			end

			inputChangedConnection:Disconnect()
			inputEndedConnection:Disconnect()
		end
	end, {})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 0.17),
		BackgroundColor3 = Color3.fromHex("000000"),
		BackgroundTransparency = 0.5,
		LayoutOrder = params.Order,
		ZIndex = zIndex,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 2),
		}),

		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("143758"),
			Thickness = 1.5,
		}),

		Main = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.04, 0.338),
			Size = UDim2.fromScale(0.7, 0.35),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = zIndex + 1,
		}, {
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = params.Icon,
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = zIndex + 1,
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),

			NameText = Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.104, 0.5),
				Size = UDim2.fromScale(0.673, 1),
				BackgroundTransparency = 1,
				Text = params.Name,
				TextColor3 = Color3.fromHex("fafafa"),
				TextScaled = true,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				ZIndex = zIndex + 2,
			}),

			PercentageText = Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(0.999, 0.5),
				Size = UDim2.fromScale(0.211, 0.75),
				BackgroundTransparency = 1,
				Text = tostring(currentValue) .. "%",
				TextColor3 = Color3.fromHex("fafafa"),
				TextScaled = true,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				ZIndex = zIndex + 2,
			}),
		}),

		ProgressBar = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.04, 0.68),
			Size = UDim2.fromScale(0.7, 0.2),
			BackgroundColor3 = Color3.fromHex("000000"),
			BackgroundTransparency = if isEnabled then 0.5 else 0.75,
			ZIndex = zIndex + 1,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),

			Bar = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(progress, 1),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BackgroundTransparency = if isEnabled then 0 else 0.45,
				ZIndex = zIndex + 2,
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}),

				Gradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("5adde9")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("306be9")),
					}),
					Rotation = 90,
				}),
			}),

			Knob = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(progress, 0.5),
				Size = UDim2.fromScale(0.08, 1.3),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BackgroundTransparency = if isEnabled then 0 else 0.45,
				ZIndex = zIndex + 3,
			}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),

				Ratio = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 0.6,
				}),
			}),
		}),

		TouchTarget = Roact.createElement("ImageButton", withSliderInputEvents({
			-- Larger transparent hitbox keeps the slider easy to drag on mobile.
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.04, 0.68),
			Size = UDim2.fromScale(0.7, touchTargetHeight),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ImageTransparency = 1,
			AutoButtonColor = false,
			Active = true,
			ZIndex = zIndex + 4,
		})),

		Toggle = makeToggleButton({
			enabled = isEnabled,
			onActivated = function()
				local newEnabled = not isEnabled
				setIsEnabled(newEnabled)
				params.OnToggle(newEnabled)
			end,
			zIndexBase = zIndex + 2,
		}),
	})
end
