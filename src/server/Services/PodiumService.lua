-- Knit Packages
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local CollectionService = game:GetService("CollectionService")

local Trove = require(ReplicatedStorage.Packages.Trove)

-- Services
local DataService
local LeaderboardService = nil

local WINS_DANCE_ANIMATION_ID = "rbxassetid://108138377328581"
local REBIRTH_DANCE_ANIMATION_ID = "rbxassetid://138780298663746"
local MONEY2_DANCE_ANIMATION_ID = "rbxassetid://137099289096793"
local ROBUXSPENT_DANCE_ANIMATION_ID = "rbxassetid://100933724268824"

local PodiumService = Knit.CreateService({
	Name = "PodiumService",
	Client = {},
	DanceCharacterTrove = {},
})

function PodiumService:CreateTopPlayersModel()
	local TopPlayers = LeaderboardService:GetTopPlayers()
	for _, podium in pairs(CollectionService:GetTagged("Podium")) do
		for key, value in pairs(TopPlayers) do
			local podiumModel = podium:FindFirstChild(key)
			if podiumModel then
				local character = Players:CreateHumanoidModelFromUserId(value.Id)
				character.Parent = podiumModel
				character:ScaleTo(1)
				character.HumanoidRootPart.Anchored = true
				character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				character.HumanoidRootPart.CFrame = podiumModel:WaitForChild("NpcPlacement").CFrame
					+ Vector3.new(0, 2.6, 0)
				self.DanceCharacterTrove:Add(character)
				local billboadPlayerName =
					podiumModel:WaitForChild("NpcPlacement"):WaitForChild("Billboard"):WaitForChild("PlayerName")
				billboadPlayerName.Text = value.Name

				local animationTrack
				local animation = Instance.new("Animation")
				animation.Name = "DanceAnimation"

				if key == "Wins" or key == "CandyCane" then
					animation.AnimationId = WINS_DANCE_ANIMATION_ID
				elseif key == "Rebirth" then
					animation.AnimationId = REBIRTH_DANCE_ANIMATION_ID
				elseif key == "Money2" then
					animation.AnimationId = MONEY2_DANCE_ANIMATION_ID
				elseif key == "RobuxSpent" then
					animation.AnimationId = ROBUXSPENT_DANCE_ANIMATION_ID
				end

				animation.Parent = character

				animationTrack = character.Humanoid:LoadAnimation(animation)
				animationTrack.Looped = true
				animationTrack:Play()
			end
		end
	end
end

function PodiumService:LeaderboardsUpdated()
	self.DanceCharacterTrove:Clean()
	self:CreateTopPlayersModel()
end

--|| Client Functions ||--

-- KNIT START
function PodiumService:KnitStart()
	DataService = Knit.GetService("DataService")
	LeaderboardService = Knit.GetService("LeaderboardService")

	self.DanceCharacterTrove = Trove.new()

	LeaderboardService.LeaderboardsUpdated:Connect(function()
		self:LeaderboardsUpdated()
	end)
end

return PodiumService
