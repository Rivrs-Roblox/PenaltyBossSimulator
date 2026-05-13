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
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)
local Size = require(Helpers.Size)

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

-- Reward
return function(params)
	setmetatable(params, {
		__index = {
			title = "" :: string,
			icon = "" :: string,
			price = 0 :: number,
			order = 0 :: number,
			hooks = nil :: any,
		},
	})

	local styles, api = RoactSpring.useSpring(params.hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		LayoutOrder = params.order,
		Size = UDim2.fromScale(0.3, 1),
		ZIndex = 4,
	}, {
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("37b9ff")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("1e6bb4")),
			}),
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 0.5),
			}),
		}),
		UICorner = Roact.createElement("UICorner", {}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("2baaff"),
			Thickness = 3,
		}),

		ValueText = Text({
			text = params.title,
			color = Color3.fromHex("ffffff"),
			position = UDim2.fromScale(0.5, 0.1),
			size = UDim2.fromScale(0.9, 0.17),
			stroke = 1.3,
			strokeColor = Color3.fromHex("15284c"),
			index = 5,
		}),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = params.icon,
			Position = UDim2.fromScale(0.5, 0.47),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.462, 0.528),
			ZIndex = 5,
		}, {
			Ratio = AspectRatio({ ratio = 1 }),
		}),

		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("3b8c13"),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.496, 0.88),
			Size = Size(styles, { X = 0.614, Y = 0.196 }),
			ZIndex = 6,
			AutoButtonColor = true,

			[Roact.Event.MouseButton1Click] = function()
				Sound:PlaySound("UI_Click")
				FriendsController:BuyReward(params.order)
			end,

			[Roact.Event.MouseEnter] = function()
				api.start({ sizeAlpha = 1.1 })
			end,

			[Roact.Event.MouseLeave] = function()
				api.start({ sizeAlpha = 1 })
			end,

			[Roact.Event.MouseButton1Down] = function()
				api.start({ sizeAlpha = 0.8 })
			end,

			[Roact.Event.MouseButton1Up] = function()
				api.start({ sizeAlpha = 1 })
			end,
		}, {
			List = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.02, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			UICorner = Roact.createElement("UICorner", {}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("25d931"),
				Thickness = 2,
			}),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = UI.Stars,
				LayoutOrder = 1,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.85, 0.85),
				ZIndex = 7,
			}, {
				Ratio = AspectRatio({ ratio = 1 }),
			}),
			PriceText = Text({
				text = FormatNumber(params.price),
				color = Color3.fromHex("ffffff"),
				size = UDim2.fromScale(0.588, 0.8),
				stroke = 2,
				strokeColor = Color3.fromHex("0e5513"),
				index = 7,
				order = 2,
			}),
		}),
	})
end
