-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.UIActions)
local AllRewardsActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.AllRewardsActions)

local UpdateLogService = nil
local DataService = nil

local DataCacheController

-- UpdateLogController
local UpdateLogController = Knit.CreateController({
	Name = "UpdateLogController",
	Template = {},
})

--|| Local Functions ||--

--|| Functions ||--
function UpdateLogController:SetAlreadyRead()
	UpdateLogService:SetAlreadyRead()
end

function UpdateLogController:SetFirstJoinFalse()
	UpdateLogService:SetFirstJoinFalse()
end

function UpdateLogController:KnitStart()
	DataService = Knit.GetService("DataService")
	UpdateLogService = Knit.GetService("UpdateLogService")
	DataCacheController = Knit.GetController("DataCacheController")

	self.Template = DataCacheController:GetFile("Template")

	local version = self.Template.Config.Version

	DataService:GetData():andThen(function(data)
		if data == nil then
			return false
		end

		if not data.FirstJoin then
			if data.UpdateLogRead[version] then
				--Store:dispatch(UIActions.setCurrentUI("AllRewards"))
				--Store:dispatch(AllRewardsActions.setAllRewards("DailyRewards"))
			else
				Store:dispatch(UIActions.setCurrentUI("UpdateLog"))
			end
		else
			self:SetFirstJoinFalse()
		end
	end)
end

return UpdateLogController
