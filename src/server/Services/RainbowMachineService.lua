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

-- RainbowMachineService
local RainbowMachineService = Knit.CreateService({
	Name = "RainbowMachineService",

	Client = {
		PetsUpdated = Knit.CreateSignal(),
	},

	Template = {},
	Pets = {},
})

--|| Client Functions ||--
function RainbowMachineService.Client:AddOrRemovePet(player: Player, params: table)
	return self.Server:AddOrRemovePet(player, params)
end

function RainbowMachineService.Client:Craft(player: Player)
	return self.Server:Craft(player)
end

--|| Functions ||--
function RainbowMachineService:AddOrRemovePet(player: Player, params: table)
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

		if not string.find(name, "Gold") then
			return { text = self.Template.Messages.Notifications.Not_Gold_Pet, type = "ERROR" }
		end
	end

	if self.Pets[player][params.id] ~= nil then
		self.Pets[player][params.id] = nil
	else
		local length = 0
		for _, _ in self.Pets[player] do
			length += 1
		end
		if length == 3 then
			return { text = self.Template.Messages.Notifications.Cant_Add_More_Than_4, type = "ERROR" }
		end
		self.Pets[player][params.id] = params.name
	end
	self.Client.PetsUpdated:Fire(player, self.Pets[player])
end

function RainbowMachineService:Craft(player: Player)
	if self.Pets[player] == nil or GetTableLength(self.Pets[player]) == 0 then
		return { text = self.Template.Messages.Notifications.Select_At_Least_One, type = "ERROR" }
	end

	local data = DataService:GetData(player)
	if data == nil then
		return warn("[RAINBOW MACHINE SERVICE] Player has no data: " .. player.Name)
	end

	local PetName
	for _, name in self.Pets[player] do
		PetName = name
		break
	end
	local RainbowPetName = string.gsub(PetName, "Gold ", "Rainbow ")
	local PetModelExists = ReplicatedStorage.Assets.Pets:FindFirstChild(RainbowPetName) ~= nil

	if not PetModelExists then
		return { text = self.Template.Messages.Notifications.No_Rainbow_Variant(PetName), type = "ERROR" }
	end

	local Chance = GetTableLength(self.Pets[player]) / 3 * 100
	--bulatkan chance

	Chance = math.floor(Chance)
	for id, _ in self.Pets[player] do
		PetsService:DeletePet(player, id)
	end

	self.Pets[player] = nil
	self.Client.PetsUpdated:Fire(player, {})

	if math.random(1, 100) <= Chance then
		--SeasonService:Increase(player, "Rainbow Pets Daily", 1)
		--SeasonService:Increase(player, "Rainbow Pets Weekly", 1)
		--EarnCandyService:OnRainbowPetCrafted(player)

		if Chance <= 33 then
			--SeasonService:Increase(player, "33% Rainbow Pets Daily", 1)
			--SeasonService:Increase(player, "33% Rainbow Pets Weekly", 1)
		end

		PetsService:AddPet(player, RainbowPetName)
		-- task.delay(1, function()
		-- 	PetsService:EquipBest(player)
		-- end)
		return { text = self.Template.Messages.Notifications.Craft_Done(PetName, RainbowPetName), type = "SUCCESS" }
	end

	return { text = self.Template.Messages.Notifications.Craft_Rainbow_Failed, type = "ERROR" }
end

--|| Knit Lifecycle ||--
function RainbowMachineService:KnitInit()
	PetsService = Knit.GetService("PetsService")
	DataCacheService = Knit.GetService("DataCacheService")
	DataService = Knit.GetService("DataService")
	--SeasonService = Knit.GetService("SeasonService")
	--EarnCandyService = Knit.GetService("EarnCandyService")

	self.Template = DataCacheService:GetFile("Template")

	print("[RAINBOW MACHINE SERVICE] Service loaded successfully.")
end

return RainbowMachineService
