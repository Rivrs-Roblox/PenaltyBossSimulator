--|| Services ||--
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnalyticsService = game:GetService("AnalyticsService")
local DataStoreService = game:GetService("DataStoreService")

--|| Imports ||--
local ImportFolder = ReplicatedStorage:FindFirstChild("Packages")

local src = script
while src and src.Name ~= "src" do
	src = src:FindFirstAncestorWhichIsA("Folder")
end

local function importPackage(name: string)
	local RootFolder = src and src:FindFirstAncestorWhichIsA("Folder") or nil

	return RootFolder and require(RootFolder[name]) or require(ImportFolder:FindFirstChild(name))
end

local Knit = importPackage("knit")
local Core = importPackage("core")

--|| Store ||--
local AnalyticsStore = DataStoreService:GetDataStore("AnalyticsStore")

--|| Service ||--
local FunnelsService = Knit.CreateService({
	Name = "FunnelsService",

	Configuration = {},
	Cache = {},
	EventsCache = {
		CustomEvents = {},
		EconomyEvents = {},
	},

	Client = {},
})

--|| Server Methods ||--

local function getCustomFields(fields)
	local CustomFields = nil
	if fields then
		CustomFields = {}

		for i = 1, 3 do
			if fields[i] then
				CustomFields[Enum.AnalyticsCustomFieldKeys["CustomFields0" .. i]] = fields[i]
			end
		end
	end

	return CustomFields
end

function FunnelsService:LogCustomEvent(player: Player, event: string, data: number, fields: table)
	if not player or not event or not data then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local CustomFields = getCustomFields(fields)

	if self.EventsCache.CustomEvents[player.UserId] == nil then
		self.EventsCache.CustomEvents[player.UserId] = {
			player = player,
			events = {},
		}
	end

	if self.EventsCache.CustomEvents[player.UserId].events[event] == nil then
		self.EventsCache.CustomEvents[player.UserId].events[event] = {}
	end

	table.insert(self.EventsCache.CustomEvents[player.UserId].events[event], {
		data = data,
		fields = CustomFields,
	})
end

function FunnelsService:LogOnboardingStep(player: Player, step: number, fields: table)
	if not player or not step then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local playerData = self:_getPlayer(player)
	if not playerData then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	if playerData.OnboardingStep >= step then
		return
	end

	local OnboardingSteps = self.Configuration.Onboarding
	if not OnboardingSteps then
		return error(Core.ErrorCodes.CONFIG_ERROR)
	end

	local Step = OnboardingSteps[step]
	if not Step then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	local CustomFields = getCustomFields(fields)

	local success, response = pcall(function()
		return AnalyticsService:LogOnboardingFunnelStepEvent(player, step, Step, CustomFields)
	end)

	if not success then
		return warn(response)
	end

	playerData.OnboardingStep = step
	self:_updatePlayer(player, playerData)
end

function FunnelsService:LogProgressionStep(player: Player, tab: number, step: number, fields: table)
	if not player or not tab or not step then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local ProgressionTabs = self.Configuration.Progress
	if not ProgressionTabs then
		return error(Core.ErrorCodes.CONFIG_ERROR)
	end

	local Tab = ProgressionTabs[tab]
	if not Tab then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	local Step = Tab[step]
	if not Step then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	local CustomFields = getCustomFields(fields)

	local success, response = pcall(function()
		return AnalyticsService:LogFunnelStepEvent(
			player,
			Tab.Tab_Name,
			HttpService:GenerateGUID(),
			step,
			Step,
			CustomFields
		)
	end)

	if not success then
		return warn(response)
	end
end

function FunnelsService:LogInGameEconomyEvent(
	player: Player,
	key: string,
	earned: number,
	new_value: number,
	fields: table
)
	if not player or not key or not earned or not new_value then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local InGameEconomy = self.Configuration.Economy.In_Game
	if not InGameEconomy then
		return error(Core.ErrorCodes.CONFIG_ERROR)
	end

	if not InGameEconomy[key] then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	local CustomFields = getCustomFields(fields)

	if self.EventsCache.EconomyEvents[player.UserId] == nil then
		self.EventsCache.EconomyEvents[player.UserId] = {
			player = player,
			currencies = {},
		}
	end

	if self.EventsCache.EconomyEvents[player.UserId].currencies[key] == nil then
		self.EventsCache.EconomyEvents[player.UserId].currencies[key] = {}
	end

	table.insert(self.EventsCache.EconomyEvents[player.UserId].currencies[key], {
		earned = earned,
		new_value = new_value,
		fields = CustomFields,
	})
end

function FunnelsService:LogIGPEconomyEvent(
	player: Player,
	currency: string,
	cost: number,
	new_value: number,
	bought_item: string,
	fields: table
)
	if not player or not currency or not cost or not new_value or not bought_item then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local InGameEconomy = self.Configuration.Economy.In_Game
	if not InGameEconomy then
		return error(Core.ErrorCodes.CONFIG_ERROR)
	end

	if not InGameEconomy[currency] then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	local CustomFields = getCustomFields(fields)

	local success, response = pcall(function()
		return AnalyticsService:LogEconomyEvent(
			player,
			Enum.AnalyticsEconomyFlowType.Sink,
			currency,
			cost,
			new_value,
			Enum.AnalyticsEconomyTransactionType.Shop.Name,
			bought_item,
			CustomFields
		)
	end)

	if not success then
		return warn(response)
	end
end

function FunnelsService:LogIAPEconomyEvent(
	player: Player,
	bought_item: string,
	bought: number,
	new_value: number,
	fields: table
)
	if not player or not bought_item or not bought or not new_value then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local RobuxEconomy = self.Configuration.Economy.Robux
	if not RobuxEconomy then
		return error(Core.ErrorCodes.CONFIG_ERROR)
	end

	if not RobuxEconomy[bought_item] then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	local CustomFields = getCustomFields(fields)

	local success, response = pcall(function()
		return AnalyticsService:LogEconomyEvent(
			player,
			Enum.AnalyticsEconomyFlowType.Source,
			RobuxEconomy[bought_item],
			bought,
			new_value,
			Enum.AnalyticsEconomyTransactionType.IAP.Name,
			bought_item,
			CustomFields
		)
	end)

	if not success then
		return warn(response)
	end
end

--|| Private Methods ||--

function FunnelsService:_handlePlayerEvents()
	task.spawn(function()
		Players.PlayerAdded:Connect(function(player: Player)
			local OnboardingSteps = self.Configuration.Onboarding
			local ProgressionTabs = self.Configuration.Progress
			local InGameEconomy = self.Configuration.Economy.In_Game

			if OnboardingSteps and OnboardingSteps.First_Auto_On_Join then
				local FirstStep = OnboardingSteps[1]
				if FirstStep then
					self:LogOnboardingStep(player, 1)
				end
			end

			local PlayerData = Core.Utils.Table.DeepCopy(self:_getPlayer(player))
			if not PlayerData then
				return
			end

			if ProgressionTabs then
				for TabIndex, Tab in ipairs(ProgressionTabs) do
					if Tab.First_Auto_On_Join and not table.find(PlayerData.InitializedTabs, Tab.Tab_Name) then
						self:LogProgressionStep(player, TabIndex, 1)
						table.insert(PlayerData.InitializedTabs, Tab.Tab_Name)
					end
				end
			end

			if InGameEconomy then
				for key, value in pairs(InGameEconomy) do
					if not table.find(PlayerData.InitializedEconomy, key) then
						self:LogInGameEconomyEvent(player, key, value, value)
						table.insert(PlayerData.InitializedEconomy, key)
					end
				end
			end

			self:_updatePlayer(player, PlayerData)
			self:_handleEvents(player)
		end)
	end)
end

function FunnelsService:_handleEvents(player: Player)
	Core.Utils.SetInterval(function()
		local PlayerData = self.Cache[player.UserId]
		if not PlayerData then
			return
		end

		if self.EventsCache.CustomEvents[player.UserId] then
			for event, data in pairs(self.EventsCache.CustomEvents[player.UserId].events) do
				for _, event_data in ipairs(data) do
					task.wait(1)
					local success, response = pcall(function()
						return AnalyticsService:LogCustomEvent(player, event, event_data.data, event_data.fields)
					end)

					if not success then
						warn(response)
					end
				end
			end

			self.EventsCache.CustomEvents[player.UserId] = nil
		end

		if self.EventsCache.EconomyEvents[player.UserId] then
			for currency, data in pairs(self.EventsCache.EconomyEvents[player.UserId].currencies) do
				for _, currency_data in ipairs(data) do
					task.wait(1)
					local success, response = pcall(function()
						return AnalyticsService:LogEconomyEvent(
							player,
							Enum.AnalyticsEconomyFlowType.Source,
							currency,
							currency_data.earned,
							currency_data.new_value,
							Enum.AnalyticsEconomyTransactionType.Gameplay.Name,
							currency,
							currency_data.fields
						)
					end)

					if not success then
						warn(response)
					end
				end
			end

			self.EventsCache.EconomyEvents[player.UserId] = nil
		end
	end, 60 * 1)
end

function FunnelsService:_getPlayer(player: Player)
	if not player then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local PlayerData = self.Cache[player.UserId]
	if not PlayerData then
		local success, response = pcall(function()
			return AnalyticsStore:GetAsync(player.UserId)
		end)

		if not success then
			return warn(response)
		end

		if success and not response then
			PlayerData = {
				OnboardingStep = 0,
				InitializedTabs = {},
				InitializedEconomy = {},
			}

			local s, r = pcall(function()
				return AnalyticsStore:SetAsync(player.UserId, PlayerData)
			end)

			if not s then
				return warn(r)
			end
		else
			PlayerData = response
		end

		self.Cache[player.UserId] = PlayerData
	end

	return PlayerData
end

function FunnelsService:_updatePlayer(player: Player, new_data)
	if not player or not new_data then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local PlayerData = self.Cache[player.UserId]
	if not PlayerData then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	local success, response = pcall(function()
		return AnalyticsStore:SetAsync(player.UserId, new_data)
	end)

	if not success then
		return warn(response)
	end

	self.Cache[player.UserId] = new_data
end

--|| Knit Lifecycle ||--
function FunnelsService:KnitInit()
	local success, Configuration = pcall(function()
		return require(Core.Utils.FindChildFromPath(ReplicatedStorage, { "Shared", "Configs", "FunnelsModule.config" }))
	end)

	if not success then
		return warn("[ Funnels Module ] - Missing configuration, check the documentation.")
	end

	self.Configuration = Configuration

	self:_handlePlayerEvents()
end

return FunnelsService
