--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local CollectionService = game:GetService("CollectionService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Zone = require(ReplicatedStorage.Shared.ZonePlus)
local MonetizationService

-- Controllers
local DataCacheController = nil

local monetizationAreas = CollectionService:GetTagged("MonetizationArea")

-- MonetizationController
local MonetizationController = Knit.CreateController({
	Name = "MonetizationController",

	Monetization = {},

	IDs = {},
	Prices = {},
})

--|| Functions ||--
function MonetizationController:GetID(name: string)
	if self.IDs[name] ~= nil then
		return self.IDs[name]
	end

	for typeName, type in pairs(self.Monetization) do
		for id, item in pairs(type) do
			if item.Name == name then
				self.IDs[name] = { ID = id, Type = typeName }
				return { ID = id, Type = typeName }
			end
		end
	end

	return nil
end

function MonetizationController:GetPrice(name: string)
	if self.Prices[name] ~= nil then
		return self.Prices[name]
	end

	local data = self:GetID(name)
	if data == nil then
		return 0
	end

	local success, result = pcall(function()
		return MarketplaceService:GetProductInfo(
			data.ID,
			data.Type == "GamePasses" and Enum.InfoType.GamePass or Enum.InfoType.Product
		)
	end)
	if not success then
        warn("Failed to get price for " .. name)
		return 0
	end

	self.Prices[name] = result.PriceInRobux
	if result.PriceInRobux then
		return result.PriceInRobux
	end
	return 0
end

--|| Knit Lifecycle ||--
function MonetizationController:KnitInit()
	MonetizationService = Knit.GetService("MonetizationService")

	DataCacheController = Knit.GetController("DataCacheController")

	self.Monetization = DataCacheController:GetFile("Monetization")

	task.wait(0.5)

	task.spawn(function()
		for type, data in pairs(self.Monetization) do
			for id, item in pairs(data) do
				task.spawn(function()
					self:GetPrice(item.Name)
				end)
			end
		end
	end)

	task.delay(3, function()
		monetizationAreas = CollectionService:GetTagged("MonetizationArea")

		for _, monetizationArea in pairs(monetizationAreas) do
			local zone = Zone.new(monetizationArea)
			zone:setDetection("Centre")

			local product = monetizationArea:GetAttribute("Product")
			local type = monetizationArea:GetAttribute("Type")

			-- Handle player entering the zone
			zone.playerEntered:Connect(function(player)
				if player == Players.LocalPlayer then
					MonetizationService:PromptPurchase(product, type)
				end
			end)
		end
	end)

	print("[MONETIZATION CONTROLLER] Controller loaded successfully.")
end

return MonetizationController
