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
local Template = DataCacheController:GetFile("Template")

return function(hooks)
	local InventoryReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.InventoryReducer
	end)
	local BoostsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.BoostsReducer
	end)

	local Boosts = {}
	local BoostsLength = 0
	for id, Boost in pairs(BoostsReducer.Boosts) do
		if Boost.Number > 0 then
			BoostsLength += 1
			local BoostItem = Item(InventoryReducer, {
				id = id,
				icon = UI[Boost.Name],
				name = Boost.Name
					:gsub("Money1", Template.Economy.Money1)
					:gsub("Money2", Template.Economy.Money2)
					:gsub("_", " ")
					:gsub("Boost", ""),
				power = `x{Boost.Number}`,
				bg_color = Items[Boost.Name].Color,
				type = "Boost",
			})

			Boosts[id] = BoostItem
		end
	end

	Boosts["UIPadding"] = Roact.createElement("UIPadding", { PaddingTop = UDim.new(0.03, 0) })
	Boosts["Grid"] = Roact.createElement("UIGridLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		CellSize = UDim2.fromScale(0.2, 0.4),
		FillDirectionMaxCells = 5,
		CellPadding = UDim2.fromScale(0.02, 0.07),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
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
		}, Boosts),

		EmptyText = Text({
			visible = BoostsLength == 0,
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
