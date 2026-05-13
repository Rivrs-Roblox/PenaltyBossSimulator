-- Knit Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataService
local DataCacheService

local UpdateLogService = Knit.CreateService({
	Name = "UpdateLogService",
	Client = {},
	Template = {},
})

--|| Client Functions ||--
function UpdateLogService.Client:SetAlreadyRead(player: Player)
	self.Server:SetAlreadyRead(player)
end

function UpdateLogService.Client:SetFirstJoinFalse(player: Player)
	self.Server:SetFirstJoinFalse(player)
end

function UpdateLogService:SetAlreadyRead(player: Player)
	DataService = Knit.GetService("DataService")

	local playerData = DataService:GetData(player)
	if playerData then
		playerData.UpdateLogRead[self.Template.Config.Version] = true
	end
end

function UpdateLogService:SetFirstJoinFalse(player: Player)
	local data = DataService:GetData(player)
	if data then
		data.FirstJoin = false
	end
end

-- KNIT START
function UpdateLogService:KnitStart()
	DataService = Knit.GetService("DataService")
	DataCacheService = Knit.GetService("DataCacheService")

	self.Template = DataCacheService:GetFile("Template")
end

return UpdateLogService
