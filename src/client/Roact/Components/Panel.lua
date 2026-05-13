local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Roact = require(ReplicatedStorage.Packages.roact)

local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local NotificationNoText = require(Components.NotificationNoText)
local Text = require(Components.Text)

local function Panel(props)
	setmetatable(props, {
		__index = {
			text = "Panel",
			icon = "rbxassetid://128581496441850",
			isActive = false,
			order = 1,
			action = function() end,
			notificationNumber = 0,
			size = UDim2.fromScale(0.325, 1),
			textSize = UDim2.fromScale(0.35, 0.5),
		},
	})

	local bgColor = props.isActive and Color3.fromHex("ff6734") or Color3.fromHex("3b65a3")

	return Roact.createElement("ImageButton", {
		LayoutOrder = props.order,
		Size = props.size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = bgColor,
		ZIndex = 2,
		[Roact.Event.MouseButton1Click] = props.action,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Notification = NotificationNoText({
			number = props.notificationNumber,
			size = UDim2.fromScale(0.5, 0.5),
			position = UDim2.fromScale(0.97, 0.1),
		}),
		Center = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				VerticalAlignment = 0,
				SortOrder = 2,
				HorizontalAlignment = 0,
				Padding = UDim.new(0.05, 0),
				FillDirection = 0,
			}),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = 3,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.37),
				ZIndex = 2,
				Image = props.icon,
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.8, 0.8),
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
			Text = Text({
				order = 2,
				text = props.text,
				size = props.textSize,
				position = UDim2.fromScale(0.5, 0.96),
				color = Color3.fromHex("fafafa"),
				index = 5,
			}),
		}),
	})
end

return Panel
