local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DS = game:GetService("DataStoreService")

-- Knit Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Services
local DataService
local DataCacheService
-- local SeasonService

local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

local Config = {}
pcall(function()
	Config = DS:GetDataStore("GameConfigs"):GetAsync("Global") or {}
end)

local BADGE_100_GOAL = 2622236422004443

local FightConfig = Config.FightConfig
	or {
		ZONE_RED_LEFT_END = 0.10,
		ZONE_ORANGE_LEFT_END = 0.30,
		ZONE_ORANGE_RIGHT_START = 0.70,
		ZONE_RED_RIGHT_START = 0.90,
		PENALTY_ORANGE = 0.6,
		PENALTY_RED = 0.3,
	}

local teleporterFolder = workspace.Teleporters
local enemyPodiums = CollectionService:GetTagged("EnemyPodium")

local MAX_WAVES = 5

local FightService = Knit.CreateService({
	Name = "FightService",
	Client = {
		FightStarted = Knit.CreateSignal(),
		FightEnded = Knit.CreateSignal(),
		PlayerTeleported = Knit.CreateSignal(),
		WaveUpdated = Knit.CreateSignal(),
	},

	OnFightStarted = Signal.new(),
	OnFightEnded = Signal.new(),
	OnPlayerTeleported = Signal.new(),

	Sessions = {},
	PlayerPity = {},

	Template = {},
})

--|| Client Functions ||--

function FightService.Client:StartFight(player: Player, battleZone: Object, bossIndex: number)
	return self.Server:StartFight(player, battleZone, bossIndex)
end

function FightService.Client:EndFight(player: Player)
	return self.Server:EndFight(player)
end

function FightService.Client:EvaluateKick(player: Player, directionPosition: number, powerPosition: number)
	return self.Server:EvaluateKick(player, directionPosition, powerPosition)
end

function FightService.Client:ApplyKickResult(player: Player)
	return self.Server:ApplyKickResult(player)
end

--|| Functions ||--

function FightService:GetEnemyKey(wave: number): string
	if wave >= 5 then
		return "Boss"
	end
	return "MiniBoss " .. wave
end

function FightService:GetGoalieDataForWave(areaData: {}, bossIndex: number, wave: number): {}?
	bossIndex = tonumber(bossIndex) or 1
	wave = tonumber(wave) or 1

	local bossKey = "Boss " .. bossIndex
	local bossData = areaData[bossKey]

	if not bossData then
		-- Backwards compatibility fallbacks
		if bossIndex == 5 and areaData["Boss"] then
			bossData = areaData["Boss"]
		elseif areaData["MiniBoss " .. bossIndex] then
			bossData = areaData["MiniBoss " .. bossIndex]
		end
	end

	if not bossData then
		return nil
	end

	return bossData
end

function FightService:StartFight(player: Player, battleZone: Object, bossIndex: number)
	if self.Sessions[player] then
		return
	end

	bossIndex = tonumber(bossIndex) or 1

	local area = battleZone:GetAttribute("Area")
	local data = DataService:GetData(player)

	-- Verify progression requirement: must beat previous boss before next one
	if data then
		data.BossProgress = data.BossProgress or {}
		local progress = data.BossProgress[area] or 0
		if bossIndex > 1 and progress < bossIndex - 1 then
			return -- progression violation, ignored (client handles notification)
		end
	end

	local playerArea = battleZone:WaitForChild("PlayerArea")
	local playerCharacter = player.Character

	if not playerCharacter then
		return
	end

	local offset = Vector3.new(-0.3, 0, -1.3)

	player:RequestStreamAroundAsync(playerArea.Position)
	playerCharacter:PivotTo(playerArea.CFrame * CFrame.new(offset))

	self.Sessions[player] = {
		CurrentArea = area,
		BossIndex = bossIndex,
		CurrentWave = 1,
		IsTutorial = data and not data.TutorialComplete,
		State = "WaitingForKick",
	}

	self.Client.FightStarted:Fire(player, area, bossIndex)
	self.Client.WaveUpdated:Fire(player, 1)

	self.OnFightStarted:Fire(player)
end

function FightService:GetZone(position: number): string
	if position <= FightConfig.ZONE_RED_LEFT_END or position >= FightConfig.ZONE_RED_RIGHT_START then
		return "Red"
	elseif position <= FightConfig.ZONE_ORANGE_LEFT_END or position >= FightConfig.ZONE_ORANGE_RIGHT_START then
		return "Orange"
	else
		return "Green"
	end
end

function FightService:GetPowerPenalty(zone: string): number
	if zone == "Green" then
		return 1.0
	elseif zone == "Orange" then
		return FightConfig.PENALTY_ORANGE
	else
		return FightConfig.PENALTY_RED
	end
end

function FightService:EvaluateKick(player: Player, directionPosition: number, powerPosition: number)
	-- Validate positions range from client
	if type(directionPosition) ~= "number" or directionPosition < 0 or directionPosition > 1 then
		return { Result = "Lost", PlayerPower = 0 }
	end
	if type(powerPosition) ~= "number" or powerPosition < 0 or powerPosition > 1 then
		return { Result = "Lost", PlayerPower = 0 }
	end

	local session = self.Sessions[player]
	if not session then
		return { Result = "Lost", PlayerPower = 0 }
	end

	if session.State ~= "WaitingForKick" then
		return { Result = "Lost", PlayerPower = 0 }
	end

	local zone = self:GetZone(powerPosition)
	local powerMultiplier = self:GetPowerPenalty(zone)

	local data = DataService:GetData(player)
	local playerPower = data and data.Money2 or 0
	local effectivePower = playerPower * powerMultiplier

	local areaData = self.Template.Enemies[session.CurrentArea]
	if not areaData then
		return { Result = "Lost", PlayerPower = playerPower }
	end

	local goalieData = self:GetGoalieDataForWave(areaData, session.BossIndex, session.CurrentWave)
	if not goalieData then
		return { Result = "Lost", PlayerPower = playerPower }
	end

	local goaliePower = goalieData.Power

	-- Special Kick Pity System
	local pity = self.PlayerPity[player] or 0
	local chance = 5 + (pity * 5) -- Base 5%, increases by 5% each fail

	local maxCap = 10
	if effectivePower >= goaliePower * 2 then
		maxCap = 100
	elseif effectivePower >= goaliePower then
		maxCap = 50
	end

	chance = math.min(chance, maxCap)

	local isSpecialKick = false
	local rewardMultiplier = 1

	if zone == "Green" then
		local randomValue = math.random(1, 100)
		if randomValue <= chance then
			isSpecialKick = true
			rewardMultiplier = 2
			self.PlayerPity[player] = 0
		else
			self.PlayerPity[player] = pity + 1
		end
	else
		self.PlayerPity[player] = pity + 1
	end

	local result
	local isMiddle = (directionPosition >= 0.4 and directionPosition <= 0.6)
	local isCorner = (directionPosition < 0.2 or directionPosition > 0.8)

	if effectivePower >= goaliePower then
		if isMiddle then
			result = "GoalBlast"
		elseif isCorner then
			result = "GoalCorner"
		else
			result = "Goal"
		end
	else
		if isCorner then
			result = "Missed"

			if isSpecialKick then
				result = "GoalCorner"
			end
		else
			result = "Saved"

			if isSpecialKick then
				result = "GoalBlast"
			end
		end
	end

	session.State = "Animating"
	session.LastResult = result
	session.RewardMultiplier = rewardMultiplier

	return {
		Result = result,
		PlayerPower = playerPower,
		EffectivePower = effectivePower,
		Zone = zone,
		IsSpecialKick = isSpecialKick,
	}
end

function FightService:ApplyKickResult(player: Player)
	local session = self.Sessions[player]
	if not session then
		return
	end

	if session.State ~= "Animating" then
		return
	end

	local result = session.LastResult
	local rewardMultiplier = session.RewardMultiplier or 1
	session.State = "WaitingForKick"
	session.LastResult = nil
	session.RewardMultiplier = nil

	if result == "Goal" or result == "GoalBlast" or result == "GoalCorner" then
		-- Reward untuk goalie yang baru saja dikalahkan (CurrentWave)
		local enemyData = self:GetGoalieDataForWave(
			self.Template.Enemies[session.CurrentArea],
			session.BossIndex,
			session.CurrentWave
		)
		if enemyData then
			local finalReward = enemyData.Reward * rewardMultiplier
			DataService:ChangeValue(player, "Wins", finalReward)
		end

		-- Mencatat total gol dan memberi badge ke-100
		local data = DataService:GetData(player)
		if data and data.TotalGoals then
			data.TotalGoals += 1
			if data.TotalGoals >= 100 then
				DataService:GiveBadge(player, BADGE_100_GOAL)
			end
		end

		-- Player scored, advance wave
		session.CurrentWave += 1

		if session.CurrentWave > MAX_WAVES then
			-- Save boss progress
			DataService:UpdateBossProgress(player, session.CurrentArea, session.BossIndex)

			-- All 5 goalies beaten — fight cleared!
			self.Client.WaveUpdated:Fire(player, "Cleared")

			-- SeasonService:Increase(player, "Win Daily", 1)
			-- SeasonService:Increase(player, "Win Weekly", 1)

			task.delay(4, function()
				self:EndFight(player)
			end)
		else
			-- Next wave
			self.Client.WaveUpdated:Fire(player, session.CurrentWave)
		end
	elseif result == "Missed" or result == "Saved" or result == "Lost" then
		-- Player lost — end fight immediately
		self.Client.WaveUpdated:Fire(player, "Lost")

		task.delay(4, function()
			self:EndFight(player)
		end)
	end
end

function FightService:EndFight(player: Player)
	if not self.Sessions[player] then
		return
	end

	local currentArea = self.Sessions[player].CurrentArea
	self.Sessions[player] = nil

	self.Client.FightEnded:Fire(player)

	self.OnFightEnded:Fire(player)

	task.wait(2)

	local zoneNumber = tonumber(currentArea:match("%d+"))
	local zoneName = "Zone" .. zoneNumber

	local playerCharacter = player.Character
	local targetPosition = teleporterFolder.Teleporters:WaitForChild(zoneName).Position
	if playerCharacter and targetPosition then
		player:RequestStreamAroundAsync(targetPosition)
		playerCharacter:MoveTo(targetPosition)
	end

	self.Client.PlayerTeleported:Fire(player)

	self.OnPlayerTeleported:Fire(player)
end

-- KNIT INIT
function FightService:KnitInit()
	DataService = Knit.GetService("DataService")
	DataCacheService = Knit.GetService("DataCacheService")
	-- SeasonService = Knit.GetService("SeasonService")
end

-- KNIT START
function FightService:KnitStart()
	self.Template = DataCacheService:GetFile("Template")

	Players.PlayerRemoving:Connect(function(player)
		self.Sessions[player] = nil
		self.PlayerPity[player] = nil
	end)

	local function getBossData(enemiesTemplate, area, typeAttr)
		if enemiesTemplate[area] then
			if enemiesTemplate[area][typeAttr] then
				return enemiesTemplate[area][typeAttr]
			end
			local index = tonumber(typeAttr:match("%d+"))
			if index then
				local bossKey = "Boss " .. index
				if enemiesTemplate[area][bossKey] then
					return enemiesTemplate[area][bossKey]
				elseif index < 5 and enemiesTemplate[area]["MiniBoss " .. index] then
					return enemiesTemplate[area]["MiniBoss " .. index]
				elseif index == 5 and enemiesTemplate[area]["Boss"] then
					return enemiesTemplate[area]["Boss"]
				end
			elseif typeAttr == "Boss" and enemiesTemplate[area]["Boss 5"] then
				return enemiesTemplate[area]["Boss 5"]
			end
		end
		return nil
	end

	for _, enemyPodium in pairs(enemyPodiums) do
		local area = enemyPodium:GetAttribute("Area")
		local podiumType = enemyPodium:GetAttribute("Type")
		local gui = enemyPodium:FindFirstChild("Title", true)
		local recommendedText = gui and gui:FindFirstChild("Number", true)

		if recommendedText then
			local bossData = getBossData(self.Template.Enemies, area, podiumType)
			if bossData then
				recommendedText.Text = FormatNumber(bossData.Power)
			end
		end
	end
end

return FightService
