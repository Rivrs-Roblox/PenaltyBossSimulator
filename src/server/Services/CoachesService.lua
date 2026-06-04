--[=[
    Owner: JustStop__
    Version: v0.0.2
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local FunnelsModule = require(ReplicatedStorage.Packages.funnelsModule)

-- Services
local DataCacheService = nil
local DataService = nil
local FightService = nil

local function EnsureCoachData(data: table)
	if data.Coaches == nil then
		data.Coaches = {
			Unlocked = {},
			Current = 0,
		}
	end

	data.Coaches.Unlocked = data.Coaches.Unlocked or {}
	data.Coaches.Current = data.Coaches.Current or 0

	return data.Coaches
end

local function IsRegularPurchasableCoach(coach: table?): boolean
	return coach ~= nil
		and not coach.VIP
		and not coach.Reward
		and not coach.StarterPack
		and not coach.Chest
end

local function GetPreviousRegularCoachId(coachesTemplate: table, id: number): number?
	local previousId = nil

	for coachId, coachData in pairs(coachesTemplate) do
		if type(coachId) == "number" and coachId < id and IsRegularPurchasableCoach(coachData) then
			if previousId == nil or coachId > previousId then
				previousId = coachId
			end
		end
	end

	return previousId
end

local CoachesService = Knit.CreateService({
	Name = "CoachesService",

	Template = {},

	Client = {
		CoachesUpdated = Knit.CreateSignal(),
		CoachBought = Knit.CreateSignal(),
		PlayerCoachesUpdated = Knit.CreateSignal(),
	},	

	CoachesToggled = {},
})

--|| Client Functions ||--

function CoachesService.Client:GetCoachesData(player: Player)
	return self.Server:GetCoachesData(player)
end

function CoachesService.Client:Buy(player: Player, id: number)
	return self.Server:Buy(player, id)
end

function CoachesService.Client:Equip(player: Player, id: number)
	return self.Server:Equip(player, id)
end

function CoachesService.Client:Unequip(player: Player)
	return self.Server:Unequip(player)
end

function CoachesService.Client:GetCoaches(player: Player, requestedPlayer: Player)
	requestedPlayer = requestedPlayer or player
	return self.Server:GetCoaches(player, requestedPlayer)
end

--|| Server Functions ||--

function CoachesService:IsPlayerFighting(player: Player): boolean
	return FightService ~= nil
		and FightService.Sessions ~= nil
		and FightService.Sessions[player] ~= nil
end

function CoachesService:GetCoachesData(player: Player)
	local data = DataService:GetData(player)
	if data == nil then
		return 0
	end

	local coachesData = EnsureCoachData(data)
	return coachesData.Current
end

function CoachesService:BuildEquippedCoachPayload(data: table): table
	local coachesData = EnsureCoachData(data)
	local equippedFormat = {}

	if coachesData.Current ~= 0 and self.Template.Coaches then
		local currentCoach = self.Template.Coaches[coachesData.Current]
		if currentCoach then
			equippedFormat["ActiveCoach"] = currentCoach
		end
	end

	return equippedFormat
end

function CoachesService:BroadcastCoachState(player: Player, data: table)
	local coachesData = EnsureCoachData(data)

	self.Client.CoachesUpdated:Fire(player, {
		Unlocked = coachesData.Unlocked,
		Current = coachesData.Current,
	})

	self.Client.PlayerCoachesUpdated:FireAll(
		player,
		if self:IsPlayerFighting(player) then {} else self:BuildEquippedCoachPayload(data)
	)
end

function CoachesService:BroadcastCoachInventory(player: Player, data: table)
	local coachesData = EnsureCoachData(data)

	self.Client.CoachesUpdated:Fire(player, {
		Unlocked = coachesData.Unlocked,
		Current = coachesData.Current,
	})
end

function CoachesService:Buy(player: Player, id: number, bypassPrice: boolean?)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[COACH SERVICE] Player has no data: " .. player.Name)
	end

	local coachesData = EnsureCoachData(data)
	local coach = self.Template.Coaches and self.Template.Coaches[id]

	if coach == nil then
		return { text = self.Template.Messages.Notifications.Coach_Not_Exists(tostring(id)), type = "ERROR" }
	end

	-- Jika sudah punya coach dan sedang fight, jangan auto equip.
	-- Ini mencegah panel robux/buy memunculkan coach lagi di arena fight.
	if table.find(coachesData.Unlocked, id) then
		if self:IsPlayerFighting(player) then
			self.CoachesToggled[player.UserId] = id
			self:BroadcastCoachInventory(player, data)
			self.Client.PlayerCoachesUpdated:FireAll(player, {})

			return {
				text = self.Template.Messages.Notifications.Coach_Bought(coach.DisplayName or coach.Name),
				type = "SUCCESS",
			}
		end

		return self:Equip(player, id)
	end

	if not bypassPrice and IsRegularPurchasableCoach(coach) then
		local previousCoachId = GetPreviousRegularCoachId(self.Template.Coaches, id)
		if previousCoachId ~= nil and not table.find(coachesData.Unlocked, previousCoachId) then
			local previousCoach = self.Template.Coaches[previousCoachId]
			local previousCoachName = previousCoach and (previousCoach.DisplayName or previousCoach.Name) or "previous coach"
			return {
				text = self.Template.Messages.Notifications.Buy_Previous_Coach_First(previousCoachName),
				type = "ERROR",
			}
		end
	end

	local currency = coach.Currency or "Money2"
	local balance = data[currency] or 0
	local price = coach.Price or 0

	if balance < price and not bypassPrice then
		local currencyLabel = currency == "Money2" and "Power" or string.lower(currency)
		return { text = self.Template.Messages.Notifications.Not_Enough_Money(currencyLabel), type = "ERROR" }
	end

	if not bypassPrice and price > 0 then
		FunnelsModule:LogIGPEconomyEvent(player, currency, price, balance - price, coach.Name)
		DataService:ChangeValue(player, currency, -price, true)
	end

	table.insert(coachesData.Unlocked, id)
	self.Client.CoachBought:Fire(player, id)

	-- Penting:
	-- Kalau beli saat fight, hanya unlock + simpan pending equip.
	-- Jangan panggil self:Equip() di sini.
	if self:IsPlayerFighting(player) then
		self.CoachesToggled[player.UserId] = id
		self:BroadcastCoachInventory(player, data)
		self.Client.PlayerCoachesUpdated:FireAll(player, {})

		return {
			text = self.Template.Messages.Notifications.Coach_Bought(coach.DisplayName or coach.Name),
			type = "SUCCESS",
		}
	end

	local equipResult = self:Equip(player, id)
	if equipResult then
		equipResult.text = self.Template.Messages.Notifications.Coach_Bought(coach.DisplayName or coach.Name)
	end

	return equipResult or {
		text = self.Template.Messages.Notifications.Coach_Bought(coach.DisplayName or coach.Name),
		type = "SUCCESS",
	}
end

function CoachesService:Equip(player: Player, id: number)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[COACH SERVICE] Player has no data: " .. player.Name)
	end

	local coachesData = EnsureCoachData(data)

	if self:IsPlayerFighting(player) then
		return { text = "Coaches are hidden during fight.", type = "ERROR" }
	end

	local previousCoach = nil
	if coachesData.Current ~= 0 then
		previousCoach = self.Template.Coaches and self.Template.Coaches[coachesData.Current]
	end

	local coach = nil

	if id ~= 0 then
		coach = self.Template.Coaches and self.Template.Coaches[id]
		if coach == nil then
			return { text = self.Template.Messages.Notifications.Coach_Not_Exists(tostring(id)), type = "ERROR" }
		end

		if not table.find(coachesData.Unlocked, id) then
			return {
				text = self.Template.Messages.Notifications.Coach_Not_Owned(coach.DisplayName or coach.Name),
				type = "ERROR",
			}
		end
	end

	coachesData.Current = id
	self:BroadcastCoachState(player, data)

	if id == 0 then
		local previousCoachName = previousCoach and (previousCoach.DisplayName or previousCoach.Name) or "coach"
		return {
			text = self.Template.Messages.Notifications.Coach_Unequipped(previousCoachName),
			type = "SUCCESS",
		}
	end

	local coachName = coach.DisplayName or coach.Name
	return {
		text = self.Template.Messages.Notifications.Coach_Equipped(coachName),
		type = "SUCCESS",
	}
end

function CoachesService:Unequip(player: Player)
	return self:Equip(player, 0)
end

function CoachesService:GetCoaches(player: Player, requestedPlayer: Player)
	local data = DataService:GetData(requestedPlayer)
	if not data then
		return {}
	end

	EnsureCoachData(data)

	if self:IsPlayerFighting(requestedPlayer) then
		return {}
	end

	return self:BuildEquippedCoachPayload(data)
end

--|| Knit Lifecycle ||--

function CoachesService:KnitInit()
	DataCacheService = Knit.GetService("DataCacheService")
	DataService = Knit.GetService("DataService")
	FightService = Knit.GetService("FightService")

	self.Template = DataCacheService:GetFile("Template")

	local function playerAdded(player: Player)
		task.spawn(function()
			while player.Parent and not player:GetAttribute("DataLoaded") do
				task.wait()
			end

			if not player.Parent then
				return
			end

			local data = DataService:GetData(player)
			if data then
				EnsureCoachData(data)
				self:BroadcastCoachState(player, data)
			end
		end)
	end

	FightService.OnFightStarted:Connect(function(player)
		local data = DataService:GetData(player)
		if data == nil then
			return
		end

		local coachesData = EnsureCoachData(data)

		if coachesData.Current ~= 0 then
			self.Client.PlayerCoachesUpdated:FireAll(player, {})
		end
	end)

	FightService.OnPlayerTeleported:Connect(function(player)
		local lastCoachId = self.CoachesToggled[player.UserId]

		if lastCoachId then
			self.CoachesToggled[player.UserId] = nil
			self:Equip(player, lastCoachId)
			return
		end

		local data = DataService:GetData(player)
		if data then
			self:BroadcastCoachState(player, data)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.CoachesToggled[player.UserId] = nil
	end)

	Players.PlayerAdded:Connect(playerAdded)

	for _, player in ipairs(Players:GetPlayers()) do
		playerAdded(player)
	end

	print("[COACHES SERVICE] Service loaded successfully.")
end

return CoachesService
