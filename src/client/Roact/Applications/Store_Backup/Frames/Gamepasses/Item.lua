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
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local Gradient = require(Components.Gradient)
local Corner = require(Components.Corner)
local Stroke = require(Components.Stroke)
local Text = require(Components.Text)
local Image = require(Components.Image)
local AspectRatio = require(Components.AspectRatio)
local ShopButton = require(Components.Shop.ShopButton)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local MonetizationController = Knit.GetController("MonetizationController")

-- UI
local Template = DataCacheController:GetFile("Template")
local UI = DataCacheController:GetFile("Images")
local Colors = DataCacheController:GetFile("Colors")

-- Featured
return function(params: table, order: number, has: boolean, hooks)
	setmetatable(params, {
		__index = {
			Name = "" :: string,
			Description = "" :: string,
			Icon = "" :: string,
			Gradient = "" :: string,
			Price = 0 :: number,
		},
	})
	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			rotation = 0,
			config = { mass = 10, tension = 100, friction = 50 },
		}
	end)

	return Roact.createElement("Frame", {
		Position = UDim2.fromScale(0.022, 0.104),
		Size = UDim2.fromScale(1, 0.45),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ClipsDescendants = true,
		LayoutOrder = order,
		[Roact.Event.MouseEnter] = function()
			-- api.start({
			-- 	rotation = 1000
			-- })
        end,
		[Roact.Event.MouseLeave] = function()
            api.stop({
				rotation = 0
			})
        end,
	}, {
		Gradient = Gradient({
			startColor = Colors.Gradients[params.Gradient].startColor,
			endColor = Colors.Gradients[params.Gradient].endColor,
			rotation = 90,
		}),
		Corner = Corner({ radius = 0.1 }),
		Stroke = Stroke({ thick = 3 }),

		Icon = Image({
			image = UI[params.Icon],
			position = UDim2.fromScale(0.156, 0.593),
			backgroundTransparency = 1,
			size = UDim2.fromScale(0.541, 0.774),
			index = 1,
			children = { AspectRatio = AspectRatio({ ratio = 1 }) },
			rotation =  styles.rotation,
		}),
		Name = Text({
			text = params.Name,
			position = UDim2.fromScale(0.502, 0.098),
			size = UDim2.fromScale(0.963, 0.148),
			backgroundTransparency = 1,
			color = Color3.fromRGB(255, 255, 255),
			index = 3,
			stroke = 2,
		}),
		Description = Text({
			text = params.Description,
			position = UDim2.fromScale(0.504, 0.341),
			size = UDim2.fromScale(0.931, 0.244),
			backgroundTransparency = 1,
			color = Color3.fromRGB(255, 255, 255),
			index = 3,
			stroke = 2,
		}),

		--Price = Text({ text = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(params.Name)}`, position = UDim2.fromScale(0.83, 0.58), size = UDim2.fromScale(0.23, 0.23), backgroundTransparency = 1, color = Color3.fromRGB(255, 255, 255), textScaled = false, textSize = 14, index = 3, stroke = 2 }),
		ShopButton({
			text = "",
			position = UDim2.fromScale(0.698, 0.812),
			size = UDim2.fromScale(0.537, 0.294),
			color = Color3.fromRGB(111, 255, 0),
			buy = params.Name,
			disabled = has,
			hooks = hooks,
			children = Text({
				text = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(params.Name)}`,
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

		Bought = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0.4,
			BackgroundColor3 = Color3.fromRGB(0, 255, 0),
			Visible = has,
			ZIndex = 10,
		}, {
			Corner = Corner({ radius = 0.1 }),
			BoughtText = Text({
				text = "Bought!",
				color = Color3.fromRGB(255, 255, 255),
				position = UDim2.fromScale(0.5, 0.5),
				size = UDim2.fromScale(0.7, 0.3),
				backgroundTransparency = 1,
				stroke = 3,
				index = 11,
			}),
		}),
	})
end
