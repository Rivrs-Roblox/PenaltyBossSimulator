local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Store
local Store = require(StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayerScripts.Client.Rodux.Actions.UIActions)

-- Constants
local SeasonConstants = require(StarterPlayerScripts.Client.Roact.Constants.SeasonConstants)

function Premium(_, hooks)
    local premium = RoduxHooks.useSelector(hooks, function(state) return state.SeasonReducer.Premium end)

    return Roact.createElement("Frame", {
        LayoutOrder=3,
        BackgroundColor3=Color3.fromHex('ffcc00'),
        BorderColor3=Color3.fromHex('000000'),
        AnchorPoint=Vector2.new(0.5,0.5),
        BorderSizePixel=0,
        Size=UDim2.fromScale(0.9,0.37),
    }, {
        Lock = Roact.createElement("ImageLabel", {
            ScaleType=3,
            BorderColor3=Color3.fromHex('000000'),
            AnchorPoint=Vector2.new(0.5,0.5),
            Image="rbxassetid://126950907883178",
            BackgroundTransparency=1,
            Position=UDim2.fromScale(0.9,0.5),
            BackgroundColor3=Color3.fromHex('ffffff'),
            BorderSizePixel=0,
            Size=UDim2.fromScale(0.5,0.5),
            ZIndex = 2,
            Visible = if not premium then true else false
        }),
        Corner = Roact.createElement("UICorner", {
            CornerRadius=UDim.new(0.2,0),
        }),
        Label = Roact.createElement("TextLabel", {
            TextWrapped=true,
            TextColor3=Color3.fromHex('ffffff'),
            BorderColor3=Color3.fromHex('000000'),
            Text="PREMIUM!",
            Size=UDim2.fromScale(0.9,0.25),
            TextScaled=true,
            AnchorPoint=Vector2.new(0.5,0.5),
            Font=26,
            BackgroundTransparency=1,
            Position=UDim2.fromScale(0.5,0.15),
            TextSize=14,
            TextYAlignment=0,
            BorderSizePixel=0,
            BackgroundColor3=Color3.fromHex('ffffff'),
            ZIndex = 2
        }, {
            Stroke = Roact.createElement("UIStroke", {
                Color=Color3.fromHex('ad4800'),
                Thickness=3,
            }),
        }),
        UIGradient = Roact.createElement("UIGradient", {
            Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('ff7700'))}),
            Rotation=90,
        }),
        Stroke = Roact.createElement("UIStroke", {
            Color=Color3.fromHex('191919'),
            Thickness=3,
        }),
        Ticket = Roact.createElement("ImageLabel", {
            ScaleType=3,
            BorderColor3=Color3.fromHex('000000'),
            AnchorPoint=Vector2.new(0.5,0.5),
            Image="rbxassetid://81846085332138",
            BackgroundTransparency=1,
            Position=UDim2.fromScale(0.5,0.5),
            BackgroundColor3=Color3.fromHex('ffffff'),
            BorderSizePixel=0,
            Size=UDim2.fromScale(0.9,0.9),
        }),
        Buy = Roact.createElement("ImageButton", {
            AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.fromScale(0.5,0.9),
            BorderColor3=Color3.fromHex('000000'),
            Size=UDim2.fromScale(0.85,0.25),
            BorderSizePixel=0,
            BackgroundColor3=Color3.fromHex('e5ff00'),
            Visible = if not premium then true else false,
            [Roact.Event.MouseButton1Click] = function()
                Sound:PlaySound("UI_Click")
                Store:dispatch(UIActions.setCurrentSeasonPassUI(SeasonConstants.PremiumRewards))
            end,
        }, {
            UIGradient = Roact.createElement("UIGradient", {
                Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('27d400'))}),
                Rotation=90,
            }),
            Stroke = Roact.createElement("UIStroke", {
                Color=Color3.fromHex('245d00'),
                Thickness=5,
            }),
            Corner = Roact.createElement("UICorner", {
                CornerRadius=UDim.new(0.3,0),
            }),
            Label = Roact.createElement("TextLabel", {
                TextWrapped=true,
                TextColor3=Color3.fromHex('ffffff'),
                BorderColor3=Color3.fromHex('000000'),
                Text="Get Now!",
                Size=UDim2.fromScale(0.9,0.9),
                AnchorPoint=Vector2.new(0.5,0.5),
                Font=26,
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.5,0.5),
                TextScaled=true,
                TextSize=14,
                BorderSizePixel=0,
                BackgroundColor3=Color3.fromHex('ffffff'),
            }, {
                Stroke = Roact.createElement("UIStroke", {
                    Color=Color3.fromHex('245d00'),
                    Thickness=3,
                }),
            }),
        }),
    })
end

Premium = RoactHooks.new(Roact)(Premium)
return Premium