--[=[
	Owner: JustStop__
	Version: v.0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataService = nil
local DailyRewardsService = nil

-- Controllers
local NotificationController = nil
local DataCacheController = nil
local StoreController = nil

-- DailyRewardsController
local DailyRewardsController = Knit.CreateController({
	Name = "DailyRewardsController",
	Template = {},
})

--|| Functions ||--
function DailyRewardsController:ClaimReward(id: number)
	local promise, res = DailyRewardsService:ClaimReward(id):await()
	if promise == false then
		return warn("[DAILY REWARDS CONTROLLER] An internal error occurred while claming reward.")
	end
	if res ~= nil and res ~= {} then
		NotificationController:Notify({
			tag = "DailyReward",
			text = res.text,
			type = res.type,
		})
	end
end

function DailyRewardsController:Skip()
	StoreController:BuyItem({ name = "Daily Rewards - Skip 1" })
end

function DailyRewardsController:BuyAll()
	StoreController:BuyItem({ name = "Daily Rewards - Skip All" })
end

--|| Knit Lifecycle ||--
function DailyRewardsController:KnitInit()
	DailyRewardsService = Knit.GetService("DailyRewardsService")
	DataService = Knit.GetService("DataService")
	NotificationController = Knit.GetController("NotificationController")
	DataCacheController = Knit.GetController("DataCacheController")
	StoreController = Knit.GetController("StoreController")

	self.Template = DataCacheController:GetFile("Template")

	print("[DAILY REWARDS CONTROLLER] Controller started successfully.")
end

return DailyRewardsController
