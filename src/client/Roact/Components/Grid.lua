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
            cellPadding = UDim2.fromScale(0, 0),
            cellSize = UDim2.fromScale(0, 0),
            fillDirection = Enum.FillDirection.Horizontal,
            horizontalAlignment = Enum.HorizontalAlignment.Left,
            verticalAlignment = Enum.VerticalAlignment.Top,
            startCorner = Enum.StartCorner.TopLeft,
            fillDirectionMaxCells = 5
        }
    })

    return Roact.createElement("UIGridLayout", {
        CellPadding = params.cellPadding,
        CellSize = params.cellSize,
        FillDirection = params.fillDirection,
        HorizontalAlignment = params.horizontalAlignment,
        VerticalAlignment = params.verticalAlignment,
        StartCorner = params.startCorner,
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirectionMaxCells = params.fillDirectionMaxCells
    })
end