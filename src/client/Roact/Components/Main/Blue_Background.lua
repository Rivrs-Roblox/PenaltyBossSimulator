--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local CloseButton = require(Components.CloseButton)
local AspectRatio = require(Components.AspectRatio)
local Title = require(Components.Main.Title)
local Text = require(Components.Text)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")
local UI = DataCacheController:GetFile("Images")

return function(params: table, children)
	setmetatable(params, {
		__index = {
			title = "" :: string,
			titleIcon = "" :: string,
			condition = false :: boolean,
			size = UDim2.fromScale(0.5, 0.5),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.2,
			align = Enum.TextXAlignment.Center,
			action = function()
				UIController:HideFrame()
			end,
		},
	})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Position = params.pos,
		ZIndex = 1,
		Size = params.size,
		Visible = params.condition,
	}, {
		Children = Roact.createFragment(children),
		Title = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.04, 0.08),
			Size = UDim2.fromScale(0.55, 0.09),
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				VerticalAlignment = 0,
				FillDirection = 0,
				Padding = UDim.new(0.02, 0),
				SortOrder = 2,
			}),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = 3,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.37),
				ZIndex = 2,
				LayoutOrder = 1,
				Image = params.titleIcon,
				Size = UDim2.fromScale(1.2, 1.2),
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
			Text = Text({
				index = 2,
				order = 2,
				text = params.title,
				align = Enum.TextXAlignment.Left,
				size = UDim2.fromScale(0.8, 1),
				anchorPoint = Vector2.new(0.5, 1),
				position = UDim2.fromScale(0.549, 1),
				color = Color3.fromHex("ffffff"),
				strokeColor = Color3.fromHex('143758'),
				stroke = 2,
			}),
		}),
		Close = CloseButton(params.action, params.hooks, { pos = UDim2.fromScale(0.94, 0.08) }),
		Ratio = AspectRatio({ ratio = params.ratio }),
		UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 2) }),
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("cee6e8")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("a0b2b4")),
			}),
			Rotation = 90,
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromRGB(20, 55, 88),
			Thickness = 2,
		}),
	})
end
