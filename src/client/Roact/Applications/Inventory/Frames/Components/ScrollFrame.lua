--[=[
    Inventory Pets ScrollFrame
    Displays equipped pets first, then stored unequipped pets.
]=]

local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.roact)

local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

local EMPTY_BOTTOM_ROWS = 2
local MAX_COLUMNS = 5

return function(params: table)
	setmetatable(params, {
		__index = {
			equippedPets = {},
			pets = {},
		},
	})

	local children = {}
	local totalItems = 0

	for id, element in pairs(params.equippedPets) do
		children["Equipped_" .. tostring(id)] = element
		totalItems += 1
	end

	for id, element in pairs(params.pets) do
		children["Pet_" .. tostring(id)] = element
		totalItems += 1
	end

	-- Dummy 2 baris kosong di bawah pet terakhir
	-- 2 baris x 5 kolom = 10 dummy item
	if totalItems > 0 then
		for i = 1, EMPTY_BOTTOM_ROWS * MAX_COLUMNS do
			children["BottomSpacer_" .. i] = Roact.createElement("Frame", {
				LayoutOrder = 999999 + i,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 1,
			})
		end
	end

	children.UIPadding = Roact.createElement("UIPadding", {
		PaddingTop = UDim.new(0.004, 0),
		PaddingBottom = UDim.new(0.02, 0),
	})

	children.Grid = Roact.createElement("UIGridLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		CellSize = UDim2.fromScale(0.16, 0.43),
		FillDirectionMaxCells = MAX_COLUMNS,
		CellPadding = UDim2.fromScale(0.02, 0.08),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.565),
		Size = UDim2.fromScale(1, 0.63),
	}, {
		Scroll = Roact.createElement("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 8,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ZIndex = 3,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.96, 0.92),
			CanvasSize = UDim2.fromScale(0, 0),
		}, children),

		EmptyText = Text({
			visible = totalItems == 0,
			color = Color3.fromHex("ffffff"),
			transparency = 0.8,
			text = "You have no pets yet.",
			anchorPoint = Vector2.new(0.5, 0.5),
			position = UDim2.fromScale(0.5, 0.5),
			textSize = 14,
			index = 2,
			textScaled = true,
			size = UDim2.fromScale(0.8, 0.2),
		}),
	})
end