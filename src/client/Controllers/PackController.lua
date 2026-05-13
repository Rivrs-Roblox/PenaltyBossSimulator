--[=[
	Owner: JustStop__
	Version: v.0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayer = game:GetService("StarterPlayer")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Players = game:GetService("Players")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Zone = require(ReplicatedStorage.Shared.ZonePlus)

-- Services
local DataService = nil
local DailyRewardsService = nil

local Helpers = ReplicatedStorage.Shared.Helpers
local SetupArea = require(Helpers.SetupArea)

local player = Players.LocalPlayer

-- Controllers
local NotificationController = nil
local DataCacheController = nil
local StoreController = nil
local UIController = nil

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.UIActions)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- PackController
local PackController = Knit.CreateController({
	Name = "PackController",
	Template = {},

	FirstRun = true,
})

--|| Functions ||--
function PackController:Update()
	local PackAreas = CollectionService:GetTagged("PackArea")

	

			SetupArea("PackArea", {
				onEnter = function(plr)
					print("onenter")
					if plr == player then
						UIController:ShowFrame({ frame = FramesConstants.StarterPack })
					end
				end,
				onExit = function(plr)
					print("onexit")
					if plr == player then
						UIController:HideFrame()
					end
				end,
			})
		

		-- local UI = Chest:WaitForChild("ChestGui")
		-- local Count = UI:WaitForChild("Count_Down")
		-- local IntTime = Store:getState()["ChestsReducer"].Chests[Chest.Name] - os.time()
		-- local Sign = math.sign(IntTime)

		-- if Sign ~= -1 then
		-- 	local Time = ToHMS(IntTime)
		-- 	Count:WaitForChild("Amount").Text = Time
		-- else
		-- 	Count:WaitForChild("Amount").Text = "Ready!"
		-- end
	

	self.FirstRun = false
end

--|| Knit Lifecycle ||--
function PackController:KnitInit()
	DailyRewardsService = Knit.GetService("DailyRewardsService")
	DataService = Knit.GetService("DataService")
	NotificationController = Knit.GetController("NotificationController")
	DataCacheController = Knit.GetController("DataCacheController")
	StoreController = Knit.GetController("StoreController")
	UIController = Knit.GetController("UIController")

	self.Template = DataCacheController:GetFile("Template")

	
		self:Update()
		print("StarterPackUpdated")
	

	print("[Pack CONTROLLER] Controller started successfully.")
end

return PackController
