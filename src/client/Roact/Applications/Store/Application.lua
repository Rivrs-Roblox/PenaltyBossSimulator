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
local Text = require(Components.Text)

-- Frames
local Featured = require(script.Parent.Frames.Featured.Featured)
local Gamepasses = require(script.Parent.Frames.Gamepasses.Gamepasses)
local Wins = require(script.Parent.Frames.Bundles.Wins)
local Boosts = require(script.Parent.Frames.Bundles.Boosts)
local Players = require(script.Parent.Frames.Players.Players)
local Coaches = require(script.Parent.Frames.Coaches.Coaches)
local Pets = require(script.Parent.Frames.Pets.Pets)

local GamepassItem = require(script.Parent.Frames.Gamepasses.Item)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")
local UI = DataCacheController:GetFile("Images")

-- Store
local scrollRef = Roact.createRef()
local featuredRef = Roact.createRef()
local gamepassRef = Roact.createRef()
local winsRef = Roact.createRef()
local boostsRef = Roact.createRef()

function Store(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)
	local MonetizationReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.MonetizationReducer
	end)

	local function HasGamepass(name)
		for _, pass in MonetizationReducer.Gamepasses do
			if pass == name then
				return true
			end
		end

		return false
	end

	local GamepassItems = {}
	for index, Item in pairs(Template.Shop.Gamepasses) do
		GamepassItems[index] = GamepassItem(Item, index, HasGamepass(Item.Name), hooks)
	end

	local activeTab, setActiveTab = hooks.useState("Featured")

	local function scrollTo(targetRef, tabName)
		setActiveTab(tabName)
		local scrollFrame = scrollRef:getValue()
		local target = targetRef:getValue()
		if scrollFrame and target then
			local offset = target.AbsolutePosition.Y - scrollFrame.AbsolutePosition.Y + scrollFrame.CanvasPosition.Y
			scrollFrame.CanvasPosition = Vector2.new(0, offset)
		end
	end

	local function onScroll(rbx)
		local scrollY = rbx.CanvasPosition.Y

		local fAnchor = featuredRef:getValue()
		local gAnchor = gamepassRef:getValue()
		local wAnchor = winsRef:getValue()
		local bAnchor = boostsRef:getValue()

		if not (fAnchor and gAnchor and wAnchor and bAnchor) then
			return
		end

		local fY = fAnchor.AbsolutePosition.Y - rbx.AbsolutePosition.Y + rbx.CanvasPosition.Y
		local gY = gAnchor.AbsolutePosition.Y - rbx.AbsolutePosition.Y + rbx.CanvasPosition.Y
		local wY = wAnchor.AbsolutePosition.Y - rbx.AbsolutePosition.Y + rbx.CanvasPosition.Y
		local bY = bAnchor.AbsolutePosition.Y - rbx.AbsolutePosition.Y + rbx.CanvasPosition.Y

		local threshold = scrollY + (rbx.AbsoluteSize.Y * 0.3)

		local newTab = "Featured"
		if threshold >= bY then
			newTab = "Boosts"
		elseif threshold >= wY then
			newTab = "Wins"
		elseif threshold >= gY then
			newTab = "Gamepass"
		end

		if newTab ~= activeTab then
			setActiveTab(newTab)
		end
	end

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Content = Blue_Background({
			title = "Store",
			titleIcon = UI.Store,
			size = UDim2.fromScale(0.7, 0.7),
			pos = UDim2.fromScale(0.5, 0.5),
			condition = UIReducer.CurrentUI == FramesConstants.Store,
			ratio = 1.6,
			hooks = hooks,
		}, {
			Panels = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.2),
				Size = UDim2.fromScale(0.91, 0.1),
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = 0,
					SortOrder = 2,
					HorizontalAlignment = 0,
					Padding = UDim.new(0.012, 0),
					FillDirection = 0,
				}),
				FeaturedPanel = Roact.createElement(Panel, {
					order = 1,
					text = "Featured",
					textSize = UDim2.fromScale(0.55, 0.5),
					icon = UI.Featured,
					isActive = activeTab == "Featured",
					size = UDim2.fromScale(0.245, 1),
					action = function()
						scrollTo(featuredRef, "Featured")
					end,
				}),
				GamepassPanel = Roact.createElement(Panel, {
					order = 2,
					text = "Gamepass",
					textSize = UDim2.fromScale(0.55, 0.5),
					icon = UI.Gamepasses,
					isActive = activeTab == "Gamepass",
					size = UDim2.fromScale(0.245, 1),
					action = function()
						scrollTo(gamepassRef, "Gamepass")
					end,
				}),
				WinsPanel = Roact.createElement(Panel, {
					order = 3,
					text = "Wins",
					textSize = UDim2.fromScale(0.45, 0.5),
					icon = UI.Wins,
					isActive = activeTab == "Wins",
					size = UDim2.fromScale(0.245, 1),
					action = function()
						scrollTo(winsRef, "Wins")
					end,
				}),
				BoostsPanel = Roact.createElement(Panel, {
					order = 4,
					text = "Boosts",
					textSize = UDim2.fromScale(0.45, 0.5),
					icon = UI.Boosts,
					isActive = activeTab == "Boosts",
					size = UDim2.fromScale(0.245, 1),
					action = function()
						scrollTo(boostsRef, "Boosts")
					end,
				}),
			}),

			Scroll = Roact.createElement("ScrollingFrame", {
				[Roact.Ref] = scrollRef,
				[Roact.Change.CanvasPosition] = onScroll,
				AutomaticCanvasSize = 2,
				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.fromScale(0.95, 0.705),
				BackgroundTransparency = 1,
				ScrollingDirection = 2,
				Position = UDim2.fromScale(0.5, 0.98),
				ScrollBarThickness = 8,
				BorderSizePixel = 0,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0.005, 0),
				}),
				List = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.05, 0),
				}),

				FeaturedText = Text({
					[Roact.Ref] = featuredRef,
					order = 1,
					text = "Featured",
					size = UDim2.fromScale(0.95, 0.1),
					position = UDim2.fromScale(0.5, 0.5),
					color = Color3.fromHex("ffffff"),
					index = 2,
					align = Enum.TextXAlignment.Left,
				}),
				Featured = Featured({ order = 2, hooks = hooks }),

				PlayersText = Text({
					order = 3,
					text = "Players",
					size = UDim2.fromScale(0.95, 0.1),
					position = UDim2.fromScale(0.5, 0.5),
					color = Color3.fromHex("ffffff"),
					index = 2,
					align = Enum.TextXAlignment.Left,
				}),
				Players = Players({ order = 4, hooks = hooks }),

				CoachesText = Text({
					order = 5,
					text = "Coaches",
					size = UDim2.fromScale(0.95, 0.1),
					position = UDim2.fromScale(0.5, 0.5),
					color = Color3.fromHex("ffffff"),
					index = 2,
					align = Enum.TextXAlignment.Left,
				}),
				Coaches = Coaches({ order = 6, hooks = hooks }),

				PetsText = Text({
					order = 7,
					text = "Exclusive Pets",
					size = UDim2.fromScale(0.95, 0.1),
					position = UDim2.fromScale(0.5, 0.5),
					color = Color3.fromHex("ffffff"),
					index = 2,
					align = Enum.TextXAlignment.Left,
				}),
				Pets = Pets({ order = 8, hooks = hooks }),

				GamepassesText = Text({
					[Roact.Ref] = gamepassRef,
					order = 9,
					text = "Gamepasses",
					size = UDim2.fromScale(0.95, 0.1),
					position = UDim2.fromScale(0.5, 0.5),
					color = Color3.fromHex("ffffff"),
					index = 2,
					align = Enum.TextXAlignment.Left,
				}),
				Gamepasses = Gamepasses({ order = 10, hooks = hooks }, GamepassItems),

				WinPacksText = Text({
					[Roact.Ref] = winsRef,
					order = 11,
					text = "Win Packs",
					size = UDim2.fromScale(0.95, 0.1),
					position = UDim2.fromScale(0.5, 0.5),
					color = Color3.fromHex("ffffff"),
					index = 2,
					align = Enum.TextXAlignment.Left,
				}),
				Wins = Wins({ order = 12, hooks = hooks }),

				BoostsText = Text({
					[Roact.Ref] = boostsRef,
					order = 13,
					text = "Boosts",
					size = UDim2.fromScale(0.95, 0.1),
					position = UDim2.fromScale(0.5, 0.5),
					color = Color3.fromHex("ffffff"),
					index = 2,
					align = Enum.TextXAlignment.Left,
				}),
				Boosts = Boosts({ order = 14, hooks = hooks }),

				Blank = Roact.createElement("Frame", {
					LayoutOrder = 15,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 0.5),
				}),
			}),
		}),
	})
end

Store = RoactHooks.new(Roact)(Store)
return Store
