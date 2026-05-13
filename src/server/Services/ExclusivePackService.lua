-- Knit Packages
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- Helpers
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Helpers = ReplicatedStorage.Shared.Helpers
local GetTableAmount = require(Helpers.Table.GetTableAmount)
local FindValue = require(Helpers.Table.FindValue)
local Map = require(Helpers.Table.Map)
local RandomElement = require(Helpers.Table.RandomElement)

local ExclusivePackTemplate = require(ReplicatedStorage.Shared.Data.Player.ExclusivePackTemplate)

-- Services
local Players = game:GetService("Players")
local DataService = nil
local MonetizationService = nil
local DataCacheService = nil

local ExclusivePackService = Knit.CreateService({
	Name = "ExclusivePackService",
	Template = {},

	Client = {
		ItemClaimed = Knit.CreateSignal(),
		ExclusivePackReseted = Knit.CreateSignal(),
		ExclusiveChestOpened = Knit.CreateSignal(),
	},
})

--|| Client Functions ||--
function ExclusivePackService.Client:BuyItem(player: Player, id: number)
	return self.Server:BuyItem(player, id)
end

function ExclusivePackService.Client:ResetExclusivePack(player: Player)
	return self.Server:ResetExclusivePack(player)
end

-- || Functions || --
function ExclusivePackService:BuyItem(player: Player, id: number)
	if id == nil then
		return
	end

	local data = DataService:GetData(player)
	if data == nil then
		return warn("[EXCLUSIVE PACK SERVICE] Player has no data: " .. player.Name)
	end

	if data.ExclusivePackCurrentIndex ~= id then
		return false, { text = "Unlock previous item first!", type = "ERROR" }
	end

	local itemData = data.ExclusivePack[id]

	if itemData.Claimed == true then
		return false, { text = "Item already claimed!", type = "ERROR" }
	end

	local MaxStorage = data.Inventory.Storage.Stored
	local CurStorage = GetTableAmount(data.Inventory.Pets)

	if (itemData.Type == "Pet" or itemData.Type == "Chest") and CurStorage + 1 > MaxStorage then
		return false, { text = self.Template.Messages.Notifications.Not_Enough_Storage_Space, type = "ERROR" }
	end

	if itemData.Price == 0 then
		self:ClaimItem(player, id)
		return true, { text = "Item successfully claimed!", type = "SUCCESS" }
	else
		local productName

		if id == 2 then
			productName = "Exclusive Pack - Tier 1"
		elseif id == 6 then
			productName = "Exclusive Pack - Tier 2"
		elseif id == 10 then
			productName = "Exclusive Pack - Tier 3"
		elseif id == 14 then
			productName = "Exclusive Pack - Tier 4"
		elseif id == 18 then
			productName = "Exclusive Pack - Tier 5"
		else
			return false, { text = "Product not exist!", type = "ERROR" }
		end

		local res = MonetizationService:GetID(player, productName)

		if res ~= nil then
			local p, r = MonetizationService:PromptPurchase(player, res.ID, res.Type)
			if p == false then
				return false, r
			else
				return true, r
			end
		end
	end
end

function ExclusivePackService:ClaimItem(player: Player, id: number)
	if id == nil then
		return
	end

	local data = DataService:GetData(player)
	if data == nil then
		return warn("[EXCLUSIVE PACK SERVICE] Player has no data: " .. player.Name)
	end

	if data.ExclusivePack[id].Claimed == true then
		return warn("[EXCLUSIVE PACK SERVICE] Player already claimed this item: " .. player.Name)
	end

	local itemData = data.ExclusivePack[id]

	if itemData.Type == "Pet" then
		-- PetsService:AddPet(player, itemData.Name)
	elseif itemData.Type == "Boost" then
		for index, boost in data.Inventory.Boosts do
			if boost.Name == itemData.Name then
				-- BoostService:AddBoost(player, index, itemData.Quantity)
				break
			end
		end
	elseif itemData.Type == "Chest" then
		local exclusiveChest = self.Template.Shop.ExclusiveChest

		local ChanceMultiplier = 1
		if FindValue(data.Gamepasses, "Lucky") then
			ChanceMultiplier = 2
		end
		if FindValue(data.Gamepasses, "Super Lucky") then
			ChanceMultiplier = 3
		end
		if FindValue(data.Gamepasses, "Ultra Lucky") then
			ChanceMultiplier = 5
		end

		local Pets = exclusiveChest.Pets
		local Chances = Map(Pets, function(i, v)
			return v.Chance * ChanceMultiplier
		end, false)

		local selectedPetIndex = RandomElement(Chances)
		local selectedPet = Pets[selectedPetIndex].Name
		-- PetsService:AddPet(player, selectedPet)
		self.Client.ExclusiveChestOpened:Fire(player, selectedPet)
	else
		return warn("[EXCLUSIVE PACK SERVICE] Invalid type: " .. itemData.Type)
	end

	data.ExclusivePack[id].Claimed = true
	data.ExclusivePackCurrentIndex = id + 1
	self.Client.ItemClaimed:Fire(player, data.ExclusivePack, id)
end

function ExclusivePackService:ResetExclusivePack(player: Player)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[EXCLUSIVE PACK SERVICE] Player has no data: " .. player.Name)
	end

	if data.ExclusivePackCurrentIndex < #data.ExclusivePack then
		return false, { text = "You need to claim all items first!", type = "ERROR" }
	end

	for id, item in data.ExclusivePack do
		item.Claimed = false
	end
	data.ExclusivePackCurrentIndex = 1

	self.Client.ExclusivePackReseted:Fire(player, data.ExclusivePack)
	return true, { text = "Exclusive pack has been reset!", type = "SUCCESS" }
end

-- KNIT START
function ExclusivePackService:KnitStart()
	DataService = Knit.GetService("DataService")
	MonetizationService = Knit.GetService("MonetizationService")
	DataCacheService = Knit.GetService("DataCacheService")

	self.Template = DataCacheService:GetFile("Template")
end

return ExclusivePackService
