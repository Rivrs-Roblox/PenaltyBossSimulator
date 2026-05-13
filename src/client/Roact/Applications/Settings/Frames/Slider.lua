--[=[
    Volume Slider Component
    Visual follows Applications/newSettings, functionality remains from Applications/Settings
]=]

-- Game services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

local function makeToggleButton(params)
	local enabled = params.enabled == true

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
		ZIndex = 5,
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
			ZIndex = 6,
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
		},
	})

	local hooks = params.hooks
	local useState = hooks.useState
	local useEffect = hooks.useEffect

	local startValue = math.clamp(params.Value or 0, 0, 100)
	local startEnabled = if params.Enabled ~= nil then params.Enabled else startValue > 0

	local isDragging, setIsDragging = useState(false)
	local currentValue, setCurrentValue = useState(startValue)
	local isEnabled, setIsEnabled = useState(startEnabled)

	useEffect(function()
		local newValue = math.clamp(params.Value or 0, 0, 100)
		setCurrentValue(newValue)
		setIsEnabled(if params.Enabled ~= nil then params.Enabled else newValue > 0)
	end, { params.Value, params.Enabled })

	local function updateValue(input, frame)
		if not isEnabled then
			return
		end

		local inputX = input.Position.X - frame.AbsolutePosition.X
		local relativeX = math.clamp(inputX / frame.AbsoluteSize.X, 0, 1)
		local newValue = math.floor(relativeX * 100 + 0.5)

		setCurrentValue(newValue)
		params.OnChange(newValue)
	end

	local progress = math.clamp((currentValue or 0) / 100, 0, 1)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 0.17),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BackgroundTransparency = 0.85,
		LayoutOrder = params.Order,
		ZIndex = 3,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),

		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("848484"),
			Thickness = 1.5,
		}),

		Main = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.04, 0.338),
			Size = UDim2.fromScale(0.7, 0.35),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 4,
		}, {
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = params.Icon,
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = 4,
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
				ZIndex = 5,
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
				ZIndex = 5,
			}),
		}),

		ProgressBar = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.04, 0.68),
			Size = UDim2.fromScale(0.7, 0.2),
			BackgroundColor3 = Color3.fromHex("000000"),
			BackgroundTransparency = if isEnabled then 0.5 else 0.75,
			ZIndex = 4,
			[Roact.Event.InputBegan] = function(obj, input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					setIsDragging(true)
					updateValue(input, obj)
				end
			end,
			[Roact.Event.InputChanged] = function(obj, input)
				if
					isDragging
					and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					)
				then
					updateValue(input, obj)
				end
			end,
			[Roact.Event.InputEnded] = function(_, input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					setIsDragging(false)
				end
			end,
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
				ZIndex = 5,
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
				ZIndex = 6,
			}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),

				Ratio = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 0.6,
				}),
			}),
		}),

		Toggle = makeToggleButton({
			enabled = isEnabled,
			onActivated = function()
				local newEnabled = not isEnabled
				setIsEnabled(newEnabled)
				params.OnToggle(newEnabled)
			end,
		}),
	})
end
