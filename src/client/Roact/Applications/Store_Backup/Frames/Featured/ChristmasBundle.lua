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
local ShopButton = require(Components.Shop.ChristmasShopButton)

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
        -- Gradient = Gradient({ startColor = Color3.fromRGB(85, 85, 255), endColor = Color3.fromRGB(255, 170, 255), rotation = 90 }),
        Background = Roact.createElement("ImageLabel", {
            Image = UI.Christmas_Bundle_Background,
            AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1.01, 1.03),
            BackgroundTransparency = 1,
        }),
        Corner = Corner({ radius = 0.1 }),
        Stroke = Stroke({ thick = 3 }),

        Bauble1 = Roact.createElement("ImageLabel", {
            Image = UI.Christmas_Bauble,
            AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.02, 0.9),
            Rotation = 20,
            Size = UDim2.fromScale(0.4, 0.4),
            BackgroundTransparency = 1,
            ZIndex = 2
        }, {
            AspectRatio = AspectRatio({ ratio = 1 })
        }),
        Bauble2 = Roact.createElement("ImageLabel", {
            Image = UI.Christmas_Bauble,
            AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.98, 0.08),
            Rotation = -20,
            Size = UDim2.fromScale(0.35, 0.35),
            BackgroundTransparency = 1,
            ZIndex = 2
        }, {
            AspectRatio = AspectRatio({ ratio = 1 })
        }),
        FirstToolIcon = Image({ image = "rbxassetid://120303300928238", position = UDim2.fromScale(0.487, 0.407), rotation = -15, backgroundTransparency = 1, size = UDim2.fromScale(0.428, 0.65), index = 2, children = { AspectRatio = AspectRatio({ ratio = 1 }) }}),
        SecondToolIcon = Image({ image = "rbxassetid://106170051067144", position = UDim2.fromScale(0.587, 0.41), rotation = 12, backgroundTransparency = 1, size = UDim2.fromScale(0.428, 1), index = 2, children = { AspectRatio = AspectRatio({ ratio = 1 }) }}),
        EggIcon = Image({ image = "rbxassetid://91929631545282", position = UDim2.fromScale(0.535, 0.675), backgroundTransparency = 1, size = UDim2.fromScale(0.428, 0.65), index = 3, children = { AspectRatio = AspectRatio({ ratio = 1 }) }}),
        Name = Text({ text = "Christmas Bundle", position = UDim2.fromScale(0.21, 0.133), size = UDim2.fromScale(0.41, 0.195), backgroundTransparency = 1, color = Color3.fromRGB(255, 255, 255), index = 3, stroke = 2,
                    children = { Gradient({ startColor = Color3.fromRGB(255, 204, 0), endColor = Color3.fromRGB(252, 64, 0), rotation = 90 }) }}),
        Item1 = Text({ text = "Gift Wrapper Skin", position = UDim2.fromScale(0.77, 0.303), size = UDim2.fromScale(0.41, 0.12), backgroundTransparency = 1, color = Color3.fromRGB(255, 255, 255), index = 3, stroke = 1.4, align = Enum.TextXAlignment.Right,}),
        Item2 = Text({ text = "Christmas Aura", position = UDim2.fromScale(0.77, 0.433), size = UDim2.fromScale(0.41, 0.12), backgroundTransparency = 1, color = Color3.fromRGB(255, 255, 255), index = 3, stroke = 1.4, align = Enum.TextXAlignment.Right,}),
        Item3 = Text({ text = "x3 Christmas Egg", position = UDim2.fromScale(0.77, 0.563), size = UDim2.fromScale(0.41, 0.12), backgroundTransparency = 1, color = Color3.fromRGB(255, 255, 255), index = 3, stroke = 1.4, align = Enum.TextXAlignment.Right,}),

        ShopButton({ text = `{Template.Messages.Robux_Icon}{MonetizationController:GetPrice("Christmas Bundle")}`, position = UDim2.fromScale(0.844, 0.825), size = UDim2.fromScale(0.28, 0.294), image = UI.Christmas_Green_Button, buy = "Christmas Bundle", hooks = hooks }),
    })
end