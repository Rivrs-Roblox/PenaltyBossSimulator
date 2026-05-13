--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Inventory Components
local InventoryComponents = script.Parent.Parent.Components
local Item = require(InventoryComponents.Item)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local UI = DataCacheController:GetFile("Images")
local Items = DataCacheController:GetFile("Items")

return function(hooks)
	local InventoryReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.InventoryReducer
	end)
	local FruitsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.FruitsReducer
	end)

	local Fruits = {}
	local FruitsLength = 0

	for id, Fruit in pairs(FruitsReducer.Fruits) do
		if Fruit.Number > 0 then
			FruitsLength += 1
			local FruitItem = Item(InventoryReducer, {
				id = id,
				icon = UI[Fruit.Name],
				name = Fruit.Name,
				power = `x{Fruit.Number}`,
				bg_color = Items[Fruit.Name].Color,
				type = "Fruit",
				hover = Items[Fruit.Name].Description,
			})

			Fruits[id] = FruitItem
		end
	end

	Fruits["UIPadding"] = Roact.createElement("UIPadding", { PaddingTop = UDim.new(0.03, 0) })
	Fruits["Grid"] = Roact.createElement("UIGridLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		CellSize = UDim2.fromScale(0.2, 0.4),
		FillDirectionMaxCells = 5,
		CellPadding = UDim2.fromScale(0.02, 0.07),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
	}, {
		Scroll = Roact.createElement("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 8,
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.98),
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ZIndex = 3,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.95, 0.705),
			CanvasSize = UDim2.fromScale(0, 0),
		}, Fruits),

		EmptyText = Text({
			visible = FruitsLength == 0,
			color = Color3.fromHex("ffffff"),
			transparency = 0.8,
			text = "You have nothing to show here yet ):",
			anchorPoint = Vector2.new(0.5, 0.5),
			position = UDim2.fromScale(0.5, 0.6),
			textSize = 14,
			index = 2,
			textScaled = true,
			size = UDim2.fromScale(0.8, 0.2),
		}),
	})
end
