--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local Blue_Background = require(Components.Main.Blue_Background)
local Panel = require(Components.Panel)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)
local InventoryConstants = require(StarterPlayerScripts.Client.Roact.Constants.InventoryConstants)

-- Store
local Store = require(StarterPlayerScripts.Client.Rodux.Store)
local InventoryActions = require(StarterPlayerScripts.Client.Rodux.Actions.InventoryActions)

-- Frames
local Frames = script.Parent.Frames
local Pets = require(Frames.Pets.Pets)
local Fruits = require(Frames.Fruits.Fruits)
local Boosts = require(Frames.Boosts.Boosts)

local DataCacheController = Knit.GetController("DataCacheController")
local UI = DataCacheController:GetFile("Images")

-- Inventory
function Inventory(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)
	local InventoryReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.InventoryReducer
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Content = Blue_Background({
			title = "Inventory",
			titleIcon = UI.Inventory,
			size = UDim2.fromScale(0.7, 0.7),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.6,
			condition = UIReducer.CurrentUI == FramesConstants.Inventory,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
		}, {
			Panels = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.2),
				Size = UDim2.fromScale(0.91, 0.1),
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.012, 0),
					FillDirection = Enum.FillDirection.Horizontal,
				}),
				Pets = Panel({
					order = 1,
					text = "Pets",
					icon = UI.Pets,
					isActive = InventoryReducer.Inventory == InventoryConstants.Pets,
					action = function()
						Store:dispatch(InventoryActions.setInventory(InventoryConstants.Pets))
					end,
					size = UDim2.fromScale(0.32, 1),
				}),
				Boosts = Panel({
					order = 2,
					text = "Boosts",
					icon = UI.Boosts,
					isActive = InventoryReducer.Inventory == InventoryConstants.Boosts,
					action = function()
						Store:dispatch(InventoryActions.setInventory(InventoryConstants.Boosts))
					end,
					size = UDim2.fromScale(0.32, 1),
				}),
				Fruits = Panel({
					order = 3,
					text = "Fruits",
					icon = UI.Fruits,
					isActive = InventoryReducer.Inventory == InventoryConstants.Fruits,
					action = function()
						Store:dispatch(InventoryActions.setInventory(InventoryConstants.Fruits))
					end,
					size = UDim2.fromScale(0.32, 1),
				}),
			}),

			Pets = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Visible = InventoryReducer.Inventory == InventoryConstants.Pets,
			}, {
				Content = Pets(hooks),
			}),

			Boosts = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Visible = InventoryReducer.Inventory == InventoryConstants.Boosts,
			}, {
				Content = Boosts(hooks),
			}),

			Fruits = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Visible = InventoryReducer.Inventory == InventoryConstants.Fruits,
			}, {
				Content = Fruits(hooks),
			}),
		}),
	})
end

Inventory = RoactHooks.new(Roact)(Inventory)
return Inventory
