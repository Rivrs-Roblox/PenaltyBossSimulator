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
local UI = DataCacheController:GetFile("Images")
local MonetizationController = Knit.GetController("MonetizationController")

local PetCard = require(script.Parent.PetCard)

-- Wins
return function(props)
	setmetatable(props, {
		__index = {
			order = 2,
		},
	})

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

		Pet_1 = Roact.createElement(PetCard, {
			order = 1,
			name = Template.Shop.OPPets.Pet_1.Name,
			amountText = Template.Shop.OPPets.Pet_1.Text,
			icon = UI[Template.Shop.OPPets.Pet_1.Icon] or "rbxassetid://114828655919261",
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(Template.Shop.OPPets.Pet_1.Name)}`,
			productName = Template.Shop.OPPets.Pet_1.Name,
		}),

		Pet_2 = Roact.createElement(PetCard, {
			order = 2,
			name = Template.Shop.OPPets.Pet_2.Name,
			amountText = Template.Shop.OPPets.Pet_2.Text,
			icon = UI[Template.Shop.OPPets.Pet_2.Icon] or "rbxassetid://114828655919261",
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(Template.Shop.OPPets.Pet_2.Name)}`,
			productName = Template.Shop.OPPets.Pet_2.Name,
		}),

		Pet_3 = Roact.createElement(PetCard, {
			order = 3,
			name = Template.Shop.OPPets.Pet_3.Name,
			amountText = Template.Shop.OPPets.Pet_3.Text,
			icon = UI[Template.Shop.OPPets.Pet_3.Icon] or "rbxassetid://114828655919261",
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(Template.Shop.OPPets.Pet_3.Name)}`,
			productName = Template.Shop.OPPets.Pet_3.Name,
		}),

		Pet_4 = Roact.createElement(PetCard, {
			order = 4,
			name = Template.Shop.OPPets.Pet_4.Name,
			amountText = Template.Shop.OPPets.Pet_4.Text,
			icon = UI[Template.Shop.OPPets.Pet_4.Icon] or "rbxassetid://114828655919261",
			price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(Template.Shop.OPPets.Pet_4.Name)}`,
			productName = Template.Shop.OPPets.Pet_4.Name,
		}),
	})
end
