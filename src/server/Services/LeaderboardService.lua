--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local SetInterval = require(Helpers.SetInterval)
local FormatNumber = require(Helpers.Numbers.FormatNumber)
local Adjustments = require(Helpers.Numbers.Adjustments)

-- Services
local DataService = nil

-- Leaderboard Service
local LeaderboardService = Knit.CreateService({
	Name = "LeaderboardService",

	Leaderboards = {},
	Stats = {},
	OrderedDatastores = {},
	TopPlayers = {},
	LeaderboardsUpdated = Signal.new(),
	CachePages = {},
})

--|| Functions ||--
function LeaderboardService:UpdateData(player: Player)
	local data = DataService:GetData(player)
	if data == nil then
		return
	end

	for _, Stat in self.Stats do
		local Amount = data[Stat]
		local CompressedAmount = Adjustments.Compress(Amount)
		self.OrderedDatastores[Stat]:SetAsync(player.UserId, CompressedAmount)
	end
end

function LeaderboardService:InitLeaderboards()
	local TaggedLeaderboards = CollectionService:GetTagged("Leaderboard")
	for _, Leaderboard in TaggedLeaderboards do
		local Stat = string.match(Leaderboard.Name, "(%w+)Leaderboard")
		if not table.find(self.Stats, Stat) then
			table.insert(self.Stats, Stat)
		end
		-- print(self.Stats)
		self.OrderedDatastores[Stat] = DataStoreService:GetOrderedDataStore(`{Stat}`)
		table.insert(self.Leaderboards, Leaderboard)
	end
end

function LeaderboardService:Update()
	for i, Stat in self.Stats do
		self.CachePages[Stat] = {}
		local OrderedDatastore = self.OrderedDatastores[Stat]:GetSortedAsync(false, 50)
		local Page = OrderedDatastore:GetCurrentPage()

		for Index, Entry in Page do
			local Key = tonumber(Entry.key) -- Konversi ke angka

			-- Pastikan Key valid dan tidak kurang dari 0
			if not Key or Key < 0 then
				continue
			end

			local Value = math.floor(Adjustments.Decompress(Entry.value))
			local FormattedValue = FormatNumber(Value)
			local name = Players:GetNameFromUserIdAsync(Entry.key)

			table.insert(self.CachePages[Stat], { Name = name, Value = FormattedValue })

			if Index == 1 then
				self.TopPlayers[Stat] = { ["Id"] = Entry.key, ["Name"] = name }
			end
		end
	end

	self.LeaderboardsUpdated:Fire()
	self:InitLeaderboardsInPlace()
end

function LeaderboardService:InitLeaderboardsInPlace()
	for i, Stat in self.Stats do
		for _, Leaderboard in self.Leaderboards do
			if Leaderboard.Name == `{Stat}Leaderboard` then
				local UITemplate = Leaderboard:WaitForChild("UITemplate")
				local Container = UITemplate:WaitForChild("Container")
				local Template = Container:WaitForChild("Template")
				for Index, Entry in Container:GetChildren() do
					if Entry:IsA(Template.ClassName) and Entry ~= Template then
						Entry:Destroy()
					end
				end
				for index, value in ipairs(self.CachePages[Stat]) do
					Template.Visible = false

					local NewEntry = Template:Clone()
					NewEntry.Visible = true
					NewEntry.Name = value.Name
					NewEntry.Parent = Container

					NewEntry.BackgroundColor3 = if index == 1
						then Color3.fromRGB(255, 214, 6)
						elseif index == 2 then Color3.fromRGB(171, 168, 168)
						elseif index == 3 then Color3.fromRGB(205, 127, 50)
						else Color3.fromRGB(56, 152, 224)

					NewEntry.LayoutOrder = index

					NewEntry:FindFirstChild("Rank").Text = `{index}.`
					NewEntry:FindFirstChild("Amount").Text = value.Value
					NewEntry:FindFirstChild("Name").Text = value.Name
				end
			end
		end
	end
end

function LeaderboardService.Client:GetTopPlayers()
	return self.Server:GetTopPlayers()
end

function LeaderboardService:GetTopPlayers()
	return self.TopPlayers
end

--|| Knit Lifecycle ||--
function LeaderboardService:KnitInit()
	DataService = Knit.GetService("DataService")

	Players.PlayerAdded:Connect(function(player: Player)
		self:UpdateData(player)
	end)
	Players.PlayerRemoving:Connect(function(player: Player)
		self:UpdateData(player)
	end)

	self.LeaderboardsUpdated:Fire()

	task.delay(0.5, function()
		self:InitLeaderboards()
		self:Update()
	end)

	SetInterval(function()
		self:Update()
	end, 360)

	print("[LEADERBOARD SERVICE] Service loaded successfully.")
end

return LeaderboardService
