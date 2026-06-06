--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")
local BadgeService = game:GetService("BadgeService")

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local FunnelsModule = require(ReplicatedStorage.Packages.funnelsModule)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)
local FindValue = require(Helpers.Table.FindValue)

-- Services
local DataCacheService = nil

-- ProfileService
local ServerModules = script.Parent.Parent.Modules
local ProfileService = require(ServerModules.ProfileService)
local ProfileTemplate = nil
local ProfileStore = nil
local ServerConfig = require(ServerStorage.Data.ServerConfig)

local BadgesId = {
	["Zone1"] = 1533207517245352,
	["Zone2"] = 4268649669368622,
	["Zone3"] = 419785454511090,
	["Zone4"] = 2140424674360387,
	["Zone5"] = 3906373985996575,
	["Zone6"] = 1594237895618651,
	["Zone7"] = 2987423990601894,
	["Zone8"] = 1419013033698560,
	["Zone9"] = 768551665149645,
	["Zone10"] = 459471181043442,
	-- ["Zone11"] = 2277013782656006,
	-- ["Zone12"] = 798903646621705,
	-- ["Zone13"] = 1330872371903188,
	-- ["Zone14"] = 2692997590463276,
}

-- Tambahkan table untuk menyimpan checkpoint terakhir setiap player
local economyMilestones = {}

-- Variables
local USE_DEFAULT_DATA = false

-- Knit Logic
local DataService = Knit.CreateService({
	Name = "DataService",
	Profiles = {},
	Template = {},
	Client = {
		DataInit = Knit.CreateSignal(),

		Money1Updated = Knit.CreateSignal(),
		Money2Updated = Knit.CreateSignal(),
		WinsUpdated = Knit.CreateSignal(),
		RebirthsUpdated = Knit.CreateSignal(),
		AreasUpdated = Knit.CreateSignal(),
		AreaUpdated = Knit.CreateSignal(),
		BossProgressUpdated = Knit.CreateSignal(),
		TutorialCompleted = Knit.CreateSignal(),
		PowerUpdated = Knit.CreateSignal(),
	},

	PowerUpdatedSignal = Signal.new(),
})

-- Constants
local TYPES = {
	Money1 = "Money1Updated",
	Money2 = "Money2Updated",
	Wins = "WinsUpdated",
	Rebirth = "RebirthsUpdated",
}

--|| Client Functions ||--

-- Returns player's data to client
function DataService.Client:GetData(player: Player): {} | nil
	return self.Server:GetData(player)
end

function DataService.Client:TutorialFinished(player: Player, state: boolean)
	return self.Server:TutorialFinished(player, state)
end

function DataService.Client:AddArea(player: Player, name: string)
	return self.Server:AddArea(player, name, false)
end

function DataService.Client:TutorialProgressed(player: Player, step: number)
	return self.Server:TutorialProgressed(player, step)
end

--|| Local Functions ||--
function DataService:_createLeaderStats(player: Player, data: {})
	local LeaderStats = Instance.new("Folder")
	LeaderStats.Name = "leaderstats"

	local Money2 = Instance.new("StringValue")
	Money2.Name = self.Template.Economy.Money2 -- To change with config call when done
	Money2.Value = FormatNumber(data.Money2)
	Money2.Parent = LeaderStats

	local Wins = Instance.new("StringValue")
	Wins.Name = "Wins"
	Wins.Value = FormatNumber(data.Wins)
	Wins.Parent = LeaderStats

	LeaderStats.Parent = player
end

-- Update LeaderStats
function DataService:_updateLeaderStats(player: Player)
	local data = self:GetData(player)
	player.leaderstats[self.Template.Economy.Money2].Value = FormatNumber(data.Money2)
	player.leaderstats.Wins.Value = FormatNumber(data.Wins)
end

-- Init & cache player profile
function DataService:_initAndCache(player: Player, profile: {})
	local data = profile.Data

	self:_createLeaderStats(player, data)

	self.Profiles[player] = profile
	player:SetAttribute("DataLoaded", true)

	print("[DATA SERVICE] Data loaded: " .. player.Name)
end

-- Delete player datas
function DataService:_deletePlayerProfile(userId: string)
	return ProfileStore:WipeProfileAsync(
		ServerConfig.Profile_Prefix .. PlayerService:GetUserIdFromNameAsync(userId.Name)
	)
end

-- Load player datas
function DataService:_loadData(player: Player)
	local profile = ProfileStore:LoadProfileAsync(ServerConfig.Profile_Prefix .. player.UserId)

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		profile:ListenToRelease(function()
			self.Profiles[player] = nil
			player:Kick("Data loaded on another server. Please rejoin!")
		end)

		if player:IsDescendantOf(Players) == true then
			if USE_DEFAULT_DATA then
				profile.Data = TableUtil.Copy(ProfileTemplate, true)
			end

			self:_initAndCache(player, profile)
			return profile
		else
			profile:Release()
		end
	else
		player:Kick("An error occured while loading your datas. Please rejoin!")
	end
end

-- Saver player datas
function DataService:_saveData(player: Player)
	local profile = self.Profiles[player]

	if profile ~= nil then
		profile.Data.LastConnection = os.time() -- ← Tambahkan ini di sini
		profile:Release()
	end

	self.Profiles[player] = nil
	print("[DATA SERVICE] Data saved: " .. player.Name)
end

-- Reset player datas
function DataService:_resetData(player: Player)
	-- Pastikan profil dan template tersedia
	if not ProfileTemplate or not ProfileStore then
		warn("[DATA SERVICE] ProfileTemplate or ProfileStore not initialized!")
		return false
	end

	local profile = self.Profiles[player]

	if profile then
		-- Set data pemain ke template default
		profile.Data = TableUtil.Copy(ProfileTemplate, true)

		-- Perbarui data dan tampilan leaderstats
		self:_updateLeaderStats(player)

		-- Kirim notifikasi pembaruan data ke client
		player:SetAttribute("DataLoaded", true)
		print("[DATA SERVICE] Data has been reset for player:", player.Name)
		return true
	else
		warn("[DATA SERVICE] Failed to reset data for player:", player.Name, "- Profile not found!")
		return false
	end
end

--|| Server Functions ||--
function DataService:GetData(player: Player): {} | nil
	local profile = self.Profiles[player]

	if profile == nil then
		repeat
			task.wait(1)
			profile = self.Profiles[player]
		until profile ~= nil or player.Parent == nil
	end

	if profile ~= nil then
		return profile.Data
	else
		return nil
	end
end

-- Get the amount of given wins froms packs in the store based on player's rebirths
function DataService:GetWinsPackAmount(player: Player, pack: string)
	local PACKS_BASE = {
		["Zone1"] = {
			SMALL = 40,
			REGULAR = 300,
			BIG = 3000,
			HUGE = 60000,
		},
		["Zone2"] = {
			SMALL = 600,
			REGULAR = 4500,
			BIG = 45000,
			HUGE = 900000,
		},
		["Zone3"] = {
			SMALL = 9000,
			REGULAR = 67500,
			BIG = 675000,
			HUGE = 13500000,
		},
		["Zone4"] = {
			SMALL = 135000,
			REGULAR = 1012500,
			BIG = 10125000,
			HUGE = 202500000,
		},
		["Zone5"] = {
			SMALL = 2025000,
			REGULAR = 15187500,
			BIG = 151875000,
			HUGE = 3037500000,
		},
		["Zone6"] = {
			SMALL = 30375000,
			REGULAR = 227812500,
			BIG = 2278125000,
			HUGE = 45562500000,
		},
		["Zone7"] = {
			SMALL = 455625000,
			REGULAR = 3417187500,
			BIG = 34171875000,
			HUGE = 683437500000,
		},
		["Zone8"] = {
			SMALL = 6834375000,
			REGULAR = 51257812500,
			BIG = 512578125000,
			HUGE = 10251562500000,
		},
		["Zone9"] = {
			SMALL = 102515625000,
			REGULAR = 768867187500,
			BIG = 7688671875000,
			HUGE = 153773437500000,
		},
		["Zone10"] = {
			SMALL = 1537734375000,
			REGULAR = 11533007812500,
			BIG = 115330078125000,
			HUGE = 2306601562500000,
		},
		["Zone11"] = {
			SMALL = 23066015625000,
			REGULAR = 172995117187500,
			BIG = 1729951171875000,
			HUGE = 34599023437500000,
		},
		["Zone12"] = {
			SMALL = 345990234375000,
			REGULAR = 2594926757812500,
			BIG = 25949267578125000,
			HUGE = 518985351562500000,
		},
		["Zone13"] = {
			SMALL = 5189853515625000,
			REGULAR = 38923901367187500,
			BIG = 389239013671875000,
			HUGE = 7784780273437499400,
		},
		["Zone14"] = {
			SMALL = 77847802734375000,
			REGULAR = 583858520507812600,
			BIG = 5838585205078125600,
			HUGE = 116771704101562482680,
		},
		["Zone15"] = {
			SMALL = 116771704101562510,
			REGULAR = 875787780761718910,
			BIG = 8757877807617187800,
			HUGE = 175157556152343724000,
		},
		["Zone16"] = {
			SMALL = 175157556152343770,
			REGULAR = 1313681671142578430,
			BIG = 13136816711425781700,
			HUGE = 262736334228515586000,
		},
		["Zone17"] = {
			SMALL = 1313681671142578000,
			REGULAR = 9852612533569338000,
			BIG = 98526125335693380000,
			HUGE = 1970522506713867700000,
		},
		["Zone18"] = {
			SMALL = 9852612533569337000,
			REGULAR = 73894594001770030000,
			BIG = 738945940017700300000,
			HUGE = 14789188003540006000000,
		},
	}

	local data = self:GetData(player)
	if data == nil then
		return 0
	end

	return math.round(
		PACKS_BASE[data.Areas.Unlocked[table.maxn(data.Areas.Unlocked)]][pack]
			+ PACKS_BASE[data.Areas.Unlocked[table.maxn(data.Areas.Unlocked)]][pack] * (1.1 * data.Rebirth)
	)
end

-- Edit value in player data & leaderstats
function DataService:ChangeValue(player: Player, key: string, value: number, cancelMultipliers: boolean?)
	local data = self:GetData(player)
	if data == nil then
		return
	end
	if not table.find({ "Money1", "Money2", "Rebirth", "Wins" }, key) then
		return
	end -- Can't use this function if not for a number data

	local function GetFriends()
		local Friends = {}
		for _, Player in Players:GetPlayers() do
			if Player ~= player then
				if Player:IsFriendsWith(player.UserId) then
					table.insert(Friends, Player)
				end
			end
		end
		return Friends
	end

	if not cancelMultipliers then
		value *= self:GetMultiplier(player, key)
	end
	value = math.round(value)

	data[key] += value

	if data[key] < 0 then
		data[key] = 0
	end

	-- --- INI BAGIAN TAMBAHAN UNTUK LOG ECONOMY HANYA PADA KELIPATAN 1 T ---
	local milestoneKey = player.UserId .. "_" .. key
	local currentMilestone = math.floor(data[key] / 1_000_000_000_000)

	if not economyMilestones[milestoneKey] then
		economyMilestones[milestoneKey] = -1 -- inisialisasi milestone terakhir
	end

	if currentMilestone > economyMilestones[milestoneKey] then
		economyMilestones[milestoneKey] = currentMilestone
		FunnelsModule:LogInGameEconomyEvent(player, key, math.abs(value), data[key])
	end
	-- --------------------------------------------------------------------------

	task.delay(1.5, function()
		self.Client[TYPES[key]]:Fire(player, value)

		if key == "Money2" then
			if not data.TutorialComplete then
				self.Client.PowerUpdated:Fire(player, data.Money2)
			end
			self.PowerUpdatedSignal:Fire(player, data.Money2)
		end
	end) -- Send information to client to update stores
	self:_updateLeaderStats(player)

	return value
end

function DataService:ChangeValueRebirth(player: Player)
	local data = self:GetData(player)
	local value = 1
	if FindValue(data.Gamepasses, "x2 Rebirths") then
		value *= 2
	end
	data.Rebirth += 1 * value
	self.Client.RebirthsUpdated:Fire(player, value)

	FunnelsModule:LogInGameEconomyEvent(player, "Rebirth", value, data.Rebirth)

	return 1
end

function DataService.Client:ChangeValueSettings(player, category, value)
	return self.Server:ChangeValueSettings(player, category, value)
end

function DataService:ChangeValueSettings(player: Player, category, value)
	local data = self:GetData(player)
	if data.Settings.Sound[category] then
		data.Settings.Sound[category] = value
	end
end

function DataService.Client:GetValue(player: Player, key: string, value: number, cancelMultipliers: boolean?)
	return self.Server:GetValue(player, key, value, cancelMultipliers)
end

function DataService.Client:GetMultiplier(player: Player, key: string)
	return self.Server:GetMultiplier(player, key)
end

function DataService:GetValue(player: Player, key: string, value: number, cancelMultipliers: boolean?)
	local data = self:GetData(player)
	if data == nil then
		return
	end
	if not table.find({ "Money1", "Money2", "Rebirth", "Wins" }, key) then
		return
	end -- Can't use this function if not for a number data

	if not cancelMultipliers then
		value *= self:GetMultiplier(player, key)
	end

	value = math.round(value)
	return value
end

function DataService:GetMultiplier(player: Player, key: string)
	local data = self:GetData(player)
	if data == nil then
		return 1
	end

	local multiplier = 1

	-- Base Multipliers (Additive logic for Coaches/Pets)
	if key == "Money1" or key == "Money2" then
		local additiveMult = 0
		local id = data.Coaches.Current
		local templateData = DataCacheService:GetFile("Template")
		local currentCoach = templateData.Coaches[id]
		if currentCoach then
			additiveMult += currentCoach.Multiplier
		end

		for _, pet in data.Inventory.EquippedPets do
			additiveMult += pet.Power
		end
		multiplier *= if additiveMult > 0 then additiveMult else 1
	elseif key == "Wins" then
		local characterId = data.Characters and data.Characters.Current
		local templateData = DataCacheService:GetFile("Template")
		local currentCharacter = templateData.Characters and templateData.Characters[characterId]

		if currentCharacter and currentCharacter.Multiplier then
			multiplier *= currentCharacter.Multiplier
		end
	end

	-- Consumable Multipliers (Fruits/Boosts)
	local Items = DataCacheService:GetFile("Items")
	for _, item in data.Inventory.ActiveFruits do
		if key == Items[item.Name].Type then
			multiplier *= 1 + Items[item.Name].Boost
		end
	end

	for _, item in data.Inventory.ActiveBoosts do
		if key == Items[item.Name].Type then
			multiplier *= 2
		end
	end

	-- Global Multipliers
	multiplier *= (1 + (data.Rebirth * 0.2)) -- +20% per rebirth

	-- Friends logic
	local friendsCount = 0
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer:IsFriendsWith(player.UserId) then
			friendsCount += 1
		end
	end
	multiplier *= (1 + (friendsCount * 0.10))

	if data.Codes.Verified then
		multiplier *= 2
	end

	if player.MembershipType == Enum.MembershipType.Premium then
		multiplier *= 1.1
	end

	if FindValue(data.Gamepasses, "VIP") then
		multiplier *= 2
	end

	-- Gamepass X2 logic
	local economyName = if key == "Money1"
		then self.Template.Economy.Money1
		elseif key == "Money2" then self.Template.Economy.Money2
		elseif key == "Rebirth" then "Rebirths"
		else key

	if FindValue(data.Gamepasses, "x2 " .. economyName) then
		multiplier *= 2
	end

	return multiplier
end

function DataService:UpdateData(player: Player, data: {})
	self.Profiles[player] = data
end

-- Add area to player's data
function DataService:AddArea(player: Player, name: string, bypass: boolean?)
	local data = self:GetData(player)
	if data == nil then
		return
	end

	-- 1. Check if already unlocked
	if table.find(data.Areas.Unlocked, name) then
		return
	end

	if not bypass then
		-- 2. Check sequential progression
		local unlockedZones = data.Areas and data.Areas.Unlocked or { "Zone1" }
		local lastUnlocked = unlockedZones[#unlockedZones]
		local lastUnlockedNumber = tonumber(string.match(lastUnlocked, "%d+"))
		local zoneNumber = tonumber(string.match(name, "%d+"))

		if not lastUnlockedNumber or not zoneNumber or (zoneNumber - 1) ~= lastUnlockedNumber then
			return
		end

		-- -- 3. Check if all bosses in the previous zone are beaten
		-- local prevAreaId = string.format("Area%02d", lastUnlockedNumber)
		-- local enemies = self.Template.Enemies
		-- local areaEnemies = enemies and enemies[prevAreaId]

		-- if areaEnemies then
		-- 	local maxBossCount = 0
		-- 	for enemyKey, _ in pairs(areaEnemies) do
		-- 		local bIndex = tonumber(string.match(enemyKey, "Boss%s+(%d+)"))
		-- 			or tonumber(string.match(enemyKey, "MiniBoss%s+(%d+)"))
		-- 		if bIndex and bIndex > maxBossCount then
		-- 			maxBossCount = bIndex
		-- 		elseif enemyKey == "Boss" and 5 > maxBossCount then
		-- 			maxBossCount = 5
		-- 		end
		-- 	end

		-- 	local progress = data.BossProgress and data.BossProgress[prevAreaId] or 0
		-- 	if progress < maxBossCount then
		-- 		return
		-- 	end
		-- end

		-- 4. Check if player has enough wins
		local price = self.Template.Areas[name] and self.Template.Areas[name].Price or 0
		if data.Wins < price then
			return
		end

		self:ChangeValue(player, "Wins", -price, true)
	end

	table.insert(data.Areas.Unlocked, name)
	self.Client.AreasUpdated:Fire(player, data.Areas.Unlocked)

	local number = tonumber(string.match(name, "%d+"))
	FunnelsModule:LogProgressionStep(player, 1, number)

	self:GiveBadge(player, BadgesId[name])
end

-- Change player's area
function DataService:SetArea(player: Player, name: string)
	local data = self:GetData(player)
	if data == nil then
		return
	end

	data.Area = name
	self.Client.AreaUpdated:Fire(player, data.Area)
end

-- Update player's boss progress
function DataService:UpdateBossProgress(player: Player, area: string, bossIndex: number)
	local data = self:GetData(player)
	if data == nil then
		return false
	end

	data.BossProgress = data.BossProgress or {}
	local currentProgress = data.BossProgress[area] or 0

	if bossIndex > currentProgress then
		data.BossProgress[area] = bossIndex
		self.Client.BossProgressUpdated:Fire(player, data.BossProgress)
		return true
	end

	return false
end

function DataService:TutorialProgressed(player: Player, step: number)
	local data = self:GetData(player)
	if data == nil then
		return
	end

	data.TutorialStep = step

	if step == 3 then
		self:ChangeValue(player, "Money2", 120, true)
	elseif step == 6 then
		self:ChangeValue(player, "Wins", 50, true)
	end

	FunnelsModule:LogOnboardingStep(player, step)
end

-- Change tutorial state
function DataService:TutorialFinished(player: Player, state: boolean)
	local data = self:GetData(player)
	if data == nil then
		return
	end

	data.TutorialComplete = true

	self.Client.TutorialCompleted:Fire(player)
end

function DataService:GiveBadge(player: Player, badgeId: number)
	local data = self:GetData(player)
	if data == nil then
		return
	end

	if table.find(data.Badges, badgeId) then
		return
	end

	-- Check if badge exists and is enabled
	local success, result = pcall(function()
		return BadgeService:GetBadgeInfoAsync(badgeId) -- Change this to desired badge ID
	end)

	if not success or not result.IsEnabled then
		print(`Get badge info error for {player.Name}`)
		return
	end

	-- Award badge
	local successAward, resultAward = pcall(function()
		return BadgeService:AwardBadge(player.UserId, badgeId)
	end)

	if successAward then
		table.insert(data.Badges, badgeId)
		print(`Awarded badge {result.Name} to {player.Name}`)
	else
		print(`Failed to award badge {result.Name} to {player.Name}: {resultAward}`)
	end
end

function DataService:GiveBadgeForEachUnlockedArea(player: Player)
	local data = self:GetData(player)
	if data == nil then
		return
	end

	for _, value in data.Areas.Unlocked do
		if BadgesId[value] then
			local badgeId = BadgesId[value]

			self:GiveBadge(player, badgeId)
		end
	end
end

function DataService:AttachGlobalUpdates(profile, player) -- panggil ini dari DataService setelah LoadProfile sukses
	-- 1) Lock semua Active → jadi Locked
	local activeUpdateAmount = 0
	for _, upd in ipairs(profile.GlobalUpdates:GetActiveUpdates()) do
		activeUpdateAmount += 1
		local updateId = upd[1]
		if profile:IsActive() then
			print("Got The Active Update")
			profile.GlobalUpdates:LockActiveUpdate(updateId)
			profile:Save()
			print("Update Locked")
		end
	end
	print("Active Updates:", activeUpdateAmount)
	-- Handler utama untuk Locked update
	local function handleLocked(updateId: number, updateData: any)
		if updateData and updateData.Type == "ReferralGift" then
			local fromId = tonumber(updateData.From)
			local amount = tonumber(updateData.Amount) or 0
			local data = profile.Data

			-- Dedup (jangan double reward untuk invitee yang sama)
			if fromId and not table.find(data.Invites.Invited_Friends, fromId) then
				data.Invites.Stars += amount
				table.insert(data.Invites.Invited_Friends, fromId)

				-- Kalau pemainnya online, update UI
				if player and player.Parent == Players then
					self.Client.RewardGiven:Fire(player, data.Invites)
				end
			end
		end

		-- Clear wajib agar update hilang dari profile
		if profile:IsActive() then
			profile.GlobalUpdates:ClearLockedUpdate(updateId)
		end
	end

	-- 2) Proses semua Locked yang tertunda (mis. saat inviter offline sebelumnya)
	for _, upd in ipairs(profile.GlobalUpdates:GetLockedUpdates()) do
		local updateId, updateData = upd[1], upd[2]
		print("new Locked Update added")
		handleLocked(updateId, updateData)
	end

	-- 3) Dengar Locked baru yang datang (real-time, ~<30 detik setelah Lock)
	profile.GlobalUpdates:ListenToNewLockedUpdate(function(updateId, updateData)
		print("new Locked Update added")
		handleLocked(updateId, updateData)
	end)

	-- 4) (Opsional) otomatis “progress” Active baru ke Locked
	profile.GlobalUpdates:ListenToNewActiveUpdate(function(updateId, _)
		-- Progress ke Locked agar segera diproses di step #3
		if profile:IsActive() then
			print("Got The Active Update")
			profile.GlobalUpdates:LockActiveUpdate(updateId)
			profile:Save()
			print("Update Locked")
		end
	end)
end

--|| Knit Lifecycle ||--
function DataService:KnitInit()
	DataCacheService = Knit.GetService("DataCacheService")

	ProfileTemplate = DataCacheService:GetFile("Player")
	ProfileStore = ProfileService.GetProfileStore("1", ProfileTemplate)

	self.Template = DataCacheService:GetFile("Template")
	self.Pets = DataCacheService:GetFile("Pets")

	local funnelInfo = {
		groupName = "Progression",
		step = 1,
		name = "Player Joined",
	}

	local function _playerAdded(player: Player)
		self:_loadData(player)
		--self:_grantTestInventory(player)
		local profile = self.Profiles[player]
		self:AttachGlobalUpdates(profile, player)
		task.spawn(function()
			self:GiveBadgeForEachUnlockedArea(player)
		end)
	end

	local function _playerRemoved(player: Player)
		self:_saveData(player)
		-- self:_resetData(player)
	end

	for _, Player in pairs(Players:GetPlayers()) do
		_playerAdded(Player)
	end

	Players.PlayerAdded:Connect(_playerAdded)
	Players.PlayerRemoving:Connect(_playerRemoved)

	print("[DATA SERVICE] Service loaded successfully.")
end

return DataService
