local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.roact)

return function(params)
    params = params or {}
    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.04, 0.08),
        Size = UDim2.fromScale(0.55, 0.09),
        ZIndex = 5,
    }, {
        UIListLayout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0.02, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
        Icon = Roact.createElement("ImageLabel", {
            BackgroundTransparency = 1,
            Image = params.icon or "rbxassetid://115827540499425",
            LayoutOrder = 1,
            ScaleType = Enum.ScaleType.Fit,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 2,
        }, { Ratio = Roact.createElement("UIAspectRatioConstraint") }),
        Text = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            LayoutOrder = 2,
            Size = UDim2.fromScale(0.8, 1),
            Text = params.text or "Rewards",
            TextColor3 = Color3.fromHex("fafafa"),
            TextScaled = true,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
        }, { }),
    })
end
