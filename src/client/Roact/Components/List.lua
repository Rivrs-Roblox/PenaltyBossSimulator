--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

return function(params: table)
    setmetatable(params, {
        __index = {
            padding = UDim.new(0, 0),
            fillDirection = Enum.FillDirection.Horizontal,
            horizontalAlignment = Enum.HorizontalAlignment.Left,
            verticalAlignment = Enum.VerticalAlignment.Top,
        }
    })

    return Roact.createElement("UIListLayout", {
        Padding = params.padding,
        FillDirection = params.fillDirection,
        HorizontalAlignment = params.horizontalAlignment,
        VerticalAlignment = params.verticalAlignment,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
end