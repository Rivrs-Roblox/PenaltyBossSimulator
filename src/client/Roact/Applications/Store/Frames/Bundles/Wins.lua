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
	local PACKS_BASE = {
		["Zone1"] = { SMALL = 40, REGULAR = 300, BIG = 3000, HUGE = 60000 },
		["Zone2"] = { SMALL = 600, REGULAR = 4500, BIG = 45000, HUGE = 900000 },
		["Zone3"] = { SMALL = 9000, REGULAR = 67500, BIG = 675000, HUGE = 13500000 },
		["Zone4"] = { SMALL = 135000, REGULAR = 1012500, BIG = 10125000, HUGE = 202500000 },
		["Zone5"] = { SMALL = 2025000, REGULAR = 15187500, BIG = 151875000, HUGE = 3037500000 },
		["Zone6"] = { SMALL = 30375000, REGULAR = 227812500, BIG = 2278125000, HUGE = 45562500000 },
		["Zone7"] = { SMALL = 455625000, REGULAR = 3417187500, BIG = 34171875000, HUGE = 683437500000 },
		["Zone8"] = { SMALL = 6834375000, REGULAR = 51257812500, BIG = 512578125000, HUGE = 10251562500000 },
		["Zone9"] = { SMALL = 102515625000, REGULAR = 768867187500, BIG = 7688671875000, HUGE = 153773437500000 },
		["Zone10"] = {
			SMALL = 1537734375000,
			REGULAR = 11533007812500,
			BIG = 115330078125000,
			HUGE = 2306601562500000,
		},
		["Zone11"] = {
			SMALL = 23066015625000,
			REGULAR = 172995117187500,
			BIG = 1729951171875000,
			HUGE = 34599023437500000,
		},
		["Zone12"] = {
			SMALL = 345990234375000,
			REGULAR = 2594926757812500,
			BIG = 25949267578125000,
			HUGE = 518985351562500000,
		},
		["Zone13"] = {
			SMALL = 5189853515625000,
			REGULAR = 38923901367187500,
			BIG = 389239013671875000,
			HUGE = 7784780273437499400,
		},
		["Zone14"] = {
			SMALL = 77847802734375000,
			REGULAR = 583858520507812600,
			BIG = 5838585205078125600,
			HUGE = 116771704101562482680,
		},
		["Zone15"] = {
			SMALL = 116771704101562510,
			REGULAR = 875787780761718910,
			BIG = 8757877807617187800,
			HUGE = 175157556152343724000,
		},
		["Zone16"] = {
			SMALL = 175157556152343770,
			REGULAR = 1313681671142578430,
			BIG = 13136816711425781700,
			HUGE = 262736334228515586000,
		},
		["Zone17"] = {
			SMALL = 1313681671142578000,
			REGULAR = 9852612533569338000,
			BIG = 98526125335693380000,
			HUGE = 1970522506713867700000,
		},
		["Zone18"] = {
			SMALL = 9852612533569337000,
			REGULAR = 73894594001770030000,
			BIG = 738945940017700300000,
			HUGE = 14789188003540006000000,
		},
	}

	return math.round(
		PACKS_BASE[zone[table.maxn(zone)]][pack] + PACKS_BASE[zone[table.maxn(zone)]][pack] * (1.1 * rebirth)
	)
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
