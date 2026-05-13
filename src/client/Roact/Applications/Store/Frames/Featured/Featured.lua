local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.roact)
local Knit = require(ReplicatedStorage.Packages.Knit)

local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")

local FeaturedCard = require(script.Parent.FeaturedCard)

return function(props)
	setmetatable(props, {
		__index = {
			order = 2,
		},
	})

	local EggsElements = {}

	if Template.Shop.Featured.Eggs then
		for index, data in ipairs(Template.Shop.Featured.Eggs) do
			EggsElements["Card" .. index] = Roact.createElement(FeaturedCard, {
				order = index,
				name = data.name,
				eggId = data.eggId,
				icon = data.icon,
				price1 = data.price1,
				price3 = data.price3,
				price8 = data.price8,
				product1 = data.product1,
				product3 = data.product3,
				product8 = data.product8,
			})
		end
	end

	EggsElements["List"] = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0.03, 0),
	})

	return Roact.createElement("Frame", {
		LayoutOrder = props.order,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1.5),
	}, EggsElements)
end
