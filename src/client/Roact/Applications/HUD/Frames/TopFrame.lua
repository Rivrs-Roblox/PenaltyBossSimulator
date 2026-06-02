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
local TopLargeDisplay = require(Components.TopLargeDisplay)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")

-- Datas
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

-- TopFrame
function TopFrame(_, hooks)
	local playerReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.PlayerReducer
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0),
		BackgroundColor3 = Color3.fromHex("142184"),
		Size = UDim2.fromScale(0.98, 0.11),
	}, {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0.1, 0),
		}),
		UIListLayout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0.01, 0),
			FillDirection = 0,
			HorizontalAlignment = 0,
			SortOrder = 2,
		}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0.15, 0),
		}),

		Rebirths = Roact.createElement(
			TopLargeDisplay,
			{ image = UI.Rebirths, mainText = playerReducer.Rebirth, bottomText = "Rebirths", order = 1 }
		),
		--Money1 = TopLargeDisplay({ image = UI.Money1, mainText = FormatNumber(playerReducer.Money1), bottomText = Template.Economy.Money1, order = 2 }),
		Money2 = Roact.createElement(TopLargeDisplay, {
			image = UI.Money2,
			mainText = playerReducer.Money2,
			bottomText = Template.Economy.Money2,
			order = 3,
			storeSection = "Boosts",
		}),
		Wins = Roact.createElement(
			TopLargeDisplay,
			{ image = UI.Wins, mainText = playerReducer.Wins, bottomText = "Wins", order = 4, storeSection = "Wins" }
		),
	})
end

TopFrame = RoactHooks.new(Roact)(TopFrame)
return TopFrame
