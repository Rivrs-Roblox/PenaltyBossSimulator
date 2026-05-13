--[=[
    Owner: JustStop__
    Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

local DEFAULT_HEADSHOT = "rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420"

return function(params: {})
    setmetatable(params, {
        __index = {
            Name = "" :: string,
            UserId = 1 :: number,
            LayoutOrder = 1 :: number,
            Action = function() end,
            hooks = nil,
        },
    })

    local headshot = DEFAULT_HEADSHOT
    if params.UserId ~= nil then
        headshot = `rbxthumb://type=AvatarHeadShot&id={params.UserId}&w=420&h=420`
    end

    return Roact.createElement("Frame", {
        LayoutOrder = params.LayoutOrder,
        BackgroundTransparency = 0.8,
        ClipsDescendants = true,
        BackgroundColor3 = Color3.fromHex("ffffff"),
        Size = UDim2.fromScale(0.9, 0.3),
        ZIndex = 4,
    }, {
        Ratio = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 5.5,
        }),

        UICorner = Roact.createElement("UICorner", {}),

        UIStroke = Roact.createElement("UIStroke", {
            Color = Color3.fromHex("939393"),
            Thickness = 2,
        }),

        IconContainer = Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromHex("ffffff"),
            Position = UDim2.fromScale(0.1, 0.5),
            Size = UDim2.fromScale(0.8, 0.8),
            ZIndex = 5,
        }, {
            Ratio = Roact.createElement("UIAspectRatioConstraint", {}),

            Corner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
            }),

            Profile = Roact.createElement("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Image = headshot,
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                ScaleType = Enum.ScaleType.Fit,
                Size = UDim2.fromScale(0.9, 0.9),
                ZIndex = 6,
            }, {
                Corner = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),

                Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
            }),
        }),

        NameText = Roact.createElement("TextLabel", {
            TextWrapped = true,
            TextColor3 = Color3.fromHex("ffffff"),
            Text = params.Name,
            AnchorPoint = Vector2.new(0, 0.5),
            FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextScaled = true,
            Position = UDim2.fromScale(0.19, 0.5),
            Size = UDim2.fromScale(0.55, 0.4),
            ZIndex = 5,
        }),

        Trade = Roact.createElement("ImageButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.87, 0.5),
            Size = UDim2.fromScale(0.22, 0.4),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromHex("3b8c13"),
            ZIndex = 6,
            AutoButtonColor = true,

            [Roact.Event.MouseButton1Click] = params.Action,
        }, {
            UICorner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0, 6),
            }),

            UIStroke = Roact.createElement("UIStroke", {
                Color = Color3.fromHex("25d931"),
                Thickness = 2,
            }),

            ButtonText = Roact.createElement("TextLabel", {
                TextWrapped = true,
                TextColor3 = Color3.fromHex("ffffff"),
                Text = "Trade",
                AnchorPoint = Vector2.new(0.5, 0.5),
                FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                TextScaled = true,
                Size = UDim2.fromScale(0.8, 0.85),
                ZIndex = 7,
            }, {
                UIStroke = Roact.createElement("UIStroke", {
                    Color = Color3.fromHex("0e5513"),
                    Thickness = 2,
                }),
            }),
        }),
    })
end
