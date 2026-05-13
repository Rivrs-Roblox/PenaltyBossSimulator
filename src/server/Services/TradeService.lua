--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataService = nil
local DataCacheService = nil
local PetsService = nil
local FightService = nil

-- TradeService
local TradeService = Knit.CreateService({
	Name = "TradeService",

	Client = {
		TradeCompleted = Knit.CreateSignal(),
		TradeCanceled = Knit.CreateSignal(),

		RequestSent = Knit.CreateSignal(),
		RequestReceived = Knit.CreateSignal(),
		RequestAccepted = Knit.CreateSignal(),
		RequestDeclined = Knit.CreateSignal(),

		MyPetsChanged = Knit.CreateSignal(),
		HisPetsChanged = Knit.CreateSignal(),

		PlayerReady = Knit.CreateSignal(),
		OtherReady = Knit.CreateSignal(),
		Timer = Knit.CreateSignal(),
	},

	Template = {},
	Pets = {},

	Requests = {},
	Trades = {},
	Readys = {},
	Proceeding = {},
	PlayersPets = {},
})

--|| Client Functions ||--
function TradeService.Client:AddPet(player: Player, params: table)
	return self.Server:AddPet(player, params)
end

function TradeService.Client:RemovePet(player: Player, params: table)
	return self.Server:RemovePet(player, params)
end

function TradeService.Client:Request(player: Player, receiver: Player)
	return self.Server:Request(player, receiver)
end

function TradeService.Client:AcceptRequest(player: Player)
	return self.Server:AcceptRequest(player)
end

function TradeService.Client:DeclineRequest(player: Player)
	return self.Server:DeclineRequest(player)
end

function TradeService.Client:CancelTrade(player: Player)
	return self.Server:CancelTrade(player)
end

function TradeService.Client:Ready(player: Player, state: boolean)
	return self.Server:Ready(player, state)
end

--|| Functions ||--
function TradeService:_hasBeenRequested(player: Player)
	for sender, receiver in pairs(self.Requests) do
		if receiver == player then
			return { s = sender, r = receiver }
		end
	end

	return false
end

----------------------------
------ TRADE HANDLING ------
----------------------------

function TradeService:AddPet(player: Player, params: table)
	setmetatable(params, {
		__index = {
			id = 0 :: number,
			name = "" :: string,
		},
	})

	local data = DataService:GetData(player)
	if data == nil then
		return warn("[TRADE SERVICE] Player has no data: " .. player.Name)
	end

	if self.Trades[player] == nil then
		return { text = self.Template.Messages.Notifications.Not_Trading, type = "ERROR" }
	end

	if self.Pets[params.name] == nil then
		return { text = self.Template.Messages.Notifications.Pet_Not_Exists(params.name), type = "ERROR" }
	end
	if data.Inventory.Pets[tostring(params.id)] == nil then
		return { text = self.Template.Messages.Notifications.Pet_Not_Yours(params.name), type = "ERROR" }
	end
	if self.PlayersPets[player][params.id] ~= nil then
		return { text = self.Template.Messages.Notifications.Pet_Alreay_Added(params.name), type = "ERROR" }
	end

	local Pet = data.Inventory.Pets[tostring(params.id)]

	self.PlayersPets[player][params.id] = Pet
	self.Client.MyPetsChanged:Fire(player, self.PlayersPets[player])
	self.Client.HisPetsChanged:Fire(self.Trades[player], self.PlayersPets[player])

	return true
end

function TradeService:RemovePet(player: Player, params: table)
	setmetatable(params, {
		__index = {
			id = 0 :: number,
			name = "" :: string,
		},
	})

	local data = DataService:GetData(player)
	if data == nil then
		return warn("[TRADE SERVICE] Player has no data: " .. player.Name)
	end

	if self.Trades[player] == nil then
		return { text = self.Template.Messages.Notifications.Not_Trading, type = "ERROR" }
	end

	if self.Pets[params.name] == nil then
		return { text = self.Template.Messages.Notifications.Pet_Not_Exists(params.name), type = "ERROR" }
	end
	if data.Inventory.Pets[tostring(params.id)] == nil then
		return { text = self.Template.Messages.Notifications.Pet_Not_Yours(params.name), type = "ERROR" }
	end
	if self.PlayersPets[player][params.id] == nil then
		return { text = self.Template.Messages.Notifications.Pet_Not_Added(params.name), type = "ERROR" }
	end

	self.PlayersPets[player][params.id] = nil
	self.Client.MyPetsChanged:Fire(player, self.PlayersPets[player])
	self.Client.HisPetsChanged:Fire(self.Trades[player], self.PlayersPets[player])

	return true
end

function TradeService:Ready(player: Player, state: boolean)
	if self.Trades[player] == nil then
		return { text = self.Template.Messages.Notifications.Not_Trading, type = "ERROR" }
	end
	if self.Proceeding[player] ~= nil then
		return { text = self.Template.Messages.Notifications.Trade_Proceeding, type = "ERROR" }
	end

	self.Readys[player] = state

	self.Client.PlayerReady:Fire(player, state)
	self.Client.OtherReady:Fire(self.Trades[player], state)

	if self.Readys[player] == true and self.Readys[self.Trades[player]] == true then
		for i = 5, 1, -1 do
			if self.Readys[player] == false or self.Readys[self.Trades[player]] == false then
				return
			end

			self.Client.Timer:Fire(player, i)
			self.Client.Timer:Fire(self.Trades[player], i)

			task.wait(1)
		end

		self:ProcessTrade(self.Trades[player])
		self:ProcessTrade(player)
	end
end

function TradeService:ProcessTrade(player: Player)
	if self.Trades[player] == nil then
		return { text = self.Template.Messages.Notifications.Not_Trading, type = "ERROR" }
	end

	self.Proceeding[player] = true

	for id, Pet in pairs(self.PlayersPets[player]) do
		PetsService:DeletePet(player, id)
		PetsService:AddPet(self.Trades[player], Pet.Name)
	end

	self.PlayersPets[player] = nil
	self.Trades[player] = nil
	self.Readys[player] = nil
	self.Proceeding[player] = nil

	self.Client.TradeCompleted:Fire(player)

	return true
end

function TradeService:CancelTrade(player: Player)
	if self.Trades[player] == nil then
		return { text = self.Template.Messages.Notifications.Not_Trading, type = "ERROR" }
	end

	self.Client.TradeCanceled:Fire(player)
	self.Client.TradeCanceled:Fire(self.Trades[player])

	self.PlayersPets[player] = nil
	self.PlayersPets[self.Trades[player]] = nil
	self.Trades[self.Trades[player]] = nil
	self.Readys[player] = nil
	self.Readys[self.Trades[player]] = nil
	self.Trades[player] = nil
end

-------------------------------
------ REQUESTS HANDLING ------
-------------------------------

function TradeService:Request(player: Player, receiver: Player)
	if player == receiver then
		return { text = self.Template.Messages.Notifications.Cant_Trade_Yoursel, type = "ERROR" }
	end
	if self.Requests[player] ~= nil then
		return { text = self.Template.Messages.Notifications.Already_Requesting, type = "ERROR" }
	end
	if self.Trades[player] ~= nil then
		return { text = self.Template.Messages.Notifications.Already_Trading, type = "ERROR" }
	end
	if self.Trades[receiver] ~= nil then
		return { text = self.Template.Messages.Notifications.Player_Already_Trading(receiver.Name), type = "ERROR" }
	end

	if FightService ~= nil and FightService.Sessions ~= nil and FightService.Sessions[receiver] ~= nil then
		return { text = self.Template.Messages.Notifications.Player_Is_Fighting(receiver.Name), type = "ERROR" }
	end

	local data = DataService:GetData(player)
	local rData = DataService:GetData(receiver)

	if data.Settings.Trade == false then
		return { text = self.Template.Messages.Notifications.Enable_Trade, type = "ERROR" }
	end
	if rData.Settings.Trade == false then
		return { text = self.Template.Messages.Notifications.Trade_Disabled(receiver.Name), type = "ERROR" }
	end

	self.Requests[player] = receiver

	self.Client.RequestSent:Fire(player, receiver)
	-- Signale au receveur qu'il a reçu une demande
	self.Client.RequestReceived:Fire(receiver, player)

	-- Délai de 10 secondes avant d'annuler automatiquement la demande
	task.delay(10, function()
		-- Vérifie si la demande existe encore après 10 secondes
		if self.Requests[player] == receiver then
			-- Annule la demande si elle n'a pas été acceptée ou refusée
			self.Requests[player] = nil
			self.Client.RequestDeclined:Fire(receiver, { text = "Trade request has expired.", type = "ERROR" })
			self.Client.RequestDeclined:Fire(player, { text = "Trade request has expired.", type = "ERROR" })
			warn("La demande de trade a expiré entre " .. player.Name .. " et " .. receiver.Name)
		end
	end)

	return { text = self.Template.Messages.Notifications.Request_Sent(receiver.Name), type = "SUCCESS" }
end

function TradeService:AcceptRequest(player: Player)
	local request = self:_hasBeenRequested(player)
	if request == false then
		return { text = self.Template.Messages.Notifications.No_Request, type = "ERROR" }
	end
	if self.Trades[player] ~= nil then
		return { text = self.Template.Messages.Notifications.Already_Trading, type = "ERROR" }
	end

	-- Vérifie si la demande a expiré
	if self.Requests[request.s] ~= player then
		return { text = self.Template.Messages.Notifications.Request_Expired, type = "ERROR" }
	end

	self.Requests[request.s] = nil

	self.Trades[request.s] = request.r
	self.Trades[request.r] = request.s

	self.PlayersPets[request.s] = {}
	self.PlayersPets[request.r] = {}

	self.Client.RequestAccepted:Fire(request.s, request.r)
	self.Client.RequestAccepted:Fire(request.r, nil)
end

function TradeService:DeclineRequest(player: Player)
	local request = self:_hasBeenRequested(player)
	if request == false then
		return { text = self.Template.Messages.Notifications.No_Request, type = "ERROR" }
	end
	if self.Trades[player] ~= nil then
		return { text = self.Template.Messages.Notifications.Already_Trading, type = "ERROR" }
	end

	self.Requests[request.s] = nil

	self.Client.RequestDeclined:Fire(
		request.s,
		{ text = self.Template.Messages.Notifications.Request_Declined(request.r.Name), type = "ERROR" }
	)
	self.Client.RequestDeclined:Fire(
		request.r,
		{ text = self.Template.Messages.Notifications.Request_Declined_Receiver(request.s.Name), type = "ERROR" }
	)

	return { text = self.Template.Messages.Notifications.Request_Declined(player.Name), type = "ERROR" }
end

--|| Knit Lifecycle ||--
function TradeService:KnitInit()
	DataService = Knit.GetService("DataService")
	DataCacheService = Knit.GetService("DataCacheService")
	PetsService = Knit.GetService("PetsService")
	FightService = Knit.GetService("FightService")

	self.Template = DataCacheService:GetFile("Template")
	self.Pets = DataCacheService:GetFile("Pets")

	Players.PlayerRemoving:Connect(function(player: Player)
		local request = self:_hasBeenRequested(player)
		if request == false then
			return
		end

		self.Requests[request.s] = nil

		if self.Trades[player] ~= nil then
			self.Client.TradeCanceled:Fire(self.Trades[player])

			self.PlayersPets[player] = nil
			self.PlayersPets[self.Trades[player]] = nil
			self.Trades[self.Trades[player]] = nil
			self.Readys[player] = nil
			self.Readys[self.Trades[player]] = nil
			self.Proceeding[player] = nil
			self.Trades[player] = nil
		end
	end)

	print("[TRADE SERVICE] Service loaded successfully.")
end

return TradeService
