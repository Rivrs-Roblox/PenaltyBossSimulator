--[=[
   Owner: JustStop__
   Version: 0.0.1
   Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

return function(params: table, hooks)
	setmetatable(params, {
		__index = {
			Text = "",
			Index = 1,
		},
	})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(44, 56, 86),
		BackgroundTransparency = 0.3,
		Size = UDim2.fromScale(0.9, 0.25),
		LayoutOrder = params.Index,
		ZIndex = 2,
	}, {
		Stroke = Roact.createElement("UIStroke", {
			Color = Color3.fromRGB(109, 136, 168),
			Thickness = 2,
		}),

		Corner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),

		Ratio = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 7,
		}),

		UpdateText = Text({
			text = params.Text,
			color = Color3.fromRGB(255, 255, 255),
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(0.95, 0.7),
			stroke = 2,
			strokeColor = Color3.fromRGB(13, 44, 117),
			index = 2,
		}),
	})
end
