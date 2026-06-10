--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local PolicyService = game:GetService("PolicyService")
local PurchaseStore = game:GetService("DataStoreService"):GetDataStore("PurchaseStore")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local FunnelsModule = require(ReplicatedStorage.Packages.funnelsModule)

-- Services
local DataCacheService = nil
local DataService = nil

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FindValue = require(Helpers.Table.FindValue)

-- MonetizationService
local MonetizationService = Knit.CreateService({
	Name = "MonetizationService",
	MonetizationList = {},
	Template = {},
	Prices = {},
	Client = {
		PurchaseFinished = Knit.CreateSignal(),
		GamepassesUpdate = Knit.CreateSignal(),
		UpdateData = Knit.CreateSignal(),
		EggPurchased = Knit.CreateSignal(),
		StarterPacksUpdated = Knit.CreateSignal(),
	},
})

--|| Client Functions ||--

-- Returns wheter or not the player has a gamepass
function MonetizationService.Client:HasGamepass(player: Player, name: string)
	return self.Server:HasGamepass(player, name)
end

-- Prompt product purchase
function MonetizationService.Client:PromptPurchase(player: Player, passId: number | string, type: string)
	return self.Server:PromptPurchase(player, passId, type)
end

-- Returns the pass ID from the product / gamepass
function MonetizationService.Client:GetID(player: Player, name: string)
	return self.Server:GetID(player, name)
end

--|| Functions ||--

-- Returns wheter or not the player has a gamepass
function MonetizationService:HasGamepass(player: Player, name: string)
	local passId = 0

	for pass, content in pairs(self.MonetizationList.GamePasses) do
		if content.Name == name then
			passId = pass
		end
	end

	if passId ~= 0 then
		local success, res = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
		end)
		if success and typeof(res) == "boolean" then
			return res
		end
		return false
	end

	return false
end

function MonetizationService:GetWinsPackProductIDFromName(player: Player, name: string)
	local tableData = {
		["SMALL"] = "Wins Pack - Small",
		["REGULAR"] = "Wins Pack - Regular",
		["BIG"] = "Wins Pack - Big",
		["HUGE"] = "Wins Pack - Huge",
	}
	return self:GetID(player, tableData[name])
end

-- Prompt product purchase
function MonetizationService:PromptPurchase(player: Player, passId: number | string, type: string)
	local cachedPassId = passId

	if typeof(passId) == "string" then
		passId = self:GetID(player, passId).ID
	end

	if self.MonetizationList[type][passId] ~= nil then
		if type == "Products" or type == "Packs" then
			local success, result = pcall(function()
				return PolicyService:GetPolicyInfoForPlayerAsync(player)
			end)
			if not success then
				return { text = self.Template.Messages.Notifications.Cant_Buy, type = "ERROR" }
			else
				if
					not self.MonetizationList[type][passId].RestrictedRegionCanBuy
					and result.ArePaidRandomItemsRestricted
				then
					return { text = self.Template.Messages.Notifications.Cant_Buy_In_Region, type = "ERROR" }
				end
			end
			local res = self.MonetizationList[type][passId].BeforeCheck(self, player.UserId)
			if res.status == false then
				return { text = res.message, type = "ERROR" }
			end
			MarketplaceService:PromptProductPurchase(player, passId)
		elseif type == "GamePasses" then
			local data = DataService:GetData(player)

			if not FindValue(data.Gamepasses, cachedPassId) then
				MarketplaceService:PromptGamePassPurchase(player, passId)
			else
				return { text = self.Template.Messages.Notifications.Cant_Buy_Pass, type = "ERROR" }
			end
		end
	end
end

function MonetizationService:GetPrice(player, name: string)
	if self.Prices[name] ~= nil then
		return self.Prices[name]
	end

	local data = self:GetID(player, name)
	if data == nil then
		return 0
	end
	--print(data)
	--print(data.Type == "GamePasses" and Enum.InfoType.GamePass or Enum.InfoType.Product)
	local success, Infos = pcall(function()
		return MarketplaceService:GetProductInfo(
			data.ID,
			data.Type == "GamePasses" and Enum.InfoType.GamePass or Enum.InfoType.Product
		)
	end)

	if not success then
		warn("[MONETIZATION] Failed to get price for", name, Infos)
		return 0
	end

	self.Prices[name] = Infos.PriceInRobux
	return Infos.PriceInRobux
end

-- Handle successfull purchase
function MonetizationService:PurchaseFinished(userId: number, passId: number, success: boolean)
	local player = Players:GetPlayerByUserId(userId)
	self.Client.PurchaseFinished:Fire(player, success)

	local passData = self:GetData(passId)
	if success then
		local data = DataService:GetData(Players:GetPlayerByUserId(userId))
		if passData.Type == "GamePasses" then
			table.insert(data.Gamepasses, self.MonetizationList[passData.Type][passId].Name)
			self.Client.GamepassesUpdate:Fire(Players:GetPlayerByUserId(userId), data.Gamepasses)
		end
		if passData.Type == "Packs" then
			local packslen = #self.Template.Shop.StarterPacks
			data.BoughtStarterPacks = if packslen > data.BoughtStarterPacks
				then data.BoughtStarterPacks + 1
				else packslen
			self.Client.StarterPacksUpdated:Fire(Players:GetPlayerByUserId(userId), data.BoughtStarterPacks)
			print("Updated Data starterpacks")
		end

		local addedRobuxSpent = self:GetPrice(player, passData.Name) or 0
		data.RobuxSpent = (data.RobuxSpent or 0) + addedRobuxSpent
		-- EarnCandyService:OnRobuxSpent(player, addedRobuxSpent)

		self.MonetizationList[passData.Type][passId].Purchased(self, userId)
		FunnelsModule:LogIAPEconomyEvent(player, passData.Name, 1, 1)
	end
end

-- Return the pass ID from the product / gamepass
function MonetizationService:GetID(player: Player, name: string)
	for typeName, type in pairs(self.MonetizationList) do
		for id, item in pairs(type) do
			if item.Name == name then
				return { ID = id, Type = typeName }
			end
		end
	end
end

function MonetizationService:GetData(id: number)
	for type, datas in pairs(self.MonetizationList) do
		for i, item in pairs(datas) do
			if i == id then
				return { Type = type, Name = item.Name }
			end
		end
	end
end

function MonetizationService:ProcessReceipt(receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId
	local purchaseId = receiptInfo.PurchaseId

	-- Cegah duplikat: cek apakah PurchaseId sudah disimpan
	local success, alreadyProcessed = pcall(function()
		return PurchaseStore:GetAsync(purchaseId)
	end)

	if not success then
		warn("[PURCHASE] Gagal membaca PurchaseStore untuk", purchaseId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if alreadyProcessed then
		print("[PURCHASE] Pembelian sudah diproses sebelumnya:", purchaseId)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- Ambil player dari userId
	local player = Players:GetPlayerByUserId(userId)
	if not player then
		warn("[PURCHASE] Player tidak ditemukan, tunda pembelian.")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Proses reward pembelian melalui MonetizationService
	local successReward, errorMessage = pcall(function()
		self:PurchaseFinished(userId, productId, true)
	end)

	if not successReward then
		warn("[PURCHASE] Gagal memberi reward ke player", userId, errorMessage)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Tandai purchaseId sudah diproses
	local saveSuccess = pcall(function()
		PurchaseStore:SetAsync(purchaseId, true)
	end)

	if not saveSuccess then
		warn("[PURCHASE] Gagal menyimpan PurchaseId", purchaseId)
		-- Tidak disarankan memberi reward tanpa menyimpan ID
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function MonetizationService:CheckPetSlots(player: Player)
	local data = DataService:GetData(player)
	if not data then
		return
	end

	local targetEquipped = 4

	if self:HasGamepass(player, "+2 Pet Equip") then
		targetEquipped += 2
	end

	if self:HasGamepass(player, "+4 Pet Equip") then
		targetEquipped += 4
	end

	if self:HasGamepass(player, "+7 Pet Equip") then
		targetEquipped += 7
	end

	-- if data.NewDailyRewards[6].Claimed == true then
	-- 	targetEquipped += 1
	-- end

	if data.Inventory.Storage.Equipped < targetEquipped then
		data.Inventory.Storage.Equipped = targetEquipped
	end

	local targetStored = 75

	if self:HasGamepass(player, "+25 Pet Storage") then
		targetStored += 25
	end

	if self:HasGamepass(player, "+50 Pet Storage") then
		targetStored += 50
	end

	if data.Inventory.Storage.Stored < targetStored then
		data.Inventory.Storage.Stored = targetStored
	end

	self.Client.UpdateData:Fire(player, data)
end

--|| Knit Lifecycle ||--
function MonetizationService:KnitInit()
	DataCacheService = Knit.GetService("DataCacheService")
	DataService = Knit.GetService("DataService")

	self.MonetizationList = DataCacheService:GetFile("Monetization")
	self.Template = DataCacheService:GetFile("Template")

	local function onPlayerAdded(player)
		task.spawn(function()
			-- wait for player Attribute DataLoaded to be true
			if not player:GetAttribute("DataLoaded") then
				player:GetAttributeChangedSignal("DataLoaded"):Wait()
			end

			local data = DataService:GetData(player)
			if not data then
				return
			end

			task.wait(0.5)
			for id, d in self.MonetizationList.GamePasses do
				print("[MONETIZATION SERVICE] Checking if player has gamepass " .. d.Name)
				if not table.find(data.Gamepasses, d.Name) and self:HasGamepass(player, d.Name) then
					table.insert(data.Gamepasses, d.Name)
					print("[MONETIZATION SERVICE] Player has gamepass " .. d.Name)
					task.wait(0.1)
				end
			end

			self:CheckPetSlots(player)
		end)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)

	-- MarketplaceService.PromptProductPurchaseFinished:Connect(
	-- 	function(userId: number, productId: number, isPurchased: boolean)
	-- 		self:PurchaseFinished(userId, productId, isPurchased)
	-- 	end
	-- )

	MarketplaceService.ProcessReceipt = function(receiptInfo)
		return self:ProcessReceipt(receiptInfo)
	end

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(player: Player, passId: number, isPurchased: boolean)
			print(passId)
			print(isPurchased)
			self:PurchaseFinished(player.UserId, passId, isPurchased)
		end
	)

	print("[MONETIZATION SERVICE] Service loaded successfully.")
end

return MonetizationService
