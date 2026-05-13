--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")
local MonetizationController = Knit.GetController("MonetizationController")

local PlayerCard = require(script.Parent.PlayerCard)

-- Featured
return function(props)
	setmetatable(props, {
		__index = {
			order = 2,
		},
	})

	local PlayerCardsElements = {}
	for index, data in ipairs(Template.Shop.Featured.MainCards) do
		local charData = Template.Characters[data.id]
		PlayerCardsElements["Card" .. index] = Roact.createElement(PlayerCard, {
			order = index,
			name = data.name,
			productName = data.productName,
			icon = charData.Image,
			multiplier = charData.Multiplier,
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(data.productName) or 339}`,
		})
	end

	PlayerCardsElements["List"] = Roact.createElement("UIListLayout", {
		Padding = UDim.new(0.025, 0),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	return Roact.createElement("Frame", {
		LayoutOrder = props.order,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.866),
	}, {
		Roact.createFragment(PlayerCardsElements),
	})
end
