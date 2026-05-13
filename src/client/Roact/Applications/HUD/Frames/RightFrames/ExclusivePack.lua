--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local Size = require(Helpers.Size)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components


-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")

-- UI
local UI = DataCacheController:GetFile("Images")

-- FreePet
function ExclusivePack(_, hooks)

    local styles, api = RoactSpring.useSpring(hooks, function()
        return {
            sizeAlpha = 1,
        }
    end)

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(-0.28, -0.45),
        Size = UDim2.fromScale(0.5, 0.8),
        ZIndex = 1,
        LayoutOrder = 1
    }, {
        UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1
        }),


        StarterPack = Roact.createElement("ImageButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = UI.UI_Brainrot,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.6),
            Size = Size(styles, { X = 1, Y = 0.905 }),
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ScaleType = Enum.ScaleType.Fit,
            LayoutOrder = 1,

            [Roact.Event.MouseEnter] = function()
                api.start({ sizeAlpha = 1.1, config = { mass = 1, tension = 1000, friction = 50 }})
            end,
    
            [Roact.Event.MouseLeave] = function()
                api.start({ sizeAlpha = 1 })
            end,
    
            [Roact.Event.MouseButton1Down] = function()
                api.start({ sizeAlpha = 0.8 })
                Sound:PlaySound("UI_Open")
                --SoundController:CreateSound(Players.LocalPlayer.Character, "UI_Open")
                UIController:ShowFrame({ frame = FramesConstants.ExclusivePack })
            end,
    
            [Roact.Event.MouseButton1Up] = function()
                api.start({ sizeAlpha = 1 })
            end
        }, {
            NewImage = Roact.createElement("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Image = UI.NewImage,
                BackgroundTransparency =  1,
                Size =  UDim2.fromScale(0.4, 0.4),
                Position = UDim2.fromScale(0.8, 0.3),
                ImageColor3= Color3.fromRGB(255, 255, 255),
                Rotation = 16
            }, {
                UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                    AspectRatio = 1
                })
            })
        })
    })
end

ExclusivePack = RoactHooks.new(Roact)(ExclusivePack)
return ExclusivePack