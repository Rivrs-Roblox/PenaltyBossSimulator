--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

local Helpers = ReplicatedStorage.Shared.Helpers
local SetupArea = require(Helpers.SetupArea)

local player = Players.LocalPlayer

-- Controllers
local DataCacheController = nil
local NotificationControlller = nil
local UIController = nil

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Services
local RejoinService = nil

-- RejoinController
local RejoinController = Knit.CreateController({
	Name = "RejoinController",
	Template = {},
})

--|| Functions ||--
function RejoinController:Claim()
	local promise, res = RejoinService:Claim():await()
	if not promise then
		return warn("[FREE PET CONTROLLER] An internal error occured while claiming free pets.")
	end

	NotificationControlller:Notify(res)
end

--|| Knit Lifecycle ||--
function RejoinController:KnitInit()
	RejoinService = Knit.GetService("RejoinService")

	DataCacheController = Knit.GetController("DataCacheController")
	NotificationControlller = Knit.GetController("NotificationController")
	UIController = Knit.GetController("UIController")

	self.Template = DataCacheController:GetFile("Template")

	print("[REJOIN CONTROLLER] Controller loaded successfully.")
end

function RejoinController:KnitStart()
	SetupArea("RejoinArea", {
		onEnter = function(plr)
			if plr == player then
				UIController:ShowFrame({ frame = FramesConstants.Rejoin })
			end
		end,
		onExit = function(plr)
			if plr == player then
				UIController:HideFrame()
			end
		end,
	})
end

return RejoinController
