--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)
local AspectRatio = require(Components.AspectRatio)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local FriendsController = Knit.GetController("FriendsController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

local function RewardSmall()
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, -0.2),
		Size = UDim2.fromScale(1, 1.2),
		ZIndex = 7,
	}, {
		List = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		NumberText = Text({
			text = "+1",
			color = Color3.fromHex("ffffff"),
			size = UDim2.fromScale(0.35, 0.8),
			align = Enum.TextXAlignment.Right,
			stroke = 1.5,
			strokeColor = Color3.fromHex("15284c"),
			index = 8,
			order = 1,
		}),
		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = UI.Stars,
			LayoutOrder = 2,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 8,
		}, {
			Ratio = AspectRatio({ ratio = 1 }),
		}),
	})
end

-- Friend
return function(params)
	setmetatable(params, {
		__index = {
			id = 2 :: number,
			name = "" :: string,
			icon = UI.Player :: string,
			online = false :: boolean,
			hooks = nil,
			order = 2,
		},
	})

	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		LayoutOrder = params.order,
		Size = UDim2.fromScale(1, 0.45),
		ZIndex = 4,
	}, {
		UICorner = Roact.createElement("UICorner", {}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("939393"),
			Thickness = 2,
		}),
		Ratio = AspectRatio({ ratio = 4 }),

		Icon = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			Position = UDim2.fromScale(0.12, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
			ZIndex = 5,
		}, {
			Ratio = AspectRatio({ ratio = 1 }),
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Profile = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = params.icon,
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.9, 0.9),
				ZIndex = 6,
			}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
				Ratio = AspectRatio({ ratio = 1 }),
			}),
		}),

		StatusText = Text({
			text = if params.online == false then "Offline" else "Online",
			color = Color3.fromHex("ffffff"),
			position = UDim2.fromScale(0.25, 0.374),
			size = UDim2.fromScale(0.45, 0.22),
			anchorPoint = Vector2.new(0, 0.5),
			align = Enum.TextXAlignment.Left,
			stroke = 1.5,
			strokeColor = if params.online == false then Color3.fromHex("ff0017") else Color3.fromHex("009f0d"),
			index = 5,
		}),

		NameText = Text({
			text = params.name,
			color = Color3.fromHex("ffffff"),
			position = UDim2.fromScale(0.25, 0.624),
			size = UDim2.fromScale(0.45, 0.22),
			anchorPoint = Vector2.new(0, 0.5),
			align = Enum.TextXAlignment.Left,
			stroke = 1.2,
			strokeColor = Color3.fromHex("15284c"),
			index = 5,
		}),

		Invite = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("3b8c13"),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.848, 0.611),
			Size = UDim2.fromScale(0.252, 0.246),
			ZIndex = 6,
			AutoButtonColor = true,

			[Roact.Event.MouseButton1Click] = function()
				Sound:PlaySound("UI_Click")
				FriendsController:InviteFriend(params.id)
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("25d931"),
				Thickness = 2,
			}),
			Rewards = RewardSmall(),
			ButtonText = Text({
				text = "Invite",
				color = Color3.fromHex("ffffff"),
				position = UDim2.fromScale(0.5, 0.5),
				size = UDim2.fromScale(0.8, 0.85),
				stroke = 2,
				strokeColor = Color3.fromHex("0e5513"),
				index = 7,
			}),
		}),
	})
end
