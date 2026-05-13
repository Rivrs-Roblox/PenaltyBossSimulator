local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Controllers
local StoreController = Knit.GetController("StoreController")
local MonetizationController = Knit.GetController("MonetizationController")

local PassPrize = require(script.Parent.PassPrize)

function Pass(_, hooks)
    return Roact.createElement("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundTransparency=0.6,
        Position=UDim2.fromScale(0.225,0.586),
        BorderColor3=Color3.fromHex('000000'),
        BackgroundColor3=Color3.fromHex('3e1162'),
        BorderSizePixel=0,
        Size=UDim2.fromScale(0.315,0.65),
    }, {
        TextTitle = Roact.createElement("TextLabel", {
        TextWrapped=true,
        AutoLocalize=false,
        TextColor3=Color3.fromHex('ffffff'),
        Text="Brainrot Pass",
        TextScaled=true,
        AnchorPoint=Vector2.new(0.5,0.5),
        Font=26,
        BackgroundTransparency=1,
        TextXAlignment=0,
        Position=UDim2.fromScale(0.5,-0.1),
        ZIndex=101,
        TextSize=14,
        Size=UDim2.fromScale(1,0.15),
        }, {
            UIStroke = Roact.createElement("UIStroke", {
                Color=Color3.fromHex('191919'),
                Thickness=2.487,
            }),
        }),
        Corner = Roact.createElement("UICorner", {
            CornerRadius=UDim.new(0.05,0),
        }),
        Prize = Roact.createElement(PassPrize),
        Stroke = Roact.createElement("UIStroke", {
            Color=Color3.fromHex('191919'),
            Thickness=4,
        }),
        Buy = Roact.createElement("ImageButton", {
            AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.fromScale(0.5,0.95),
            BorderColor3=Color3.fromHex('000000'),
            Size=UDim2.fromScale(0.8,0.2),
            BorderSizePixel=0,
            BackgroundColor3=Color3.fromHex('e5ff00'),
            [Roact.Event.MouseButton1Click] = function()
                Sound:PlaySound("UI_Click")
                StoreController:BuyItem({ name = "Brainrot Pass - Regular" })
            end,
        }, {
            UIGradient = Roact.createElement("UIGradient", {
                Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('27d400'))}),
                Rotation=90,
            }),
            Robux = Roact.createElement("ImageLabel", {
                ScaleType=3,
                BorderColor3=Color3.fromHex('000000'),
                AnchorPoint=Vector2.new(0.5,0.5),
                Image="rbxassetid://96573043483506",
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.15,0.5),
                BackgroundColor3=Color3.fromHex('ffffff'),
                BorderSizePixel=0,
                Size=UDim2.fromScale(0.3,0.9),
            }),
            Price = Roact.createElement("TextLabel", {
                TextWrapped=true,
                AutoLocalize=false,
                TextColor3=Color3.fromHex('ffffff'),
                BorderColor3=Color3.fromHex('000000'),
                Text=`{MonetizationController:GetPrice("Brainrot Pass - Regular")}`,
                Size=UDim2.fromScale(0.65,0.9),
                AnchorPoint=Vector2.new(0.5,0.5),
                Font=26,
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.625,0.5),
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
            Stroke = Roact.createElement("UIStroke", {
                Color=Color3.fromHex('153400'),
                Thickness=5,
            }),
            Corner = Roact.createElement("UICorner", {
                CornerRadius=UDim.new(0.2,0),
            }),
        }),
        TitleShadow = Roact.createElement("TextLabel", {
            TextWrapped=true,
            AutoLocalize=false,
            TextColor3=Color3.fromHex('191919'),
            Text="Brainrot Pass",
            TextScaled=true,
            AnchorPoint=Vector2.new(0.5,0.5),
            Font=26,
            BackgroundTransparency=1,
            TextXAlignment=0,
            Position=UDim2.fromScale(0.51,-0.085),
            ZIndex=100,
            TextSize=14,
            Size=UDim2.fromScale(1,0.15),
        }),
    })
end

Pass = RoactHooks.new(Roact)(Pass)
return Pass