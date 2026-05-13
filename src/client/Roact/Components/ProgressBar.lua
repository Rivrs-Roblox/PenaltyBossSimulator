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
local Corner = require(Components.Corner)
local Stroke = require(Components.Stroke)
local Gradient = require(Components.Gradient)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")

-- UI
local Colors = DataCacheController:GetFile("Colors")

return function(params: {})
	setmetatable(params, {
		__index = {
			text = "" :: string,
			current = 0 :: number,
			total = 100 :: number,

			gradientColor = "Yellow",
			backgroundTransparency = 1,

			pos = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(0.5, 0.5),
			index = 1,
		},
	})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = params.backgroundTransparency,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Position = params.pos,
		Size = params.size,
		ZIndex = params.index,
	}, {
		Corner = Corner({ radius = 0.25 }),
		Stroke = Stroke({ thick = 3 }),
		Progress = Text({
			text = if params.text == ""
				then FormatNumber(params.current) .. "/" .. FormatNumber(params.total) .. " (" .. tostring(
					math.min(math.floor(((params.current / params.total) * 100)), 100)
				) .. "%)"
				elseif params.text ~= "nil" then params.text .. " (" .. tostring(
					math.min(math.floor(((params.current / params.total) * 100)), 100)
				) .. "%)"
				else "",
			color = Color3.fromRGB(255, 255, 255),
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(0.83, 0.718),
			backgroundTransparency = 1,
			stroke = 2,
			index = 2,
		}),

		Bar = Roact.createElement("Frame", {
			Size = UDim2.fromScale(math.min(params.current / params.total, 1), 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			ZIndex = 1,
		}, {
			Gradient = Gradient({
				startColor = Colors.Gradients[params.gradientColor].startColor,
				endColor = Colors.Gradients[params.gradientColor].endColor,
				rotation = 90,
			}),
			Corner = Corner({ radius = 0.25 }),
		}),
	})
end
