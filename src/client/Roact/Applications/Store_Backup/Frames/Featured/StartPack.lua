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
local Gradient = require(Components.Gradient)
local Corner = require(Components.Corner)
local Stroke = require(Components.Stroke)
local Text = require(Components.Text)
local Image = require(Components.Image)
local AspectRatio = require(Components.AspectRatio)
local ShopIcon = require(Components.Shop.ShopIcon)
local ShopButton = require(Components.Shop.ShopButton)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local MonetizationController = Knit.GetController("MonetizationController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")
local Colors = DataCacheController:GetFile("Colors")

-- Featured
return function(hooks)
	return Roact.createElement("Frame", {
		Position = UDim2.fromScale(0.022, 0.104),
		Size = UDim2.fromScale(1, 0.45),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ClipsDescendants = true,
		LayoutOrder = 1,
	}, {
		Gradient = Gradient({
			startColor = Colors.Gradients.Yellow.startColor,
			endColor = Colors.Gradients.Yellow.endColor,
			rotation = 90,
		}),
		Corner = Corner({ radius = 0.1 }),
		Stroke = Stroke({ thick = 3 }),

		Background_Icon = Image({
			image = UI.Starter_Pack,
			transparency = 0.7,
			position = UDim2.fromScale(0.142, 0.527),
			backgroundTransparency = 1,
			size = UDim2.fromScale(0.528, 1.705),
			index = 1,
			children = { AspectRatio = AspectRatio({ ratio = 1 }) },
		}),
		Name = Text({
			text = "Starter Bundle",
			position = UDim2.fromScale(0.23, 0.133),
			size = UDim2.fromScale(0.41, 0.215),
			backgroundTransparency = 1,
			color = Color3.fromRGB(255, 255, 255),
			index = 3,
			stroke = 2,
		}),
		Expiration = Text({
			text = "Expires Soon",
			position = UDim2.fromScale(0.165, 0.342),
			size = UDim2.fromScale(0.279, 0.215),
			backgroundTransparency = 1,
			color = Color3.fromRGB(85, 255, 0),
			index = 3,
			stroke = 2,
		}),
		Discount = Text({
			text = "50% OFF",
			position = UDim2.fromScale(0.85, 0.136),
			size = UDim2.fromScale(0.2, 0.215),
			backgroundTransparency = 1,
			color = Color3.fromRGB(255, 255, 255),
			index = 3,
			stroke = 2,
		}),

		--ShopIcon({ icon = UI.Money1, text = "x250", position = UDim2.fromScale(0.086, 0.712), size = UDim2.fromScale(0.125, 0.441) }),
		ShopIcon({
			icon = UI.Money2,
			text = "x500",
			position = UDim2.fromScale(0.215, 0.7),
			size = UDim2.fromScale(0.125, 0.441),
		}),
		ShopIcon({
			icon = UI.Wins,
			text = "x100",
			position = UDim2.fromScale(0.35, 0.712),
			size = UDim2.fromScale(0.125, 0.441),
		}),
		ShopIcon({
			icon = UI.Unicorn,
			text = "x1",
			topText = "x5k",
			position = UDim2.fromScale(0.484, 0.712),
			size = UDim2.fromScale(0.125, 0.441),
		}),
		ShopIcon({
			icon = UI.Rebirth,
			text = "x2",
			position = UDim2.fromScale(0.608, 0.692),
			size = UDim2.fromScale(0.15, 0.441),
		}),

		--Price = Text({ text = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice("Starter Bundle")}`, position = UDim2.fromScale(0.87, 0.35), size = UDim2.fromScale(0.15, 0.215), backgroundTransparency = 1, color = Color3.fromRGB(255, 255, 255), index = 3, stroke = 2 }),

		ShopButton({
			text = "",
			position = UDim2.fromScale(0.844, 0.785),
			size = UDim2.fromScale(0.28, 0.294),
			color = Color3.fromRGB(111, 255, 0),
			buy = "Starter Bundle",
			hooks = hooks,
			children = Text({
				text = `{Template.Messages.Robux_Icon} 100`, -- {MonetizationController:GetPrice("Starter Bundle")}
				position = UDim2.fromScale(0.5, 0.5),
				size = UDim2.fromScale(0.33, 0.33),
				backgroundTransparency = 1,
				color = Color3.fromRGB(255, 255, 255),
				textScaled = false,
				textSize = 18,
				index = 3,
				stroke = 2,
			}),
		}),
	})
end
