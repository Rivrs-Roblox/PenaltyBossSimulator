local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)

function Free(_, hooks)
    return Roact.createElement("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5),
        BorderColor3=Color3.fromHex('000000'),
        BackgroundColor3=Color3.fromHex('ff85d0'),
        BorderSizePixel=0,
        Size=UDim2.fromScale(0.9,0.37),
    }, {
        Corner = Roact.createElement("UICorner", {
            CornerRadius=UDim.new(0.2,0),
        }),
        Label = Roact.createElement("TextLabel", {
            TextWrapped=true,
            TextColor3=Color3.fromHex('ffffff'),
            BorderColor3=Color3.fromHex('000000'),
            Text="FREE",
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
                Color=Color3.fromHex('7a0464'),
                Thickness=3,
            }),
        }),
        Stroke = Roact.createElement("UIStroke", {
            Color=Color3.fromHex('191919'),
            Thickness=3,
        }),
        UIGradient = Roact.createElement("UIGradient", {
            Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('c064da'))}),
            Rotation=90,
        }),
        Ticket = Roact.createElement("ImageLabel", {
            ScaleType=3,
            BorderColor3=Color3.fromHex('000000'),
            AnchorPoint=Vector2.new(0.5,0.5),
            Image="rbxassetid://88297782209011",
            BackgroundTransparency=1,
            Position=UDim2.fromScale(0.5,0.5),
            BackgroundColor3=Color3.fromHex('ffffff'),
            BorderSizePixel=0,
            Size=UDim2.fromScale(0.9,0.9),
        }),
    })
end

Free = RoactHooks.new(Roact)(Free)
return Free