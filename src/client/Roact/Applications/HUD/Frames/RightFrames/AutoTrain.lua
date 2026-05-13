--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Controllers
local AutoController = Knit.GetController("AutoController")

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)
local Image = require(Components.Image)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local UI = DataCacheController:GetFile("Images")

-- Auto
function AutoTrain(_, hooks)
    local AutoReducer = RoduxHooks.useSelector(hooks, function(state)
        return state.AutoReducer
    end)

    local styles, api = RoactSpring.useSpring(hooks, function()
        return {
            sizeAlpha = 1,
            sizeBeta = 1,
        }
    end)

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.162, 0.47),
        Size = UDim2.fromScale(0.838, 0.517),
        ZIndex = 1,
        LayoutOrder = 4
    }, {
        UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1.5
        }),

        UIListLayout = Roact.createElement("UIListLayout", {
            Padding = UDim.new(0.05, 0),
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center
        }),

        AutoTrain = Roact.createElement("ImageButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = UI.Background,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, -0.305),
            Size = styles.sizeBeta:map(function(beta)
                return UDim2.fromScale(0.94 *beta, 0.431 * beta)
            end),
            ImageColor3 = if AutoReducer.AutoTraining == true then Color3.fromRGB(111, 255, 0) else Color3.fromRGB(255, 51, 0),
            ScaleType = Enum.ScaleType.Fit,
            LayoutOrder = 2,
            [Roact.Event.MouseButton1Click] = function()
                AutoController:AutoTrain()
                Sound:PlaySound("UI_Click")
            end,

            [Roact.Event.MouseEnter] = function()
                api.start({ sizeBeta = 1.1 })
            end,
    
            [Roact.Event.MouseLeave] = function()
                api.start({ sizeBeta = 1 })
            end,
    
            [Roact.Event.MouseButton1Down] = function()
                api.start({ sizeBeta = 0.8 })
            end,
    
            [Roact.Event.MouseButton1Up] = function()
                api.start({ sizeBeta = 1 })
            end
        }, {
            Icon = Image({ image = UI.Money2, position = UDim2.fromScale(0.049, 0.482), size = UDim2.fromScale(0.284, 1.036), backgroundTransparency = 1, children = {
                UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                    AspectRatio = 1
                }),
            }}),

            Title = Text({ text = "Auto Training", position = UDim2.fromScale(0.508, 0.473), size = UDim2.fromScale(0.494, 0.441), stroke = 1.5, color = Color3.fromRGB(255, 255, 255) }),
            Free = Text({ text = "FREE!", position = UDim2.fromScale(0.832, 0.137), size = UDim2.fromScale(0.221, 0.441), stroke = 1.5, color = Color3.fromRGB(255, 255, 255) }),
        }),
    })
end

AutoTrain = RoactHooks.new(Roact)(AutoTrain)
return AutoTrain