--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Blue_Background = require(Components.Main.Blue_Background)

-- Services
local DataService = Knit.GetService("DataService")

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")
local TeleportController = Knit.GetController("TeleportController")

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Frames
local Frames = script.Parent.Frames
local Item = require(Frames.Item)

-- Datas
local Template = DataCacheController:GetFile("Template")
local UI = DataCacheController:GetFile("Images")

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FindValue = require(Helpers.Table.FindValue)

-- Travel
function Travel(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)
	local AreaReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.AreaReducer
	end)

	local teleporters = {}
	for _, teleporter in Template.Areas do
		if table.find(AreaReducer.Areas, teleporter.Id) ~= nil then
			teleporters[teleporter.Order] = Item({
				id = teleporter.Id,
				name = teleporter.Name,
				price = 0,
				unlocked = true,
				order = teleporter.Order,
				action = function()
					DataService:GetData(Players.LocalPlayer):andThen(function(playerData)
						TeleportController:RequestTeleport(teleporter.Id)
						UIController:HideFrame()
					end)
				end,
				hooks = hooks,
				mapImage = teleporter.Image,
			})
		else
			teleporters[teleporter.Order] = Item({
				id = teleporter.Id,
				name = teleporter.Name,
				price = teleporter.Price,
				unlocked = false,
				order = teleporter.Order,
				action = function()
					UIController:BuyArea(teleporter)
				end,
				hooks = hooks,
				mapImage = teleporter.Image,
			})
		end
	end

	-- Layout helpers injected into children table
	teleporters["UIPadding"] = Roact.createElement("UIPadding", {
		PaddingTop = UDim.new(0.025, 0),
		PaddingLeft = UDim.new(0.05, 0),
		PaddingRight = UDim.new(0.05, 0),
	})
	teleporters["List"] = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0.03, 0),
	})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Content = Blue_Background({
			title = "Travel",
			titleIcon = UI.Travel or "rbxassetid://83238579499788",
			size = UDim2.fromScale(0.7, 0.7),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 0.95,
			condition = UIReducer.CurrentUI == FramesConstants.Travel,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
		}, {
			Scroll = Roact.createElement("ScrollingFrame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.57),
				BackgroundTransparency = 1,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 8,
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromScale(0, 2),
				Size = UDim2.fromScale(0.96, 0.799),
				ZIndex = 2,
			}, teleporters),
		}),
	})
end

Travel = RoactHooks.new(Roact)(Travel)
return Travel
