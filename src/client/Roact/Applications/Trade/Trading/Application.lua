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

-- Helpers
local FormatNumber = require(ReplicatedStorage.Shared.Helpers.Numbers.FormatNumber)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Blue_Background = require(Components.Main.Blue_Background)

-- Controllers
local TradeController = Knit.GetController("TradeController")
local DataCacheController = Knit.GetController("DataCacheController")

-- Frames
local Frames = script.Parent.Frames
local Scroll = require(Frames.Scroll)
local Pet = require(Frames.Pet)

-- UI
local UI = DataCacheController:GetFile("Images")
local Colors = DataCacheController:GetFile("Colors")
local PetsData = DataCacheController:GetFile("Pets")

local TITLE_ICON = "rbxassetid://128766941288775"
local CLOSE_ICON = "rbxassetid://120045489184571"
local SEARCH_ICON = "rbxassetid://108045196460145"
local READY_ICON = "rbxassetid://93840956317609"

local function getPetIcon(petName: string)
    local icon = UI[petName]
    if icon == nil then
        icon = UI[petName:gsub("Gold ", ""):gsub("Rainbow ", "")]
    end

    return icon or ""
end

local function getPetPower(petName: string, PetsReducer)
    local petData = PetsData[petName]
    if petData == nil then
        return 0
    end

    local powerData = petData.Power
    if powerData == nil and petData.Type == "Scaling" then
        powerData = PetsReducer.ScaledPetsPower[petName] or 0
    end

    return tonumber(powerData) or 0
end

local function getPetColor(rarity: string)
    return Colors[rarity] or Color3.fromHex("e1e1e1")
end

local function countItems(items: table)
    local amount = 0
    for _ in pairs(items) do
        amount += 1
    end
    return amount
end

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
            Text = "Trade",
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
        Size = params.Size or UDim2.fromScale(0.19, 1),
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

local function PlayerPanel(params)
    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.5,
        LayoutOrder = params.LayoutOrder,
        BackgroundColor3 = Color3.fromHex("606393"),
        Size = UDim2.fromScale(0.5, 1),
        ZIndex = 3,
    }, {
        UICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 10),
        }),

        NameText = Roact.createElement("TextLabel", {
            TextWrapped = true,
            TextColor3 = Color3.fromHex("ffffff"),
            Text = params.Title,
            AnchorPoint = Vector2.new(0.5, 0),
            FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.02),
            ZIndex = 4,
            TextScaled = true,
            Size = UDim2.fromScale(0.85, 0.08),
        }),

        EmptyText = Roact.createElement("TextLabel", {
            Visible = params.Count <= 0,
            TextWrapped = true,
            TextColor3 = Color3.fromHex("ffffff"),
            TextTransparency = 0.8,
            Text = params.EmptyText,
            AnchorPoint = Vector2.new(0.5, 0.5),
            FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.52),
            ZIndex = 4,
            TextScaled = true,
            Size = UDim2.fromScale(0.8, 0.2),
        }),

        Scroll = Scroll({
            pets = params.Pets,
            pos = UDim2.fromScale(0.5, 0.96),
            size = UDim2.fromScale(0.94, 0.8),
        }),

        Ready = Roact.createElement("ImageLabel", {
            Visible = params.Ready,
            ScaleType = Enum.ScaleType.Fit,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = UI.Check or READY_ICON,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.55),
            ZIndex = 20,
            ImageColor3 = Color3.fromHex("00fa00"),
            Size = UDim2.fromScale(0.35, 0.35),
        }),
    })
end

-- Trading
function Trading(_, hooks)
    local TradeReducer = RoduxHooks.useSelector(hooks, function(state)
        return state.TradeReducer
    end)

    local PetsReducer = RoduxHooks.useSelector(hooks, function(state)
        return state.PetsReducer
    end)

    local SearchText, SetSearchText = hooks.useState("")

    local MyPets = {}

    for id, pet in pairs(TradeReducer.MyPets) do
        if SearchText == "" or string.find(string.lower(pet.Name), SearchText, 1, true) then
            local powerData = getPetPower(pet.Name, PetsReducer)

            MyPets[id] = Pet({
                trading = true,
                icon = getPetIcon(pet.Name),
                name = pet.Name,
                id = id,
                power = `x{if powerData then FormatNumber(powerData) else "???"}`,
                bg_color = getPetColor(pet.Rarity),
                rarity = pet.Rarity,
                my_side = true,
                order = -(powerData * 10000),
            })
        end
    end

    for id, pet in pairs(PetsReducer.Pets) do
        if MyPets[id] == nil then
            if SearchText == "" or string.find(string.lower(pet.Name), SearchText, 1, true) then
                local powerData = getPetPower(pet.Name, PetsReducer)

                MyPets[id] = Pet({
                    trading = false,
                    icon = getPetIcon(pet.Name),
                    name = pet.Name,
                    id = id,
                    power = `x{if powerData then FormatNumber(powerData) else "???"}`,
                    bg_color = getPetColor(pet.Rarity),
                    rarity = pet.Rarity,
                    my_side = true,
                    order = -powerData,
                })
            end
        end
    end

    local HisPets = {}
    for id, pet in pairs(TradeReducer.HisPets) do
        local powerData = getPetPower(pet.Name, PetsReducer)

        HisPets[id] = Pet({
            trading = true,
            icon = getPetIcon(pet.Name),
            name = pet.Name,
            id = id,
            power = `x{if powerData then FormatNumber(powerData) else "???"}`,
            bg_color = getPetColor(pet.Rarity),
            rarity = pet.Rarity,
            my_side = false,
            order = -powerData,
        })
    end

    local otherPlayerName = "Other"
    if TradeReducer.IncomingRequest then
        otherPlayerName = TradeReducer.IncomingRequest.Name
    elseif TradeReducer.OutgoingRequest then
        otherPlayerName = TradeReducer.OutgoingRequest.Name
    end

    local acceptButtonText = "Accept"
    local acceptButtonAction = function()
        TradeController:Ready(true)
    end
    local acceptStroke = Color3.fromHex("04da01")
    local acceptGradientA = Color3.fromHex("00d921")
    local acceptGradientB = Color3.fromHex("0e820e")

    if TradeReducer.Ready and TradeReducer.OtherReady then
        acceptButtonText = "Cancel"
        acceptButtonAction = function()
            TradeController:Ready(false)
        end
        acceptStroke = Color3.fromHex("da5b5d")
        acceptGradientA = Color3.fromHex("ff3134")
        acceptGradientB = Color3.fromHex("822b2d")
    end

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 2,
    }, {
        Content = Blue_Background({
            title = "Trade",
            titleIcon = TITLE_ICON,
            size = UDim2.fromScale(0.7, 0.7),
            pos = UDim2.fromScale(0.5, 0.5),
            ratio = 1.6,
            condition = TradeReducer.Trading == true,
            align = Enum.TextXAlignment.Left,
            hooks = hooks,
            action = function()
                TradeController:CancelTrade()
            end,
        }, {

            Center = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.88, 0.65),
                ZIndex = 3,
            }, {
                UIListLayout = Roact.createElement("UIListLayout", {
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = UDim.new(0.015, 0),
                    FillDirection = Enum.FillDirection.Horizontal,
                }),

                Player = PlayerPanel({
                    LayoutOrder = 1,
                    Title = "Your Pets",
                    EmptyText = "You have nothing to show here yet ):",
                    Pets = MyPets,
                    Count = countItems(MyPets),
                    Ready = TradeReducer.Ready,
                }),

                OtherPlayer = PlayerPanel({
                    LayoutOrder = 2,
                    Title = `{otherPlayerName}'s Pets`,
                    EmptyText = "They have nothing to show here yet ):",
                    Pets = HisPets,
                    Count = countItems(HisPets),
                    Ready = TradeReducer.OtherReady,
                }),
            }),

            Timer = Roact.createElement("TextLabel", {
                Visible = TradeReducer.Ready and TradeReducer.OtherReady,
                TextWrapped = true,
                TextColor3 = Color3.fromHex("ffffff"),
                Text = tostring(TradeReducer.Timer),
                AnchorPoint = Vector2.new(0.5, 0.5),
                FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                TextScaled = true,
                Size = UDim2.fromScale(0.35, 0.22),
                ZIndex = 30,
                TextStrokeTransparency = 0,
                TextStrokeColor3 = Color3.fromHex("000000"),
            }),

            Bottom = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.93),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(0.9, 0.1),
                ZIndex = 5,
            }, {
                UIListLayout = Roact.createElement("UIListLayout", {
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = UDim.new(0.02, 0),
                    FillDirection = Enum.FillDirection.Horizontal,
                }),

                SearchBar = Roact.createElement("Frame", {
                    LayoutOrder = 1,
                    ZIndex = 10,
                    BackgroundColor3 = Color3.fromHex("3b65a3"),
                    Size = UDim2.fromScale(0.57, 1),
                }, {
                    UICorner = Roact.createElement("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                    }),

                    UIStroke = Roact.createElement("UIStroke", {
                        Color = Color3.fromHex("6f88e1"),
                        Thickness = 2,
                    }),

                    Icon = Roact.createElement("ImageLabel", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Image = SEARCH_ICON,
                        BackgroundTransparency = 1,
                        ImageTransparency = 0.5,
                        Position = UDim2.fromScale(0.06, 0.5),
                        ScaleType = Enum.ScaleType.Fit,
                        Size = UDim2.fromScale(0.6, 0.6),
                        ZIndex = 11,
                    }, {
                        Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
                    }),

                    TextBox = Roact.createElement("TextBox", {
                        TextWrapped = true,
                        TextColor3 = Color3.fromHex("ffffff"),
                        TextTransparency = 0.5,
                        Text = SearchText,
                        PlaceholderColor3 = Color3.fromHex("ffffff"),
                        AnchorPoint = Vector2.new(0, 0.5),
                        FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Position = UDim2.fromScale(0.12, 0.5),
                        PlaceholderText = "Search pets...",
                        TextScaled = true,
                        Size = UDim2.fromScale(0.8, 0.5),
                        ZIndex = 11,
                        ClearTextOnFocus = false,

                        [Roact.Change.Text] = function(rbx)
                            SetSearchText(string.lower(rbx.Text))
                        end,
                    }),
                }),

                Decline = GradientButton({
                    LayoutOrder = 2,
                    Text = "Decline",
                    StrokeColor = Color3.fromHex("da5b5d"),
                    GradientA = Color3.fromHex("ff3134"),
                    GradientB = Color3.fromHex("822b2d"),
                    Action = function()
                        TradeController:CancelTrade()
                    end,
                }),

                Accept = GradientButton({
                    LayoutOrder = 3,
                    Text = acceptButtonText,
                    StrokeColor = acceptStroke,
                    GradientA = acceptGradientA,
                    GradientB = acceptGradientB,
                    Action = acceptButtonAction,
                }),
            }),
        }),
    })
end

Trading = RoactHooks.new(Roact)(Trading)
return Trading
