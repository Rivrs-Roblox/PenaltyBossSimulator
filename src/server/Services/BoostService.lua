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
local BoostService = Knit.CreateService({
	Name = "BoostService",
	Client = {
		BoostsUpdated = Knit.CreateSignal(),
	},

	Items = {} :: table,
})

--|| Client Functions ||--
function BoostService.Client:Consume(player: Player, id: number)
	return self.Server:Consume(player, id)
end

function BoostService.Client:End(player: Player, id: number)
	return self.Server:End(player, id)
end

--|| Functions ||--

function BoostService:AddBoost(player: Player, id: string, number: number)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[BOOST SERVICE] Player has no data: " .. player.Name)
	end

	data.Inventory.Boosts[id].Number += number

	self.Client.BoostsUpdated:Fire(
		player,
		{ boosts = data.Inventory.Boosts, activeBoosts = data.Inventory.ActiveBoosts }
	)
end

-- Called from client to consume a boost and gain its effects for a defined duration
function BoostService:Consume(player: Player, id: string)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[BOOST SERVICE] Player has no data: " .. player.Name)
	end

	local boost = data.Inventory.Boosts[id]
	if boost == nil or boost.Number == 0 then
		return false
	end

	local currentBoost = {
		Name = boost.Name,
		Number = boost.Number - 1,
		End = os.time(),
	}

	for activeId, activeFruit in pairs(data.Inventory.ActiveBoosts) do
		if activeId == id then
			currentBoost = activeFruit
		end
	end

	currentBoost.End += self.Items[currentBoost.Name].Duration
	data.Inventory.ActiveBoosts[id] = currentBoost
	data.Inventory.Boosts[id].Number -= 1

	self.Client.BoostsUpdated:Fire(
		player,
		{ boosts = data.Inventory.Boosts, activeBoosts = data.Inventory.ActiveBoosts }
	)

	return true
end

-- Called from client to end a boost if timer is ended
function BoostService:End(player: Player, id: string)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[BOOST SERVICE] Player has no data: " .. player.Name)
	end

	local boost = data.Inventory.ActiveBoosts[id]
	if boost == nil then
		return false
	end

	if boost.End >= os.time() then
		return false
	end

	TableRemove(data.Inventory.ActiveBoosts, id)

	self.Client.BoostsUpdated:Fire(
		player,
		{ boosts = data.Inventory.Boosts, activeBoosts = data.Inventory.ActiveBoosts }
	)

	return true
end

-- Used to add or remove a boost from player's inventory
function BoostService:Update(player: Player, id: string, change: number)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[BOOST SERVICE] Player has no data: " .. player.Name)
	end

	local boost = data.Inventory.Boosts[id]
	if boost == nil or (change < 0 and boost.Number == 0) then
		return false
	end

	data.Inventory.Boosts[id].Number += change

	self.Client.BoostsUpdated:Fire(
		player,
		{ boosts = data.Inventory.Boosts, activeBoosts = data.Inventory.ActiveBoosts }
	)

	return true
end

--|| Knit Lifecycle ||--
function BoostService:KnitInit()
	DataService = Knit.GetService("DataService")
	DataCacheService = Knit.GetService("DataCacheService")

	self.Items = DataCacheService:GetFile("Items")

	print("[BOOST SERVICE] Service loaded successfully.")
end

return BoostService
