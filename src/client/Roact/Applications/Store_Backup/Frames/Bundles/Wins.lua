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

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local Gradient = require(Components.Gradient)
local Corner = require(Components.Corner)
local Stroke = require(Components.Stroke)
local Text = require(Components.Text)
local List = require(Components.List)
local ShopCard = require(Components.Shop.ShopCard)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")
local Colors = DataCacheController:GetFile("Colors")

function calculateAmount(zone, rebirth, pack)
    local PACKS_BASE = {
		["Zone1"] = {
			SMALL = 40,
			REGULAR = 300,
			BIG = 3000,
			HUGE = 60000,
		},
		["Zone2"] = {
			SMALL = 600,
			REGULAR = 4500,
			BIG = 45000,
			HUGE = 900000,
		},
		["Zone3"] = {
			SMALL = 9000,
			REGULAR = 67500,
			BIG = 675000,
			HUGE = 13500000,
		},
		["Zone4"] = {
			SMALL = 135000,
			REGULAR = 1012500,
			BIG = 10125000,
			HUGE = 202500000,
		},
		["Zone5"] = {
			SMALL = 2025000,
			REGULAR = 15187500,
			BIG = 151875000,
			HUGE = 3037500000,
		},
		["Zone6"] = {
			SMALL = 30375000,
			REGULAR = 227812500,
			BIG = 2278125000,
			HUGE = 45562500000,
		},
		["Zone7"] = {
			SMALL = 455625000,
			REGULAR = 3417187500,
			BIG = 34171875000,
			HUGE = 683437500000,
		},
		["Zone8"] = {
			SMALL = 6834375000,
			REGULAR = 51257812500,
			BIG = 512578125000,
			HUGE = 10251562500000,
		},
		["Zone9"] = {
			SMALL = 102515625000,
			REGULAR = 768867187500,
			BIG = 7688671875000,
			HUGE = 153773437500000,
		},
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
        PACKS_BASE[zone[table.maxn(zone)]][pack]
        + PACKS_BASE[zone[table.maxn(zone)]][pack] * (1.1 * rebirth)
    )
end

-- Wins
return function(hooks)
    local PlayerReducer = RoduxHooks.useSelector(hooks, function(state) return state.PlayerReducer end)
    local AreaReducer = RoduxHooks.useSelector(hooks, function(state) return state.AreaReducer end)

    return Roact.createElement("Frame", {
        Position = UDim2.fromScale(2.84, 0),
        Size = UDim2.fromScale(1.2, 0.95),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ClipsDescendants = true,
        LayoutOrder = 4
    }, {
        Gradient = Gradient({ startColor = Colors.Gradients.Blue.startColor, endColor = Colors.Gradients.Blue.endColor, rotation = 270 }),
        Corner = Corner({ radius = 0.04 }),
        Stroke = Stroke({ thick = 3 }),

        Name = Text({ text = "Wins Packs", position = UDim2.fromScale(0.25, 0.077), size = UDim2.fromScale(0.411, 0.1), backgroundTransparency = 1, color = Color3.fromRGB(255, 255, 255), index = 3, stroke = 2, align = Enum.TextXAlignment.Left }),
        Description = Text({ text = Template.Shop.Wins.Description, position = UDim2.fromScale(0.79, 0.1), size = UDim2.fromScale(0.318, 0.15), backgroundTransparency = 1, color = Color3.fromRGB(255, 255, 255), index = 3, stroke = 2, align = Enum.TextXAlignment.Right }),

        Content = Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.6),
            Size = UDim2.fromScale(0.934, 0.731),
            BackgroundTransparency = 1
        }, {
            List = List({ padding = UDim.new(0.03, 0), fillDirection = Enum.FillDirection.Horizontal, horizontalAlignment = Enum.HorizontalAlignment.Left, verticalAlignment = Enum.VerticalAlignment.Center }),

            ShopCard({ size = UDim2.fromScale(0.225, 0.833), hooks = hooks }, Template.Shop.Wins.Pack_1, `+{FormatNumber(calculateAmount(AreaReducer.Areas, PlayerReducer.Rebirth, "SMALL"))} Wins`),
            ShopCard({ size = UDim2.fromScale(0.225, 0.833), hooks = hooks }, Template.Shop.Wins.Pack_2, `+{FormatNumber(calculateAmount(AreaReducer.Areas, PlayerReducer.Rebirth, "REGULAR"))} Wins`),
            ShopCard({ size = UDim2.fromScale(0.225, 0.833), hooks = hooks }, Template.Shop.Wins.Pack_3, `+{FormatNumber(calculateAmount(AreaReducer.Areas, PlayerReducer.Rebirth, "BIG"))} Wins`),
            ShopCard({ size = UDim2.fromScale(0.225, 0.833), hooks = hooks }, Template.Shop.Wins.Pack_4, `+{FormatNumber(calculateAmount(AreaReducer.Areas, PlayerReducer.Rebirth, "HUGE"))} Wins`),
        })
    })
end