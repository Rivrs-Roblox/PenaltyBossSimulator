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
local White_Background = require(Components.Main.White_Background)
local AspectRatio = require(Components.AspectRatio)
local Text = require(Components.Text)
local List = require(Components.List)

-- Frames
local Featured = require(script.Parent.Frames.Featured.Featured)
local Gamepasses = require(script.Parent.Frames.Gamepasses.Gamepasses)
local Pets = require(script.Parent.Frames.Bundles.Pets)
local Wins = require(script.Parent.Frames.Bundles.Wins)
local Boosts = require(script.Parent.Frames.Bundles.Boosts)

local GamepassItem = require(script.Parent.Frames.Gamepasses.Item)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")

-- Store
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

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.55, 0.55),
		BackgroundTransparency = 1,
	}, {
		Content = White_Background({
			title = "Exclusive Store",
			size = UDim2.fromScale(1, 1),
			pos = UDim2.fromScale(0.5, 0.5),
			condition = UIReducer.CurrentUI == FramesConstants.Store,
			ratio = 1.7,
			hooks = hooks,
		}, {
			Container = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.497, 0.515),
				Size = UDim2.fromScale(0.952, 0.869),
			}, {
				Ratio = AspectRatio({ ratio = 1.9 }),

				ShopScroll = Roact.createElement("ScrollingFrame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.519),
					Size = UDim2.fromScale(1, 1.037),
					CanvasSize = UDim2.fromScale(1.3, 0),
					ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
					ScrollBarImageTransparency = 0.32,
					ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
					ScrollBarThickness = 7,
					BorderSizePixel = 0,
					AutomaticCanvasSize = Enum.AutomaticSize.X,
				}, {
					Content = Roact.createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.478, 0.537),
						Size = UDim2.fromScale(0.906, 0.876),
						BackgroundTransparency = 1,
					}, {
						List = List({
							padding = UDim.new(0.03, 0),
							fillDirection = Enum.FillDirection.Horizontal,
							horizontalAlignment = Enum.HorizontalAlignment.Left,
							verticalAlignment = Enum.VerticalAlignment.Top,
						}),
						Featured = Featured(hooks),
						Gamepasses = Gamepasses(GamepassItems),
						Pets = Pets(hooks),
						Wins = Wins(hooks),
						Boosts = Boosts(hooks),
					}),

					Featured = Text({
						text = "Featured",
						BackgroundTransparency = 1,
						color = Color3.fromRGB(25, 25, 25),
						transparency = 0.63,
						size = UDim2.fromScale(0.22, 0.081),
						position = UDim2.fromScale(0.125, 0.037),
					}),
					Gamepasses = Text({
						text = "Gamepasses",
						BackgroundTransparency = 1,
						color = Color3.fromRGB(25, 25, 25),
						transparency = 0.63,
						size = UDim2.fromScale(0.22, 0.081),
						position = UDim2.fromScale(0.878, 0.037),
					}),
					Pets = Text({
						text = "Pets",
						BackgroundTransparency = 1,
						color = Color3.fromRGB(25, 25, 25),
						transparency = 0.63,
						size = UDim2.fromScale(0.22, 0.081),
						position = UDim2.fromScale(3.11, 0.037),
					}),
					Wins = Text({
						text = "Wins",
						BackgroundTransparency = 1,
						color = Color3.fromRGB(25, 25, 25),
						transparency = 0.63,
						size = UDim2.fromScale(0.22, 0.081),
						position = UDim2.fromScale(4.23, 0.037),
					}),
					Boosts = Text({
						text = "Boosts",
						BackgroundTransparency = 1,
						color = Color3.fromRGB(25, 25, 25),
						transparency = 0.63,
						size = UDim2.fromScale(0.22, 0.081),
						position = UDim2.fromScale(5.36, 0.037),
					}),
				}),
			}),
		}),
	})
end

Store = RoactHooks.new(Roact)(Store)
return Store
