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
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")
local UI = DataCacheController:GetFile("Images")
local MonetizationController = Knit.GetController("MonetizationController")
local StoreController = Knit.GetController("StoreController")

local function calculateAmount(zone, rebirth, pack)
	local PACKS_BASE = Template.WinsPacks

	return PACKS_BASE[zone[table.maxn(zone)]][pack]
end

local WinsCard = require(script.Parent.WinsCard)

-- Wins
return function(props)
	setmetatable(props, {
		__index = {
			order = 2,
		},
	})

	local PlayerReducer = RoduxHooks.useSelector(props.hooks, function(state)
		return state.PlayerReducer
	end)
	local AreaReducer = RoduxHooks.useSelector(props.hooks, function(state)
		return state.AreaReducer
	end)

	return Roact.createElement("Frame", {
		LayoutOrder = props.order,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.87),
	}, {
		List = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0.02, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Pack1 = Roact.createElement(WinsCard, {
			order = 1,
			name = "Small",
			amountText = `+{FormatNumber(calculateAmount(AreaReducer.Areas, PlayerReducer.Rebirth, "SMALL"))} Wins`,
			icon = UI[Template.Shop.Wins.Pack_1.Icon] or "rbxassetid://114828655919261",
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(Template.Shop.Wins.Pack_1.Name)}`,
			productName = Template.Shop.Wins.Pack_1.Name,
			tier = 1,
		}),

		Pack2 = Roact.createElement(WinsCard, {
			order = 2,
			name = "Regular",
			amountText = `+{FormatNumber(calculateAmount(AreaReducer.Areas, PlayerReducer.Rebirth, "REGULAR"))} Wins`,
			icon = UI[Template.Shop.Wins.Pack_2.Icon] or "rbxassetid://114828655919261",
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(Template.Shop.Wins.Pack_2.Name)}`,
			productName = Template.Shop.Wins.Pack_2.Name,
			tier = 2,
		}),

		Pack3 = Roact.createElement(WinsCard, {
			order = 3,
			name = "Big",
			amountText = `+{FormatNumber(calculateAmount(AreaReducer.Areas, PlayerReducer.Rebirth, "BIG"))} Wins`,
			icon = UI[Template.Shop.Wins.Pack_3.Icon] or "rbxassetid://114828655919261",
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(Template.Shop.Wins.Pack_3.Name)}`,
			productName = Template.Shop.Wins.Pack_3.Name,
			tier = 3,
		}),

		Pack4 = Roact.createElement(WinsCard, {
			order = 4,
			name = "Huge",
			amountText = `+{FormatNumber(calculateAmount(AreaReducer.Areas, PlayerReducer.Rebirth, "HUGE"))} Wins`,
			icon = UI[Template.Shop.Wins.Pack_4.Icon] or "rbxassetid://114828655919261",
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(Template.Shop.Wins.Pack_4.Name)}`,
			productName = Template.Shop.Wins.Pack_4.Name,
			tier = 4,
		}),
	})
end
