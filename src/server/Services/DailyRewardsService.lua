--[=[
	Owner: JustStop__
	Version: v.0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Service
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

local DailyRewardsTemplate = require(ReplicatedStorage.Shared.Data.Player.DailyRewardsTemplate)

-- Services
local DataService = nil
local DataCacheService = nil
--local SeasonService = nil
local BoostService = nil
local FruitService = nil
local CharactersService = nil
local PetsService = nil
local EggsService = nil

-- DailyRewardsService
local DailyRewardsService = Knit.CreateService({
	Name = "DailyRewardsService",

	Template = {},
	PlayerTemplate = {},

	Client = {
		DailyRewardsUpdated = Knit.CreateSignal(),
		UpgradeClaimed = Knit.CreateSignal(),
		EggHatched = Knit.CreateSignal(),
	},
})

local function FormatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	local parts = {}
	if hours > 0 then
		table.insert(parts, hours .. " hour" .. (hours > 1 and "s" or ""))
	end
	if minutes > 0 then
		table.insert(parts, minutes .. " minute" .. (minutes > 1 and "s" or ""))
	end
	if hours == 0 and minutes == 0 then
		table.insert(parts, secs .. " second" .. (secs > 1 and "s" or ""))
	end

	return table.concat(parts, ", ")
end

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

--|| Client Functions ||--
function DailyRewardsService.Client:ClaimReward(player: Player, id: number)
	return self.Server:ClaimReward(player, id)
end

--|| Functions ||--
function DailyRewardsService:ClaimReward(player: Player, id: number, bypassTime: boolean?)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[DAILY REWARD SERVICE] Player has no data: " .. player.Name)
	end

	local Reward = data.DailyRewards[id]

	if Reward == nil then
		return { text = self.Template.Messages.Notifications.Reward_Not_Exists(id), type = "ERROR" }
	end

	if Reward.Claimed == true then
		return { text = self.Template.Messages.Notifications.Reward_Already_Claimed, type = "ERROR" }
	end

	local time = os.time() - data.LastDailyRewarded
	if time < 86400 and (bypassTime == nil or bypassTime == false) then
		return {
			text = "Come back in " .. FormatTime(86400 - time),
			type = "ERROR",
		}
	end

	if id == 1 then
		pcall(function()
			return HttpService:PostAsync(
				"https://rivrs.juststop.dev/api/users",
				HttpService:JSONEncode({
					["user_id"] = player.UserId,
					["universe_id"] = game.GameId,
				}),
				Enum.HttpContentType.ApplicationJson,
				false,
				{
					["x-api-key"] = "532NZEF3LyVGhSQN8GhebSmpRNHq7xNjHNcUv3v5dLhtTGCBzoCkktIDm0iKeabIDXvAqbx4iUSdt5qwsRWY9H7Ihtt0Z4eHs19foDteaKyRXVyXM7RtF4xh68ampuZm",
				}
			)
		end)
	end

	data.DailyRewards[id].Claimed = true
	data.LastDailyRewarded = os.time()
	data.LastRedeemedId = id

	if Reward.Reward == "Currency" and table.find({ "Money1", "Money2", "Wins", "Rebirth" }, Reward.Currency) then
		DataService:ChangeValue(player, Reward.Currency, Reward.Amount, true)
	elseif Reward.Reward == "Pets" then
		for _ = 1, (Reward.Amount or 1) do
			PetsService:AddPet(player, Reward.Pet)
		end
	elseif Reward.Reward == "Egg" then
		local eggName = Reward.Egg or "DragonBatEgg"
		local _, pets = EggsService:Hatch(player, Reward.Amount or 1, eggName, {}, true)
		self.Client.EggHatched:Fire(player, pets, eggName)
	elseif Reward.Reward == "Upgrade" and Reward.Upgrade == "+1PetEquip" then
		data.Inventory.Storage.Equipped += (Reward.Amount or 1)
		self.Client.UpgradeClaimed:Fire(player, data.Inventory.Storage.Equipped)
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
	elseif Reward.Reward == "Character" then
		local CharId = GetIdFromName(Reward.Character, self.Template.Characters)
		if CharId == 0 then
			return { text = "This character doesn't exist", type = "ERROR" }
		end
		CharactersService:Buy(player, CharId, true)
	elseif Reward.Reward == "Body" then
		local bodyId = GetIdFromName(Reward.Body, self.Template.Bodies)
		if bodyId == 0 then
			return { text = "This skin doesn't exist", type = "ERROR" }
		end

		-- BodyService:Buy(player, bodyId, true)
	end

	--SeasonService:Increase(player, "Daily Rewards", 1)

	self.Client.DailyRewardsUpdated:Fire(player, {
		lastRedeemedTimestamp = data.LastDailyRewarded,
		rewards = data.DailyRewards,
		lastRedeemedId = data.LastRedeemedId,
	})

	return { text = self.Template.Messages.Notifications.Reward_Claimed_Success, type = "SUCCESS" }
end

--|| Knit Lifecycle ||--
function DailyRewardsService:KnitInit()
	DataService = Knit.GetService("DataService")
	DataCacheService = Knit.GetService("DataCacheService")
	--SeasonService = Knit.GetService("SeasonService")
	BoostService = Knit.GetService("BoostService")
	FruitService = Knit.GetService("FruitService")
	CharactersService = Knit.GetService("CharactersService")
	PetsService = Knit.GetService("PetsService")
	EggsService = Knit.GetService("EggsService")

	self.Template = DataCacheService:GetFile("Template")
	self.PlayerTemplate = DataCacheService:GetFile("Player")

	print("[DAILY REWARDS SERVICE] Service started successfully.")
end

return DailyRewardsService
