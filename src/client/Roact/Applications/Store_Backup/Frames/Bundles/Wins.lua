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
    local PACKS_BASE = Template.WinsPacks

    return math.round(
        PACKS_BASE[zone[table.maxn(zone)]][pack]
        + PACKS_BASE[zone[table.maxn(zone)]][pack] * (0.2 * rebirth)
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