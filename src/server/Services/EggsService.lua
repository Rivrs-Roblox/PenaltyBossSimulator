--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local GetTableAmount = require(Helpers.Table.GetTableAmount)
local FindValue = require(Helpers.Table.FindValue)
local Map = require(Helpers.Table.Map)
local RandomElement = require(Helpers.Table.RandomElement)
local FunnelsModule = require(ReplicatedStorage.Packages.funnelsModule)

-- Services
local DataService = nil
local DataCacheService = nil
--local SeasonService = nil
local PetsService = nil
local MonetizationService = nil
local BoostEventService = nil
--local EarnCandyService = nil

local DEFAULT_EGG = "DefaultEgg"
local DEFAULT_EGG_GUARANTEED_RARITY = "Epic"

local function getRandomPetByRarity(eggPets: table, petsLibrary: table, rarity: string): string?
	local Chances = {}

	for petName, eggPetInfo in eggPets do
		local petInfo = petsLibrary[petName]
		if petInfo and petInfo.Rarity == rarity then
			Chances[petName] = eggPetInfo.Chance or 1
		end
	end

	if next(Chances) == nil then
		return nil
	end

	return RandomElement(Chances)
end

local function hasOwnedPetFromEgg(data: table, eggPets: table): boolean
	if data.Inventory == nil or data.Inventory.Pets == nil then
		return false
	end

	for _, petData in data.Inventory.Pets do
		if petData.Name and eggPets[petData.Name] then
			return true
		end
	end

	return false
end

-- EggsService
local EggsService = Knit.CreateService({
	Name = "EggsService",

	Template = {},
	Eggs = {},
	Pets = {},
})

--|| Client Functions ||--
function EggsService.Client:Hatch(Player: Player, Amount: number, Egg: string, AutoDelete: { string }, Robux: boolean)
	return self.Server:Hatch(Player, Amount, Egg, AutoDelete, Robux, false)
end

--|| Functions ||--
function EggsService:Hatch(Player: Player, Amount: number, Egg: string, AutoDelete: { string }, Robux: boolean, Free: boolean)
	local data = DataService:GetData(Player)
	if data == nil then
		return false, warn("[EGGS SERVICE] Player has no data: " .. Player.Name)
	end

	local EggInfo = self.Eggs[Egg]
	if EggInfo == nil then
		return false, { text = self.Template.Messages.Notifications.Egg_Not_Exists(Egg), type = "ERROR" }
	end

	local Currency = EggInfo.Currency

	if Currency == "Robux" and not Robux then
		return false, { text = self.Template.Messages.Notifications.Egg_Not_Robux, type = "ERROR" }
	end

	local MaxStorage = data.Inventory.Storage.Stored
	local CurStorage = GetTableAmount(data.Inventory.Pets)

	if not Robux and not Free then
		local Price = EggInfo.Price * Amount

		if CurStorage + Amount > MaxStorage then
			return false, { text = self.Template.Messages.Notifications.Not_Enough_Storage_Space, type = "ERROR" }
		end

		if Amount == 3 and not FindValue(data.Gamepasses, "x3 Hatch") then
			return false
		end
		if Amount == 8 and not FindValue(data.Gamepasses, "x8 Hatch") then
			return false
		end

		if data[Currency] < Price then
			local promptInfos = self:GetLowestWinsPackIDToBuyEgg(Player, data[Currency], Price)
			MonetizationService:PromptPurchase(Player, promptInfos.ID, promptInfos.Type)
			return false, { text = self.Template.Messages.Notifications.Not_Enough_Money(Currency), type = "ERROR" }
		end

		FunnelsModule:LogIGPEconomyEvent(Player, Currency, Price, data[Currency] - Price, Egg)
		DataService:ChangeValue(Player, Currency, -Price, true)
	end

	--SeasonService:Increase(Player, "Eggs Daily", Amount)
	--SeasonService:Increase(Player, "Eggs Weekly", Amount)

	--EarnCandyService:OnEggHatched(Player, Amount)

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

	if BoostEventService.CurrentBoost and BoostEventService.CurrentBoost.type == "Luck" then
		ChanceMultiplier += BoostEventService.CurrentBoost.multiplier
	end

	local Pets = EggInfo.Pets
	local Chances = Map(Pets, function(i, v)
		return v.Chance * ChanceMultiplier
	end, false)

	local GuaranteedDefaultEggPet = nil
	if
		Egg == DEFAULT_EGG
		and data.DefaultEggEpicClaimed ~= true
		and data.TutorialDefaultEggEpicClaimed ~= true
		and not hasOwnedPetFromEgg(data, Pets)
	then
		GuaranteedDefaultEggPet = getRandomPetByRarity(Pets, self.Pets, DEFAULT_EGG_GUARANTEED_RARITY)
		if GuaranteedDefaultEggPet then
			data.DefaultEggEpicClaimed = true
			data.TutorialDefaultEggEpicClaimed = true
		else
			warn(
				`[EGGS SERVICE] No {DEFAULT_EGG_GUARANTEED_RARITY} pet found for first hatch guarantee in egg: {Egg}`
			)
		end
	end

	local SelectedPets = {}
	for i = 1, Amount do
		if i == 1 and GuaranteedDefaultEggPet then
			table.insert(SelectedPets, GuaranteedDefaultEggPet)
		else
			table.insert(SelectedPets, RandomElement(Chances))
		end
	end

	if type(AutoDelete) ~= "table" then
		AutoDelete = {}
	end

	local FilteredSelectedPets = {}
	for i, Name in SelectedPets do
		local isGuaranteedDefaultEggPet = i == 1 and GuaranteedDefaultEggPet == Name
		if isGuaranteedDefaultEggPet or not table.find(AutoDelete, Name) then
			table.insert(FilteredSelectedPets, Name)
		end
	end

	for _, Name in FilteredSelectedPets do
		PetsService:AddPet(Player, Name)
	end

	return true, FilteredSelectedPets
end

function EggsService:GetLowestWinsPackIDToBuyEgg(Player: Player, Wins: number, EggPrice: number)
	local Pack_data = {
		[1] = "SMALL",
		[2] = "REGULAR",
		[3] = "BIG",
		[4] = "HUGE",
	}

	local function WichProductToPrompt()
		for i, value in pairs(Pack_data) do
			if DataService:GetWinsPackAmount(Player, value) + Wins > EggPrice then
				return value
			elseif value == "HUGE" then
				return value
			end
		end
	end

	local packToPrompt = WichProductToPrompt()
	return MonetizationService:GetWinsPackProductIDFromName(Player, packToPrompt)
end

--|| Knit Lifecycle ||--
function EggsService:KnitInit()
	DataService = Knit.GetService("DataService")
	DataCacheService = Knit.GetService("DataCacheService")
	--SeasonService = Knit.GetService("SeasonService")
	PetsService = Knit.GetService("PetsService")
	MonetizationService = Knit.GetService("MonetizationService")
	BoostEventService = Knit.GetService("BoostEventService")
	--EarnCandyService = Knit.GetService("EarnCandyService")

	self.Template = DataCacheService:GetFile("Template")
	self.Eggs = DataCacheService:GetFile("Eggs")
	self.Pets = DataCacheService:GetFile("Pets")

	print("[EGGS SERVICE] Service loaded successfully.")
end

return EggsService
