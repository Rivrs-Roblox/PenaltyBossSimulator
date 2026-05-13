--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local White_Background = require(Components.Main.White_Background)
local ImageButton = require(Components.ImageButton)
local Text = require(Components.Text)
local AspectRatio = require(Components.AspectRatio)
local List = require(Components.List)
local Grid = require(Components.Grid)
local Blue_Background = require(Components.Main.Blue_Background)
local Panel = require(Components.Panel)
local NewImageButton = RoactHooks.new(Roact)(require(Components.NewImageButton))

-- Frames
local Frames = script.Parent.Frames
local TrailCard = require(Frames.TrailCard)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local StoreController = Knit.GetController("StoreController")
local MonetizationController = Knit.GetController("MonetizationController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

function Trail(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)
	local TrailsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.TrailsReducer
	end)
	-- local NotificationReducer = RoduxHooks.useSelector(hooks, function(state)
	-- 	return state.NotificationReducer
	-- end)

	-- local TrailsNotif = NotificationReducer.Notifications["Trails"] or 0
	-- local CoachNotif = NotificationReducer.Notifications["Coaches"] or 0
	-- local CharacterNotif = NotificationReducer.Notifications["Characters"] or 0

	local Trails = {}
	for index, trail in pairs(Template.Trails) do
		Trails[index] = TrailCard({
			id = index,
			name = trail.Name,
			displayName = trail.DisplayName,
			price = trail.Price,
			image = trail.Image,
			possessed = table.find(TrailsReducer.Trails, index) ~= nil,
			equipped = TrailsReducer.CurrentTrail == index,
			multiplier = trail.Multiplier,
			VIP = trail.VIP,
			speed = trail.Speed,
			order = trail.Order,
		}, hooks)
	end

	return Roact.createElement("Frame", {
		Visible = true,
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 2,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
	}, {
		Content = Blue_Background({
			title = "Trails",
			titleIcon = UI.Trails,
			size = UDim2.fromScale(0.7, 0.7),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.6,
			condition = UIReducer.CurrentUI == FramesConstants.Trails,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
		}, {
			-- Panels = Roact.createElement("Frame", {
			-- 	AnchorPoint = Vector2.new(0.5, 0.5),
			-- 	BackgroundTransparency = 1,
			-- 	Position = UDim2.fromScale(0.5, 0.2),
			-- 	Size = UDim2.fromScale(0.91, 0.1),
			-- }, {
			-- 	UIListLayout = Roact.createElement("UIListLayout", {
			-- 		VerticalAlignment = 0,
			-- 		SortOrder = 2,
			-- 		HorizontalAlignment = 0,
			-- 		Padding = UDim.new(0.01, 0),
			-- 		FillDirection = 0,
			-- 	}),

			-- 	Panel1 = Panel({
			-- 		order = 1,
			-- 		isActive = false,
			-- 		text = "Players",
			-- 		icon = UI.Characters,
			-- 		action = function()
			-- 			UIController:ShowFrame({ frame = "Characters" })
			-- 		end,
			-- 		notificationNumber = CharacterNotif,
			-- 	}),
			-- 	Panel2 = Panel({
			-- 		order = 2,
			-- 		isActive = false,
			-- 		text = "Coaches",
			-- 		icon = UI.Coaches,
			-- 		action = function()
			-- 			UIController:ShowFrame({ frame = "Coach" })
			-- 		end,
			-- 		notificationNumber = CoachNotif,
			-- 	}),
			-- 	Panel3 = Panel({
			-- 		order = 3,
			-- 		isActive = true,
			-- 		text = "Trails",
			-- 		icon = UI.Trails,
			-- 		action = function()
			-- 			-- UIController:ShowFrame({ frame = "Trails" })
			-- 		end,
			-- 		notificationNumber = TrailsNotif,
			-- 	}),
			-- }),

			ActionContainer = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.612, 0.93),
				BorderColor3 = Color3.fromHex("000000"),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.686, 0.1),
			}, {
				Skip1 = Roact.createElement(NewImageButton, {
					layoutOrder = 2,
					color = Color3.fromHex("1b8d1b"),
					price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice("Trail - Skip 1")}`,
					priceStroke = Color3.fromHex("052f03"),
					text = "Skip 1",
					textStroke = Color3.fromHex("052f03"),
					onClick = function()
						StoreController:BuyItem({ name = "Trail - Skip 1" })
					end,
				}),
				SkipAll = Roact.createElement(NewImageButton, {
					layoutOrder = 3,
					color = Color3.fromHex("ff6734"),
					price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice("Trail - Buy All")}`,
					priceStroke = Color3.fromHex("671311"),
					text = "Buy All",
					textStroke = Color3.fromHex("671311"),
					onClick = function()
						StoreController:BuyItem({ name = "Trail - Buy All" })
					end,
				}),
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = 0,
					SortOrder = 2,
					HorizontalAlignment = 2,
					Padding = UDim.new(0.01, 0),
					FillDirection = 0,
				}),
			}),
			Container = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
			}, {
				ScrollingFrame = Roact.createElement("ScrollingFrame", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.843),
					Size = UDim2.fromScale(0.95, 0.678),
					ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
					AutomaticCanvasSize = Enum.AutomaticSize.XY,
					ScrollingDirection = Enum.ScrollingDirection.XY,
					ScrollBarImageTransparency = 0.32,
					ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
					ScrollBarThickness = 0,
					ClipsDescendants = true,
					BorderSizePixel = 0,
					CanvasSize = UDim2.fromScale(0, 1.8),
				}, {
					Padding = Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0.03, 0),
					}),
					Grid = Grid({
						cellPadding = UDim2.fromScale(0.02, 0.07),
						cellSize = UDim2.fromScale(0.23, 0.58),
						fillDirection = Enum.FillDirection.Horizontal,
						horizontalAlignment = Enum.HorizontalAlignment.Center,
						verticalAlignment = Enum.VerticalAlignment.Top,
					}),
					Roact.createFragment(Trails),
				}),
			}),
		}),
	})
end

Trail = RoactHooks.new(Roact)(Trail)
return Trail
