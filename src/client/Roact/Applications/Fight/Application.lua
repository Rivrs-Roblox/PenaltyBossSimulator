--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local AspectRatio = require(Components.AspectRatio)
local Corner = require(Components.Corner)
local Stroke = require(Components.Stroke)
local Text = require(Components.Text)
local Image = require(Components.Image)
local ClickFrame = require(script.Parent.Click)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local AutoController = Knit.GetController("AutoController")

-- UI
local UI = DataCacheController:GetFile("Images")

-- Fight
function Fight(_, hooks)
	local fightReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.FightReducer
	end)
	local autoReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.AutoReducer
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.931),
		Size = UDim2.fromScale(0.349, 0.083),
		-- BackgroundColor3 = Color3.fromRGB(255, 38, 38),
		BackgroundTransparency = 1,
		Visible = fightReducer.Fighting,
		ZIndex = 1,
	}, {
		-- UIAspectRadioConstraint = AspectRatio({ ratio = 9 }),
		-- UICorner = Corner({ radius = 1 }),
		-- UIStroke = Stroke({ color = Color3.fromRGB(15, 15, 15), thick = 3 }),

		-- Indicator = Roact.createElement("Frame", {
		-- 	BackgroundColor3 = Color3.fromRGB(0, 292, 0),
		-- 	Size = UDim2.fromScale(fightReducer.BarSize, 1),
		-- 	ZIndex = 2,
		-- }, {
		-- 	UICorner = Corner({ radius = 1 }),
		-- }),

		-- Shine = Roact.createElement("Frame", {
		-- 	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		-- 	BackgroundTransparency = 0.8,
		-- 	Position = UDim2.fromScale(-0.014, 0.217),
		-- 	Size = UDim2.fromScale(0.996, 0.225),
		-- 	ZIndex = 3,
		-- }, {
		-- 	UICorner = Corner({ radius = 0.1 }),
		-- }),

		-- BossImage = Image({
		-- 	image = UI.Player,
		-- 	size = UDim2.fromScale(0.152, 1.681),
		-- 	position = UDim2.fromScale(1.038, 0.497),
		-- 	stroke = 3,
		-- 	index = 4,
		-- 	backgroundTransparency = 0,
		-- 	children = {
		-- 		UIAspectRadioConstraint = AspectRatio({ ratio = 1 }),
		-- 		UICorner = Corner({ radius = 1 }),
		-- 		Name = Text({
		-- 			text = fightReducer.BossName,
		-- 			size = UDim2.fromScale(1.5, 0.335),
		-- 			position = UDim2.fromScale(0.5, 0),
		-- 			stroke = 2,
		-- 			color = Color3.fromRGB(255, 255, 255),
		-- 			index = 5,
		-- 		}),
		-- 		Power = Text({
		-- 			text = FormatNumber(fightReducer.BossPower),
		-- 			size = UDim2.fromScale(1.232, 0.489),
		-- 			position = UDim2.fromScale(0.496, 0.957),
		-- 			stroke = 2,
		-- 			color = Color3.fromRGB(255, 255, 255),
		-- 			index = 5,
		-- 		}),
		-- 	},
		-- }),

		-- PlayerImage = Image({
		-- 	image = UI.Player,
		-- 	size = UDim2.fromScale(0.152, 1.681),
		-- 	position = UDim2.fromScale(-0.041, 0.497),
		-- 	stroke = 3,
		-- 	index = 4,
		-- 	backgroundTransparency = 0,
		-- 	children = {
		-- 		UIAspectRadioConstraint = AspectRatio({ ratio = 1 }),
		-- 		UICorner = Corner({ radius = 1 }),
		-- 		Name = Text({
		-- 			text = "You",
		-- 			size = UDim2.fromScale(1.5, 0.335),
		-- 			position = UDim2.fromScale(0.5, 0),
		-- 			stroke = 2,
		-- 			color = Color3.fromRGB(255, 255, 255),
		-- 			index = 5,
		-- 		}),
		-- 		Power = Text({
		-- 			text = FormatNumber(fightReducer.ClientPower),
		-- 			size = UDim2.fromScale(1.232, 0.489),
		-- 			position = UDim2.fromScale(0.496, 0.957),
		-- 			stroke = 2,
		-- 			color = Color3.fromRGB(255, 255, 255),
		-- 			index = 5,
		-- 		}),
		-- 	},
		-- }),

		-- Cancel = Roact.createElement("Frame", {
		-- 	AnchorPoint = Vector2.new(0.5, 0.5),
		-- 	Position = UDim2.fromScale(-0.3, 0.5),
		-- 	Size = UDim2.fromScale(0.135, 1.2),
		-- 	BackgroundTransparency = 1,
		-- 	ClipsDescendants = true,
		-- 	Visible = autoReducer.AutoWinning == true,
		-- }, {
		-- 	Cross = Roact.createElement("ImageButton", {
		-- 		AnchorPoint = Vector2.new(0.5, 0.5),
		-- 		BackgroundTransparency = 1,
		-- 		Position = UDim2.fromScale(1, 0.5),
		-- 		Rotation = 30,
		-- 		Size = UDim2.fromScale(1, 1),
		-- 		Image = "rbxassetid://76247528104943",

		-- 		[Roact.Event.MouseButton1Click] = function()
		-- 			AutoController:StopAutoWin()
		-- 		end,
		-- 	}),
		-- }),

		-- Click = Text({
		-- 	text = `Start Tapping ({fightReducer.AverageClicks}/s)`,
		-- 	stroke = 2,
		-- 	color = Color3.fromRGB(255, 255, 255),
		-- 	size = UDim2.fromScale(0.5, 0.791),
		-- 	position = UDim2.fromScale(0.5, -0.544),
		-- 	index = 4,
		-- }),

		-- ClickFrame = Roact.createElement(ClickFrame),
		-- Timer = Text({
		-- 	text = "3",
		-- 	stroke = 2,
		-- 	color = Color3.fromRGB(255, 255, 255),
		-- 	size = UDim2.fromScale(0.11, 1.338),
		-- 	position = UDim2.fromScale(0.5, -4.263),
		-- 	index = 4,
		-- }),
	})
end

Fight = RoactHooks.new(Roact)(Fight)
return Fight
