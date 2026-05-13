--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local RandomTable = require(Helpers.Table.Random)

-- Services
local DataCacheService = nil
local DataService = nil
local BoostService = nil
local FruitService = nil

-- Constants
local Signals = {
	Free = "FreeSpinsUpdated",
	Premium = "PremiumSpinsUpdated",
}

local FREE_SPIN_INTERVAL = 60 * 15
local MAX_OFFLINE_FREE_SPINS = 3

-- SpinService
local SpinService = Knit.CreateService({
	Name = "SpinService",

	Template = {},
	Spining = {
		Free = {},
		Premium = {},
	},
	FreeSpinLoops = {},

	Client = {
		FreeSpinsUpdated = Knit.CreateSignal(),
		PremiumSpinsUpdated = Knit.CreateSignal(),
		LastFreeSpinUpdated = Knit.CreateSignal(),
		FreeSpin = Knit.CreateSignal(),
		EggHatched = Knit.CreateSignal(),
	},
})

local function GetIdFromName(name, table)
	local id2 = 0
	for id, data in pairs(table) do
		if data.Name == name then
			id2 = id
			break
		end
	end
	return id2
end

local function normalizeRotation(rotation: number): number
	rotation = rotation % 360
	if rotation < 0 then
		rotation += 360
	end
	return rotation
end

local function getRewardDegrees(rewards: table): number
	local rewardCount = #rewards
	if rewardCount <= 0 then
		return 360
	end

	return 360 / rewardCount
end

local function getTargetRotation(rewards: table, rewardIndex: number): number
	local rewardDegrees = getRewardDegrees(rewards)

	-- Visual AllRewards/SpinWheels menyusun reward dari index 1 di atas,
	-- lalu index berikutnya searah jarum jam. Agar reward index terpilih
	-- berpindah ke pointer atas, wheel harus berhenti pada rotasi kebalikannya.
	local centerRotation = -((rewardIndex - 1) * rewardDegrees)

	-- Jangan pakai setengah segment penuh, supaya jarum tidak terlalu dekat
	-- ke batas reward sebelahnya.
	local safePadding = rewardDegrees * 0.32
	local randomOffset = Random.new():NextNumber(-safePadding, safePadding)

	return normalizeRotation(centerRotation + randomOffset)
end

--|| Client Functions ||--
function SpinService.Client:Spin(player: Player, wheel: string)
	return self.Server:Spin(player, wheel)
end

function SpinService.Client:GetFreeSpinCooldown(player: Player)
	return self.Server:GetFreeSpinCooldown(player)
end

--|| Functions ||--
function SpinService:_ensureSpinData(data: table)
	data.Spins = data.Spins or {}
	data.Spins.Free = data.Spins.Free or 0
	data.Spins.Premium = data.Spins.Premium or 0
	data.Spins.Last_Free_Spin = data.Spins.Last_Free_Spin or 0
end

function SpinService:_syncFreeSpin(player: Player, data: table, notificationAmount: number?)
	self.Client.FreeSpinsUpdated:Fire(player, data.Spins.Free)
	self.Client.LastFreeSpinUpdated:Fire(player, data.Spins.Last_Free_Spin)

	if notificationAmount ~= nil and notificationAmount > 0 then
		self.Client.FreeSpin:Fire(player, notificationAmount)
	end
end

function SpinService:GetFreeSpinCooldown(player: Player)
	local data = DataService:GetData(player)
	if data == nil then
		return os.time()
	end

	self:_ensureSpinData(data)

	if data.Spins.Last_Free_Spin <= 0 then
		data.Spins.Last_Free_Spin = os.time()
	end

	return data.Spins.Last_Free_Spin
end

function SpinService:ReconcileOfflineFreeSpin(player: Player, data: table)
	self:_ensureSpinData(data)

	local now = os.time()

	if data.Spins.Last_Free_Spin <= 0 then
		data.Spins.Last_Free_Spin = now
		self:_syncFreeSpin(player, data)
		return
	end

	local elapsed = now - data.Spins.Last_Free_Spin
	local freeSpinsToGive = math.floor(elapsed / FREE_SPIN_INTERVAL)

	if freeSpinsToGive <= 0 then
		self:_syncFreeSpin(player, data)
		return
	end

	freeSpinsToGive = math.min(freeSpinsToGive, MAX_OFFLINE_FREE_SPINS)

	data.Spins.Free += freeSpinsToGive
	data.Spins.Last_Free_Spin = now

	self:_syncFreeSpin(player, data, freeSpinsToGive)
end

function SpinService:GiveFreeSpin(player: Player, data: table)
	self:_ensureSpinData(data)

	data.Spins.Free += 1
	data.Spins.Last_Free_Spin = os.time()

	self:_syncFreeSpin(player, data, 1)
end

function SpinService:Spin(player: Player, wheel: string)
	if not self.Spining[wheel] then
		return { text = self.Template.Messages.Notifications.Wheel_Not_Found(wheel), type = "ERROR" }
	end

	if self.Spining[wheel][player] then
		return { text = self.Template.Messages.Notifications.Already_Spining, type = "ERROR" }
	end

	local data = DataService:GetData(player)
	if data == nil then
		return warn("[SPIN SERVICE] Player has no data: " .. player.Name)
	end

	self:_ensureSpinData(data)

	if data.Spins[wheel] <= 0 then
		return { text = self.Template.Messages.Notifications.No_More_Spins(wheel), type = "ERROR" }
	end

	local Rewards = self.Template.Spins and self.Template.Spins[wheel]
	if typeof(Rewards) ~= "table" or #Rewards <= 0 then
		return { text = self.Template.Messages.Notifications.Wheel_Not_Found(wheel), type = "ERROR" }
	end

	data.Spins[wheel] -= 1
	self.Client[Signals[wheel]]:Fire(player, data.Spins[wheel])

	if wheel == "Premium" then
		--EarnCandyService:OnPremiumWheelSpin(player)
	else
		--EarnCandyService:OnWheelSpin(player)
	end

	self.Spining[wheel][player] = true

	local rewardIndex = RandomTable(Rewards)
	local targetRotation = getTargetRotation(Rewards, rewardIndex)

	task.delay(5, function()
		self.Spining[wheel][player] = nil

		local Reward = Rewards[rewardIndex]
		DataService:ChangeValue(player, Reward.Reward, Reward.Amount, true)

		if Reward.Reward == "Premium_Spin" then
			data.Spins["Premium"] += Reward.Amount
			self.Client.PremiumSpinsUpdated:Fire(player, data.Spins.Premium)
		elseif Reward.Reward == "Boost" then
			local boostId = GetIdFromName(Reward.Boost, data.Inventory.Boosts)
			if boostId == 0 then
				return { text = "This boost doesn't exist", type = "ERROR" }
			end
			BoostService:AddBoost(player, boostId, Reward.Amount)
		elseif Reward.Reward == "Fruit" then
			local fruitId = GetIdFromName(Reward.Fruit, data.Inventory.Fruits)
			if fruitId == 0 then
				return { text = "This fruit doesn't exist", type = "ERROR" }
			end
			FruitService:AddFruit(player, fruitId, Reward.Amount)
		end
	end)

	return targetRotation,
		{
			text = self.Template.Messages.Notifications.Wheel_Won(
				Rewards[rewardIndex].Name
					:gsub("MONEY_1", self.Template.Economy.Money1)
					:gsub("MONEY_2", self.Template.Economy.Money2)
			),
			type = "SUCCESS",
		}
end

function SpinService:FreeSpin(player: Player)
	if self.FreeSpinLoops[player] then
		return
	end

	self.FreeSpinLoops[player] = true

	task.spawn(function()
		local data = DataService:GetData(player)
		if data == nil then
			self.FreeSpinLoops[player] = nil
			return warn("[SPIN SERVICE] Player has no data: " .. player.Name)
		end

		self:ReconcileOfflineFreeSpin(player, data)

		while player.Parent ~= nil do
			local now = os.time()
			local remaining = FREE_SPIN_INTERVAL - (now - data.Spins.Last_Free_Spin)

			if remaining > 0 then
				task.wait(math.min(remaining, 60))
			else
				self:GiveFreeSpin(player, data)
			end
		end

		self.FreeSpinLoops[player] = nil
	end)
end

--|| Knit Lifecycle ||--
function SpinService:KnitInit()
	DataCacheService = Knit.GetService("DataCacheService")
	DataService = Knit.GetService("DataService")
	BoostService = Knit.GetService("BoostService")
	FruitService = Knit.GetService("FruitService")

	self.Template = DataCacheService:GetFile("Template")

	Players.PlayerAdded:Connect(function(player)
		self:FreeSpin(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:FreeSpin(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		self.Spining.Free[player] = nil
		self.Spining.Premium[player] = nil
		self.FreeSpinLoops[player] = nil
	end)

	print("[SPIN SERVICE] Service loaded successfully.")
end

return SpinService
