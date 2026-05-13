local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)

local Knit = require(ReplicatedStorage.Packages.Knit)
local ExitGiftController = Knit.GetController("ExitGiftController")

function ExitGift(_, hooks)
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 1.35),
		LayoutOrder = 1,
		ZIndex = 50,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.7),
	}, {
		Star = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://106335669168445",
			BackgroundTransparency = 1,
			ImageTransparency = 0.1,
			ZIndex = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1.1, 1.1),
		}, {
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ffff00")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("ffc800")),
				}),
			}),
		}),

		Sparkle = Roact.createElement("ImageLabel", {
			ScaleType = Enum.ScaleType.Stretch,
			BorderColor3 = Color3.fromHex("000000"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://106466414055348",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ZIndex = 3,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),

		Close = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.95, 0.2),
			ZIndex = 100,
			Size = UDim2.fromScale(0.12, 0.12),
			BackgroundColor3 = Color3.fromHex("ffffff"),

			[Roact.Event.MouseButton1Click] = function()
				ExitGiftController:HideFrame()
			end,
		}, {
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ff362f")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("8d1414")),
				}),
				Rotation = 90,
			}),

			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),

			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("8f0000"),
				Thickness = 3,
			}),

			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Stretch,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 101,
				Image = "rbxassetid://120045489184571",
				Size = UDim2.fromScale(0.5, 0.5),
			}),

			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),

		Label = Roact.createElement("TextLabel", {
			TextWrapped = true,
			TextColor3 = Color3.fromHex("ffffff"),
			Text = "Open your FREE Gift!",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Font = Enum.Font.FredokaOne,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.744),
			TextSize = 17,
			ZIndex = 6,
			TextScaled = true,
			Size = UDim2.fromScale(0.85, 0.15),
		}, {
			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 4,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("59ff00")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("00360d")),
					}),
					Rotation = 90,
				}),
			}),
		}),

		Claim = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(0.5, 0.15),
			Position = UDim2.fromScale(0.5, 0.9),
			BorderColor3 = Color3.fromHex("000000"),
			Visible = false,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHex("e5ff00"),
			ZIndex = 10,
		}, {
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0.3, 0),
			}),

			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("245d00"),
				Thickness = 8,
			}),

			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("27d400")),
				}),
				Rotation = 90,
			}),

			Label = Roact.createElement("TextLabel", {
				TextWrapped = true,
				TextColor3 = Color3.fromHex("ffffff"),
				BorderColor3 = Color3.fromHex("000000"),
				Text = "CLAIM",
				Size = UDim2.fromScale(0.9, 0.9),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Font = Enum.Font.FredokaOne,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				TextScaled = true,
				TextSize = 14,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 11,
			}, {
				Stroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("245d00"),
					Thickness = 3,
				}),
			}),
		}),

		Gift = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://135619375841555",
			BackgroundTransparency = 1,
			ImageTransparency = 0.1,
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(0.7, 0.7),
			ZIndex = 4,
		}),

		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {}),
	})
end

ExitGift = RoactHooks.new(Roact)(ExitGift)
return ExitGift