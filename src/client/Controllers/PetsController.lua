--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

-- Preset warna pelangi
local rainbowColors = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(255, 127, 0),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(75, 0, 130),
	Color3.fromRGB(143, 0, 255),
}

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Zone = require(ReplicatedStorage.Shared.ZonePlus)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local PetsActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.PetsActions)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local GridFunctions = require(Helpers.Pets.Grid)
local Update = require(Helpers.Pets.Update)
local Filter = require(Helpers.Table.Filter)

-- Controllers
local DataCacheController = nil
local UIController = nil

-- Services
local PetsService = nil
local DataService = nil
local SettingsService = nil
local TeleportService = nil

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Variables
local RaycastExcludeModels = {}

local petAreas

local Functions = {
	GetTableAmount = require(Helpers.Table.GetTableAmount),
	GetAngleDistance = require(Helpers.Math.GetAngleDistance),
	DeepCopy = require(Helpers.Table.DeepCopy),
	GetPetModel = require(Helpers.Pets.GetPetModel),
}

-- PetsController
local PetsController = Knit.CreateController({
	Name = "PetsController",

	PetsInSession = {} :: table,
	PetInstances = nil,

	Pets = {},
	Colors = {},

	RainbowParts = {}, -- Cache for rainbow parts

	ScaledPetsPowerCache = {}, -- Cache for scaled pets power
})

--|| Functions ||--
function PetsController:DestroyRenderedPet(player: Player, index: string | number)
	local modelName = player.Name .. "_" .. tostring(index)

	for _, petModel in pairs(self.PetInstances:GetChildren()) do
		if petModel.Name == modelName then
			local excludeIndex = table.find(RaycastExcludeModels, petModel)
			if excludeIndex then
				table.remove(RaycastExcludeModels, excludeIndex)
			end

			petModel:Destroy()
		end
	end
end

--|| Functions ||--
function PetsController:AddPets(player: Player, Pets: table)
	if not self.PetsInSession[player] then
		self.PetsInSession[player] = {}
	end

	local GeneratedPets = GridFunctions.GetGrids(Pets, self.PetsInSession[player], player)
	for i, v in GeneratedPets do
		if not self.PetsInSession[player][i] then
			self.PetsInSession[player][i] = v
		end
	end

	for i, _ in self.PetsInSession[player] do
		if not GeneratedPets[i] then
			self.PetsInSession[player][i] = nil
			self:DestroyRenderedPet(player, i)
		end
	end
end


function PetsController:HandleMove()
	RunService:BindToRenderStep("PetsMovement", Enum.RenderPriority.Last.Value, function(Delta: number)
		local state = Store:getState()
		if state["SettingsReducer"] and state["SettingsReducer"].Pets_Visible == true then
			Update(Delta, Functions, self.PetsInSession, self.Pets, self.PetInstances, RaycastExcludeModels, self)
		end
	end)
end

function PetsController:RefreshPlayerTarget(player: Player)
	local grids = self.PetsInSession[player]
	if not grids then
		return
	end

	local character = player.Character
	if not character or not character.Parent then
		character = player.CharacterAdded:Wait()
	end

	local hrp = character:WaitForChild("HumanoidRootPart")

	for _, grid in pairs(grids) do
		if grid.Information then
			grid.Information.Target = hrp
		end
	end
end

function PetsController:PlayerRemove(player: Player)
	if self.PetsInSession[player] then
		local FoundPets = Filter(self.PetInstances:GetChildren(), function(Pet: Model)
			return Pet:GetAttribute("Owner") == player.Name
		end) :: { Model }

		for _, Pet in pairs(FoundPets) do
			local ExcludeIndex = table.find(RaycastExcludeModels, Pet)
			if ExcludeIndex then
				table.remove(RaycastExcludeModels, ExcludeIndex)
			end

			Pet:Destroy()
		end

		for Index = #RaycastExcludeModels, 1, -1 do
			local Model = RaycastExcludeModels[Index]
			if Model and Model.Name == player.Name then
				table.remove(RaycastExcludeModels, Index)
			end
		end

		self.PetsInSession[player] = nil
	end
end

-- Reloads the pets for a player
function PetsController:ReloadPets(player: Player)
	-- First remove all existing pets for the player
	self:PlayerRemove(player) -- Reuse the existing removal function

	-- Then add them back fresh
	local success, pets = PetsService:GetPets(player):await()
	if success and pets then
		local _, data = DataService:GetData(Players.LocalPlayer):await()
		if data and data.Settings and data.Settings.Pets_Visible == true then
			self:AddPets(player, pets)
			return true
		end
	end
	return false
end

function PetsController:GetScaledPower(petName: string)
	if not self.ScaledPetsPowerCache then
		self.ScaledPetsPowerCache = {}
	end

	if self.ScaledPetsPowerCache[petName] then
		return self.ScaledPetsPowerCache[petName]
	else
		local success, power = PetsService:GetScaledPower(petName):await()
		if success then
			self.ScaledPetsPowerCache[petName] = power
			return power
		else
			return 1 -- Default value if fetching fails
		end
	end
end

local function rainbowPetsMeshRandomizer(self)
	local index = 1
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

	-- Initial cache of rainbow parts
	for _, petModel in self.PetInstances:GetChildren() do
		if petModel:IsA("Model") then
			local rainbowPart = petModel:FindFirstChild("Rainbow")
			if rainbowPart and rainbowPart:IsA("MeshPart") then
				table.insert(self.RainbowParts, rainbowPart)
			end
		end
	end

	-- Listen for new pets being added
	self.PetInstances.ChildAdded:Connect(function(child)
		task.wait(0.1) -- Small delay to allow model to fully load
		if child:IsA("Model") then
			local rainbowPart = child:FindFirstChild("Rainbow")
			if rainbowPart and rainbowPart:IsA("MeshPart") then
				table.insert(self.RainbowParts, rainbowPart)
			end
		end
	end)

	while true do
		local color = rainbowColors[index]
		index = index % #rainbowColors + 1

		-- Change colors in parallel
		for i = #self.RainbowParts, 1, -1 do
			local part = self.RainbowParts[i]
			if part and part.Parent then
				local tween = TweenService:Create(part, tweenInfo, { Color = color })
				tween:Play()
			else
				table.remove(self.RainbowParts, i) -- Clean up invalid parts
			end
		end

		task.wait(0.5)
	end
end

--|| Knit Lifecycle ||--
function PetsController:KnitInit()
	self.PetInstances = Instance.new("Model")
	self.PetInstances.Parent = workspace
	self.PetInstances.Name = "Pets"

	DataCacheController = Knit.GetController("DataCacheController")
	UIController = Knit.GetController("UIController")

	PetsService = Knit.GetService("PetsService")
	SettingsService = Knit.GetService("SettingsService")
	DataService = Knit.GetService("DataService")
	TeleportService = Knit.GetService("TeleportService")

	self.Pets = DataCacheController:GetFile("Pets")
	self.Colors = DataCacheController:GetFile("Colors")

	self:HandleMove()

	-- Start the rainbow pets mesh randomizer
	task.spawn(rainbowPetsMeshRandomizer, self)

	local function connectCharacterRefresh(player: Player)
		player.CharacterAdded:Connect(function()
			task.defer(function()
				local character = player.Character
				if character then
					character:WaitForChild("HumanoidRootPart", 5)
				end

				if self.PetsInSession[player] then
					self:RefreshPlayerTarget(player)
				end
			end)
		end)
	end

	for _, Player in pairs(Players:GetPlayers()) do
		connectCharacterRefresh(Player)
	end

	task.spawn(function()
		for _, Player in Players:GetPlayers() do
			local _ = Player.Character or Player.CharacterAdded:Wait()
			local __, Pets = PetsService:GetPets(Player):await()
			local ___, Data = DataService:GetData(Players.LocalPlayer):await()
			if Data and Data.Settings and Data.Settings.Pets_Visible == true then
				self:AddPets(Player, Pets)
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:PlayerRemove(player)
	end)
	Players.PlayerAdded:Connect(function(player: Player)
		connectCharacterRefresh(player)

		task.spawn(function()
			local _ = player.Character or player.CharacterAdded:Wait()
			local __, Pets = PetsService:GetPets(player):await()
			local ___, Data = DataService:GetData(Players.LocalPlayer):await()
			if Data and Data.Settings and Data.Settings.Pets_Visible == true then
				self:AddPets(player, Pets)
			end
		end)
	end)

	self.PetInstances.ChildAdded:Connect(function(Pet: Model)
		local assets = ReplicatedStorage:FindFirstChild("Assets")
		local prompts = assets and assets:FindFirstChild("Prompts")
		local petNamePrompt = prompts and prompts:FindFirstChild("PetName")

		if petNamePrompt == nil then
			return
		end

		local PetName = petNamePrompt:Clone()
		PetName.Parent = Pet

		local Name = Pet:GetAttribute("Pet") or Pet.Name
		local NameTL = PetName:WaitForChild("Name")
		local RarityTL = PetName:WaitForChild("Rarity")

		NameTL.Text = Name

		if string.find(Name, "Gold ") then
			NameTL.TextColor3 = self.Colors["Gold"]
		elseif string.find(Name, "Rainbow") then
			NameTL.TextColor3 = self.Colors["Rainbow"]
		else
			NameTL.TextColor3 = self.Colors["Normal"] or Color3.fromRGB(255, 255, 255)
		end

		local petData = self.Pets[Name]
		local rarity = (petData and petData.Rarity) or "Common"

		RarityTL.Text = rarity
		RarityTL.TextColor3 = self.Colors[rarity] or Color3.fromRGB(255, 255, 255)
	end)

	PetsService.PlayerPetsUpdated:Connect(function(player: Player, pets)
		local ___, Data = DataService:GetData(Players.LocalPlayer):await()
		if Data and Data.Settings and Data.Settings.Pets_Visible == true then
			self:AddPets(player, pets)
		end
	end)

	PetsService.ScaledPetsUpdated:Connect(function(scaledPets)
		self.ScaledPetsPowerCache = scaledPets
		Store:dispatch(PetsActions.setScaledPetsPower(scaledPets))
	end)

	TeleportService.PlayerTeleported:Connect(function(player, coachData, pets)
		local ___, Data = DataService:GetData(Players.LocalPlayer):await()
		if Data and Data.Settings and Data.Settings.Pets_Visible == true then
			self:AddPets(player, {})
			self:AddPets(player, pets)
		end
	end)

	SettingsService.SettingsUpdated:Connect(function(settings: table)
		if settings.Pets_Visible == false then
			for _, p in Players:GetPlayers() do
				if self.PetsInSession[p] then
					for i, _ in self.PetsInSession[p] do
						self.PetsInSession[p][i] = nil
						self:DestroyRenderedPet(p, i)
					end
				end
			end
		else
			for _, Player in Players:GetPlayers() do
				local _ = Player.Character or Player.CharacterAdded:Wait()
				local __, Pets = PetsService:GetPets(Player):await()
				self:AddPets(Player, Pets)
			end
		end
	end)

	task.delay(3, function()
		petAreas = CollectionService:GetTagged("PetArea")

		for _, petArea in pairs(petAreas) do
			local zone = Zone.new(petArea)
			zone:setDetection("Centre")

			-- Handle player entering the zone
			zone.playerEntered:Connect(function(player)
				if player == Players.LocalPlayer then
					UIController:ShowFrame({ frame = FramesConstants.Inventory })
				end
			end)

			-- Handle player exiting the zone
			zone.playerExited:Connect(function(player)
				if player == Players.LocalPlayer then
					UIController:HideFrame()
				end
			end)
		end
	end)

	print("[PETS CONTROLLER] Controller loaded successfully.")
end

return PetsController
