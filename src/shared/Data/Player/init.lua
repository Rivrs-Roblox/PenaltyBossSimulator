--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingsTemplate = require(ReplicatedStorage.Shared.Data.Player.SettingsTemplate)
local DailyRewardsTemplate = require(ReplicatedStorage.Shared.Data.Player.DailyRewardsTemplate)
local ExclusivePackTemplate = require(ReplicatedStorage.Shared.Data.Player.ExclusivePackTemplate)
local FruitsTemplate = require(ReplicatedStorage.Shared.Data.Player.FruitsTemplate)
local BoostsTemplate = require(ReplicatedStorage.Shared.Data.Player.BoostsTemplate)

return table.freeze({
	["Money1"] = 0, -- DO NOT CHANGE THIS, WILL BE CALLED IN GAME TEMPLATE CONFIG
	["Money2"] = 100, -- DO NOT CHANGE THIS, WILL BE CALLED IN GAME TEMPLATE CONFIG
	["Rebirth"] = 0,
	["Wins"] = 0,
	["TotalGoals"] = 0,
	["RobuxSpent"] = 0,

	["Characters"] = {
		["Unlocked"] = { 1 },
		["Current"] = 1,
	},

	["Spins"] = {
		["Free"] = 1,
		["Premium"] = 0,
		["Last_Free_Spin"] = 0,
	},

	["Settings"] = table.clone(SettingsTemplate),

	["Areas"] = {
		["Unlocked"] = { "Zone1" },
		["Current"] = "Zone1",
	},

	["BossProgress"] = {},

	["BestZoneWon"] = 0,

	["Chests"] = {
		["Epic Chest"] = 0,
	},

	["Trails"] = {
		["Unlocked"] = {},
		["Current"] = 0,
	},

	["Coaches"] = {
		["Unlocked"] = {},
		["Current"] = 0,
	},

	["Inventory"] = {
		["Last_Stored_Pet_Id"] = 0,
		["Pets"] = {},
		["EquippedPets"] = {},
		["Storage"] = {
			["Equipped"] = 4,
			["Stored"] = 75,
		},
		["ScaledPetsPower"] = {},

		["Fruits"] = table.clone(FruitsTemplate),
		["ActiveFruits"] = {},

		["Boosts"] = table.clone(BoostsTemplate),
		["ActiveBoosts"] = {},
	},

	["Invites"] = {
		["Stars"] = 0,
		["Invited_Friends"] = {},
	},

	["Codes"] = {
		["Redeemed"] = {},
		["Verified"] = false,
	},

	["Badges"] = {},

	["BoughtStarterPacks"] = 0,
	["FirstConnection"] = os.time(),
	["ClaimedRejoinReward"] = false,

	["DailyRewards"] = table.clone(DailyRewardsTemplate),
	["LastDailyRewarded"] = 0,
	["LastRedeemedId"] = 0,
	
	["ExitGiftClaimed"] = false,

	--season pass
	["Season"] = {},
	["SeasonPassCompleted"] = 0,

	["Gamepasses"] = {},

	["TutorialStep"] = 1,
	["TutorialComplete"] = false,

	["GroupRewardClaimed"] = false,

	["ExclusivePack"] = table.clone(ExclusivePackTemplate),
	["ExclusivePackCurrentIndex"] = 1,

	["UpdateLogRead"] = {},
	["FirstJoin"] = true,

	["LastConnection"] = os.time(),
})
