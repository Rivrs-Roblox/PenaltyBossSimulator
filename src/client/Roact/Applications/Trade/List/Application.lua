--[=[
    Owner: JustStop__
    Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Frames
local Frames = script.Parent.Frames
local Item = require(Frames.Item)

-- Controllers
local TradeController = Knit.GetController("TradeController")
local UIController = Knit.GetController("UIController")

local TITLE_ICON = "rbxassetid://128766941288775"
local CLOSE_ICON = "rbxassetid://120045489184571"

local function TitleBar()
    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.04, 0.08),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0.55, 0.09),
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
            Text = "Trading",
            TextScaled = true,
            FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
            Size = UDim2.fromScale(0.8, 1),
        }),
    })
end

-- Trading
function Trading(_, hooks)
    local UIReducer = RoduxHooks.useSelector(hooks, function(state)
        return state.UIReducer
    end)

    local PlayersItems = {}
    local order = 1

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player.UserId ~= Players.LocalPlayer.UserId then
            PlayersItems[tostring(Player.UserId)] = Item({
                Name = Player.Name,
                UserId = Player.UserId,
                Value = "Trade",
                LayoutOrder = order,
                Action = function()
                    UIController:HideFrame()
                    TradeController:Request(Player)
                end,
                hooks = hooks,
            })

            order += 1
        end
    end

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = UIReducer.CurrentUI == FramesConstants.TradeList,
        ZIndex = 2,
    }, {
        Popup = Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromHex("ffffff"),
            Position = UDim2.fromScale(0.5, 0.5),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(0.7, 0.7),
            ZIndex = 2,
        }, {
            Ratio = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 1.3,
            }),

            UICorner = Roact.createElement("UICorner", {}),

            UIGradient = Roact.createElement("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHex("1e314b")),
                    ColorSequenceKeypoint.new(1, Color3.fromHex("0a0e27")),
                }),
                Rotation = 90,
            }),

            UIStroke = Roact.createElement("UIStroke", {
                Color = Color3.fromHex("ffffff"),
                Thickness = 5,
            }, {
                UIGradient = Roact.createElement("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHex("3369e6")),
                        ColorSequenceKeypoint.new(1, Color3.fromHex("1e388d")),
                    }),
                    Rotation = 90,
                }),
            }),

            Close = Roact.createElement("ImageButton", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.94, 0.08),
                Size = UDim2.fromScale(0.09, 0.09),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromHex("ffffff"),
                ZIndex = 8,
                AutoButtonColor = true,

                [Roact.Event.MouseButton1Click] = function()
                    UIController:HideFrame()
                end,
            }, {
                UIGradient = Roact.createElement("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHex("ff362f")),
                        ColorSequenceKeypoint.new(1, Color3.fromHex("8d1414")),
                    }),
                    Rotation = 90,
                }),

                UICorner = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                }),

                UIStroke = Roact.createElement("UIStroke", {
                    Color = Color3.fromHex("8f0000"),
                    Thickness = 3,
                }),

                Icon = Roact.createElement("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ScaleType = Enum.ScaleType.Fit,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Image = CLOSE_ICON,
                    Size = UDim2.fromScale(0.5, 0.5),
                    ZIndex = 9,
                }),

                Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
            }),

            Title = TitleBar(),

            Scroll = Roact.createElement("ScrollingFrame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.573),
                BackgroundTransparency = 1,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 8,
                BorderSizePixel = 0,
                CanvasSize = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(0.95, 0.807),
                ZIndex = 3,
            }, {
                UIPadding = Roact.createElement("UIPadding", {
                    PaddingTop = UDim.new(0.01, 0),
                    PaddingBottom = UDim.new(0.03, 0),
                }),

                List = Roact.createElement("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = UDim.new(0.05, 0),
                }),

                Roact.createFragment(PlayersItems),
            }),
        }),
    })
end

Trading = RoactHooks.new(Roact)(Trading)
return Trading
