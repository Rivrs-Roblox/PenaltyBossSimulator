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
			multiplier = coachData.Multiplier,
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(data.productName) or 339}`,
		})
	end

	CoachCardsElements["List"] = Roact.createElement("UIListLayout", {
		Padding = UDim.new(0.03, 0),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	return Roact.createElement("Frame", {
		LayoutOrder = props.order,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.66),
	}, {
		Roact.createFragment(CoachCardsElements),
	})
end
