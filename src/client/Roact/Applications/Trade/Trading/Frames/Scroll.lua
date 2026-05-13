--[=[
    Owner: JustStop__
    Version: v0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

-- Config
local EMPTY_BOTTOM_ROWS = 2
local MAX_CELLS_PER_ROW = 4

-- Scroll
return function(params: table)
    setmetatable(params, {
        __index = {
            pets = {} :: table,
            pos = UDim2.fromScale(0.5, 1),
            size = UDim2.fromScale(1, 0.877),
        },
    })

    local children = {}

    children.UICorner = Roact.createElement("UICorner", {
        CornerRadius = UDim.new(0, 10),
    })

    children.UIPadding = Roact.createElement("UIPadding", {
        PaddingTop = UDim.new(0.03, 0),
        PaddingBottom = UDim.new(0.03, 0),
        PaddingLeft = UDim.new(0.03, 0),
        PaddingRight = UDim.new(0.03, 0),
    })

    children.Grid = Roact.createElement("UIGridLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        CellSize = UDim2.fromScale(0.2, 0.25),
        FillDirectionMaxCells = MAX_CELLS_PER_ROW,
        CellPadding = UDim2.fromScale(0.04, 0.04),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    })

    for key, element in pairs(params.pets) do
        children[key] = element
    end

    -- Tambahan slot kosong supaya bagian bawah seakan masih punya 2 baris pet
    for i = 1, EMPTY_BOTTOM_ROWS * MAX_CELLS_PER_ROW do
        children["BottomSpacer_" .. i] = Roact.createElement("Frame", {
            LayoutOrder = 999999 + i,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 1,
        })
    end

    return Roact.createElement("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 8,
        AnchorPoint = Vector2.new(0.5, 1),
        Size = params.size,
        BackgroundTransparency = 0.5,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Position = params.pos,
        ZIndex = 3,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        BackgroundColor3 = Color3.fromHex("606393"),
    }, children)
end