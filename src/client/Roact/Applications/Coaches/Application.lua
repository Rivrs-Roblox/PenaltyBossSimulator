--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Grid = require(Components.Grid)
local Blue_Background = require(Components.Main.Blue_Background)
-- local Panel = require(Components.Panel)

-- Frames
local Frames = script.Parent.Frames
local CoachCard = require(Frames.CoachCard)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

local function isRegularPurchasableCoach(coachData: table): boolean
	return not coachData.VIP
		and not coachData.Reward
		and not coachData.StarterPack
		and not coachData.Chest
end

local function getPreviousRegularCoachId(id: number): number?
	local previousId = nil

	for coachId, coachData in pairs(Template.Coaches) do
		if type(coachId) == "number" and coachId < id and isRegularPurchasableCoach(coachData) then
			if previousId == nil or coachId > previousId then
				previousId = coachId
			end
		end
	end

	return previousId
end

function Coaches(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)
	local coachState = RoduxHooks.useSelector(hooks, function(state)
		return state.CoachReducer
	end)
	-- local NotificationReducer = RoduxHooks.useSelector(hooks, function(state)
	-- 	return state.NotificationReducer
	-- end)

	-- local TrailsNotif = NotificationReducer.Notifications["Trails"] or 0
	-- local CoachNotif = NotificationReducer.Notifications["Coaches"] or 0
	-- local CharacterNotif = NotificationReducer.Notifications["Characters"] or 0

	local Coaches = {}
	for index, coachData in pairs(Template.Coaches) do
		local possessed = table.find(coachState.Coaches, index) ~= nil
		local previousCoachId = if isRegularPurchasableCoach(coachData) then getPreviousRegularCoachId(index) else nil
		local previousCoach = previousCoachId and Template.Coaches[previousCoachId] or nil
		local locked = not possessed
			and previousCoachId ~= nil
			and table.find(coachState.Coaches, previousCoachId) == nil

		Coaches[index] = CoachCard({
			id = index,
			name = coachData.Name,
			displayName = coachData.DisplayName,
			price = coachData.Price,
			image = coachData.Image,
			possessed = possessed,
			equipped = coachState.CurrentCoach == index,
			locked = locked,
			previousName = previousCoach and (previousCoach.DisplayName or previousCoach.Name) or nil,
			multiplier = coachData.Multiplier,
			VIP = coachData.VIP,
			Chest = coachData.Chest,
			speed = coachData.Speed,
			order = coachData.Order,
			flag = coachData.Flag,
		}, hooks)
	end

	return Roact.createElement("Frame", {
		Visible = true,
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 2,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
	}, {
		Content = Blue_Background({
			title = "Coaches",
			titleIcon = UI.Coaches,
			size = UDim2.fromScale(0.7, 0.7),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.6,
			condition = UIReducer.CurrentUI == FramesConstants.Coach,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
		}, {
			-- Panels = Roact.createElement("Frame", {
			-- 	AnchorPoint = Vector2.new(0.5, 0.5),
			-- 	BackgroundTransparency = 1,
			-- 	Position = UDim2.fromScale(0.5, 0.2),
			-- 	Size = UDim2.fromScale(0.91, 0.1),
			-- }, {
			-- 	UIListLayout = Roact.createElement("UIListLayout", {
			-- 		VerticalAlignment = 0,
			-- 		SortOrder = 2,
			-- 		HorizontalAlignment = 0,
			-- 		Padding = UDim.new(0.01, 0),
			-- 		FillDirection = 0,
			-- 	}),

			-- 	Panel1 = Panel({
			-- 		order = 1,
			-- 		isActive = false,
			-- 		text = "Players",
			-- 		icon = UI.Characters,
			-- 		action = function()
			-- 			UIController:ShowFrame({ frame = "Characters" })
			-- 		end,
			-- 		notificationNumber = CharacterNotif,
			-- 	}),
			-- 	Panel2 = Panel({
			-- 		order = 2,
			-- 		isActive = true,
			-- 		text = "Coaches",
			-- 		icon = UI.Coaches,
			-- 		action = function()
			-- 			-- UIController:ShowFrame({ frame = "Coach" })
			-- 		end,
			-- 		notificationNumber = CoachNotif,
			-- 	}),
			-- 	Panel3 = Panel({
			-- 		order = 3,
			-- 		isActive = false,
			-- 		text = "Trails",
			-- 		icon = UI.Trails,
			-- 		action = function()
			-- 			UIController:ShowFrame({ frame = "Trails" })
			-- 		end,
			-- 		notificationNumber = TrailsNotif,
			-- 	}),
			-- }),

			Container = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
			}, {
				ScrollingFrame = Roact.createElement("ScrollingFrame", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.98),
					Size = UDim2.fromScale(0.95, 0.815),
					ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
					AutomaticCanvasSize = Enum.AutomaticSize.XY,
					ScrollingDirection = Enum.ScrollingDirection.XY,
					ScrollBarImageTransparency = 0.32,
					ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
					ScrollBarThickness = 0,
					ClipsDescendants = true,
					BorderSizePixel = 0,
					CanvasSize = UDim2.fromScale(0, 2.8),
				}, {
					Padding = Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0.005, 0),
					}),
					Grid = Grid({
						cellPadding = UDim2.fromScale(0.02, 0.04),
						cellSize = UDim2.fromScale(0.3, 0.45),
						fillDirection = Enum.FillDirection.Horizontal,
						horizontalAlignment = Enum.HorizontalAlignment.Center,
						verticalAlignment = Enum.VerticalAlignment.Top,
					}),
					Roact.createFragment(Coaches),
				}),
			}),
		}),
	})
end

Coaches = RoactHooks.new(Roact)(Coaches)
return Coaches
