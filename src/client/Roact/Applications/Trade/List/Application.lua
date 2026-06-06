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

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Blue_Background = require(Components.Main.Blue_Background)

-- Frames
local Frames = script.Parent.Frames
local Item = require(Frames.Item)

-- Controllers
local TradeController = Knit.GetController("TradeController")
local UIController = Knit.GetController("UIController")

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local UI = DataCacheController:GetFile("Images")

local TITLE_ICON = "rbxassetid://128766941288775"
local CLOSE_ICON = "rbxassetid://120045489184571"

local PLAYER_ITEM_WIDTH_SCALE = 0.9
local PLAYER_ITEM_FALLBACK_HEIGHT_SCALE = 0.3
local PLAYER_ITEM_ASPECT_RATIO = 5.5
local PLAYER_ITEM_PADDING_SCALE = 0.05
local LIST_PADDING_TOP_SCALE = 0.01
local LIST_PADDING_BOTTOM_SCALE = 0.03

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

    local ScrollRef = hooks.useValue(Roact.createRef())
    local ViewportSize, SetViewportSize = hooks.useState(Vector2.new(0, 0))

    hooks.useEffect(function()
        local scroll = ScrollRef.value:getValue()
        if scroll == nil then
            return
        end

        local function updateViewportSize()
            SetViewportSize(scroll.AbsoluteSize)
        end

        updateViewportSize()

        local connection = scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateViewportSize)
        return function()
            connection:Disconnect()
        end
    end, {})

    local hasViewportSize = ViewportSize.X > 0 and ViewportSize.Y > 0
    local itemHeightOffset = if hasViewportSize
        then (ViewportSize.X * PLAYER_ITEM_WIDTH_SCALE) / PLAYER_ITEM_ASPECT_RATIO
        else 0
    local playerItemSize = if hasViewportSize
        then UDim2.new(PLAYER_ITEM_WIDTH_SCALE, 0, 0, itemHeightOffset)
        else UDim2.fromScale(PLAYER_ITEM_WIDTH_SCALE, PLAYER_ITEM_FALLBACK_HEIGHT_SCALE)
    local itemPadding = if hasViewportSize
        then UDim.new(0, ViewportSize.Y * PLAYER_ITEM_PADDING_SCALE)
        else UDim.new(PLAYER_ITEM_PADDING_SCALE, 0)
    local paddingTop = if hasViewportSize
        then UDim.new(0, ViewportSize.Y * LIST_PADDING_TOP_SCALE)
        else UDim.new(LIST_PADDING_TOP_SCALE, 0)
    local paddingBottom = if hasViewportSize
        then UDim.new(0, ViewportSize.Y * LIST_PADDING_BOTTOM_SCALE)
        else UDim.new(LIST_PADDING_BOTTOM_SCALE, 0)

    local PlayersItems = {}
    local order = 1

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player.UserId ~= Players.LocalPlayer.UserId then
            PlayersItems[tostring(Player.UserId)] = Item({
                Name = Player.Name,
                UserId = Player.UserId,
                Value = "Trade",
                LayoutOrder = order,
                Size = playerItemSize,
                Action = function()
                    UIController:HideFrame()
                    TradeController:Request(Player)
                end,
                hooks = hooks,
            })

            order += 1
        end
    end

    local playerCount = order - 1
    local canvasHeightOffset = if hasViewportSize
        then math.max(
            ViewportSize.Y,
            (playerCount * itemHeightOffset)
                + (math.max(playerCount - 1, 0) * itemPadding.Offset)
                + paddingTop.Offset
                + paddingBottom.Offset
        )
        else 0

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = UIReducer.CurrentUI == FramesConstants.TradeList,
        ZIndex = 2,
    }, {
        Content = Blue_Background({
            title = "Trading",
            titleIcon = UI.Trading,
            size = UDim2.fromScale(0.7, 0.7),
            pos = UDim2.fromScale(0.5, 0.5),
            ratio = 1.3,
            condition = UIReducer.CurrentUI == FramesConstants.TradeList,
            align = Enum.TextXAlignment.Left,
            hooks = hooks,
        }, {

            ScrollFrame = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.573),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(0.95, 0.807),
                ZIndex = 3,
            }, {
                Scroll = Roact.createElement("ScrollingFrame", {
                    Active = true,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    BackgroundTransparency = 1,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    ScrollBarThickness = 8,
                    ClipsDescendants = true,
                    ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromOffset(0, canvasHeightOffset),
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 3,
                    [Roact.Ref] = ScrollRef.value,
                }, {
                    UIPadding = Roact.createElement("UIPadding", {
                        PaddingTop = paddingTop,
                        PaddingBottom = paddingBottom,
                    }),

                    List = Roact.createElement("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        Padding = itemPadding,
                    }),

                    Roact.createFragment(PlayersItems),
                }),
            }),
        }),
    })
end

Trading = RoactHooks.new(Roact)(Trading)
return Trading
