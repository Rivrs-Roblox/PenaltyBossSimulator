--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback

	Used to initialiaze all the used data in DataTemplate of DataService. 
	Also initialiaze different data connection between reducer and DataChanged signal in various services. 
]=]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local Sound = require(ReplicatedStorage.Packages.Sound)
local player = Players.LocalPlayer

-- Actions
local Actions = StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions
local PlayerActions = require(Actions.PlayerActions)
local AreaActions = require(Actions.AreaActions)
local PetsActions = require(Actions.PetsActions)
local FriendsActions = require(Actions.FriendsActions)
local FruitsActions = require(Actions.FruitsActions)
local InventoryActions = require(Actions.InventoryActions)
local AllRewardsActions = require(Actions.AllRewardsActions)
local BoostsActions = require(Actions.BoostsActions)
local GoldPetsActions = require(Actions.GoldPetsActions)
local RainbowPetsActions = require(Actions.RainbowPetsActions)
local SettingsActions = require(Actions.SettingsActions)
local RewardsActions = require(Actions.RewardsActions)
local DailyRewardsActions = require(Actions.DailyRewardsActions)
local StarterPacksActions = require(Actions.StarterPacksActions)
local UIActions = require(Actions.UIActions)
local TradeActions = require(Actions.TradeActions)
local SeasonActions = require(Actions.SeasonActions)
local UpdateActions = require(Actions.UpdateActions)
local ClicksActions = require(Actions.ClicksActions)
local NotificationActions = require(Actions.NotificationActions)
local SpinsActions = require(Actions.SpinsActions)
local MonetizationActions = require(Actions.MonetizationActions)
local ChestsActions = require(Actions.ChestsActions)
local TrailsActions = require(Actions.TrailsActions)
local CoachActions = require(Actions.CoachActions)
local ExclusivePackActions = require(Actions.ExclusivePackActions)
local CharacterActions = require(Actions.CharacterActions)
local RejoinActions = require(Actions.RejoinActions)

local Data = {}

function Data:Init()
	local PetsService = Knit.GetService("PetsService")
	local TrailsService = Knit.GetService("TrailsService")
	local CoachesService = Knit.GetService("CoachesService")
	local FruitService = Knit.GetService("FruitService")
	local BoostService = Knit.GetService("BoostService")
	local SettingsService = Knit.GetService("SettingsService")
	local RewardsService = Knit.GetService("RewardsService")
	local DailyRewardsService = Knit.GetService("DailyRewardsService")
	local SpinService = Knit.GetService("SpinService")
	local TradeService = Knit.GetService("TradeService")
	local SeasonService = Knit.GetService("SeasonService")
	local MonetizationService = Knit.GetService("MonetizationService")
	local ChestService = Knit.GetService("ChestService")
	local GoldMachineService = Knit.GetService("GoldMachineService")
	local RainbowMachineService = Knit.GetService("RainbowMachineService")
	local SoftShutdownService = Knit.GetService("SoftShutdownService")
	--local TeleportationService = Knit.GetService("TeleportationService")
	local DataService = Knit.GetService("DataService")
	local ExclusivePackService = Knit.GetService("ExclusivePackService")
	local FriendsService = Knit.GetService("FriendsService")
	local CharactersService = Knit.GetService("CharactersService")
	local RejoinService = Knit.GetService("RejoinService")

	local DataCacheController = Knit.GetController("DataCacheController")
	local UIController = Knit.GetController("UIController")

	DataService:GetData():andThen(function(data)
		Store:dispatch(PlayerActions.addMoney1(data.Money1))
		Store:dispatch(PlayerActions.addMoney2(data.Money2))
		Store:dispatch(PlayerActions.addWins(data.Wins))
		Store:dispatch(PlayerActions.addRebirth(data.Rebirth))
		Store:dispatch(SpinsActions.setSpins("Free", data.Spins.Free))
		Store:dispatch(SpinsActions.setSpins("Premium", data.Spins.Premium))
		Store:dispatch(SpinsActions.setLastFreeSpin(data.Spins.Last_Free_Spin))
		Store:dispatch(MonetizationActions.setGamepasses(data.Gamepasses))
		Store:dispatch(ChestsActions.setChests(data.Chests))
		Store:dispatch(ChestsActions.setVerified(data.Codes.Verified))

		Store:dispatch(AreaActions.setAreas(data.Areas.Unlocked))
		Store:dispatch(AreaActions.setArea(DataCacheController:GetFile("Template").Config.First_Area_Name))

		Store:dispatch(PetsActions.setPets(data.Inventory.Pets))
		Store:dispatch(PetsActions.setEquippedPets(data.Inventory.EquippedPets))

		Store:dispatch(InventoryActions.setMaxEquipped(data.Inventory.Storage.Equipped))
		Store:dispatch(InventoryActions.setMaxStored(data.Inventory.Storage.Stored))

		Store:dispatch(FruitsActions.setFruits(data.Inventory.Fruits))
		Store:dispatch(FruitsActions.setActiveFruits(data.Inventory.ActiveFruits))

		Store:dispatch(BoostsActions.setBoosts(data.Inventory.Boosts))
		Store:dispatch(BoostsActions.setActiveBoosts(data.Inventory.ActiveBoosts))

		Store:dispatch(ClicksActions.setClicksUnlock(data.UnlockedClicks))
		Store:dispatch(ClicksActions.setCurrentClick(data.CurrentClick))
		Store:dispatch(ClicksActions.setGoldClick(table.find(data.Gamepasses, "Gold Click")))

		Store:dispatch(FriendsActions.setStars(data.Invites.Stars))
		Store:dispatch(FriendsActions.setInvitedFriends(data.Invites.Invited_Friends))

		Store:dispatch(SettingsActions.setPetsVisible(data.Settings.Pets_Visible))
		Store:dispatch(SettingsActions.setTrade(data.Settings.Trade))

		Store:dispatch(StarterPacksActions.setBoughtStarterPacks(data.BoughtStarterPacks))

		Store:dispatch(DailyRewardsActions.setLastRedeemedTimestamp(data.LastDailyRewarded))
		Store:dispatch(DailyRewardsActions.setLastRedeemedId(data.LastRedeemedId))
		Store:dispatch(DailyRewardsActions.setDailyRewards(data.DailyRewards))
		Store:dispatch(SeasonActions.setSeasonQuests(data.Season.DailyQuests, data.Season.WeeklyQuests))
		Store:dispatch(SeasonActions.setSeason(data.Season.Completed))
		Store:dispatch(SeasonActions.setFreeRewards(DataCacheController:GetFile("Template").Season.Rewards))
		Store:dispatch(
			SeasonActions.setPremiumRewards(DataCacheController:GetFile("Template").Season["Premium Rewards"])
		)
		Store:dispatch(SeasonActions.setClaimedRewards(data.Season.Claimed))
		Store:dispatch(SeasonActions.setClaimedPremiumRewards(data.Season["Premium Claimed"]))
		Store:dispatch(SeasonActions.setLevel(data.Season.Level))
		Store:dispatch(SeasonActions.setExp(data.Season.Exp))
		Store:dispatch(SeasonActions.setPremium(data.Season.Premium))

		Store:dispatch(NotificationActions.setNotification("Store", "NEW!"))

		Store:dispatch(TrailsActions.setTrails(data.Trails.Unlocked))
		Store:dispatch(TrailsActions.setTrail(data.Trails.Current))

		Store:dispatch(CoachActions.setCoaches(data.Coaches.Unlocked))
		Store:dispatch(CoachActions.setCoach(data.Coaches.Current))

		Store:dispatch(CharacterActions.setCharacters(data.Characters.Unlocked))
		Store:dispatch(CharacterActions.setCharacter(data.Characters.Current))

		Store:dispatch(RejoinActions.setFirstConnection(data.FirstConnection))
		Store:dispatch(RejoinActions.setClaimedRejoinReward(data.ClaimedRejoinReward))

		Store:dispatch(ExclusivePackActions.setExclusivePackData(data.ExclusivePack))
		Store:dispatch(ExclusivePackActions.setExclusivePackCurrentIndex(data.ExclusivePackCurrentIndex))
	end)

	SpinService:GetFreeSpinCooldown()
		:andThen(function(lastFreeSpin)
			Store:dispatch(SpinsActions.setLastFreeSpin(lastFreeSpin))
		end)
		:catch(function(err)
			warn("[DATA SYNC] Failed to get free spin cooldown:", err)
		end)

	DataService.Money1Updated:Connect(function(value)
		Store:dispatch(PlayerActions.addMoney1(value))
	end)

	DataService.Money2Updated:Connect(function(value)
		Store:dispatch(PlayerActions.addMoney2(value))
	end)

	DataService.RebirthsUpdated:Connect(function(value)
		Store:dispatch(PlayerActions.addRebirth(value))
	end)

	DataService.WinsUpdated:Connect(function(value)
		Store:dispatch(PlayerActions.addWins(value))
	end)

	DataService.AreasUpdated:Connect(function(value)
		Store:dispatch(AreaActions.setAreas(value))
	end)

	DataService.AreaUpdated:Connect(function(value)
		Store:dispatch(AreaActions.setArea(value))
	end)

	PetsService.PetsUpdated:Connect(function(pets: table)
		Store:dispatch(PetsActions.setPets(pets.pets))
		Store:dispatch(PetsActions.setEquippedPets(pets.equippedPets))
	end)

	FruitService.FruitsUpdated:Connect(function(fruits: table)
		Store:dispatch(FruitsActions.setFruits(fruits.fruits))
		Store:dispatch(FruitsActions.setActiveFruits(fruits.activeFruits))
	end)

	BoostService.BoostsUpdated:Connect(function(boosts: table)
		Store:dispatch(BoostsActions.setBoosts(boosts.boosts))
		Store:dispatch(BoostsActions.setActiveBoosts(boosts.activeBoosts))
	end)

	CharactersService.CharactersUpdated:Connect(function(characters: table)
		Store:dispatch(CharacterActions.setCharacters(characters.Unlocked))
		Store:dispatch(CharacterActions.setCharacter(characters.Current))
	end)

	SettingsService.SettingsUpdated:Connect(function(settings: table)
		Store:dispatch(SettingsActions.setTrade(settings.Trade))
		Store:dispatch(SettingsActions.setPetsVisible(settings.Pets_Visible))
	end)

	RewardsService.RewardsUpdated:Connect(function(rewards: table)
		Store:dispatch(RewardsActions.setRewards(rewards.rewards))
	end)

	MonetizationService.StarterPacksUpdated:Connect(function(packs)
		Store:dispatch(StarterPacksActions.setBoughtStarterPacks(packs))
	end)

	GoldMachineService.PetsUpdated:Connect(function(pets)
		Store:dispatch(GoldPetsActions.setSelectedPets(pets))
	end)

	RainbowMachineService.PetsUpdated:Connect(function(pets)
		Store:dispatch(RainbowPetsActions.setSelectedRainbowPets(pets))
	end)

	TrailsService.TrailsUpdated:Connect(function(trails: table)
		Store:dispatch(TrailsActions.setTrails(trails.Unlocked))
		Store:dispatch(TrailsActions.setTrail(trails.Current))
	end)

	CoachesService.CoachesUpdated:Connect(function(coaches: table)
		if coaches.Unlocked ~= nil or coaches.Current ~= nil then
			Store:dispatch(CoachActions.setCoaches(coaches.Unlocked or {}))
			Store:dispatch(CoachActions.setCoach(coaches.Current or 0))
		end
	end)

	DailyRewardsService.DailyRewardsUpdated:Connect(function(rewards)
		Store:dispatch(DailyRewardsActions.setDailyRewards(rewards.rewards))
		Store:dispatch(DailyRewardsActions.setLastRedeemedTimestamp(rewards.lastRedeemedTimestamp))
		Store:dispatch(DailyRewardsActions.setLastRedeemedId(rewards.lastRedeemedId))
	end)

	DailyRewardsService.UpgradeClaimed:Connect(function(maxEquipped)
		Store:dispatch(InventoryActions.setMaxEquipped(maxEquipped))
	end)

	SpinService.FreeSpinsUpdated:Connect(function(spins)
		Store:dispatch(SpinsActions.setSpins("Free", spins))
	end)

	SpinService.PremiumSpinsUpdated:Connect(function(spins)
		Store:dispatch(SpinsActions.setSpins("Premium", spins))
	end)

	SpinService.LastFreeSpinUpdated:Connect(function(time)
		Store:dispatch(SpinsActions.setLastFreeSpin(time))
	end)

	TradeService.RequestSent:Connect(function(receiver: Player)
		Store:dispatch(UIActions.resetCurrentUI())
		Store:dispatch(TradeActions.setOutgoingRequest(receiver))
	end)

	TradeService.RequestReceived:Connect(function(sender: Player)
		Store:dispatch(UIActions.resetCurrentUI())
		Store:dispatch(TradeActions.setIncomingRequest(sender))
		Sound:PlaySound("UI_Trade_Requested")
	end)

	TradeService.RequestDeclined:Connect(function()
		Store:dispatch(TradeActions.setMyPets({}))
		Store:dispatch(TradeActions.setHisPets({}))

		Store:dispatch(TradeActions.setIncomingRequest(nil))
		Store:dispatch(TradeActions.setOutgoingRequest(nil))

		Store:dispatch(TradeActions.setReady(false))
		Store:dispatch(TradeActions.setOtherReady(false))

		Store:dispatch(TradeActions.setTrading(false))
	end)

	TradeService.RequestAccepted:Connect(function()
		Store:dispatch(TradeActions.setMyPets({}))
		Store:dispatch(TradeActions.setHisPets({}))
		Store:dispatch(TradeActions.setTrading(true))
	end)

	TradeService.TradeCanceled:Connect(function()
		Store:dispatch(TradeActions.setMyPets({}))
		Store:dispatch(TradeActions.setHisPets({}))

		Store:dispatch(TradeActions.setIncomingRequest(nil))
		Store:dispatch(TradeActions.setOutgoingRequest(nil))

		Store:dispatch(TradeActions.setReady(false))
		Store:dispatch(TradeActions.setOtherReady(false))

		Store:dispatch(TradeActions.setTrading(false))
	end)

	TradeService.TradeCompleted:Connect(function()
		Store:dispatch(TradeActions.setMyPets({}))
		Store:dispatch(TradeActions.setHisPets({}))

		Store:dispatch(TradeActions.setIncomingRequest(nil))
		Store:dispatch(TradeActions.setOutgoingRequest(nil))

		Store:dispatch(TradeActions.setReady(false))
		Store:dispatch(TradeActions.setOtherReady(false))

		Store:dispatch(TradeActions.setTrading(false))
	end)

	TradeService.MyPetsChanged:Connect(function(pets: table)
		Store:dispatch(TradeActions.setMyPets(pets))
	end)

	TradeService.HisPetsChanged:Connect(function(pets: table)
		Store:dispatch(TradeActions.setHisPets(pets))
	end)

	TradeService.PlayerReady:Connect(function(state: boolean)
		Store:dispatch(TradeActions.setReady(state))
	end)

	TradeService.OtherReady:Connect(function(state: boolean)
		Store:dispatch(TradeActions.setOtherReady(state))
	end)

	TradeService.Timer:Connect(function(time: number)
		Store:dispatch(TradeActions.setTimer(time))
	end)

	SeasonService.QuestsUpdated:Connect(function(dailyQuests: table, weeklyQuests: table)
		Store:dispatch(SeasonActions.setSeasonQuests(dailyQuests, weeklyQuests))
	end)

	SeasonService.ClaimedRewardsUpdate:Connect(function(params: table)
		Store:dispatch(SeasonActions.setClaimedRewards(params.free))
		Store:dispatch(SeasonActions.setClaimedPremiumRewards(params.premium))
	end)

	SeasonService.SeasonUpdated:Connect(function(season: number)
		Store:dispatch(SeasonActions.setSeason(season))
	end)

	SeasonService.RemainingDayTimeUpdated:Connect(function(remainingSeconds: number)
		Store:dispatch(SeasonActions.setRemainingDayTime(remainingSeconds))
	end)

	SeasonService.RemainingWeekTimeUpdated:Connect(function(remainingSeconds: number)
		Store:dispatch(SeasonActions.setRemainingWeekTime(remainingSeconds))
	end)

	SeasonService.LevelUpdated:Connect(function(newLevel: number)
		Store:dispatch(SeasonActions.setLevel(newLevel))
	end)

	SeasonService.ExpUpdated:Connect(function(newExp: number)
		Store:dispatch(SeasonActions.setExp(newExp))
	end)

	SeasonService.PremiumUpdated:Connect(function(premium: boolean)
		Store:dispatch(SeasonActions.setPremium(premium))
	end)

	ChestService.ChestsUpdated:Connect(function(chests)
		Store:dispatch(ChestsActions.setChests(chests.chests))
	end)

	MonetizationService.GamepassesUpdate:Connect(function(passes: table)
		Store:dispatch(MonetizationActions.setGamepasses(passes))
	end)

	SoftShutdownService.Update:Connect(function(updating, timer)
		UIController:RemoveHUD({ ignoreTopFrame = false })

		Store:dispatch(UpdateActions.setUpdating(updating))
		Store:dispatch(UpdateActions.setTimer(timer))
	end)

	RejoinService.RejoinUpdated:Connect(function(date)
		Store:dispatch(RejoinActions.setFirstConnection(date.FirstConnection))
		Store:dispatch(RejoinActions.setClaimedRejoinReward(date.ClaimedRejoinReward))
	end)

	--[[TeleportationService.AreaUpdated:Connect(function(area)
		Store:dispatch(AreaActions.setArea(area))
	end)]]

	MonetizationService.UpdateData:Connect(function(data)
		-- Store:dispatch(PlayerActions.addMoney1(data.Money1))
		-- Store:dispatch(PlayerActions.addMoney2(data.Money2))
		-- Store:dispatch(PlayerActions.addWins(data.Wins))
		-- Store:dispatch(PlayerActions.addRebirth(data.Rebirth))
		Store:dispatch(SpinsActions.setSpins("Free", data.Spins.Free))
		Store:dispatch(SpinsActions.setSpins("Premium", data.Spins.Premium))

		Store:dispatch(CharacterActions.setCharacters(data.Characters.Unlocked))
		Store:dispatch(CharacterActions.setCharacter(data.Characters.Current))

		Store:dispatch(TrailsActions.setTrail(data.Trails.Current))
		Store:dispatch(TrailsActions.setTrails(data.Trails.Unlocked))

		Store:dispatch(CoachActions.setCoach(data.Coaches.Current))
		Store:dispatch(CoachActions.setCoaches(data.Coaches.Unlocked))

		Store:dispatch(MonetizationActions.setGamepasses(data.Gamepasses))
		Store:dispatch(ChestsActions.setVerified(data.Codes.Verified))

		Store:dispatch(AreaActions.setAreas(data.Areas.Unlocked))
		Store:dispatch(AreaActions.setArea(data.Areas.Current))

		Store:dispatch(PetsActions.setPets(data.Inventory.Pets))
		Store:dispatch(PetsActions.setEquippedPets(data.Inventory.EquippedPets))

		Store:dispatch(InventoryActions.setMaxEquipped(data.Inventory.Storage.Equipped))
		Store:dispatch(InventoryActions.setMaxStored(data.Inventory.Storage.Stored))

		Store:dispatch(FruitsActions.setFruits(data.Inventory.Fruits))
		Store:dispatch(FruitsActions.setActiveFruits(data.Inventory.ActiveFruits))

		Store:dispatch(BoostsActions.setBoosts(data.Inventory.Boosts))
		Store:dispatch(BoostsActions.setActiveBoosts(data.Inventory.ActiveBoosts))

		Store:dispatch(FriendsActions.setStars(data.Invites.Stars))
		Store:dispatch(FriendsActions.setInvitedFriends(data.Invites.Invited_Friends))

		Store:dispatch(StarterPacksActions.setBoughtStarterPacks(data.BoughtStarterPacks))

		Store:dispatch(DailyRewardsActions.setLastRedeemedTimestamp(data.LastDailyRewarded))
		Store:dispatch(DailyRewardsActions.setLastRedeemedId(data.LastRedeemedId))
		Store:dispatch(DailyRewardsActions.setDailyRewards(data.DailyRewards))

		Store:dispatch(SeasonActions.setSeasonQuests(data.Season.DailyQuests, data.Season.WeeklyQuests))
		Store:dispatch(SeasonActions.setSeason(data.Season.Completed))
		Store:dispatch(SeasonActions.setFreeRewards(DataCacheController:GetFile("Template").Season.Rewards))
		Store:dispatch(
			SeasonActions.setPremiumRewards(DataCacheController:GetFile("Template").Season["Premium Rewards"])
		)
		Store:dispatch(SeasonActions.setClaimedRewards(data.Season.Claimed))
		Store:dispatch(SeasonActions.setClaimedPremiumRewards(data.Season["Premium Claimed"]))
		Store:dispatch(SeasonActions.setLevel(data.Season.Level))
		Store:dispatch(SeasonActions.setExp(data.Season.Exp))
		Store:dispatch(SeasonActions.setPremium(data.Season.Premium))

		Store:dispatch(ClicksActions.setGoldClick(table.find(data.Gamepasses, "Gold Click")))
	end)

	-- ExclusivePackService.ItemClaimed:Connect(function(exclusivePack, id: number)
	-- 	Store:dispatch(ExclusivePackActions.setExclusivePackData(exclusivePack))
	-- 	Store:dispatch(ExclusivePackActions.setExclusivePackCurrentIndex(id + 1))
	-- end)

	-- ExclusivePackService.ExclusivePackReseted:Connect(function(exclusivePack)
	-- 	Store:dispatch(ExclusivePackActions.setExclusivePackData(exclusivePack))
	-- 	Store:dispatch(ExclusivePackActions.setExclusivePackCurrentIndex(1))
	-- end)

	FriendsService.RewardGiven:Connect(function(invitesTable)
		Store:dispatch(FriendsActions.setStars(invitesTable.Stars))
		Store:dispatch(FriendsActions.setInvitedFriends(invitesTable.Invited_Friends))
	end)

	FriendsService.RewardBought:Connect(function(stars)
		Store:dispatch(FriendsActions.setStars(stars))
	end)

	-- Continuous sync
	task.spawn(function()
		while true do
			task.wait(1)

			DataService:GetData(player):andThen(function(playerData)
				Store:dispatch(FruitsActions.setFruits(playerData.Inventory.Fruits))
				Store:dispatch(FruitsActions.setActiveFruits(playerData.Inventory.ActiveFruits))
			end)
		end
	end)
end

return Data
