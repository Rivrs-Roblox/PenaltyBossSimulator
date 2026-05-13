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

-- Services
local DataService = nil
local DataCacheService = nil
-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local TableRemove = require(Helpers.TableRemove)

-- FuitService
local FruitService = Knit.CreateService({
	Name = "FruitService",
	Client = {
		FruitsUpdated = Knit.CreateSignal(),
	},

	Items = {} :: table,
})

--|| Client Functions ||--
function FruitService.Client:Consume(player: Player, id: number)
	return self.Server:Consume(player, id)
end

function FruitService.Client:End(player: Player, id: number)
	return self.Server:End(player, id)
end

--|| Functions ||--

function FruitService:AddFruit(player: Player, id: string, number: number)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[FRUIT SERVICE] Player has no data: " .. player.Name)
	end

	if data.Inventory.Fruits[id] == nil then
		for _, fruit in pairs(self.Items) do
			if fruit.Id == id then
				data.Inventory.Fruits[id] = {
					Name = fruit.Name,
					Number = 0,
				}
			end
		end
	end

	data.Inventory.Fruits[id].Number += number

	self.Client.FruitsUpdated:Fire(
		player,
		{ fruits = data.Inventory.Fruits, activeFruits = data.Inventory.ActiveFruits }
	)
end

-- Called from client to consume a fruit and gain its effects for a defined duration
function FruitService:Consume(player: Player, id: string)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[FRUIT SERVICE] Player has no data: " .. player.Name)
	end

	local fruit = data.Inventory.Fruits[id]
	if fruit == nil or fruit.Number == 0 then
		return false
	end

	local currentFruit = {
		Name = fruit.Name,
		Number = fruit.Number - 1,
		End = os.time(),
	}
	for activeId, activeFruit in pairs(data.Inventory.ActiveFruits) do
		if activeId == id then
			currentFruit = activeFruit
		end
	end

	currentFruit.End += self.Items[currentFruit.Name].Duration
	data.Inventory.ActiveFruits[id] = currentFruit
	data.Inventory.Fruits[id].Number -= 1

	self.Client.FruitsUpdated:Fire(
		player,
		{ fruits = data.Inventory.Fruits, activeFruits = data.Inventory.ActiveFruits }
	)

	return true
end

-- Called from client to end a fruit if timer is ended
function FruitService:End(player: Player, id: string)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[FRUIT SERVICE] Player has no data: " .. player.Name)
	end

	local fruit = data.Inventory.ActiveFruits[id]
	if fruit == nil then
		return false
	end

	if fruit.End >= os.time() then
		return false
	end

	TableRemove(data.Inventory.ActiveFruits, id)

	self.Client.FruitsUpdated:Fire(
		player,
		{ fruits = data.Inventory.Fruits, activeFruits = data.Inventory.ActiveFruits }
	)

	return true
end

-- Used to add or remove a fruit from player's inventory
function FruitService:Update(player: Player, id: string, change: number)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[FRUIT SERVICE] Player has no data: " .. player.Name)
	end

	local fruit = data.Inventory.Fruits[id]
	if fruit == nil or (change < 0 and fruit.Number == 0) then
		return false
	end

	data.Inventory.Fruits[id].Number += change

	self.Client.FruitsUpdated:Fire(
		player,
		{ fruits = data.Inventory.Fruits, activeFruits = data.Inventory.ActiveFruits }
	)

	return true
end

--|| Knit Lifecycle ||--
function FruitService:KnitInit()
	DataService = Knit.GetService("DataService")
	DataCacheService = Knit.GetService("DataCacheService")

	self.Items = DataCacheService:GetFile("Items")

	print("[FRUIT SERVICE] Service loaded successfully.")
end

return FruitService
