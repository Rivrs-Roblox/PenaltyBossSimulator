--[=[
	Owner: JustStop__
	Version: v.0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local RewardsActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.RewardsActions)

-- Services
local RewardsService = nil

-- Controllers
local NotificationController = nil
local DataCacheController = nil
local StoreController = nil

-- RewardsController
local RewardsController = Knit.CreateController({
	Name = "RewardsController",
	Template = {},
})

--|| Functions ||--

function RewardsController:ClaimReward(id: number)
	local promise, res = RewardsService:ClaimReward(id):await()

	if promise == false then
		return warn("[REWARDS CONTROLLER] An internal error occurred while claiming reward.")
	end

	if res ~= nil and res ~= {} then
		NotificationController:Notify({
			tag = "TimeReward",
			text = res.text,
			type = res.type,
		})
	end
end

function RewardsController:ResetGifts()
	local promise, res = RewardsService:ResetGifts():await()

	if promise == false then
		return warn("[REWARDS CONTROLLER] An internal error occurred while resetting gifts.")
	end

	if res ~= nil and res ~= {} then
		NotificationController:Notify({
			tag = "TimeReward",
			text = res.text,
			type = res.type,
		})

		if res.type == "SUCCESS" then
			Store:dispatch(RewardsActions.addTime(-Store:getState()["RewardsReducer"].time))
		end
	end
end

function RewardsController:UpdateTimer()
	task.spawn(function()
		while task.wait(1) do
			Store:dispatch(RewardsActions.addTime(1))
		end
	end)
end

function RewardsController:SkipTwo()
	StoreController:BuyItem({ name = "Time Rewards - Buy 2" })
end

function RewardsController:BuyAll()
	StoreController:BuyItem({ name = "Time Rewards - Buy All" })
end

--|| Knit Lifecycle ||--

function RewardsController:KnitInit()
	RewardsService = Knit.GetService("RewardsService")

	NotificationController = Knit.GetController("NotificationController")
	DataCacheController = Knit.GetController("DataCacheController")
	StoreController = Knit.GetController("StoreController")

	self.Template = DataCacheController:GetFile("Template")

	self:UpdateTimer()

	RewardsService:GetRewards():andThen(function(rewards)
		if rewards then
			Store:dispatch(RewardsActions.setRewards(rewards))
		end
	end)

	print("[REWARDS CONTROLLER] Controller started successfully.")
end

return RewardsController
