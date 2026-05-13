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
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local UIButton = require(Components.UIButton)
local Text = require(Components.Text)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")
local UI = DataCacheController:GetFile("Images")

local function getNotif(notificationReducer, key, defaultValue)
	defaultValue = defaultValue or 0

	if typeof(notificationReducer) ~= "table" then
		return defaultValue
	end

	if typeof(notificationReducer.Notifications) ~= "table" then
		return defaultValue
	end

	return notificationReducer.Notifications[key] or defaultValue
end

-- LeftFrame
function LeftFrame(_, hooks)
	local RejoinReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.RejoinReducer
	end)

	local NotificationReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.NotificationReducer
	end)

	local RebirthNotif = getNotif(NotificationReducer, "Rebirth")
	local AreaNotif = getNotif(NotificationReducer, "Areas")
	local TrailsNotif = getNotif(NotificationReducer, "Trails")
	local CoachNotif = getNotif(NotificationReducer, "Coaches")
	local StoreNotif = getNotif(NotificationReducer, "Store")
	local CharacterNotif = getNotif(NotificationReducer, "Characters")

	local rejoinStyles, rejoinApi = RoactSpring.useSpring(hooks, function()
		return {
			rotation = 0,
		}
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0.01, 0.42),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.134, 0.2),
	}, {
		Rejoin = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.45, -0.5),
			Size = UDim2.fromScale(0.8, 0.8),
			AutoButtonColor = false,

			[Roact.Event.MouseEnter] = function()
				rejoinApi.start({
					rotation = 35,
					config = { mass = 1, tension = 1000, friction = 50 },
				})
			end,

			[Roact.Event.MouseLeave] = function()
				rejoinApi.start({
					rotation = 0,
					config = { mass = 1, tension = 1000, friction = 50 },
				})
			end,

			[Roact.Event.MouseButton1Down] = function()
				rejoinApi.start({ sizeAlpha = 0.8, config = { mass = 1, tension = 1000, friction = 50 } })
			end,

			[Roact.Event.MouseButton1Up] = function()
				rejoinApi.start({
					sizeAlpha = 1,
				})

				Sound:PlaySound("UI_Open")
			end,

			[Roact.Event.MouseButton1Click] = function()
				UIController:ShowFrame({ frame = FramesConstants.Rejoin })
			end,
		}, {

			ButtonText = Text({
				text = "Rejoin Player!",
				color = Color3.fromHex("fafafa"),
				anchorPoint = Vector2.new(0.5, 1),
				position = UDim2.fromScale(0.5, 0.98),
				index = 5,
				size = UDim2.fromScale(1.3, 0.35),
				stroke = 1.5,
			}),

			Ratio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.9,
			}),

			Effect = Roact.createElement("ImageLabel", {
				ImageColor3 = Color3.fromHex("ff5e00"),
				Image = "rbxassetid://106335669168445",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1.5, 1.5),
				ZIndex = 1,
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),

			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				ZIndex = 2,
				Image = "rbxassetid://106178870318178",
				Rotation = rejoinStyles.rotation,
				Size = UDim2.fromScale(1, 1),
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),
		}),

		Main = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0),
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0, 0),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			UIGridLayout = Roact.createElement("UIGridLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				CellSize = UDim2.fromScale(0.45, 0.45),
				CellPadding = UDim2.fromScale(0, 0.1),
			}),

			Store = UIButton({
				-- gold = true,
				icon = UI.Store,
				text = "Store",
				order = 1,
				frame = FramesConstants.Store,
				hooks = hooks,
				notifs = StoreNotif,
			}),

			Inventory = UIButton({
				icon = UI.Pets,
				text = "Pets",
				order = 2,
				frame = FramesConstants.Inventory,
				hooks = hooks,
			}),

			Rebirth = UIButton({
				icon = UI.Rebirth,
				text = "Rebirth",
				order = 3,
				frame = FramesConstants.Rebirth,
				hooks = hooks,
				notifs = RebirthNotif,
			}),

			Characters = UIButton({
				icon = UI.Characters,
				text = "Players",
				order = 4,
				frame = FramesConstants.Characters,
				hooks = hooks,
				notifs = CharacterNotif,
			}),

			Coaches = UIButton({
				icon = UI.Coaches,
				text = "Coaches",
				order = 5,
				frame = FramesConstants.Coach,
				hooks = hooks,
				notifs = CoachNotif,
			}),

			Trails = UIButton({
				icon = UI.Trails,
				text = "Trails",
				order = 6,
				frame = FramesConstants.Trails,
				hooks = hooks,
				notifs = TrailsNotif,
			}),

			Travel = UIButton({
				icon = UI.Travel,
				text = "Travel",
				order = 7,
				frame = FramesConstants.Travel,
				hooks = hooks,
				notifs = AreaNotif,
			}),
		}),
	})
end

LeftFrame = RoactHooks.new(Roact)(LeftFrame)
return LeftFrame
