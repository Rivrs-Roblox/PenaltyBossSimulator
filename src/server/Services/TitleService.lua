-- Knit Packages
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local Players = game:GetService("Players")
local DataService

local TitleGuiTemplate = ReplicatedStorage:WaitForChild("PlayerTitleGui")

local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

local titlesTemplate = {
	{ Threshold = 0, Title = "Beginner 🐣💤😴" },
	{ Threshold = 1_000, Title = "Rookie 🏃🤓😅" },
	{ Threshold = 100_000, Title = "Trainee 🔧📚💪" },
	{ Threshold = 1_000_000, Title = "Newbie 😎🧢🎯" },
	{ Threshold = 3_000_000, Title = "Novice 🪓🛡️🎒" },
	{ Threshold = 10_000_000, Title = "Apprentice 📘🗡️🎯" },
	{ Threshold = 25_000_000, Title = "Fighter 🥊🔥💢" },
	{ Threshold = 50_000_000, Title = "Warrior 🛡️⚔️🦾" },
	{ Threshold = 100_000_000, Title = "Elite 💼🧠💥" },
	{ Threshold = 250_000_000, Title = "Master 🧙‍♂️📜✨" },
	{ Threshold = 500_000_000, Title = "Champion 🏆💪👑" },
	{ Threshold = 1_000_000_000, Title = "Hero 🦸‍♂️🌟⚡" },
	{ Threshold = 2_500_000_000, Title = "Legend 🐉📖🏰" },
	{ Threshold = 5_000_000_000, Title = "Mythic 🧬💫🔮" },
	{ Threshold = 10_000_000_000, Title = "Godlike ⚡🌌🕊️" },
	{ Threshold = 100_000_000_000_000_000_000, Title = "Omniscient 🧠👁️📈" },
	{ Threshold = 1_000_000_000_000_000_000_000_000_000_000_000, Title = "Transcendent 🌀👑🌠" },
	{ Threshold = 100_000_000_000_000_000_000_000_000_000_000_000, Title = "Cosmic Entity 🌌🛸🧿" },
	{ Threshold = 10_000_000_000_000_000_000_000_000_000_000_000_000_000, Title = "Beyond Reality 🧭🌠🕳️" },
}

local TitleService = Knit.CreateService({
	Name = "TitleService",

	Client = {
		TitleGuiCreated = Knit.CreateSignal(),
	},
})

local function titleDecider(power: number): string
	local result = "Newbie"
	for _, data in ipairs(titlesTemplate) do
		if power >= data.Threshold then
			result = data.Title
		else
			break
		end
	end
	return result
end

--|| Client Functions ||--
function TitleService.Client:UpdateTitleData(player: Player, power: number)
	self.Server:UpdateTitleData(player, power)
end

function TitleService:UpdateTitleData(player: Player, power: number)
	local character = player.Character
	if not character then
		return
	end

	local playerTitleGui = character:FindFirstChild("PlayerTitleGui")
	if playerTitleGui then
		playerTitleGui.Frame.PowerText.Text = FormatNumber(power) .. " Power"
		playerTitleGui.Frame.TitleText.Text = titleDecider(power)
	end
end

-- KNIT START
function TitleService:KnitInit()
	DataService = Knit.GetService("DataService")

	DataService.PowerUpdatedSignal:Connect(function(player: Player, power: number)
		self:UpdateTitleData(player, power)
	end)

	local function characterAdded(player: Player, character: Instance)
		local data = DataService:GetData(player)
		if not data then
			return
		end

		if character:FindFirstChild("PlayerTitleGui") then
			return
		end

		-- matikan nametag player
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

		-- masukkan title gui ke kepala player
		local playerTitleGui = TitleGuiTemplate:Clone()
		playerTitleGui.Parent = character
		playerTitleGui.Adornee = humanoidRootPart
		playerTitleGui.StudsOffset = Vector3.new(0, 4.5, 0)
		playerTitleGui.Frame.NameText.Text = player.DisplayName

		self:UpdateTitleData(player, data.Money2)
	end

	local function playerAdded(player: Player)
		player.CharacterAdded:Connect(function(character)
			characterAdded(player, character)
		end)

		if player.Character then
			characterAdded(player, player.Character)
		end
	end

	Players.PlayerAdded:Connect(playerAdded)
	for _, player in pairs(Players:GetChildren()) do
		playerAdded(player)
	end
end

return TitleService
