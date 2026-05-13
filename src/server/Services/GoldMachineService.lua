--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Helpers
local GetTableLength = require(ReplicatedStorage.Shared.Helpers.GetTableLength)

-- Services
local PetsService = nil
local DataCacheService = nil
local DataService = nil
--local SeasonService = nil
--local EarnCandyService = nil

-- GoldMachineService
local GoldMachineService = Knit.CreateService({
	Name = "GoldMachineService",

	Client = {
		PetsUpdated = Knit.CreateSignal(),
	},

	Template = {},
	Pets = {},
})

--|| Client Functions ||--
function GoldMachineService.Client:AddOrRemovePet(player: Player, params: table)
	return self.Server:AddOrRemovePet(player, params)
end

function GoldMachineService.Client:Craft(player: Player)
	return self.Server:Craft(player)
end

--|| Functions ||--
function GoldMachineService:AddOrRemovePet(player: Player, params: table)
	setmetatable(params, {
		__index = {
			name = "" :: string,
			id = 0 :: number,
		},
	})

	if self.Pets[player] == nil then
		self.Pets[player] = {}
	end

	for id, name in self.Pets[player] do
		if name ~= params.name then
			return { text = self.Template.Messages.Notifications.Not_Same_Pet, type = "ERROR" }
		end

		if string.find(name, "Gold ") or string.find(name, "Rainbow ") then
			return { text = self.Template.Messages.Notifications.No_Gold_Variant(name), type = "ERROR" }
		end
	end

	if self.Pets[player][params.id] ~= nil then
		self.Pets[player][params.id] = nil
	else
		local lenght = 0
		for _, _ in self.Pets[player] do
			lenght += 1
		end
		if lenght == 4 then
			return { text = self.Template.Messages.Notifications.Cant_Add_More_Than_4, type = "ERROR" }
		end
		self.Pets[player][params.id] = params.name
	end
	self.Client.PetsUpdated:Fire(player, self.Pets[player])
end

function GoldMachineService:Craft(player: Player)
	if self.Pets[player] == nil or GetTableLength(self.Pets[player]) == 0 then
		return { text = self.Template.Messages.Notifications.Select_At_Least_One, type = "ERROR" }
	end

	local data = DataService:GetData(player)
	if data == nil then
		return warn("[GOLD MACHINE SERVICE] Player has no data: " .. player.Name)
	end

	local PetName
	for _, name in self.Pets[player] do
		PetName = name
		break
	end
	local GoldPetName = `Gold {PetName}`
	local PetModelExists = ReplicatedStorage.Assets.Pets:FindFirstChild(GoldPetName) ~= nil

	if not PetModelExists then
		return { text = self.Template.Messages.Notifications.No_Gold_Variant(PetName), type = "ERROR" }
	end

	local Chance = 25 * GetTableLength(self.Pets[player])
	for id, _ in self.Pets[player] do
		PetsService:DeletePet(player, id)
	end

	self.Pets[player] = nil
	self.Client.PetsUpdated:Fire(player, {})

	if math.random(1, 100) <= Chance then
		--SeasonService:Increase(player, "Gold Pets Daily", 1)
		--SeasonService:Increase(player, "Gold Pets Weekly", 1)
		--EarnCandyService:OnGoldPetCrafted(player)

		if Chance <= 25 then
		--	SeasonService:Increase(player, "25% Gold Pets Daily", 1)
		--	SeasonService:Increase(player, "25% Gold Pets Weekly", 1)
		end

		PetsService:AddPet(player, GoldPetName)
		-- task.delay(1, function() PetsService:EquipBest(player) end)
		return { text = self.Template.Messages.Notifications.Craft_Done(PetName, GoldPetName), type = "SUCCESS" }
	end

	return { text = self.Template.Messages.Notifications.Craft_Failed, type = "ERROR" }
end

--|| Knit Lifecycle ||--
function GoldMachineService:KnitInit()
	PetsService = Knit.GetService("PetsService")
	DataCacheService = Knit.GetService("DataCacheService")
	DataService = Knit.GetService("DataService")
	-- = Knit.GetService("SeasonService")
	--EarnCandyService = Knit.GetService("EarnCandyService")

	self.Template = DataCacheService:GetFile("Template")

	print("[GOLD MACHINE SERVICE] Service loaded successfully.")
end

return GoldMachineService
