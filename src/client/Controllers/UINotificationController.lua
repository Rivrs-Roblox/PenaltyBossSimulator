--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local NotificationActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.NotificationActions)

-- Controllers
local DataCacheController = nil
local NotificationController = nil
local RebirthController = nil

-- UINotificationController
local UINotificationController = Knit.CreateController({
	Name = "UINotificationController",

	Notifications = {},
	Stored_Datas = {},

	SendNotif = false,

	-- Datas
	RebirthTable = {},
	Template = {},
})

local function isRegularPurchasableCoach(coach: table?): boolean
	return coach ~= nil
		and not coach.VIP
		and not coach.Reward
		and not coach.StarterPack
		and not coach.Chest
end

local function isRegularPurchasableCharacter(character: table?): boolean
	return character ~= nil
		and not character.VIP
		and not character.Reward
		and not character.StarterPack
		and not character.RejoinReward
end

local function getPreviousRegularId(templateData: table, id: number, isRegularPurchasable: (table?) -> boolean): number?
	local previousId = nil

	for itemId, itemData in pairs(templateData) do
		if type(itemId) == "number" and itemId < id and isRegularPurchasable(itemData) then
			if previousId == nil or itemId > previousId then
				previousId = itemId
			end
		end
	end

	return previousId
end

local function canBuyInSequence(
	templateData: table,
	ownedItems: table,
	id: number,
	isRegularPurchasable: (table?) -> boolean
): boolean
	local previousId = getPreviousRegularId(templateData, id, isRegularPurchasable)
	return previousId == nil or table.find(ownedItems, previousId) ~= nil
end

--|| Functions ||--
function UINotificationController:InitChecks()
	task.spawn(function()
		while task.wait(2) do
			local State = Store:getState()

			local Rebirth = State["PlayerReducer"].Rebirth
			local Wins = State["PlayerReducer"].Wins
			local Money2 = State["PlayerReducer"].Money2
			local Areas = State["AreaReducer"].Areas
			local Trails = (State["TrailsReducer"] and State["TrailsReducer"].Trails) or {}
			local Coaches = (State["CoachReducer"] and State["CoachReducer"].Coaches) or {}
			local Characters = State["CharacterReducer"].Characters
			if self.Stored_Datas["Wins"] ~= Wins then
				self.Stored_Datas["Wins"] = Wins

				if self.RebirthTable[Rebirth + 1] ~= nil and Wins >= self.RebirthTable[Rebirth + 1] then
					local RebirthCount = 1

					if
						self.Notifications["Rebirth"] ~= RebirthCount
						and self.SendNotif == true
						and RebirthCount > 0
					then
						NotificationController:Notify({
							text = self.Template.Messages.Notifications.Can_Rebirth_X_Times(1),
							type = "SUCCESS",
						})
					end

					self.Notifications["Rebirth"] = RebirthCount
					Store:dispatch(NotificationActions.setNotification("Rebirth", RebirthCount))
				elseif self.RebirthTable[Rebirth + 1] ~= nil and Wins < self.RebirthTable[Rebirth + 1] then
					local RebirthCount = 0

					self.Notifications["Rebirth"] = RebirthCount
					Store:dispatch(NotificationActions.setNotification("Rebirth", RebirthCount))
				end

				local AreaCount = 0
				for name, area in self.Template.Areas do
					if not table.find(Areas, name) and Wins >= area.Price then
						AreaCount += 1
					end
				end

				if self.Notifications["Areas"] ~= AreaCount and self.SendNotif == true and AreaCount > 0 then
					NotificationController:Notify({
						text = self.Template.Messages.Notifications.Can_Buy_X_Areas(1),
						type = "SUCCESS",
					})
				end

				self.Notifications["Areas"] = AreaCount
				Store:dispatch(NotificationActions.setNotification("Areas", AreaCount))

				local TrailCount = 0
				for id, trail in self.Template.Trails do
					if not table.find(Trails, id) and Wins >= trail.Price and not trail.VIP then
						TrailCount += 1
					end
				end

				if self.Notifications["Trails"] ~= TrailCount and self.SendNotif == true and TrailCount > 0 then
					NotificationController:Notify({
						text = self.Template.Messages.Notifications.Can_Buy_X_Trails(TrailCount),
						type = "SUCCESS",
					})
				end

				self.Notifications["Trails"] = TrailCount
				Store:dispatch(NotificationActions.setNotification("Trails", TrailCount))

				local CharacterCount = 0
				for id, char in self.Template.Characters do
					if
						not table.find(Characters, id)
						and char.Price ~= 0
						and Wins >= char.Price
						and not char.VIP
						and not char.Reward
						and not char.StarterPack
						and not char.RejoinReward
						and canBuyInSequence(self.Template.Characters, Characters, id, isRegularPurchasableCharacter)
					then
						CharacterCount += 1
					end
				end

				if
					self.Notifications["Characters"] ~= CharacterCount
					and self.SendNotif == true
					and CharacterCount > 0
				then
					NotificationController:Notify({
						text = self.Template.Messages.Notifications.Can_Buy_X_Characters(CharacterCount),
						type = "SUCCESS",
					})
				end

				self.Notifications["Characters"] = CharacterCount
				Store:dispatch(NotificationActions.setNotification("Characters", CharacterCount))
			end

			if self.Stored_Datas["Money2"] ~= Money2 then
				self.Stored_Datas["Money2"] = Money2

				local CoachCount = 0
				for id, coach in (self.Template.Coaches or {}) do
					if
						not table.find(Coaches, id)
						and Money2 >= coach.Price
						and isRegularPurchasableCoach(coach)
						and canBuyInSequence(self.Template.Coaches, Coaches, id, isRegularPurchasableCoach)
					then
						CoachCount += 1
					end
				end

				if self.Notifications["Coaches"] ~= CoachCount and self.SendNotif == true and CoachCount > 0 then
					NotificationController:Notify({
						text = self.Template.Messages.Notifications.Can_Buy_X_Coaches(CoachCount),
						type = "SUCCESS",
					})
				end

				self.Notifications["Coaches"] = CoachCount
				Store:dispatch(NotificationActions.setNotification("Coaches", CoachCount))
			end

			local DailyRewardsReducer = State["DailyRewardsReducer"]
			local RewardClaimable = false

			for id, _ in DailyRewardsReducer.rewards do
				if
					DailyRewardsReducer.lastRedeemedId == 0
					or (
						os.time() - DailyRewardsReducer.lastRedeemedTimestamp >= 86400
						and id == DailyRewardsReducer.lastRedeemedId + 1
					)
				then
					RewardClaimable = true
					break
				end
			end

			if
				self.Notifications["DailyRewards"] ~= RewardClaimable
				and self.SendNotif == true
				and RewardClaimable == 1
			then
				NotificationController:Notify({
					text = self.Template.Messages.Notifications.Can_Buy_Claim_Daily_Reward,
					type = "SUCCESS",
				})
			end
			-- We need to make sure we update UI only when a value changes
			-- It is to make continuous UI animations
			local notification = if RewardClaimable then 1 else 0
			if self.Notifications["DailyRewards"] ~= notification then
				self.Notifications["DailyRewards"] = notification
				Store:dispatch(NotificationActions.setNotification("DailyRewards", if RewardClaimable then 1 else 0))
			end
		end
	end)
end

--|| Knit Lifecycle ||--
function UINotificationController:KnitInit()
	DataCacheController = Knit.GetController("DataCacheController")
	NotificationController = Knit.GetController("NotificationController")
	RebirthController = Knit.GetController("RebirthController")

	task.delay(1, function()
		self:InitChecks()

		task.wait(10)

		self.SendNotif = true
	end)

	self.RebirthTable = DataCacheController:GetFile("RebirthTable")
	self.Template = DataCacheController:GetFile("Template")

	print("[UI NOTIFICATION CONTROLLER] Controller loaded successfully!")
end

return UINotificationController
