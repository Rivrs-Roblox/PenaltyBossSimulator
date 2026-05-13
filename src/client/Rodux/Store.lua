--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- Variables
local Reducers = StarterPlayer.StarterPlayerScripts.Client.Rodux.Reducers

-- Reducers
local PlayerReducer = require(Reducers.PlayerReducer)
local UIReducer = require(Reducers.UIReducer)
local AreaReducer = require(Reducers.AreaReducer)
local CoachReducer = require(Reducers.CoachReducer)
local FriendsReducer = require(Reducers.FriendsReducer)
local InventoryReducer = require(Reducers.InventoryReducer)
local PetsReducer = require(Reducers.PetsReducer)
local AllRewardsReducer = require(Reducers.AllRewardsReducer)
local FruitsReducer = require(Reducers.FruitsReducer)
local BoostsReducer = require(Reducers.BoostsReducer)
local GoldPetsReducer = require(Reducers.GoldPetsReducer)
local RainbowPetsReducer = require(Reducers.RainbowPetsReducer)
local BoostEventReducer = require(Reducers.BoostEventReducer)
local SettingsReducer = require(Reducers.SettingsReducer)
local RewardsReducer = require(Reducers.RewardsReducer)
local DailyRewardsReducer = require(Reducers.DailyRewardsReducer)
local StarterPacksReducer = require(Reducers.StarterPacksReducer)
local QuestsReducer = require(Reducers.QuestsReducer)
local TradeReducer = require(Reducers.TradeReducer)
local SeasonReducer = require(Reducers.SeasonReducer)
local UpdateReducer = require(Reducers.UpdateReducer)
local NotificationReducer = require(Reducers.NotificationReducer)
local ClicksReducer = require(Reducers.ClicksReducer)
local GroupReducer = require(Reducers.GroupReducer)
local TutorialReducer = require(Reducers.TutorialReducer)
local SpinsReducer = require(Reducers.SpinsReducer)
local MonetizationReducer = require(Reducers.MonetizationReducer)
local ChestsReducer = require(Reducers.ChestsReducer)
local TrailsReducer = require(Reducers.TrailsReducer)
local AutoReducer = require(Reducers.AutoReducer)
local ExclusivePackReducer = require(Reducers.ExclusivePackReducer)
local FightReducer = require(Reducers.FightReducer)
local OfflineFarmReducer = require(Reducers.OfflineFarmReducer)
local CharacterReducer = require(Reducers.CharacterReducer)
local RejoinReducer = require(Reducers.RejoinReducer)

-- Store
local StoreReducer = Rodux.combineReducers({
	PlayerReducer = PlayerReducer,
	UIReducer = UIReducer,
	AreaReducer = AreaReducer,
	CoachReducer = CoachReducer,
	FriendsReducer = FriendsReducer,
	InventoryReducer = InventoryReducer,
	PetsReducer = PetsReducer,
	AllRewardsReducer = AllRewardsReducer,
	FruitsReducer = FruitsReducer,
	BoostsReducer = BoostsReducer,
	GoldPetsReducer = GoldPetsReducer,
	BoostEventReducer = BoostEventReducer,
	SettingsReducer = SettingsReducer,
	RewardsReducer = RewardsReducer,
	DailyRewardsReducer = DailyRewardsReducer,
	StarterPacksReducer = StarterPacksReducer,
	QuestsReducer = QuestsReducer,
	TradeReducer = TradeReducer,
	SeasonReducer = SeasonReducer,
	UpdateReducer = UpdateReducer,
	NotificationReducer = NotificationReducer,
	ClicksReducer = ClicksReducer,
	GroupReducer = GroupReducer,
	TutorialReducer = TutorialReducer,
	SpinsReducer = SpinsReducer,
	MonetizationReducer = MonetizationReducer,
	ChestsReducer = ChestsReducer,
	TrailsReducer = TrailsReducer,
	AutoReducer = AutoReducer,
	ExclusivePackReducer = ExclusivePackReducer,
	RainbowPetsReducer = RainbowPetsReducer,
	FightReducer = FightReducer,
	OfflineFarmReducer = OfflineFarmReducer,
	CharacterReducer = CharacterReducer,
	RejoinReducer = RejoinReducer,
})

local Store = Rodux.Store.new(StoreReducer, nil, {})

return Store
