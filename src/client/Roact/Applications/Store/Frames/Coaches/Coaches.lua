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

local CoachCard = require(script.Parent.CoachCard)

-- Featured
return function(props)
	setmetatable(props, {
		__index = {
			order = 2,
		},
	})

	local CoachCardsElements = {}
	for index, data in ipairs(Template.Shop.Featured.SubCards) do
		local coachData = Template.Coaches[data.id]
		CoachCardsElements["Card" .. index] = Roact.createElement(CoachCard, {
			order = index,
			name = data.name,
			productName = data.productName,
			icon = coachData.Image,
			flag = coachData.Flag,
			multiplier = coachData.Multiplier,
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(data.productName) or 339}`,
		})
	end

	CoachCardsElements["List"] = Roact.createElement("UIListLayout", {
		Padding = UDim.new(0.02, 0),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	return Roact.createElement("Frame", {
		LayoutOrder = props.order,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.7),
	}, {
		Roact.createFragment(CoachCardsElements),
	})
end
