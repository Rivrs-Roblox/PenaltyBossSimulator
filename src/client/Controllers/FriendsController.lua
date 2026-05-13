-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local SocialService = game:GetService("SocialService")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

-- Player
local player = Players.LocalPlayer

local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local FriendsActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.FriendsActions)

local FriendsService

local NotificationController

-- FriendsController
local FriendsController = Knit.CreateController({
	Name = "FriendsController",
})

--|| Local Functions ||--

--|| Functions ||--
function FriendsController:BuyReward(rewardId)
	local _, result = FriendsService:BuyReward(rewardId):await()

	if result then
		NotificationController:Notify({
			text = result.text,
			type = result.type,
		})
	end
end

function FriendsController:SetFriendList()
	local success, friendPages = pcall(function()
		return Players:GetFriendsAsync(player.UserId)
	end)

	if not success or not friendPages then
		warn("Failed to get friend pages. UserId might be invalid (are you testing in Local Server?).")
		return
	end

	local friends = {}

	while true do
		-- Ambil teman di halaman saat ini
		for _, item in pairs(friendPages:GetCurrentPage()) do
			-- Tambahkan data Thumbnail
			item["AvatarUrl"] = Players:GetUserThumbnailAsync(
				item.Id, 
				Enum.ThumbnailType.HeadShot, 
				Enum.ThumbnailSize.Size420x420
			)
			table.insert(friends, item)
		end
		
		-- Cek apakah ini halaman terakhir
		if friendPages.IsFinished then
			break
		end
		
		-- Jika belum selesai, lanjut ke halaman berikutnya
		local advanceSuccess, advanceError = pcall(function()
			friendPages:AdvanceToNextPageAsync()
		end)
		
		if not advanceSuccess then
			warn("Failed to advance friend pages: " .. tostring(advanceError))
			break
		end
	end

	Store:dispatch(FriendsActions.setFriends(friends))

	-- Set online friends
	local onlineFriends = {}
	local successOnline, resultOnline = pcall(function()
		return player:GetFriendsOnline()
	end)
	
	if successOnline and resultOnline then
		onlineFriends = resultOnline
	end

	Store:dispatch(FriendsActions.setOnlineFriends(onlineFriends))
end

function FriendsController:InviteFriend(friendId)
	local success, canSend = pcall(function()
		return SocialService:CanSendGameInviteAsync(Players.LocalPlayer)
	end)

	if success and canSend then
		local inviteOptions = Instance.new("ExperienceInviteOptions")
		inviteOptions.InviteUser = friendId

		local success, errorMessage = pcall(function()
			SocialService:PromptGameInvite(Players.LocalPlayer, inviteOptions)
		end)

		if not success then
			NotificationController:Notify({
				text = "Failed to send invite: " .. errorMessage,
				type = "ERROR",
			})
		end
	else
		NotificationController:Notify({
			text = "You cannot send game invites at this time.",
			type = "ERROR",
		})
	end
end

function FriendsController:KnitStart()
	FriendsService = Knit.GetService("FriendsService")

	NotificationController = Knit.GetController("NotificationController")

	self:SetFriendList()

	FriendsService.RewardGiven:Connect(function(invitesTable)
		NotificationController:Notify({
			text = "You have been rewarded for inviting a friend!",
			type = "SUCCESS",
		})
	end)
end

return FriendsController
