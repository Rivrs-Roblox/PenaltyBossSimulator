--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local UIButton = require(Components.UIButton)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")
local UI = DataCacheController:GetFile("Images")

-- Buttons
function Buttons(_, hooks)
	local NotificationReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.NotificationReducer
	end)

	local DailyRewardsNotif = NotificationReducer.Notifications["DailyRewards"]
	local SeasonNotif = NotificationReducer.Notifications["SeasonPass"]

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(-0.01, 0.05),
		Size = UDim2.fromScale(0.926, 0.257),
		ZIndex = 1,
		LayoutOrder = 6,
	}, {

		UIListLayout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0.02, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Daily = UIButton({
			background = UI.Blue_Background,
			icon = UI.UI_Daily,
			text = "Daily",
			pos = UDim2.fromScale(0.134, -0.072),
			size = UDim2.fromScale(0.3, 1),
			order = 2,
			hooks = hooks,
			frame = FramesConstants.DailyRewards,
			notifs = DailyRewardsNotif,
		}),
		Settings = UIButton({
			background = UI.Blue_Background,
			icon = UI.Settings,
			text = "Settings",
			pos = UDim2.fromScale(0.134, -0.072),
			size = UDim2.fromScale(0.3, 1),
			order = 3,
			hooks = hooks,
			frame = FramesConstants.Settings,
		}),

		Season = UIButton({
			background = UI.Gold_Background,
			icon = UI.Season,
			text = "Season",
			pos = UDim2.fromScale(0.134, -0.072),
			size = UDim2.fromScale(0.3, 1),
			order = 1,
			hooks = hooks,
			frame = FramesConstants.Season,
			notifs = SeasonNotif
		}),
		--Codes = UIButton({ background = UI.Blue_Background, icon = UI.Codes, text = "Codes", pos = UDim2.fromScale(0.733, -0.072), size = UDim2.fromScale(0.3, 1), order = 4, hooks = hooks, frame = FramesConstants.Codes, visible = Template.Config.Tools }),
	})
end

Buttons = RoactHooks.new(Roact)(Buttons)
return Buttons
