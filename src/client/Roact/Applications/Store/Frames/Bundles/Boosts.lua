--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")
local UI = DataCacheController:GetFile("Images")
local MonetizationController = Knit.GetController("MonetizationController")
local StoreController = Knit.GetController("StoreController")

local BoostCard = require(script.Parent.BoostCard)

-- Boosts
return function(props)
	setmetatable(props, {
		__index = {
			order = 2,
		},
	})

	return Roact.createElement("Frame", {
		LayoutOrder = props.order,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1.65),
	}, {
		Grid = Roact.createElement("UIGridLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			CellSize = UDim2.fromScale(0.3, 0.45),
			FillDirectionMaxCells = 3,
			CellPadding = UDim2.fromScale(0.02, 0.03),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		Money_2 = Roact.createElement(BoostCard, {
			order = 1,
			colorKey = "Money_2",
			name = Template.Shop.Boosts.Money_2.Name,
			timeText = Template.Shop.Boosts.Money_2.Text,
			icon = UI[Template.Shop.Boosts.Money_2.Icon] or "rbxassetid://132944797019733",
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(Template.Shop.Boosts.Money_2.Name)}`,
			productName = Template.Shop.Boosts.Money_2.Name,
		}),

		Wins = Roact.createElement(BoostCard, {
			order = 2,
			colorKey = "Wins",
			name = Template.Shop.Boosts.Wins.Name,
			timeText = Template.Shop.Boosts.Wins.Text,
			icon = UI[Template.Shop.Boosts.Wins.Icon] or "rbxassetid://132944797019733",
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(Template.Shop.Boosts.Wins.Name)}`,
			productName = Template.Shop.Boosts.Wins.Name,
		}),

		All = Roact.createElement(BoostCard, {
			order = 3,
			colorKey = "All",
			name = Template.Shop.Boosts.All.Name,
			timeText = Template.Shop.Boosts.All.Text,
			icon = UI[Template.Shop.Boosts.All.Icon] or "rbxassetid://132944797019733",
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(Template.Shop.Boosts.All.Name)}`,
			productName = Template.Shop.Boosts.All.Name,
		}),
	})
end
