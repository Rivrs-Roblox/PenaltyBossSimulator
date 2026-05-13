--[=[
	Owner: JustStop__
	Version: v.0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Service
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataService = nil
local DataCacheService = nil
local CharactersService = nil

-- RejoinService
local RejoinService = Knit.CreateService({
	Name = "RejoinService",
	Client = {
		RejoinUpdated = Knit.CreateSignal(),
	},
	Template = {},
})

function RejoinService.Client:Claim(player: Player)
	return self.Server:Claim(player)
end
function RejoinService:Claim(player)
	local data = DataService:GetData(player)
	print(data)
	if not data then
		return warn("[REJOIN SERVICE] Player has no data: " .. player.Name)
	end
	if data.ClaimedRejoinReward then
		return { text = self.Template.Messages.Notifications.Rejoin_Reward_Claimed_Done, type = "ERROR" }
	end

	if (os.time() - data.FirstConnection < self.Template.RejoinReward.RequiredTime) or not data.Codes.Verified then
		return { text = self.Template.Messages.Notifications.Rejoin_Reward_Not_Ready, type = "ERROR" }
	end
	local added = CharactersService:Buy(player, self.Template.RejoinReward.Id, true)
	if added.type == "SUCCESS" then
		data.ClaimedRejoinReward = true
		self.Client.RejoinUpdated:Fire(
			player,
			{ FirstConnection = data.FirstConnection, ClaimedRejoinReward = data.ClaimedRejoinReward }
		)
		return {
			text = self.Template.Messages.Notifications.Rejoin_Reward_Claimed,
			type = "SUCCESS",
		}
	end
end
--|| Knit Lifecycle ||--
function RejoinService:KnitInit()
	DataCacheService = Knit.GetService("DataCacheService")
	DataService = Knit.GetService("DataService")
	CharactersService = Knit.GetService("CharactersService")

	self.Template = DataCacheService:GetFile("Template")
	print("[REJOIN SERVICE] Service started successfully.")
end

return RejoinService
