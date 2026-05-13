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

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local AutoUIButton = require(Components.AutoUIButton)
local Text = require(Components.Text)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local UI = DataCacheController:GetFile("Images")

function BottomFrame(_, hooks)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.99),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.2, 0.1),
	}, {
		Center = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				VerticalAlignment = 0,
				SortOrder = 2,
				HorizontalAlignment = 0,
				Padding = UDim.new(0.07, 0),
				FillDirection = 0,
			}),
			AutoTrain = AutoUIButton({
				autoType = "AutoTraining",
				icon = UI.Money2,
				text = "Training",
				hooks = hooks,
				order = 1,
			}),
			AutoWin = AutoUIButton({
				autoType = "AutoWinning",
				icon = UI.Wins,
				text = "Win",
				hooks = hooks,
				order = 2,
			}),
		}),
		Text = Text({
			text = "Auto (Free!)",
			color = Color3.fromHex("fafafa"),
			anchorPoint = Vector2.new(0.5, 1),
			position = UDim2.fromScale(0.5, -0.05),
			size = UDim2.fromScale(0.85, 0.3),
			index = 5,
			stroke = 1.5,
			strokeColor = Color3.fromHex("8a1616"),
		}),
	})
end

BottomFrame = RoactHooks.new(Roact)(BottomFrame)
return BottomFrame
