--[=[
    Owner: JustStop__
    Version: v0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Blue_Background = require(Components.Main.Blue_Background)

-- Controllers
local TradeController = Knit.GetController("TradeController")

local TITLE_ICON = "rbxassetid://128766941288775"

local function TitleBar()
    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.04, 0.12),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0.55, 0.171),
        ZIndex = 5,
    }, {
        UIListLayout = Roact.createElement("UIListLayout", {
            VerticalAlignment = Enum.VerticalAlignment.Center,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0.02, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),

        Icon = Roact.createElement("ImageLabel", {
            LayoutOrder = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            ScaleType = Enum.ScaleType.Fit,
            BackgroundTransparency = 1,
            Image = TITLE_ICON,
            Size = UDim2.fromScale(0.18, 1.2),
            ZIndex = 6,
        }, {
            Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
        }),

        TitleText = Roact.createElement("TextLabel", {
            LayoutOrder = 2,
            TextWrapped = true,
            TextColor3 = Color3.fromHex("fafafa"),
            Text = "Hey!",
            TextScaled = true,
            FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
            Size = UDim2.fromScale(0.8, 1),
        }),
    })
end

local function GradientButton(params)
    return Roact.createElement("ImageButton", {
        LayoutOrder = params.LayoutOrder,
        Size = UDim2.fromScale(0.45, 1),
        Position = UDim2.fromScale(0.5, 0.5),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromHex("ffffff"),
        ZIndex = 6,
        AutoButtonColor = true,

        [Roact.Event.MouseButton1Click] = params.Action,
    }, {
        UICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),

        UIStroke = Roact.createElement("UIStroke", {
            Color = params.StrokeColor,
            Thickness = 2,
        }),

        UIGradient = Roact.createElement("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, params.GradientA),
                ColorSequenceKeypoint.new(1, params.GradientB),
            }),
            Rotation = 90,
        }),

        ButtonText = Roact.createElement("TextLabel", {
            TextWrapped = true,
            TextColor3 = Color3.fromHex("fafafa"),
            Text = params.Text,
            AnchorPoint = Vector2.new(0.5, 0.5),
            FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            ZIndex = 7,
            TextScaled = true,
            Size = UDim2.fromScale(0.9, 0.55),
        }),
    })
end

-- Trading
function Trading(_, hooks)
    local TradeReducer = RoduxHooks.useSelector(hooks, function(state)
        return state.TradeReducer
    end)

    local incomingName = "OtherPlayer"
    if TradeReducer.IncomingRequest then
        incomingName = TradeReducer.IncomingRequest.Name
    end

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 2,
    }, {
        Content = Blue_Background({
            title = "Hey!",
            titleIcon = TITLE_ICON,
            size = UDim2.fromScale(0.5, 0.4),
            pos = UDim2.fromScale(0.5, 0.461),
            ratio = 2.2,
            condition = TradeReducer.IncomingRequest ~= nil and TradeReducer.Trading == false,
            align = Enum.TextXAlignment.Left,
            hooks = hooks,
            showClose = false,
        }, {

            InfoText = Roact.createElement("TextLabel", {
                TextWrapped = true,
                TextColor3 = Color3.fromHex("fafafa"),
                Text = `{incomingName} would like to trade with you!`,
                AnchorPoint = Vector2.new(0.5, 0.5),
                FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.45),
                ZIndex = 5,
                TextScaled = true,
                Size = UDim2.fromScale(0.82, 0.25),
            }),

            Bottom = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.8),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(0.9, 0.2),
                ZIndex = 5,
            }, {
                UIListLayout = Roact.createElement("UIListLayout", {
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = UDim.new(0.05, 0),
                    FillDirection = Enum.FillDirection.Horizontal,
                }),

                Decline = GradientButton({
                    LayoutOrder = 1,
                    Text = "Decline Trade",
                    StrokeColor = Color3.fromHex("da5b5d"),
                    GradientA = Color3.fromHex("ff3134"),
                    GradientB = Color3.fromHex("822b2d"),
                    Action = function()
                        TradeController:DeclineRequest()
                    end,
                }),

                Accept = GradientButton({
                    LayoutOrder = 2,
                    Text = "Accept Trade",
                    StrokeColor = Color3.fromHex("04da01"),
                    GradientA = Color3.fromHex("00d921"),
                    GradientB = Color3.fromHex("0e820e"),
                    Action = function()
                        TradeController:AcceptRequest()
                    end,
                }),
            }),
        }),
    })
end

Trading = RoactHooks.new(Roact)(Trading)
return Trading
