local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.roact)

return function(params)
    params = params or {}
    local color = params.color or Color3.fromHex("1b8d1b")
    local strokeColor = params.strokeColor or Color3.fromHex("052f03")
    return Roact.createElement("ImageButton", {
        LayoutOrder = params.layoutOrder or 1,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = params.size or UDim2.fromScale(0.32, 1),
        ZIndex = 2,
        [Roact.Event.MouseButton1Click] = params.onClick,
    }, {
        UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
        ButtonText = Roact.createElement("TextLabel", {
            AnchorPoint = params.price and Vector2.new(0, 0.5) or Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Position = params.price and UDim2.fromScale(0.05, 0.5) or UDim2.fromScale(0.5, 0.5),
            Size = params.price and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(0.9, 0.5),
            Text = params.text or "Button",
            TextColor3 = Color3.fromHex("fafafa"),
            TextScaled = true,
            TextWrapped = true,
            TextXAlignment = params.price and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
            ZIndex = 5,
        }, { UIStroke = Roact.createElement("UIStroke", { Color = strokeColor, Thickness = 2 }) }),
        PriceText = params.price and Roact.createElement("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Position = UDim2.fromScale(0.95, 0.5),
            Size = UDim2.fromScale(0.5, 0.5),
            Text = params.price,
            TextColor3 = Color3.fromHex("ffffff"),
            TextScaled = true,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 5,
        }, { UIStroke = Roact.createElement("UIStroke", { Color = strokeColor, Thickness = 2 }) }) or nil,
    })
end
