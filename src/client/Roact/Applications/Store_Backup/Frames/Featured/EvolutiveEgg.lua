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

-- Featured
return function(hooks)
    return Roact.createElement("Frame", {
        Position = UDim2.fromScale(0.022, 0.503),
        Size = UDim2.fromScale(1, 0.45),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ClipsDescendants = true,
        LayoutOrder = 2
    }, {
        Gradient = Gradient({ startColor = Color3.fromRGB(85, 85, 255), endColor = Color3.fromRGB(255, 170, 255), rotation = 90 }),
        Corner = Corner({ radius = 0.1 }),
        Stroke = Stroke({ thick = 3 }),

        Background_Icon = Image({ image = UI.Evolutive_Egg, position = UDim2.fromScale(0.142, 0.527), backgroundTransparency = 1, size = UDim2.fromScale(0.428, 1.605), index = 1, children = { AspectRatio = AspectRatio({ ratio = 1 }) }}),
        Name = Text({ text = "Super Heroes Egg", position = UDim2.fromScale(0.20, 0.133), size = UDim2.fromScale(0.41, 0.195), backgroundTransparency = 1, color = Color3.fromRGB(255, 255, 255), index = 3, stroke = 2 }),

        ShopIcon({ icon = UI.Evolutive_1Percent, text = "1%", position = UDim2.fromScale(0.386, 0.3), size = UDim2.fromScale(0.25, 0.351), tooltip = "600" }),
        ShopIcon({ icon = UI.Evolutive_5Percent, text = "4%", position = UDim2.fromScale(0.515, 0.3), size = UDim2.fromScale(0.25, 0.351), tooltip ="420"}),
        ShopIcon({ icon = UI.Evolutive_15Percent, text = "15%", position = UDim2.fromScale(0.65, 0.3), size = UDim2.fromScale(0.25, 0.351), tooltip ="175"}),
        ShopIcon({ icon = UI.Evolutive_30Percent, text = "30%", position = UDim2.fromScale(0.784, 0.3), size = UDim2.fromScale(0.25, 0.351), tooltip ="93"}),
        ShopIcon({ icon = UI.Evolutive_50Percent, text = "50%", position = UDim2.fromScale(0.908, 0.3), size = UDim2.fromScale(0.25, 0.351), tooltip ="49"}),

        ShopButton({ text = `x1 - {Template.Messages.Robux_Icon}{MonetizationController:GetPrice("x1 Super Heroes Egg")}`, position = UDim2.fromScale(0.26, 0.785), size = UDim2.fromScale(0.28, 0.294), image = UI.Yellow_Button, buy = "x1 Super Heroes Egg", hooks = hooks }),
        ShopButton({ text = `x3 - {Template.Messages.Robux_Icon}{MonetizationController:GetPrice("x3 Super Heroes Egg")}`, position = UDim2.fromScale(0.554, 0.785), size = UDim2.fromScale(0.28, 0.294), image = UI.Blue_Button, buy = "x3 Super Heroes Egg", hooks = hooks }),
        ShopButton({ text = `x8 - {Template.Messages.Robux_Icon}{MonetizationController:GetPrice("x8 Super Heroes Egg")}`, position = UDim2.fromScale(0.844, 0.785), size = UDim2.fromScale(0.28, 0.294), color = Color3.fromRGB(111, 255, 0), buy = "x8 Super Heroes Egg", hooks = hooks }),
    })
end