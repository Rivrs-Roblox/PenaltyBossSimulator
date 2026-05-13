-- Knit Packages
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ProfileService = require(game.ServerScriptService.Server.Modules.ProfileService)
local ServerStorage = game:GetService("ServerStorage")

local profileTemplate = require(game.ReplicatedStorage.Shared.Data.Player)

-- Ambil store yang sama dengan di DataService
local profileStore = ProfileService.GetProfileStore("1", profileTemplate)
local ServerConfig = require(ServerStorage.Data.ServerConfig)

-- Services
local Players = game:GetService("Players")
local DataService
local DataCacheService

local FriendsService = Knit.CreateService({
	Name = "FriendsService",
	Template = {},
	Client = {
		RewardGiven = Knit.CreateSignal(),
		RewardBought = Knit.CreateSignal(),
		EggHatched = Knit.CreateSignal(),
	},
})

--|| Client Functions ||--
function FriendsService.Client:BuyReward(player, rewardId)
	return self.Server:BuyReward(player, rewardId)
end

-- || Server Functions ||--
function FriendsService:BuyReward(player, rewardId)
	local data = DataService:GetData(player)
	if not data then
		return warn("[FRIENDS SERVICE] Player has no data: " .. player.Name)
	end

	local reward = self.Template.Friends.Rewards[rewardId]

	if not reward then
		return { text = "Reward does not exist", type = "ERROR" }
	end

	if data.Invites.Stars < reward.Price then
		return { text = "Not enough stars!", type = "ERROR" }
	end

	if table.find({ "Wins", "Money2" }, reward.RewardType) then
		DataService:ChangeValue(player, reward.RewardType, reward.Reward, true)
		-- elseif reward.RewardType == "Egg" then
		-- 	local _, pet = EggsService:Hatch(player, 1, reward.Reward, {}, true)
		-- 	self.Client.EggHatched:Fire(player, pet, reward.Reward)
	end

	data.Invites.Stars -= reward.Price
	self.Client.RewardBought:Fire(player, data.Invites.Stars)

	return { text = "Reward purchased successfully!", type = "SUCCESS" }
end

function FriendsService:GiveRewards(inviterUserId: number, invitedPlayer: Player)
	if not inviterUserId or inviterUserId <= 0 then
		return
	end
	if not invitedPlayer then
		return
	end

	-- Kirim Active Update ke profile inviter.
	-- TANPA LoadProfileAsync: aman & idempotent.

	profileStore:GlobalUpdateProfileAsync(ServerConfig.Profile_Prefix .. inviterUserId, function(update_handler)
		update_handler:AddActiveUpdate({
			Type = "ReferralGift",
			From = invitedPlayer.UserId,
			Amount = 1, -- +1 Stars (ubah sesuai desainmu)
			Ts = os.time(),
		})
	end)
end

function FriendsService:_processJoinReferral(player: Player)
	local joinData = player:GetJoinData()
	local referredBy = joinData.ReferredByPlayerId

	print("[FRIENDS] JoinData:", player.Name, "ReferredBy:", referredBy)

	if not referredBy then
		return
	end

	if referredBy > 0 and referredBy ~= player.UserId then
		self:GiveRewards(referredBy, player)
	else
		print("[FRIENDS] No valid referral for:", player.Name)
	end
end

function FriendsService:KnitStart()
	DataService = Knit.GetService("DataService")
	DataCacheService = Knit.GetService("DataCacheService")

	self.Template = DataCacheService:GetFile("Template")

	for _, player in ipairs(Players:GetPlayers()) do
		task.defer(function()
			self:_processJoinReferral(player)
		end)
	end

	Players.PlayerAdded:Connect(function(player)
		self:_processJoinReferral(player)
	end)
end
return FriendsService
