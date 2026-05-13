local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.roact)
local PanelButton = require(script.Parent.PanelButton)

return function(hooks)
    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.2),
        Size = UDim2.fromScale(0.91, 0.08),
        ZIndex = 5,
    }, {
        UIListLayout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0.01, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
        TimeRewards = PanelButton({ layoutOrder = 1, name = "TimeRewards", hooks = hooks}),
        DailyRewards = PanelButton({ layoutOrder = 2, name = "DailyRewards", hooks = hooks}),
        SpinWheels = PanelButton({ layoutOrder = 3, name = "SpinWheels", hooks = hooks}),
    })
end
