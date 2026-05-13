--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Constants

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
function StarterPack(_, hooks)

    local styles, api = RoactSpring.useSpring(hooks, function()
        return {
            sizeAlpha = 1,
            rotation = 0,
        }
    end)

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.1, 0.275),
        Size = UDim2.fromScale(0.871, 0.8),
        ZIndex = 1,
        LayoutOrder = 1
    }, {
        UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1
        }),


        StarterPack = Roact.createElement("ImageButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = UI.StarterPackHUD,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.6),
            Size = Size(styles, { X = 1, Y = 0.905 }),
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ScaleType = Enum.ScaleType.Fit,
            LayoutOrder = 1,

            [Roact.Event.MouseEnter] = function()
                api.start({ sizeAlpha = 1.1, rotation = 35, config = { mass = 1, tension = 1000, friction = 50 }})
            end,
    
            [Roact.Event.MouseLeave] = function()
                api.start({ sizeAlpha = 1, rotation = 0, config = { mass = 1, tension = 1000, friction = 50 } })
            end,
    
            [Roact.Event.MouseButton1Down] = function()
                api.start({ sizeAlpha = 0.8 })
                Sound:PlaySound("UI_Open")
                --SoundController:CreateSound(Players.LocalPlayer.Character, "UI_Open")
                local MonetizationService = Knit.GetService("MonetizationService")
                MonetizationService:PromptPurchase(1838396540, "Packs")
            end,
    
            [Roact.Event.MouseButton1Up] = function()
                api.start({ sizeAlpha = 1 })
            end
        }, {
            NewImage = Roact.createElement("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Image = UI.NewImage,
                BackgroundTransparency =  1,
                Size =  UDim2.fromScale(1, 1),
                Position = UDim2.fromScale(0.8, 0.3),
                ImageColor3= Color3.fromRGB(255, 255, 255),
                Rotation = styles.rotation,
            }, {
                UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                    AspectRatio = 1
                })
            })
        })
    })
end

StarterPack = RoactHooks.new(Roact)(StarterPack)
return StarterPack