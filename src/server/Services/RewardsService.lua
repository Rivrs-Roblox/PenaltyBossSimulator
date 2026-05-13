--[=[
	Owner: JustStop__
	Version: v.0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Service
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local SetInterval = require(Helpers.SetInterval)
local DeepCopy = require(Helpers.Table.DeepCopy)

-- Services
local DataService = nil
local DataCacheService = nil
--local SeasonService = nil
local FruitService = nil
local BoostService = nil
local PetsService = nil
local EggsService = nil

-- RewardsService
local RewardsService = Knit.CreateService({
	Name = "RewardsService",

	Template = {},

	Rewards = {},
	Timers = {},

	TimersThreads = {},

	Client = {
		RewardsUpdated = Knit.CreateSignal(),
		EggHatched = Knit.CreateSignal(),
	},
})

--|| Client Functions ||--

function RewardsService.Client:ClaimReward(player: Player, id: number)
	return self.Server:ClaimReward(player, id)
end

function RewardsService.Client:ResetGifts(player: Player)
	return self.Server:ResetGifts(player)
end

function RewardsService.Client:GetRewards(player: Player)
	return self.Server:GetRewards(player)
end

--|| Functions ||--

function RewardsService:GetCurrentZoneName(data)
	local unlockedAreas = data.Areas and data.Areas.Unlocked
	if unlockedAreas == nil then
		return "Zone1"
	end

	return unlockedAreas[table.maxn(unlockedAreas)] or "Zone1"
end

function RewardsService:GetAreaRewardValue(Reward, zoneName)
	local areaData = Reward.Areas and Reward.Areas[zoneName]

	if areaData == nil then
		areaData = Reward.Areas and Reward.Areas.Zone1
	end

	if areaData == nil then
		return nil
	end

	return areaData[2]
end

function RewardsService:GetRandomEggFromArea(areaValue)
	if typeof(areaValue) == "table" then
		if #areaValue <= 0 then
			return nil
		end

		return areaValue[math.random(1, #areaValue)]
	end

	return areaValue
end

function RewardsService:ClaimReward(player: Player, id: number, bypassTimer: boolean?)
	local playerRewards = self.Rewards[player]
	if playerRewards == nil then
		return { text = self.Template.Messages.Notifications.Reward_Not_Exists(id), type = "ERROR" }
	end

	local Reward = playerRewards[id]
	if Reward == nil then
		return { text = self.Template.Messages.Notifications.Reward_Not_Exists(id), type = "ERROR" }
	end

	local data = DataService:GetData(player)
	if data == nil then
		return warn("[REWARDS SERVICE] Player has no data: " .. player.Name)
	end

	if Reward.Claimed == true then
		return { text = self.Template.Messages.Notifications.Reward_Already_Claimed, type = "ERROR" }
	end

	local timer = self:GetTimer(player)

	if timer < Reward.Time and not bypassTimer then
		print(timer)
		return { text = self.Template.Messages.Notifications.Reward_Not_Ready, type = "ERROR" }
	end

	self.Rewards[player][id].Claimed = true
	local currentZone = self:GetCurrentZoneName(data)

	if Reward.Reward == "Currency" and table.find({ "Money1", "Money2", "Wins", "Rebirth" }, Reward.Currency) then
		DataService:ChangeValue(
			player,
			Reward.Currency,
			Reward.Areas[data.Areas.Unlocked[table.maxn(data.Areas.Unlocked)]][2],
			true
		)
	elseif Reward.Reward == "Pets" then
		for _ = 1, (Reward.Amount or 1) do
			PetsService:AddPet(player, Reward.Areas[data.Areas.Unlocked[table.maxn(data.Areas.Unlocked)]][2])
		end
	elseif Reward.Reward == "Egg" then
		local areaValue = self:GetAreaRewardValue(Reward, currentZone)
		local allPets = {}
		local lastEggName = nil

		for _ = 1, (Reward.Amount or 1) do
			local eggName = self:GetRandomEggFromArea(areaValue)

			if eggName ~= nil then
				local _, pets = EggsService:Hatch(player, Reward.Amount or 1, eggName, {}, true)
				self.Client.EggHatched:Fire(player, pets, eggName)
			end
		end

		if #allPets > 0 then
			self.Client.EggHatched:Fire(player, allPets, lastEggName)
		end
	elseif Reward.Reward == "Fruit" then
		FruitService:AddFruit(
			player,
			Reward.Areas[data.Areas.Unlocked[table.maxn(data.Areas.Unlocked)]][2],
			Reward.Amount
		)
	elseif Reward.Reward == "Boost" then
		BoostService:AddBoost(
			player,
			Reward.Areas[data.Areas.Unlocked[table.maxn(data.Areas.Unlocked)]][2],
			Reward.Amount
		)
	end

	-- SeasonService:Increase(player, "Time Rewards", 1)

	self.Client.RewardsUpdated:Fire(player, {
		rewards = self.Rewards[player],
	})

	return { text = self.Template.Messages.Notifications.Reward_Claimed_Success, type = "SUCCESS" }
end

function RewardsService:ResetGifts(player: Player)
	self.Timers[player] = 0

	local newRewards = DeepCopy(self.Template.Rewards)
	self.Rewards[player] = newRewards

	self.Client.RewardsUpdated:Fire(player, { rewards = self.Rewards[player] })

	return { text = self.Template.Messages.Notifications.Reward_Reseted, type = "SUCCESS" }
end

function RewardsService:UpdateTimer(player: Player)
	self.TimersThreads[player] = SetInterval(function()
		if self.Timers[player] == nil then
			self.Timers[player] = 0
		end
		self.Timers[player] += 1
	end, 1)
end

function RewardsService:GetRewards(player: Player)
	return self.Rewards[player]
end

function RewardsService:GetTimer(player: Player)
	return self.Timers[player]
end

function RewardsService:SetTimer(player: Player, value: number)
	self.Timers[player] = value
end

--|| Knit Lifecycle ||--
function RewardsService:KnitInit()
	DataService = Knit.GetService("DataService")
	PetsService = Knit.GetService("PetsService")
	DataCacheService = Knit.GetService("DataCacheService")
	FruitService = Knit.GetService("FruitService")
	EggsService = Knit.GetService("EggsService")
	BoostService = Knit.GetService("BoostService")

	self.Template = DataCacheService:GetFile("Template")

	local function _playerAdded(player: Player)
		self.Rewards[player] = DeepCopy(self.Template.Rewards)
		self:UpdateTimer(player)

		self.Client.RewardsUpdated:Fire(player, { rewards = self.Rewards[player] })
	end

	for _, player in ipairs(Players:GetPlayers()) do
		_playerAdded(player)
	end

	Players.PlayerAdded:Connect(_playerAdded)

	Players.PlayerRemoving:Connect(function(player: Player)
		if self.TimersThreads[player] ~= nil then
			task.cancel(self.TimersThreads[player])
			self.TimersThreads[player] = nil
		end

		self.Rewards[player] = nil
		self.Timers[player] = nil
	end)

	print("[REWARDS SERVICE] Service started successfully.")
end

return RewardsService
