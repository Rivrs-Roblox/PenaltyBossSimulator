--[=[
	Owner: JustStop__
	Version: v0.0.3
	Notes: Standalone Pets inventory/equip system, sample pets, fight auto-hide/restore.
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local GetTableLength = require(Helpers.GetTableLength)

-- Services
local DataCacheService = nil
local DataService = nil
local FightService = nil



local function safeClone(tbl: table): table
	local copy = {}
	for key, value in pairs(tbl or {}) do
		if type(value) == "table" then
			copy[key] = safeClone(value)
		else
			copy[key] = value
		end
	end
	return copy
end

local function ensureInventoryData(data: table)
	data.Inventory = data.Inventory or {}
	data.Inventory.Last_Stored_Pet_Id = tonumber(data.Inventory.Last_Stored_Pet_Id) or 0
	data.Inventory.Pets = data.Inventory.Pets or {}
	data.Inventory.EquippedPets = data.Inventory.EquippedPets or {}
	data.Inventory.ScaledPetsPower = data.Inventory.ScaledPetsPower or {}
	data.Inventory.Storage = data.Inventory.Storage or {}
	data.Inventory.Storage.Equipped = data.Inventory.Storage.Equipped or 4
	data.Inventory.Storage.Stored = data.Inventory.Storage.Stored or 75
end

local function getNextPetId(data: table): string
	ensureInventoryData(data)

	local id = tonumber(data.Inventory.Last_Stored_Pet_Id) or 0
	while data.Inventory.Pets[tostring(id)] ~= nil do
		id += 1
	end

	data.Inventory.Last_Stored_Pet_Id = id + 1
	return tostring(id)
end

local function getPetDisplayName(petData: table?): string
	if petData == nil then
		return "pet"
	end

	return petData.DisplayName or petData.Name or "pet"
end



local function isValidPet(petsLibrary: table, petData: table?): boolean
	return type(petData) == "table" and petData.Name ~= nil and petsLibrary[petData.Name] ~= nil
end

-- PetsService
local PetsService = Knit.CreateService({
	Name = "PetsService",

	Pets = {},
	Template = {},
	EquipBestDebounce = {},

	Client = {
		PetsUpdated = Knit.CreateSignal(),
		PlayerPetsUpdated = Knit.CreateSignal(),
		ScaledPetsUpdated = Knit.CreateSignal(),
	},
})

function PetsService:IsPlayerInFight(player: Player): boolean
	return FightService ~= nil and FightService.Sessions ~= nil and FightService.Sessions[player] ~= nil
end

--|| Client Functions ||--
function PetsService.Client:EquipPet(player: Player, params: table, fromEquipBest: boolean?)
	return self.Server:EquipPet(player, params, fromEquipBest)
end

function PetsService.Client:UnequipPet(player: Player, params: table, fromEquipBest: boolean?)
	return self.Server:UnequipPet(player, params, fromEquipBest)
end

function PetsService.Client:DeletePet(player: Player, id: number | string)
	return self.Server:DeletePet(player, id)
end

function PetsService.Client:EquipBest(player: Player)
	return self.Server:EquipBest(player)
end

function PetsService.Client:GetPets(player: Player, requestedPlayer: Player?)
	return self.Server:GetPets(player, requestedPlayer or player)
end

function PetsService.Client:GetScaledPower(player: Player, petName: string)
	return self.Server:GetScaledPower(player, petName)
end

function PetsService.Client:GetEquippedPetsMultiplier(player: Player)
	return self.Server:GetEquippedPetsMultiplier(player)
end

--|| Internal Functions ||--
function PetsService:CleanInvalidPets(player: Player?, data: table)
	ensureInventoryData(data)

	for id, pet in pairs(table.clone(data.Inventory.Pets)) do
		if not isValidPet(self.Pets, pet) then
			warn("[PETS SERVICE] Removing invalid pet:", player and player.Name, id, type(pet) == "table" and pet.Name or pet)
			data.Inventory.Pets[tostring(id)] = nil
			data.Inventory.EquippedPets[tostring(id)] = nil
		end
	end

	for id, pet in pairs(table.clone(data.Inventory.EquippedPets)) do
		local ownedPet = data.Inventory.Pets[tostring(id)]
		if not isValidPet(self.Pets, pet) or not isValidPet(self.Pets, ownedPet) then
			warn("[PETS SERVICE] Removing invalid equipped pet:", player and player.Name, id, type(pet) == "table" and pet.Name or pet)
			data.Inventory.EquippedPets[tostring(id)] = nil
		end
	end
end

function PetsService:BroadcastPets(player: Player, data: table)
	ensureInventoryData(data)
	self:CleanInvalidPets(player, data)

	self.Client.PetsUpdated:Fire(player, {
		pets = data.Inventory.Pets,
		equippedPets = data.Inventory.EquippedPets,
	})
	self.Client.PlayerPetsUpdated:FireAll(
		player,
		if self:IsPlayerInFight(player) then {} else data.Inventory.EquippedPets
	)
	self.Client.ScaledPetsUpdated:Fire(player, data.Inventory.ScaledPetsPower)
end

function PetsService:GetPetPower(player: Player, petData: table?): number
	if petData == nil or petData.Name == nil then
		return 0
	end

	local templatePet = self.Pets[petData.Name] or petData
	local powerData = templatePet.Power or petData.Power

	if powerData == nil and templatePet.Type == "Scaling" then
		powerData = self:GetScaledPower(player, petData.Name)
	end

	return tonumber(powerData) or 0
end

function PetsService:GetEquippedPetsMultiplier(player: Player): number
	local data = DataService:GetData(player)
	if not data then
		return 1
	end

	ensureInventoryData(data)
	self:CleanInvalidPets(player, data)

	local multiplier = 0
	for _, petData in pairs(data.Inventory.EquippedPets) do
		multiplier += self:GetPetPower(player, petData)
	end

	return if multiplier > 0 then multiplier else 1
end

function PetsService:QueueEquipBest(player: Player)
	local playerId = tostring(player.UserId)
	if self.EquipBestDebounce[playerId] then
		task.cancel(self.EquipBestDebounce[playerId])
	end

	self.EquipBestDebounce[playerId] = task.delay(0.75, function()
		if player.Parent then
			self:EquipBest(player)
		end
		self.EquipBestDebounce[playerId] = nil
	end)
end

function PetsService:UnequipPetsForFight(player: Player)
	local data = DataService:GetData(player)
	if not data then
		return
	end

	ensureInventoryData(data)
	self:CleanInvalidPets(player, data)

	if GetTableLength(data.Inventory.EquippedPets) <= 0 then
		return
	end

	self.Client.PlayerPetsUpdated:FireAll(player, {})
end

function PetsService:RestorePetsAfterFight(player: Player)
	local data = DataService:GetData(player)
	if not data then
		return
	end

	ensureInventoryData(data)
	self:CleanInvalidPets(player, data)

	self:BroadcastPets(player, data)
end

--|| Public Server Functions ||--
function PetsService:AddPet(player: Player, name: string, options: table?)
	if player == nil or name == nil then
		return false
	end

	options = options or {}

	local petData = self.Pets[name]
	if petData == nil then
		return { text = self.Template.Messages.Notifications.Pet_Not_Exists(name), type = "ERROR" }
	end

	local data = DataService:GetData(player)
	if not data then
		warn("[PETS SERVICE] Player has no data: " .. player.Name)
		return false
	end

	ensureInventoryData(data)
	self:CleanInvalidPets(player, data)

	if GetTableLength(data.Inventory.Pets) >= data.Inventory.Storage.Stored then
		return {
			text = self.Template.Messages.Notifications.Max_Pet_Stored(data.Inventory.Storage.Stored),
			type = "ERROR",
		}
	end

	local id = getNextPetId(data)
	data.Inventory.Pets[id] = safeClone(petData)

	if petData.Type == "Scaling" then
		self:UpdateScaledPower(player, name)
	else
		for petName, _ in pairs(data.Inventory.ScaledPetsPower) do
			self:UpdateScaledPower(player, petName, name)
		end
	end

	self:BroadcastPets(player, data)

	if options.skipAutoEquip ~= true then
		self:QueueEquipBest(player)
	end

	return true
end

function PetsService:DeletePet(player: Player, id: number | string)
	if player == nil or id == nil then
		return nil
	end

	local data = DataService:GetData(player)
	if not data then
		warn("[PETS SERVICE] Player has no data: " .. player.Name)
		return nil
	end

	ensureInventoryData(data)
	self:CleanInvalidPets(player, data)

	local petId = tostring(id)
	local pet = data.Inventory.Pets[petId]
	if pet == nil then
		return { text = self.Template.Messages.Notifications.Pet_Not_Yours("pet"), type = "ERROR" }
	end

	data.Inventory.Pets[petId] = nil
	data.Inventory.EquippedPets[petId] = nil

	for petName, _ in pairs(data.Inventory.ScaledPetsPower) do
		self:UpdateScaledPower(player, petName)
	end

	self:BroadcastPets(player, data)

	return { text = self.Template.Messages.Notifications.Pet_Deleted(getPetDisplayName(pet)), type = "SUCCESS" }
end

function PetsService:EquipPet(player: Player, params: table, fromEquipBest: boolean?)
	if player == nil or params == nil or params.id == nil then
		return nil
	end

	local data = DataService:GetData(player)
	if not data then
		warn("[PETS SERVICE] Player has no data: " .. player.Name)
		return nil
	end

	ensureInventoryData(data)
	self:CleanInvalidPets(player, data)

	if self:IsPlayerInFight(player) then
		return { text = "Pets are hidden during fight.", type = "ERROR" }
	end

	local petId = tostring(params.id)
	local ownedPet = data.Inventory.Pets[petId]
	if ownedPet == nil then
		return { text = self.Template.Messages.Notifications.Pet_Not_Yours(params.name or "pet"), type = "ERROR" }
	end

	local petData = self.Pets[ownedPet.Name]
	if petData == nil then
		return { text = self.Template.Messages.Notifications.Pet_Not_Exists(ownedPet.Name), type = "ERROR" }
	end

	if data.Inventory.EquippedPets[petId] ~= nil then
		return if fromEquipBest then {} else {
			text = self.Template.Messages.Notifications.Pet_Equipped(getPetDisplayName(ownedPet)),
			type = "SUCCESS",
		}
	end

	if GetTableLength(data.Inventory.EquippedPets) >= data.Inventory.Storage.Equipped then
		return {
			text = self.Template.Messages.Notifications.Max_Pet_Equipped(data.Inventory.Storage.Equipped),
			type = "ERROR",
		}
	end

	data.Inventory.EquippedPets[petId] = safeClone(petData)
	self:BroadcastPets(player, data)

	if not fromEquipBest then
		return {
			text = self.Template.Messages.Notifications.Pet_Equipped(getPetDisplayName(ownedPet)),
			type = "SUCCESS",
		}
	end

	return {}
end

function PetsService:UnequipPet(player: Player, params: table, fromEquipBest: boolean?)
	if player == nil or params == nil or params.id == nil then
		return nil
	end

	local data = DataService:GetData(player)
	if not data then
		warn("[PETS SERVICE] Player has no data: " .. player.Name)
		return nil
	end

	ensureInventoryData(data)
	self:CleanInvalidPets(player, data)

	if self:IsPlayerInFight(player) then
		return { text = "Pets are hidden during fight.", type = "ERROR" }
	end

	local petId = tostring(params.id)
	local pet = data.Inventory.EquippedPets[petId]
	if pet == nil then
		return { text = self.Template.Messages.Notifications.Pet_Not_Equipped(params.name or "pet"), type = "ERROR" }
	end

	data.Inventory.EquippedPets[petId] = nil
	self:BroadcastPets(player, data)

	if not fromEquipBest then
		return { text = self.Template.Messages.Notifications.Pet_Unequipped(getPetDisplayName(pet)), type = "SUCCESS" }
	end

	return {}
end

function PetsService:GetScaledPower(player: Player, petName: string)
	local data = DataService:GetData(player)
	if not data then
		warn("[PETS SERVICE] Player has no data: " .. player.Name)
		return 0
	end

	ensureInventoryData(data)
	return data.Inventory.ScaledPetsPower[petName] or 0
end

function PetsService:InitiateScaledPet(player: Player)
	local data = DataService:GetData(player)
	if not data or self.Pets == nil then
		if player and player.Parent then
			warn("[PETS SERVICE] Player has no data: " .. player.Name)
		end
		return
	end

	ensureInventoryData(data)
	self:CleanInvalidPets(player, data)

	for petName, petData in pairs(self.Pets) do
		if petData.Type == "Scaling" then
			local foundInInventory = false

			for id, pet in pairs(data.Inventory.Pets) do
				if pet.Name == petName then
					foundInInventory = true
					data.Inventory.Pets[id] = safeClone(petData)
				end
			end

			if foundInInventory then
				self:UpdateScaledPower(player, petName)
			end
		end
	end

	self:BroadcastPets(player, data)
end

function PetsService:UpdateScaledPower(player: Player, petName: string, compareTo: string?)
	local data = DataService:GetData(player)
	if not data then
		warn("[PETS SERVICE] Player has no data: " .. player.Name)
		return
	end

	ensureInventoryData(data)
	self:CleanInvalidPets(player, data)

	local scalingPetData = self.Pets[petName]
	if not scalingPetData then
		warn("[PETS SERVICE] Pet does not exist: " .. tostring(petName))
		return
	end

	if scalingPetData.Type ~= "Scaling" then
		return
	end

	if compareTo then
		local comparePetData = self.Pets[compareTo]
		if not comparePetData then
			warn("[PETS SERVICE] Compare pet does not exist: " .. tostring(compareTo))
			return
		end

		local scaledFromCompareData = (comparePetData.Power or 1) * (scalingPetData.Multiplier or 1)
		local currentScaledPower = data.Inventory.ScaledPetsPower[petName] or 0

		if scaledFromCompareData > currentScaledPower then
			data.Inventory.ScaledPetsPower[petName] = math.floor(scaledFromCompareData)
		end
	else
		local bestPower = nil

		for _, pet in pairs(data.Inventory.Pets) do
			local templatePet = self.Pets[pet.Name]
			if templatePet and templatePet.Power then
				if bestPower == nil or templatePet.Power > bestPower then
					bestPower = templatePet.Power
				end
			end
		end

		if bestPower then
			data.Inventory.ScaledPetsPower[petName] = math.floor(bestPower * (scalingPetData.Multiplier or 1))
		else
			data.Inventory.ScaledPetsPower[petName] = 1
		end
	end

	self.Client.ScaledPetsUpdated:Fire(player, data.Inventory.ScaledPetsPower)
end

function PetsService:EquipBest(player: Player)
	local data = DataService:GetData(player)
	if not data then
		warn("[PETS SERVICE] Player has no data: " .. player.Name)
		return nil
	end

	ensureInventoryData(data)
	self:CleanInvalidPets(player, data)

	if self:IsPlayerInFight(player) then
		return { text = "Pets are hidden during fight.", type = "ERROR" }
	end

	data.Inventory.EquippedPets = {}

	local equippedCount = 0
	for _ = 1, data.Inventory.Storage.Equipped do
		local bestPet = nil
		local bestPower = -math.huge

		for id, pet in pairs(data.Inventory.Pets) do
			if data.Inventory.EquippedPets[tostring(id)] == nil then
				local powerData = self:GetPetPower(player, pet)
				if powerData > bestPower then
					bestPet = { id = id, name = pet.Name }
					bestPower = powerData
				end
			end
		end

		if bestPet == nil then
			break
		end

		local result = self:EquipPet(player, bestPet, true)
		if result ~= nil then
			equippedCount += 1
		end
	end

	self:BroadcastPets(player, data)

	return {
		text = self.Template.Messages.Notifications.Pets_Best_Equipped(equippedCount),
		type = "SUCCESS",
	}
end

function PetsService:GetPets(player: Player, requestedPlayer: Player?)
	requestedPlayer = requestedPlayer or player

	local data = DataService:GetData(requestedPlayer)
	if not data then
		return {}
	end

	ensureInventoryData(data)
	self:CleanInvalidPets(requestedPlayer, data)

	if self:IsPlayerInFight(requestedPlayer) then
		return {}
	end

	return data.Inventory.EquippedPets
end

--|| Knit Lifecycle ||--
function PetsService:KnitInit()
	DataCacheService = Knit.GetService("DataCacheService")
	DataService = Knit.GetService("DataService")
	FightService = Knit.GetService("FightService")

	self.Pets = DataCacheService:GetFile("Pets")
	self.Template = DataCacheService:GetFile("Template")

	local function playerAdded(player: Player)
		task.spawn(function()
			while player.Parent and not player:GetAttribute("DataLoaded") do
				task.wait()
			end

			if not player.Parent then
				return
			end

			local data = DataService:GetData(player)
			if data then
				ensureInventoryData(data)
				self:CleanInvalidPets(player, data)
				self:InitiateScaledPet(player)
				self:BroadcastPets(player, data)
			end
		end)
	end

	FightService.OnFightStarted:Connect(function(player)
		self:UnequipPetsForFight(player)
	end)

	FightService.OnPlayerTeleported:Connect(function(player)
		self:RestorePetsAfterFight(player)
	end)

	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(function(player)
		self:RestorePetsAfterFight(player)

		local playerId = tostring(player.UserId)
		if self.EquipBestDebounce[playerId] then
			task.cancel(self.EquipBestDebounce[playerId])
			self.EquipBestDebounce[playerId] = nil
		end
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		playerAdded(player)
	end

	print("[PETS SERVICE] Service loaded successfully.")
end

return PetsService
