--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataCacheService = nil
local DataService = nil
local CoachesService = nil

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local GetIdFromName = require(Helpers.Table.GetIdFromName)

-- ChestService
local ChestService = Knit.CreateService({
	Name = "ChestService",

	Client = {
		ChestsUpdated = Knit.CreateSignal(),
	},

	Template = {},
	FirstRun = true,
})

--|| Client Functions ||--
function ChestService.Client:Claim(player: Player, name: string)
	return self.Server:Claim(player, name)
end

--|| Functions ||--
function ChestService:Claim(player: Player, name: string)
	local data = DataService:GetData(player)
	local infos = self.Template.Chests[name]

	if infos.Requirement == "Group" and not player:IsInGroup(self.Template.Config.Group) then
		return { text = self.Template.Messages.Notifications.Not_In_Group, type = "ERROR" }
	end
	if typeof(data.Chests[name]) == "number" then
		for _, Reward in infos.Rewards do
			if Reward.Type == "Coaches" then
				local id = GetIdFromName(Reward.Name, self.Template.Coaches)
				CoachesService:Buy(player, id, true)
			end
		end
		data.Chests[name] = "claimed"
		self.Client.ChestsUpdated:Fire(player, { chests = data.Chests })
		return { text = self.Template.Messages.Notifications.Chest_Claimed(`Mafia Coach`), type = "SUCCESS" }
	end

	return { text = self.Template.Messages.Notifications.Chest_Already_Claimed, type = "ERROR" }
end

--|| Knit Lifecycle ||--
function ChestService:KnitInit()
	DataCacheService = Knit.GetService("DataCacheService")
	DataService = Knit.GetService("DataService")
	CoachesService = Knit.GetService("CoachesService")

	self.Template = DataCacheService:GetFile("Template")

	print("[CHEST SERVICE] Service loaded successfully.")
end

return ChestService
