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
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.UIActions)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Corner = require(Components.Corner)
local TextButton = require(Components.TextButton)
local Gradient = require(Components.Gradient)
local Text = require(Components.Text)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")

-- UI
local UI = DataCacheController:GetFile("Images")

return function(params: table)
    setmetatable(params, { __index = { count = 0 :: number, max = 0 :: number, pos = UDim2.fromScale(0.668, 0.937) }})

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = params.pos,
        Size = UDim2.fromScale(0.184, 0.1),
    }, {
        Corner = Corner({ radius = 2 }),

        Amout = Text({ text = `{params.count}/{params.max}`, backgroundTransparency = 1, color = Color3.fromRGB(255, 255, 255), stroke = 2, position = UDim2.fromScale(0.612, 0.525), size = UDim2.fromScale(0.595, 0.597) }),

        Button = TextButton({ text = "+", pos = UDim2.fromScale(0.983, 0.439), size = UDim2.fromScale(0.238, 0.777), index = 4, children = {
            UIGradient = Gradient({ endColor = Color3.fromRGB(255, 206, 10), roatation = 0 }),
        }, action = function()
            Store:dispatch(UIActions.setCurrentUI("Store"))
            UIController:RemoveHUD({ ignoreTopFrame = true })
        end}),

        PetIcon = Roact.createElement("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.186, 0.505),
            Size = UDim2.fromScale(0.385, 0.811),
            Image = UI.Pets,
            BackgroundTransparency = 1,
            ScaleType = Enum.ScaleType.Fit
        })
    })
end