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

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)
local AspectRatio = require(Components.AspectRatio)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")

-- UI
local UI = DataCacheController:GetFile("Images")

local function formatValue(value)
	return if type(value) == "number" then FormatNumber(value) else value
end

-- Row
return function(params: {})
	setmetatable(params, {
		__index = {
			name = "" :: string,
			currentValue = 0,
			nextValue = 0,
			pos = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(1, 0.2),
			layoutOrder = 1,
		}
	})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0.85,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Position = params.pos,
		Size = params.size,
		LayoutOrder = params.layoutOrder,
		ZIndex = 3,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		CurrentIcon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = UI[params.name],
			Position = UDim2.fromScale(0.07, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.9, 0.9),
			ZIndex = 4,
		}, {
			Ratio = AspectRatio({ ratio = 1 }),
		}),

		CurrentText = Text({
			text = formatValue(params.currentValue),
			color = Color3.fromHex("ffffff"),
			position = UDim2.fromScale(0.29, 0.5),
			size = UDim2.fromScale(0.283, 0.6),
			anchorPoint = Vector2.new(0.5, 0.5),
			align = Enum.TextXAlignment.Left,
			stroke = 0,
			strokeColor = Color3.fromHex("15284c"),
			index = 4,
		}),

		Arrow = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://112270660846602",
			ImageTransparency = 0.7,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.6, 0.6),
			ZIndex = 4,
		}, {
			Ratio = AspectRatio({ ratio = 1 }),
		}),

		NextIcon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = UI[params.name],
			Position = UDim2.fromScale(0.604, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.9, 0.9),
			ZIndex = 4,
		}, {
			Ratio = AspectRatio({ ratio = 1 }),
		}),

		NextText = Text({
			text = formatValue(params.nextValue),
			color = Color3.fromHex("ffffff"),
			position = UDim2.fromScale(0.831, 0.5),
			size = UDim2.fromScale(0.283, 0.6),
			anchorPoint = Vector2.new(0.5, 0.5),
			align = Enum.TextXAlignment.Left,
			stroke = 0,
			strokeColor = Color3.fromHex("15284c"),
			index = 4,
		}),
	})
end
