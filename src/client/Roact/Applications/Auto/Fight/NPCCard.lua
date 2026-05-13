--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.UIActions)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Image = require(Components.Image)
local Text = require(Components.Text)

-- UI
local UI = DataCacheController:GetFile("Images")

return function(params: table)
    setmetatable(params, {
        __index = {
            name = "Nerd" :: string,
            color = Color3.fromRGB(0, 0, 0) :: Color3,
            image = "Player",
            order = 1,
        }})

    return Roact.createElement("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = UI.Vertical_Background,
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        LayoutOrder = params.order
    }, {
        NPCIcon = Image({ image = UI[params.image], color = Color3.fromRGB(255, 255, 255), position = UDim2.fromScale(0.5, 0.25), size = UDim2.fromScale(0.7, 0.43), backgroundTransparency = 1 }),
        NPCName = Text({ text = params.name, color = params.color, position = UDim2.fromScale(0.5, 0.6), size = UDim2.fromScale(0.7, 0.15), backgroundTransparency = 1, stroke = 2 }),
        
        FightButton = Roact.createElement("ImageButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.8),
            Size = UDim2.fromScale(0.8, 0.2),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(111, 255, 0),
            Image = UI.Button,
            ZIndex = 2,

            [Roact.Event.MouseButton1Click] = function()
                UIController:HideFrame()
            end
        }, {
            FightText = Text({ text = "Fight", position = UDim2.fromScale(0.5, 0.45), size = UDim2.fromScale(0.7, 0.7), color = Color3.fromRGB(255, 255, 255), backgroundTransparency = 1, stroke = 1.5, index = 3 })
        })
    })
end