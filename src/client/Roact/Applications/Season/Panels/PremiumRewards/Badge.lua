local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)

function Badge(_, hooks)
    return Roact.createElement("Frame", {
        AnchorPoint=Vector2.new(1,0),
        Position=UDim2.fromScale(0.93,1.03),
        BorderColor3=Color3.fromHex('000000'),
        BackgroundColor3=Color3.fromHex('4f0095'),
        BorderSizePixel=0,
        Size=UDim2.fromScale(0.45,0.15),
    }, {
        Corner = Roact.createElement("UICorner", {
            CornerRadius=UDim.new(0.1,0),
        }),
        Label2 = Roact.createElement("TextLabel", {
            TextWrapped=true,
            TextColor3=Color3.fromHex('ffffff'),
            BorderColor3=Color3.fromHex('000000'),
            Text="by purchasing the Pass Plus!",
            Size=UDim2.fromScale(0.8,0.3),
            Position=UDim2.fromScale(0.43,0.7),
            AnchorPoint=Vector2.new(0.5,0.5),
            Font=26,
            BackgroundTransparency=1,
            TextXAlignment=1,
            TextScaled=true,
            TextSize=14,
            BorderSizePixel=0,
            BackgroundColor3=Color3.fromHex('ffffff'),
        }),
        Label1 = Roact.createElement("TextLabel", {
            TextWrapped=true,
            TextColor3=Color3.fromHex('ffe100'),
            BorderColor3=Color3.fromHex('000000'),
            Text="Unlock Exclusive Achievement",
            Size=UDim2.fromScale(0.8,0.45),
            Position=UDim2.fromScale(0.43,0.35),
            AnchorPoint=Vector2.new(0.5,0.5),
            Font=26,
            BackgroundTransparency=1,
            TextXAlignment=1,
            TextScaled=true,
            TextSize=14,
            BorderSizePixel=0,
            BackgroundColor3=Color3.fromHex('ffffff'),
        }),
        Stroke = Roact.createElement("UIStroke", {
            Thickness=5,
        }),
        Icon = Roact.createElement("ImageLabel", {
            ScaleType=3,
            BorderColor3=Color3.fromHex('000000'),
            AnchorPoint=Vector2.new(0.5,0.5),
            Image="rbxassetid://138226796849089",
            BackgroundTransparency=1,
            Position=UDim2.fromScale(1,0.5),
            BackgroundColor3=Color3.fromHex('ffffff'),
            BorderSizePixel=0,
            Size=UDim2.fromScale(0.35,1.7),
        }, {
            Sparkle2 = Roact.createElement("ImageLabel", {
                AnchorPoint=Vector2.new(0.5,0.5),
                Image="rbxassetid://6822501679",
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.815,0.673),
                BorderColor3=Color3.fromHex('000000'),
                BackgroundColor3=Color3.fromHex('ffffff'),
                BorderSizePixel=0,
                Size=UDim2.fromScale(0.3,0.3),
            }),
            Sparkle1 = Roact.createElement("ImageLabel", {
                AnchorPoint=Vector2.new(0.5,0.5),
                Image="rbxassetid://6822501679",
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.95,0.398),
                BorderColor3=Color3.fromHex('000000'),
                BackgroundColor3=Color3.fromHex('ffffff'),
                BorderSizePixel=0,
                Size=UDim2.fromScale(0.4,0.4),
            }),
        }),
        UIGradient = Roact.createElement("UIGradient", {
            Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('5900a1'))}),
            Rotation=90,
        }),
    })
end

Badge = RoactHooks.new(Roact)(Badge)
return Badge